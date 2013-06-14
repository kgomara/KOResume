//
//  GlobalConstants.m
//  KOResume
//
//  Created by Kevin O'Mara on 6/11/13.
//  Copyright (c) 2013 O'Mara Consulting Associates. All rights reserved.
//

#import "GlobalConstants.h"

@implementation GlobalConstants

// App constants
NSString *const kDB_NAME                        = @"KOResume";
NSString *const kDB_TYPE                        = @"sqlite";
NSString *const kUBIQUITY_ID                    = @"<your iCloud ID goes here>";


// Notifications
NSString *const kRefetchAllDatabaseData         = @"RefetchAllDatabaseData";
NSString *const kRefreshAllViews                = @"RefreshAllViews";

// Database Attribute names
NSString *const kSequenceNumberAttr             = @"sequence_number";

// View Controller XIBs
NSString *const kSummaryViewController          = @"SummaryViewController";
NSString *const kJobsDetailViewController       = @"JobsDetailViewController";
NSString *const kEducationViewController        = @"EducationViewController";
NSString *const kPackagesViewController         = @"PackagesViewController";
NSString *const kAccomplishmentViewController   = @"AccomplishmentViewController";
NSString *const kCoverLtrViewController         = @"CoverLtrViewController";
NSString *const kResumeViewController           = @"ResumeViewController";

// Miscellaneous constants
CGFloat const kAddBtnWidth                      = 29.0f;
CGFloat const kAddBtnHeight                     = 29.0f;
NSString *const kPackagesEditing                = @"Packages_Editing";
NSString *const kCellIdentifier                 = @"Cell";


@end
