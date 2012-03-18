//
//  ResumeViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011, 2012 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resumes.h"

@interface ResumeViewController : UIViewController <UITableViewDelegate, 
                                                    NSFetchedResultsControllerDelegate> 
{

}

@property (nonatomic, strong) IBOutlet      UITableView*                tblView;
@property (nonatomic, strong)               Resumes*                    selectedResume;

@property (nonatomic, strong)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, strong)               NSFetchedResultsController* fetchedResultsController;

@end
