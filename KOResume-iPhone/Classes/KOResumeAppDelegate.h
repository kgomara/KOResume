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

@property (nonatomic, strong) IBOutlet UIWindow*                        window;
@property (nonatomic, strong) IBOutlet UINavigationController*          navigationController;

@property (nonatomic, strong, readonly) NSManagedObjectContext*         managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel*           managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator*   persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;

- (void)saveContext;

@end

