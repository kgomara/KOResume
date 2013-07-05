
/*
     File: CoreDataController.m
 Abstract: 
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreDataController.h"
#import "KOResumeAppDelegate.h"
#import "Packages.h"

NSString * kiCloudPersistentStoreFilename = @"iCloudStore.sqlite";
NSString * kFallbackPersistentStoreFilename = @"fallbackStore.sqlite"; //used when iCloud is not available
NSString * kSeedStoreFilename = @"seedStore.sqlite"; //holds the seed package records
NSString * kLocalStoreFilename = @"localStore.sqlite"; //holds the states information

#define SEED_ICLOUD_STORE YES
//#define FORCE_FALLBACK_STORE

static NSOperationQueue *_presentedItemOperationQueue;

@interface CoreDataController (Private)

- (BOOL)iCloudAvailable;

//- (BOOL)loadLocalPersistentStore:(NSError *__autoreleasing *)error;
- (BOOL)loadFallbackStore:(NSError * __autoreleasing *)error;
- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error;
- (void)asyncLoadPersistentStores;
- (void)dropStores;
- (void)reLoadiCloudStore:(NSPersistentStore *)store readOnly:(BOOL)readOnly;

- (void)deDupe:(NSNotification *)importNotification;

- (void)addPackage:(Packages *)package
           toStore:(NSPersistentStore *)store
       withContext:(NSManagedObjectContext *)moc;

- (BOOL)        seedStore:(NSPersistentStore *)store
 withPersistentStoreAtURL:(NSURL *)seedStoreURL
                    error:(NSError * __autoreleasing *)error;

- (void)copyContainerToSandbox;
- (void)nukeAndPave;

- (NSURL *)iCloudStoreURL;
- (NSURL *)seedStoreURL;
- (NSURL *)fallbackStoreURL;
- (NSURL *)applicationSandboxStoresDirectory;
- (NSString *)applicationDocumentsDirectory;

@end

@implementation CoreDataController
{
    NSLock *_loadingLock;
    NSURL *_presentedItemURL;
}


//----------------------------------------------------------------------------------------------------------
+ (void)initialize
{
    DLog();
    
    if (self == [CoreDataController class]) {
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    }
}


//----------------------------------------------------------------------------------------------------------
- (id)init
{
    DLog();

    self = [super init];
    if (!self) {
        return nil;
    }
    
    _loadingLock            = [[NSLock alloc] init];
    _ubiquityURL            = nil;
    _currentUbiquityToken   = nil;
    _presentedItemURL       = nil;
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles: nil];
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    [_mainThreadContext setPersistentStoreCoordinator: _psc];
    
    _currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    //subscribe to the account change notification
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(iCloudAccountChanged:)
                                                 name: NSUbiquityIdentityDidChangeNotification
                                               object: nil];
    return self;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)iCloudAvailable
{
    DLog();

#ifdef FORCE_FALLBACK_STORE
    BOOL available = NO;
#else
    BOOL available = (_currentUbiquityToken != nil);
#endif
    return available;
}


//----------------------------------------------------------------------------------------------------------
- (void)applicationResumed
{
    DLog();
    
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (self.currentUbiquityToken != token) {
        if ( ![self.currentUbiquityToken isEqual:token]) {
            [self iCloudAccountChanged:nil];
        }
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)iCloudAccountChanged: (NSNotification *)notification
{
    DLog();
    
    //tell the UI to clean up while we re-add the store
    [self dropStores];
    
    // update the current ubiquity token
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    _currentUbiquityToken = token;
    
    //reload persistent store
    [self loadPersistentStores];
}

#pragma mark Managing the Persistent Stores

//----------------------------------------------------------------------------------------------------------
- (void)loadPersistentStores
{
    DLog();
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        BOOL locked = NO;
        @try {
            [_loadingLock lock];
            locked = YES;
            [self asyncLoadPersistentStores];
        } @finally {
            if (locked) {
                [_loadingLock unlock];
                locked = NO;
            }
        }
    });
}


//----------------------------------------------------------------------------------------------------------
//- (BOOL)loadLocalPersistentStore:(NSError *__autoreleasing *)error
//{
//    DLog();
//    
//    BOOL success = YES;
//    
//    NSError *localError = nil;
//    
//    if (_localStore) {
//        return success;
//    }
//    
//    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
//    
//    //load the store file containing the 50 states
//    NSURL *storeURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:kLocalStoreFilename];
//    
//    if (NO == [fm fileExistsAtPath:[storeURL path]]) {
//        //copy it from the bundle
//        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"localStore" withExtension:@"sqlite"];
//        if (nil == bundleURL) {
//            NSLog(@"Local store not found in bundle, this is likely a build issue, make sure the store file is being copied as a bundle resource.");
//            abort();
//        }
//        
//        success = [fm copyItemAtURL:bundleURL toURL:storeURL error:&localError];
//        if (NO == success) {
//            NSLog(@"Trouble copying the local store file from the bundle: %@", localError);
//            abort();
//        }
//    }
//    
//    //add the store, use the "LocalConfiguration" to make sure state entities all end up in this store and that no iCloud entities end up in it
//    _localStore = [_psc addPersistentStoreWithType:NSSQLiteStoreType
//                                     configuration:@"LocalConfig"
//                                               URL:storeURL
//                                           options:nil
//                                             error:&localError];
//    success = (_localStore != nil);
//    if (success == NO) {
//        //ruh roh
//        if (localError && (error != NULL)) {
//            *error = localError;
//        }
//    }
//    
//    return success;
//}

//----------------------------------------------------------------------------------------------------------
- (BOOL)loadFallbackStore: (NSError * __autoreleasing *)error
{
    DLog();
    
    BOOL success = YES;
    
    NSError *localError = nil;
    
    if (_fallbackStore) {
        return YES;
    }
    
    NSURL *storeURL = [self fallbackStoreURL];
    _fallbackStore = [_psc addPersistentStoreWithType: NSSQLiteStoreType
                                        configuration: nil
                                                  URL: storeURL
                                              options: nil
                                                error: &localError];
    success = (_fallbackStore != nil);
    if ( !success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

//----------------------------------------------------------------------------------------------------------
- (BOOL)loadiCloudStore: (NSError * __autoreleasing *)error
{
    DLog();
    
    BOOL success = YES;
    
    NSError *localError = nil;
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    _ubiquityURL      = [fm URLForUbiquityContainerIdentifier: nil];
    
    NSURL *iCloudStoreURL = [self iCloudStoreURL];
    NSURL *iCloudDataURL  = [self.ubiquityURL URLByAppendingPathComponent: @"iCloudData"];
    NSString *storeName   = [NSString stringWithFormat: @"%@.%@", KODatabaseName, @"store"];
    
    NSDictionary *options = @{ NSPersistentStoreUbiquitousContentNameKey : storeName,
                                NSPersistentStoreUbiquitousContentURLKey : iCloudDataURL };
    
    _iCloudStore = [self.psc addPersistentStoreWithType: NSSQLiteStoreType
                                          configuration: nil
                                                    URL: iCloudStoreURL
                                                options: options
                                                  error: &localError];
    success = (_iCloudStore != nil);
    if (success) {
        //set up the file presenter
        _presentedItemURL = iCloudDataURL;
        [NSFileCoordinator addFilePresenter: self];
    } else {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    
    return success;
}

//----------------------------------------------------------------------------------------------------------
- (void)asyncLoadPersistentStores
{
    DLog();
    
    NSError *error = nil;
//    if ([self loadLocalPersistentStore:&error]) {
//        NSLog(@"Added local store");
//    } else {
//        NSLog(@"Unable to add local persistent store: %@", error);
//    }
    
    //if iCloud is available, add the persistent store
    //if iCloud is not available, or the add call fails, fallback to local storage
    BOOL useFallbackStore = NO;
    
    if ([self iCloudAvailable]) {
        if ([self loadiCloudStore:&error]) {
            ALog(@"Added iCloud Store");
            
            //check to see if we need to seed data from the seed store
            if (SEED_ICLOUD_STORE) {
                //do this synchronously
                if ([self seedStore: _iCloudStore withPersistentStoreAtURL: [self seedStoreURL] error: &error]) {
                    [self deDupe: nil];
                } else {
                    ELog(error, @"Error seeding iCloud Store");
                    abort();
                }
            }
            
            //check to see if we need to seed or migrate data from the fallback store
            NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
            if ([fm fileExistsAtPath: [[self fallbackStoreURL] path]]) {
                //migrate data from the fallback store to the iCloud store
                //there is no reason to do this synchronously since no other peer should have this data
                dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(globalQueue, ^{
                    NSError *blockError = nil;
                    BOOL seedSuccess = [self seedStore: _iCloudStore
                              withPersistentStoreAtURL: [self fallbackStoreURL]
                                                 error: &blockError];
                    if (seedSuccess) {
                        ALog(@"Successfully seeded iCloud Store from Fallback Store");
                    } else {
                        ELog(error, @"Error seeding iCloud Store from fallback store");
                        abort();
                    }
                });
            }
        } else {
            ELog(error, @"Unable to add iCloud store");
            useFallbackStore = YES;
        }
    } else {
        useFallbackStore = YES;
    }
    
    if (useFallbackStore) {
        if ([self loadFallbackStore: &error]) {
            ALog(@"Added fallback store: %@", self.fallbackStore);
            
            //you can seed the fallback store if you want to examine seeding performance without iCloud enabled
            //check to see if we need to seed data from the seed store
            if (SEED_ICLOUD_STORE) {
                //do this synchronously
                BOOL seedSuccess = [self seedStore: _fallbackStore
                          withPersistentStoreAtURL: [self seedStoreURL]
                                             error: &error];
                if (seedSuccess) {
                    //delete the fallback store
                    seedSuccess = [_psc removePersistentStore: _fallbackStore error: &error];
                    if (seedSuccess) {
                        NSFileManager *fm = [NSFileManager defaultManager];
                        seedSuccess = [fm removeItemAtURL: [self fallbackStoreURL]
                                                    error: &error];
                        if ( !seedSuccess) {
                            ELog(error, @"Error deleting fallback store");
                        }
                    } else {
                        ELog(error, @"Error removing fallback store after seed");
                    }
                    [self deDupe: nil];
                } else {
                    ELog(error, @"Error seeding iCloud Store");
                    abort();
                }
            }
        } else {
            ELog(error, @"Unable to add fallback store");
            abort();
        }
    }
}

//----------------------------------------------------------------------------------------------------------
- (void)dropStores
{
    DLog();
    
    NSError *error = nil;
    
    if (_fallbackStore) {
        if ([_psc removePersistentStore: _fallbackStore error: &error]) {
            ALog(@"Removed fallback store");
            _fallbackStore = nil;
        } else {
            ELog(error, @"Error removing fallback store");
        }
    }
    
    if (_iCloudStore) {
        _presentedItemURL = nil;
        [NSFileCoordinator removeFilePresenter: self];
        if ([_psc removePersistentStore: _iCloudStore error: &error]) {
            ALog(@"Removed iCloud Store");
            _iCloudStore = nil;
        } else {
            ELog(error, @"Error removing iCloud Store");
        }
    }
}

//----------------------------------------------------------------------------------------------------------
- (void)reLoadiCloudStore: (NSPersistentStore *)store
                 readOnly: (BOOL)readOnly
{
    DLog();
    
    NSMutableDictionary *options = [[[NSMutableDictionary alloc] initWithDictionary: [store options]] autorelease];
    if (readOnly) {
        [options setObject: [NSNumber numberWithBool:YES]
                    forKey: NSReadOnlyPersistentStoreOption];
    }
    
    NSError *error      = nil;
    NSURL *storeURL     = [store URL];
    NSString *storeType = [store type];
    
    _iCloudStore = [_psc addPersistentStoreWithType: storeType
                                      configuration: nil
                                                URL: storeURL
                                            options: options
                                              error: &error];
    if (_iCloudStore) {
        ALog(@"Added store back as read only: %@", store);
    } else {
        ELog(error, @"Error adding read only store");
    }
}

#pragma mark - Application Lifecycle - Uniquing

//----------------------------------------------------------------------------------------------------------
- (void)deDupe:(NSNotification *)importNotification
{
    DLog();
    
    //if importNotification, scope dedupe by inserted records
    //else no search scope, prey for efficiency.
    @autoreleasepool {
        NSError *error = nil;
        
        NSManagedObjectContext *moc = [[[NSManagedObjectContext alloc] init] autorelease];
        [moc setPersistentStoreCoordinator: _psc];

        NSFetchRequest *fr = [[[NSFetchRequest alloc] initWithEntityName: KOPackagesEntity] autorelease];
        [fr setIncludesPendingChanges: NO];         //distinct has to go down to the db, not implemented for in memory filtering
        [fr setFetchBatchSize: 1000];               //protect thy memory
        
        NSExpression *countExpr                 = [NSExpression expressionWithFormat: @"count:(%@)", KOSequenceNumberAttributeName];
        NSExpressionDescription *countExprDesc  = [[[NSExpressionDescription alloc] init] autorelease];
        [countExprDesc setName: @"count"];
        [countExprDesc setExpression: countExpr];
        [countExprDesc setExpressionResultType: NSInteger64AttributeType];
        
        NSAttributeDescription *seqAttr = [[[[[_psc managedObjectModel] entitiesByName] objectForKey:KOPackagesEntity] propertiesByName] objectForKey: KOSequenceNumberAttributeName];
        
        [fr setPropertiesToFetch: [NSArray arrayWithObjects: seqAttr, countExprDesc, nil]];
        [fr setPropertiesToGroupBy: [NSArray arrayWithObject: seqAttr]];
        [fr setResultType: NSDictionaryResultType];
        
        NSArray *countDictionaries      = [moc executeFetchRequest: fr
                                                             error: &error];
        
        NSMutableArray *seqWithDupes = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *dict in countDictionaries) {
            NSNumber *count = [dict objectForKey: @"count"];
            if ([count integerValue] > 1) {
                [seqWithDupes addObject: [dict objectForKey: KOSequenceNumberAttributeName]];
            }
        }
        
        DLog(@"Sequence numbers with dupes: %@", seqWithDupes);
        
        //fetch out all the duplicate records
        fr = [NSFetchRequest fetchRequestWithEntityName: KOPackagesEntity];
        [fr setIncludesPendingChanges: NO];
        
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"%@ IN (%@)", KOSequenceNumberAttributeName, seqWithDupes];
        [fr setPredicate: p];
        
        NSSortDescriptor *seqSort = [NSSortDescriptor sortDescriptorWithKey: KOSequenceNumberAttributeName
                                                                  ascending: YES];
        [fr setSortDescriptors:[NSArray arrayWithObject:seqSort]];
        
        NSUInteger batchSize = 500; //can be set 100-10000 objects depending on individual object size and available device memory
        [fr setFetchBatchSize: batchSize];
        NSArray *dupes = [moc executeFetchRequest: fr
                                            error: &error];
        
        Packages *prevPackage = nil;
        
        NSUInteger i = 1;
        for (Packages *package in dupes) {
            if (prevPackage) {
                if ([package.created_date timeIntervalSinceDate:prevPackage.created_date] == 0) {
                    // it's a duplicate
                    DLog(@"Deleting:");
                    [package logAllFields];
                    [moc deleteObject: package];
                } else {
                    prevPackage = package;
                }
            } else {
                prevPackage = package;
            }
            
            if (i % batchSize) {
                //save the changes after each batch, this helps control memory pressure by turning previously examined objects back in to faults
                if ([moc save: &error]) {
                    ALog(@"Saved successfully after uniquing");
                } else {
                    ELog(error, @"Error saving unique results");
                }
            }
            
            i++;
        }
        
        if ([moc save: &error]) {
            ALog(@"Saved successfully after uniquing");
        } else {
            ELog(error, @"Error saving unique results");
        }
    }
}

#pragma mark - Application Lifecycle - Seeding

//----------------------------------------------------------------------------------------------------------
- (void)addPackage: (Packages *)package
           toStore: (NSPersistentStore *)store
       withContext: (NSManagedObjectContext *)moc
{
    DLog();
    
    NSEntityDescription *entity = [package entity];
    Packages *newPackage        = [[[Packages alloc] initWithEntity: entity
                                     insertIntoManagedObjectContext: moc] autorelease];
    
    newPackage.cover_ltr    = package.cover_ltr;
    newPackage.created_date = package.created_date;
    newPackage.name         = package.name;
//    newPackage.recordUUID = (package.recordUUID == nil) ? [[[NSUUID alloc] init] UUIDString] : package.recordUUID;
    [moc assignObject: newPackage
    toPersistentStore: store];
}



//----------------------------------------------------------------------------------------------------------
- (BOOL)       seedStore: (NSPersistentStore *)store
withPersistentStoreAtURL: (NSURL *)seedStoreURL
                   error: (NSError * __autoreleasing *)error
{
    DLog();
    
    BOOL success = YES;
    
    NSError *localError = nil;
    
    NSManagedObjectModel *model             = [NSManagedObjectModel mergedModelFromBundles: nil];
    NSPersistentStoreCoordinator *seedPSC   = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model] autorelease];
    NSDictionary *seedStoreOptions          = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool: YES] };
    NSPersistentStore *seedStore            = [seedPSC addPersistentStoreWithType: NSSQLiteStoreType
                                                                    configuration: nil
                                                                              URL: seedStoreURL
                                                                          options: seedStoreOptions
                                                                            error: &localError];
    if (seedStore) {
        NSManagedObjectContext *seedMOC = [[[NSManagedObjectContext alloc] init] autorelease];
        [seedMOC setPersistentStoreCoordinator: seedPSC];
        
        //fetch all the package objects, use a batched fetch request to control memory usage
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName: KOPackagesEntity];
        NSUInteger batchSize = 5000;
        [fr setFetchBatchSize: batchSize];
        
        NSArray *packages           = [seedMOC executeFetchRequest:fr error:&localError];
        NSManagedObjectContext *moc = [[[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType] autorelease];
        [moc setPersistentStoreCoordinator: _psc];
        
        NSUInteger i = 1;
        for (Packages *package in packages) {
            [self addPackage: package
                     toStore: store
                 withContext: moc];
            
            if (i % batchSize) {
                success = [moc save: &localError];
                if (success) {
                    /*
                     Reset the managed object context to free the memory for the inserted objects
                     The faulting array used for the fetch request will automatically free objects
                     with each batch, but inserted objects remain in the managed object context for
                     the lifecycle of the context
                     */
                    [moc reset];
                } else {
                    ELog(localError, @"Error saving during seed");
                    break;
                }
            }
            
            i++;
        }
        
        //one last save
        if ([moc hasChanges]) {
            success = [moc save: &localError];
            [moc reset];
        }
    } else {
        success = NO;
        ELog(localError, @"Error adding seed store");
    }
    
    if ( !success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }

    return success;
}

