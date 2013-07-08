//
//  KOResumeAppDelegate.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "KOResumeAppDelegate.h"
#import "CoreDataController.h"
#import "Packages.h"

@interface CoreDataController ()
{
    
}

@property (nonatomic, strong, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

- (NSDictionary *)createStoreOptions;

- (BOOL)seedStoreFromURL: (NSURL *)seedURL
                   toURL: (NSURL *)storeURL
                 options: (NSDictionary *)options;

- (BOOL)loadStore: (NSURL *)storeURL
          options: (NSDictionary *)options;

@end

@implementation CoreDataController

@synthesize managedObjectModel          = __managedObjectModel;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;

//----------------------------------------------------------------------------------------------------------
- (id)init
{
    DLog();

    self = [super init];
    if (self) {
//        NSManagedObjectModel *model     = [NSManagedObjectModel mergedModelFromBundles: nil];
//        __persistentStoreCoordinator    = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
//        __managedObjectContext          = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
//        [__managedObjectContext setPersistentStoreCoordinator: __persistentStoreCoordinator];
    }

    return self;
}


#pragma mark - Core Data Stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the app.
 http://goddess-gate.com/dc2/index.php/post/452 and 
 http://www.raywenderlich.com/12170/core-data-tutorial-how-to-preloadimport-existing-data-updated
 */
//----------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *)managedObjectContext
{
    DLog();
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        
        // PerformBlockAndWait adds the block to the backing queue and schedules it to run on its own thread.
        //  The block will not return until the block is finished executing.
        //  If you can't move on until you know whether the operation was successful, then this is your choice.
        [moc performBlockAndWait: ^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector( mergeChangesFrom_iCloud:)
                                                         name: NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                       object: coordinator];
        }];
        __managedObjectContext = moc;
        
        // Instantiate an UndoManager
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [__managedObjectContext setUndoManager: undoManager];
        [undoManager release];
        [__managedObjectContext setMergePolicy: NSMergeByPropertyStoreTrumpMergePolicy];
    }
    
    return __managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the app's model.
 */
//----------------------------------------------------------------------------------------------------------
- (NSManagedObjectModel *)managedObjectModel
{
    DLog();
    
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: KODatabaseName
                                              withExtension: @"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
    return __managedObjectModel;
}


//----------------------------------------------------------------------------------------------------------
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    DLog();
    
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    // TODO - moving the database to ubiquity container, so check from version 2.0 in Documents and move...
    
    if (__persistentStoreCoordinator) {
        // Set up the path to the location of the database
        // TODO need to get it inside iCloud if enabled
        NSString *docDir            = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbFileName        = [NSString stringWithFormat: @"%@.%@", KODatabaseName, KODatabaseType];
        NSString *dbPath            = [docDir stringByAppendingPathComponent: dbFileName];
        // TODO - need to put this in iCloud (if enabled) with .nosync
        NSURL *storeURL             = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: dbFileName];
        DLog(@"Core Data store path = \"%@\"", [storeURL path]);
        
        // TODO - implement HUD
        dispatch_queue_t queue;
        queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0);        // User is waiting - dispatch at high priority
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath: dbPath]) {
            // A database already exists in the user's documents, just add it to the persistent store coordinator
            dispatch_async(queue, ^{
                // ...first, get options appropriate for iCloud available or not
                __block NSDictionary *options = [self createStoreOptions];
                if (options) {
                    // ...load the store to the persistentStoreCoordinator
                    if ([self loadStore: storeURL
                                options: options])
                    {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            DLog(@"Added persistent store already in existance!");
                            [[NSNotificationCenter defaultCenter] postNotificationName: KOApplicationDidAddPersistentStoreCoordinatorNotification
                                                                                object: self
                                                                              userInfo: nil];
                            
                        });
                    } else {
                        ALog(@"Failed to load store");
                    }
                } else {
                    ALog(@"Failed to create options");
                }
            });
        } else {
            // database does not exist, need to migrate the seed database in from the app bundle
            dispatch_async(queue, ^{
                // First copy file from bundle
                __block NSURL *bundleSeedURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: KODatabaseName
                                                                                                       ofType: KODatabaseType]];
                __block NSURL *seedURL       = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"temp.sqlite"];
                NSError *error;
                if ([fileManager copyItemAtURL: bundleSeedURL
                                         toURL: seedURL
                                         error: &error])
                {
                    // ...get options appropriate for iCloud available or not
                    __block NSDictionary *options = [self createStoreOptions];
                    if (options) {
                        // ...migrate the seed store from the bundle to the user's space
                        if ([self seedStoreFromURL: bundleSeedURL /* seedURL */
                                             toURL: storeURL
                                           options: options])
                        {
                            DLog(@"Successfully added persistent store migrated from bundle!");
                            dispatch_async( dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName: KOApplicationDidAddPersistentStoreCoordinatorNotification
                                                                                    object: self
                                                                                  userInfo: nil];
                                
                            });
                        } else {
                            ALog(@"Could not seed database");
                        }
                        if ([fileManager removeItemAtURL: seedURL
                                                   error: &error])
                        {
                            DLog(@"Removed temporary database successful!");
                        } else {
                            ALog(@"Failed to remove temporary database!");
                        }
                    } else {
                        ALog(@"Failed to create options");
                    }
                } else {
                    ELog(error, @"Copy seed Error");
                }
            });
        }
    } else {
        ALog(@"Could not inititialize NSPersistentStoreCoordinator");
    }
    
    return __persistentStoreCoordinator;
}

