//
//  ResumeViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Packages.h"

@interface ResumeViewController : UIViewController <UITableViewDelegate> 
{
    UITableView*                tblView;
    NSDictionary*               mgmtJobsDict;
    NSManagedObjectContext*     managedObjectContext;
    Packages*                   selectedPackage;
    NSFetchedResultsController* fetchedResultsController;
}

@property (nonatomic, retain) IBOutlet      UITableView*    tblView;
@property (nonatomic, retain)               NSDictionary*   mgmtJobsDict;
@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) Packages*                     selectedPackage;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

@end