#pragma mark - Merging Changes

//----------------------------------------------------------------------------------------------------------
+ (void)mergeiCloudChangeNotification: (NSNotification *)note
             withManagedObjectContext: (NSManagedObjectContext *)moc
{
    DLog();
    
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification: note];
    }];
}

#pragma mark - Debugging Helpers

//----------------------------------------------------------------------------------------------------------
- (void)copyContainerToSandbox
{
    DLog();
    
    @autoreleasepool {
//        NSFileCoordinator *fc = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
        NSError *error          = nil;
        NSFileManager *fm       = [[[NSFileManager alloc] init] autorelease];
        NSString *path          = [self.ubiquityURL path];
        NSString *sandboxPath   = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: [self.ubiquityURL lastPathComponent]];
        
        if ([fm createDirectoryAtPath:sandboxPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            ALog(@"Created container directory in sandbox: %@", sandboxPath);
        } else {
            if ([[error domain] isEqualToString: NSCocoaErrorDomain]) {
                if ([error code] == NSFileWriteFileExistsError) {
                    //delete the existing directory
                    error = nil;
                    if ([fm removeItemAtPath:sandboxPath error:&error]) {
                        ALog(@"Removed old sandbox container copy");
                    } else {
                        ELog(error, @"Error trying to remove old sandbox container copy");
                    }
                }
            } else {
                ELog(error, @"Error attempting to create sandbox container copy");
                return;
            }
        }
        
        
        NSArray *subPaths = [fm subpathsAtPath: path];
        
        for (NSString *subPath in subPaths) {
            NSString *fullPath          = [NSString stringWithFormat: @"%@/%@", path, subPath];
            NSString *fullSandboxPath   = [NSString stringWithFormat: @"%@/%@", sandboxPath, subPath];
            
            BOOL isDirectory = NO;
            if ([fm fileExistsAtPath: fullPath isDirectory: &isDirectory]) {
                if (isDirectory) {
                    //create the directory
                    BOOL createSuccess = [fm createDirectoryAtPath: fullSandboxPath
                                       withIntermediateDirectories: YES
                                                        attributes: nil
                                                             error: &error];
                    if (createSuccess) {
                        //yay
                    } else {
                        ELog(error, @"Error creating directory in sandbox");
                    }
                } else {
                    //simply copy the file over
                    BOOL copySuccess = [fm copyItemAtPath: fullPath
                                                   toPath: fullSandboxPath
                                                    error: &error];
                    if (copySuccess) {
                        //yay
                    } else {
                        ELog(error, @"Error copying item at path: %@\nTo path: %@", fullPath, fullSandboxPath);
                    }
                }
            } else {
                ALog(@"Got subpath but there is no file at the full path: %@", fullPath);
            }
        }
        
//        fc = nil;
    }
}

