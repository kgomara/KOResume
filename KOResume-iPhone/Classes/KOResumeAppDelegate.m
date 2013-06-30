//
//  KOResumeAppDelegate.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "KOResumeAppDelegate.h"
#import "KOExtensions.h"
#import "RootViewController.h"

@implementation KOResumeAppDelegate

@synthesize window                      = _window;
@synthesize navigationController        = _navigationController;

@synthesize managedObjectModel          = __managedObjectModel;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;


#pragma mark -
#pragma mark Application lifecycle

//----------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    DLog();
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (!moc) {
        ALog(@"Could not get managedObjectContext");
        NSString* msg = NSLocalizedString(@"Failed to open database.\nApplication will quit.", @"Failed to open database.\nApplication will quit.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    // Pass the managed object context to the view controller.
    RootViewController *rootViewController     = (RootViewController *) self.navigationController.topViewController;
    rootViewController.managedObjectContext    = moc;
    
    // Set the rootViewController
    // TODO - this leaves us with no navbar -- fix in version 3
//    [self.window setRootViewController: rootViewController];
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview: self.navigationController.view];
    [self.window makeKeyAndVisible];

    // Check for availability of iCloud (user may not have it configured)
    // ...we only have one container, passing nil returns the first (and only) one
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
    if (ubiq) {
        DLog(@"iCloud access at %@", ubiq);
    } else {
        DLog(@"No iCloud access");
    }
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application 
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types 
     of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the 
     application and it begins the transition to the background state.
     
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games 
     should use this method to pause the game.
     */
    DLog();
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough 
     application state information to restore your application to its current state in case it is terminated 
     later.
     
     If your application supports background execution, called instead of applicationWillTerminate: when the 
     user quits.
     */
    DLog();
    
    [self saveContext];
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the 
     changes made on entering the background.
     */
    DLog();
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the 
     application was previously in the background, optionally refresh the user interface.
     */
    DLog();
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    DLog();
    
    // Save changes to application's managed object context before application terminates
    [self saveContext];
}


#pragma mark -
#pragma mark Memory management

//----------------------------------------------------------------------------------------------------------
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded 
     from disk) later.
     */
    ALog();
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();
    
	[_navigationController release];
	[_window release];

    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
    DLog();
    
    RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}


//----------------------------------------------------------------------------------------------------------
- (void)saveContext
{
    DLog();
    
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    if (moc) {
        if ([moc hasChanges]) {
            if (![moc save: &error]) {
                ELog(error, @"Failed to save");
                abort();
            } else {
                DLog(@"Save successful");
            }
        } else {
            DLog(@"No changes to save");
        }
    } else {
        ALog(@"managedObjectContext is null");
    }
}

#pragma mark - Core Data Stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the app.
 http://goddess-gate.com/dc2/index.php/post/452
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
    }
    
//    [__managedObjectContext setMergePolicy: NSMergeByPropertyStoreTrumpMergePolicy];
//    [__managedObjectContext setMergePolicy: NSRollbackMergePolicy];

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
    
    // Set up the path to the location of the database
    NSString *docDir            = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFileName        = [NSString stringWithFormat: @"%@.%@", KODatabaseName, KODatabaseType];
    NSString *dbPath            = [docDir stringByAppendingPathComponent: dbFileName];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    
    if ( ![fileManager fileExistsAtPath: dbPath]) {
        // database does not exist, copy in default
        NSString *defaultDatabasePath = [[NSBundle mainBundle] pathForResource: KODatabaseName
                                                                        ofType: KODatabaseType];
        DLog(@"defaultDatabasePath = %@", defaultDatabasePath);
        if (defaultDatabasePath) {
// TODO             migratePersistentStore:toURL:options:withType:error:?
            [fileManager copyItemAtPath: defaultDatabasePath
                                 toPath: dbPath
                                  error: NULL];
        } else {
            ALog(@"Could not load default database");
        }
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: dbFileName];
    DLog(@"Core Data store path = \"%@\"", [storeURL path]); 
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

    NSPersistentStoreCoordinator *coordinator = __persistentStoreCoordinator;

    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Migrate datamodel
        NSDictionary *options = nil;
        
        NSURL *cloudURL                 = [fileManager URLForUbiquityContainerIdentifier: KOUbiquityID];
        NSString *coreDataCloudContent  = [[cloudURL path] stringByAppendingPathComponent: @"data"];
        
        if ([coreDataCloudContent length] != 0) {
            // iCloud is available
            cloudURL = [NSURL fileURLWithPath: coreDataCloudContent];
            
            NSString *storeName = [NSString stringWithFormat: @"%@.%@", KODatabaseName, @"store"];
            options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], NSMigratePersistentStoresAutomaticallyOption,
                                                                  [NSNumber numberWithBool: YES], NSInferMappingModelAutomaticallyOption,
                                                                   storeName,                     NSPersistentStoreUbiquitousContentNameKey,
                                                                   cloudURL,                      NSPersistentStoreUbiquitousContentURLKey,
                                                                   nil];
        } else {
            // iCloud is not available
            options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], NSMigratePersistentStoresAutomaticallyOption,
                                                                  [NSNumber numberWithBool: YES], NSInferMappingModelAutomaticallyOption,
                                                                   nil];
        }
        
        NSError *error = nil;
        [coordinator lock];
        if ( ![coordinator addPersistentStoreWithType: NSSQLiteStoreType 
                                        configuration: nil 
                                                  URL: storeURL 
                                              options: options 
                                                error: &error])
        {
            ELog(error, @"Could not add PersistentStore");
            // TODO - PFUbiguity sometimes returns "error" if it cannot find log data on the device
            //        commenting out the abort seems to work - but it does not feel right.
            //        Research is needed to see if the error return could be parsed and handled better.
//            abort();
        }
        [coordinator unlock];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            DLog(@"asynchronously added persistent store!");
            [[NSNotificationCenter defaultCenter] postNotificationName: KOApplicationDidAddPersistentStoreCoordinatorNotification
                                                                object: self 
                                                              userInfo: nil];
        });
        
    });
    
    return __persistentStoreCoordinator;
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
// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (NSURL *)applicationDocumentsDirectory
{
    DLog();
    
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                   inDomains: NSUserDomainMask] lastObject];
}

@end

