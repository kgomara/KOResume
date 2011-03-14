//
//  RootViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	NSArray *mgmtJobsArray;
	NSDictionary	*mgmtJobsDict;
}

@property (nonatomic, retain) NSArray		*mgmtJobsArray;
@property (nonatomic, retain) NSDictionary	*mgmtJobsDict;

@end