//----------------------------------------------------------------------------------------------------------
- (void)nukeAndPave
{
    DLog();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self asyncNukeAndPave];
    });
}

//----------------------------------------------------------------------------------------------------------
- (void)asyncNukeAndPave
{
    DLog();
    
    //disconnect from the various stores
    [self dropStores];
    
    NSFileCoordinator *fc   = [[[NSFileCoordinator alloc] initWithFilePresenter: nil] autorelease];
    NSError *error          = nil;
    NSFileManager *fm       = [NSFileManager defaultManager];
    NSString *path          = [self.ubiquityURL path];
    NSArray *subPaths       = [fm subpathsAtPath:path];
    
    for (NSString *subPath in subPaths) {
        NSString *fullPath = [NSString stringWithFormat: @"%@/%@", path, subPath];
        [fc coordinateWritingItemAtURL: [NSURL fileURLWithPath: fullPath]
                               options: NSFileCoordinatorWritingForDeleting
                                 error: &error
                            byAccessor: ^(NSURL *newURL) {
            NSError *blockError = nil;
            if ([fm removeItemAtURL: newURL error: &blockError]) {
                ALog(@"Deleted file: %@", newURL);
            } else {
                ELog(blockError, @"Error deleting file: %@", newURL);
            }

        }];
    }

    fc = nil;
}

