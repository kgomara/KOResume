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

@interface KOResumeAppDelegate ()
{
    
}

@property (nonatomic, strong) IBOutlet UINavigationController           *navigationController;
@property (nonatomic, strong, readonly) NSManagedObjectContext          *managedObjectContext;

- (void)saveContext;

@end

@implementation KOResumeAppDelegate

@synthesize window                      = _window;
@synthesize navigationController        = _navigationController;
@synthesize managedObjectContext        = __managedObjectContext;


#pragma mark -
#pragma mark Application lifecycle

//----------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    DLog();

    // Initialize CoreDataController
    _coreDataController = [[CoreDataController alloc] init];

    __managedObjectContext = self.coreDataController.managedObjectContext;
    if (!__managedObjectContext) {
        ALog(@"Could not get managedObjectContext");
        NSString *msg = NSLocalizedString(@"Failed to open database.", nil);
        [KOExtensions showErrorWithMessage: msg];
        abort();
    }
    
    // Pass the managed object context to the view controller.
    RootViewController *rootViewController     = (RootViewController *) self.navigationController.topViewController;
    rootViewController.managedObjectContext    = self.managedObjectContext;
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview: self.navigationController.view];
    [self.window makeKeyAndVisible];
    
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
- (void)saveContext
{
    DLog();
    
    // Save changes to application's managed object context
    [__managedObjectContext performBlock:^{
        if ([__managedObjectContext hasChanges]) {
            NSError *error = nil;
            if ([__managedObjectContext save: &error]) {
                DLog(@"Save successful");
            } else {
                ELog(error, @"Failed to save data");
                NSString* msg = NSLocalizedString( @"Failed to save data.", nil);
                [KOExtensions showErrorWithMessage: msg];
            }
        } else {
            DLog(@"No changes to save");
        }
    }];
}


@end

