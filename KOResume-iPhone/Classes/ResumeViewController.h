//
//  ResumeViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resumes.h"

@interface ResumeViewController : UIViewController <UITableViewDelegate, 
                                                    NSFetchedResultsControllerDelegate> 
{

}

@property (nonatomic, retain) IBOutlet      UITableView*                tblView;
@property (nonatomic, retain)               NSDictionary*               mgmtJobsDict;
@property (nonatomic, strong)               Resumes*                    selectedResume;

@property (nonatomic, retain)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, retain)               NSFetchedResultsController* fetchedResultsController;

@end