#pragma mark - Other helper methods

//----------------------------------------------------------------------------------------------------------
- (NSString *)folderForUbiquityToken: (id)token
{
    DLog();
    
    NSURL *tokenURL     = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent: @"TokenFoldersData"];
    NSData *tokenData   = [NSData dataWithContentsOfURL: tokenURL];
    
    NSMutableDictionary *foldersByToken = nil;
    if (tokenData) {
        foldersByToken = [NSKeyedUnarchiver unarchiveObjectWithData: tokenData];
    } else {
        foldersByToken = [NSMutableDictionary dictionary];
    }
    NSString *storeDirectoryUUID = [foldersByToken objectForKey: token];
    if (storeDirectoryUUID == nil) {
        NSUUID *uuid        = [[[NSUUID alloc] init] autorelease];
        storeDirectoryUUID  = [uuid UUIDString];
        [foldersByToken setObject: storeDirectoryUUID
                           forKey: token];
        tokenData = [NSKeyedArchiver archivedDataWithRootObject: foldersByToken];
        [tokenData writeToFile: [tokenURL path]
                    atomically: YES];
    }
    
    return storeDirectoryUUID;
}

//----------------------------------------------------------------------------------------------------------
- (NSURL *)iCloudStoreURL
{
    DLog();
    
    NSURL *iCloudStoreURL = [self applicationSandboxStoresDirectory];
    NSAssert1(self.currentUbiquityToken, @"No ubiquity token? Why you no use fallback store? %@", self);
    
    NSString *storeDirectoryUUID = [self folderForUbiquityToken: self.currentUbiquityToken];
    
    iCloudStoreURL      = [iCloudStoreURL URLByAppendingPathComponent: storeDirectoryUUID];
    NSFileManager *fm   = [[[NSFileManager alloc] init] autorelease];
    if ( ![fm fileExistsAtPath:[iCloudStoreURL path]]) {
        NSError *error = nil;
        BOOL createSuccess = [fm createDirectoryAtURL:iCloudStoreURL withIntermediateDirectories:YES attributes:nil error:&error];
        if ( !createSuccess) {
            ELog(error, @"Unable to create iCloud store directory");
        }
    }
    
    iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", KODatabaseName, @"store"]];
    
    return iCloudStoreURL;
}