//----------------------------------------------------------------------------------------------------------
- (NSDictionary *)createStoreOptions
{
    DLog();
    
    NSDictionary *options;
    
    NSURL *cloudURL                 = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: KOUbiquityID];
    NSString *coreDataCloudContent  = [[cloudURL path] stringByAppendingPathComponent: @"data"];
    
    if ([coreDataCloudContent length] != 0) {
        // iCloud is available
        cloudURL = [NSURL fileURLWithPath: coreDataCloudContent];
        
        NSString *storeName = [NSString stringWithFormat: @"%@.%@", KODatabaseName, @"store"];
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   //                   [NSNumber numberWithBool: NO],  NSReadOnlyPersistentStoreOption,
                   [NSNumber numberWithBool: YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool: YES], NSInferMappingModelAutomaticallyOption,
                   storeName,                      NSPersistentStoreUbiquitousContentNameKey,
                   cloudURL,                       NSPersistentStoreUbiquitousContentURLKey,
                   nil];
    } else {
        // iCloud is not available
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool: NO],  NSReadOnlyPersistentStoreOption,
                   [NSNumber numberWithBool: YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool: YES], NSInferMappingModelAutomaticallyOption,
                   nil];
    }
    
    return options;
}

//----------------------------------------------------------------------------------------------------------
- (BOOL)seedStoreFromURL: (NSURL *)seedURL
                   toURL: (NSURL *)storeURL
                 options: (NSDictionary *)options
{
    DLog(/* @"seedURL=%@, storeURL=%@", seedURL, storeURL */);
    
    BOOL success = NO;
    NSDictionary *localOnlyOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (id)kCFBooleanTrue, NSMigratePersistentStoresAutomaticallyOption,
                                      (id)kCFBooleanTrue, NSInferMappingModelAutomaticallyOption,
                                      nil];

    NSError *error = nil;
    NSPersistentStore *oldStore = [__persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                             configuration: nil
                                                                                       URL: seedURL
                                                                                   options: localOnlyOptions
                                                                                     error: &error];
    if (oldStore && !error) {
        NSPersistentStore *newStore = [__persistentStoreCoordinator migratePersistentStore: oldStore
                                                                                     toURL: storeURL
                                                                                   options: options
                                                                                  withType: NSSQLiteStoreType
                                                                                     error: &error];
        if (newStore && !error) {
            success = YES;
        } else {
            if (error) {
                ELog(error, @"Failed to migrate seed store from bundle");

            } else {
                ALog(@"Failed to migrate seed store from bundle, no error returned");
            }
        }
    }
    
    return success;
}

//----------------------------------------------------------------------------------------------------------
- (BOOL)loadStore: (NSURL *)storeURL
          options: (NSDictionary *)options
{
    DLog();
    
    BOOL success = NO;
    
    NSError *error = nil;
    [__persistentStoreCoordinator lock];
    if ( [__persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                    configuration: nil
                                                              URL: storeURL
                                                          options: options
                                                            error: &error])
    {
        success = YES;
    } else {
        ELog(error, @"Could not add PersistentStore");
        // TODO - PFUbiguity sometimes returns "error" if it cannot find log data on the device
        //        commenting out the abort seems to work - but it does not feel right.
        //        Research is needed to see if the error return could be parsed and handled better.
        //            abort();
    }
    [__persistentStoreCoordinator unlock];
    
    return success;
}


//----------------------------------------------------------------------------------------------------------
- (void)merge_iCloudChanges:(NSNotification *)note
                 forContext:(NSManagedObjectContext *)moc
{
    DLog();
    
    [moc mergeChangesFromContextDidSaveNotification: note];
    DLog(@"completed merging changes from iCloud, posting notification");
    
    // Create a notification for change observers, passing along the userInfo from iCloud
    NSNotification *refreshNotification = [NSNotification notificationWithName: KOApplicationDidMergeChangesFrom_iCloudNotification
                                                                        object: self
                                                                      userInfo: [note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification: refreshNotification];
}


//----------------------------------------------------------------------------------------------------------
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
    DLog();
    
    // NSNotifications are posted synchronously on the caller's thread
    // make sure to vector this back to the thread we want, in this case
    // the main thread for our views & controller
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    // TODO - possible problem?
    [moc performBlock:^{
        [self merge_iCloudChanges: notification
                       forContext: moc];
    }];
}

#pragma mark - Helper methods

/**
 Returns the URL to the application's documents directory
 */
- (NSURL *)applicationDocumentsDirectory
{
    DLog();
    
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                   inDomains: NSUserDomainMask] lastObject];
}

@end
