//
//  KOResumeAppDelegate.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>
#import "CoreDataController.h"

#define kAppDelegate        [[UIApplication sharedApplication] delegate]

@interface KOResumeAppDelegate : NSObject <UIApplicationDelegate> 
{

}

//@property (nonatomic, strong, readonly) CoreDataController *coreDataController;

@property (nonatomic, strong) IBOutlet UIWindow                         *window;
@property (nonatomic, strong) IBOutlet UINavigationController           *navigationController;

@property (nonatomic, strong, readonly) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator    *persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;

- (void)saveContext;

@end

