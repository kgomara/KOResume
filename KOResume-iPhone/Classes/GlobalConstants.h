//
//  GlobalConstants.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/11/13.
//  Copyright (c) 2013 O'Mara Consulting Associates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalConstants : NSObject

// App constants
FOUNDATION_EXPORT NSString *const kDB_NAME;
FOUNDATION_EXPORT NSString *const kDB_TYPE;
FOUNDATION_EXPORT NSString *const kUBIQUITY_ID;


// Notifications
FOUNDATION_EXPORT NSString *const kRefetchAllDatabaseData;
FOUNDATION_EXPORT NSString *const kRefreshAllViews;

// Database Attribute names
FOUNDATION_EXPORT NSString *const kSequenceNumberAttr;

// View Controller XIBs
FOUNDATION_EXPORT NSString *const kSummaryViewController;
FOUNDATION_EXPORT NSString *const kJobsDetailViewController;
FOUNDATION_EXPORT NSString *const kEducationViewController;
FOUNDATION_EXPORT NSString *const kPackagesViewController;
FOUNDATION_EXPORT NSString *const kAccomplishmentViewController;
FOUNDATION_EXPORT NSString *const kCoverLtrViewController;
FOUNDATION_EXPORT NSString *const kResumeViewController;

// Miscellaneous constants
extern CGFloat const kAddBtnWidth;
extern CGFloat const kAddBtnHeight;
FOUNDATION_EXPORT NSString *const kPackagesEditing;
FOUNDATION_EXPORT NSString *const kCellIdentifier;


@end
