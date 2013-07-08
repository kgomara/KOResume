//
//  KOResumeAppDelegate.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "CoreDataController.h"

#define kAppDelegate        [[UIApplication sharedApplication] delegate]

@interface KOResumeAppDelegate : NSObject <UIApplicationDelegate> 
{

}

@property (nonatomic, strong) IBOutlet UIWindow             *window;
@property (nonatomic, strong, readonly) CoreDataController  *coreDataController;

@end

