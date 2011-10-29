//
//  ResumeViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResumeViewController : UIViewController <UITableViewDelegate> 
{
    UITableView*    tblView;
    NSArray*        mgmtJobsArray;
    NSArray*        progJobsArray;
    NSDictionary*   mgmtJobsDict;
}

@property (nonatomic, retain) IBOutlet      UITableView*    tblView;
@property (nonatomic, retain)               NSArray*        mgmtJobsArray;
@property (nonatomic, retain)               NSArray*        progJobsArray;
@property (nonatomic, retain)               NSDictionary*   mgmtJobsDict;

@end
