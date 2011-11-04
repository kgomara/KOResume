//
//  KOResumeAppDelegate.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KOResumeAppDelegate : NSObject <UIApplicationDelegate> 
{

}

@property (nonatomic, retain) IBOutlet UIWindow*                        window;
@property (nonatomic, retain) IBOutlet UINavigationController*          navigationController;

@property (nonatomic, retain, readonly) NSManagedObjectContext*         managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel*           managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator*   persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;

- (void)saveContext;

@end

