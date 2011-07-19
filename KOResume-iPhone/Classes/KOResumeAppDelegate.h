//
//  KOResumeAppDelegate.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KOResumeAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow*                       window;
    UINavigationController*         navigationController;
    
    NSManagedObjectContext*         managedObjectContext;
    NSManagedObjectModel*           managedObjectModel;
    NSPersistentStoreCoordinator*   persistentStoreCoordinator;
}

@property (nonatomic, retain) IBOutlet UIWindow*                        window;
@property (nonatomic, retain) IBOutlet UINavigationController*          navigationController;

@property (nonatomic, retain, readonly) NSManagedObjectContext*         managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel*           managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *  persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;

- (void)saveContext;

@end

