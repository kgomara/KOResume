//
//  ResumeViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResumeViewController : UIViewController <UITableViewDelegate> {
			UITableView*    tableView;
            NSArray*        mgmtJobsArray;
            NSArray*        progJobsArray;
            NSDictionary*   mgmtJobsDict;
}

@property (nonatomic, retain) IBOutlet      UITableView*    tableView;
@property (nonatomic, retain)               NSArray*        mgmtJobsArray;
@property (nonatomic, retain)               NSArray*        progJobsArray;
@property (nonatomic, retain)               NSDictionary*   mgmtJobsDict;

@end