//----------------------------------------------------------------------------------------------------------
- (NSURL *)seedStoreURL
{
    DLog();
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSURL *bundleURL = [mainBundle URLForResource: KODatabaseName
                                    withExtension: KODatabaseType];
    
    return bundleURL;
}

//----------------------------------------------------------------------------------------------------------
- (NSURL *)fallbackStoreURL
{
    DLog();
    
    NSURL *storeURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent: kFallbackPersistentStoreFilename];
    
    return storeURL;
}

//----------------------------------------------------------------------------------------------------------
- (NSURL *)applicationSandboxStoresDirectory
{
    DLog();
    
    NSURL *storesDirectory  = [NSURL fileURLWithPath: [self applicationDocumentsDirectory]];
    storesDirectory         = [storesDirectory URLByAppendingPathComponent: @"KOResumeDataStores"];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    
    if ( ![fm fileExistsAtPath: [storesDirectory path]]) {
        //create it
        NSError *error = nil;
        BOOL createSuccess = [fm createDirectoryAtURL: storesDirectory
                          withIntermediateDirectories: YES
                                           attributes: nil
                                                error: &error];
        if ( !createSuccess) {
            ELog(error, @"Unable to create application sandbox stores directory: %@", storesDirectory);
        }
    }
    return storesDirectory;
}

//----------------------------------------------------------------------------------------------------------
- (NSString *)applicationDocumentsDirectory
{
    DLog();
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - NSFilePresenter

//----------------------------------------------------------------------------------------------------------
- (NSURL *)presentedItemURL
{
    DLog();
    
    return _presentedItemURL;
}

//----------------------------------------------------------------------------------------------------------
- (NSOperationQueue *)presentedItemOperationQueue
{
    DLog();
    
    return _presentedItemOperationQueue;
}

//----------------------------------------------------------------------------------------------------------
- (void)accommodatePresentedItemDeletionWithCompletionHandler: (void (^)(NSError *))completionHandler
{
    DLog();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self iCloudAccountChanged: nil];
    });
    completionHandler(NULL);
}

@end
