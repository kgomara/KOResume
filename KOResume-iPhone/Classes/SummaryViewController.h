//
//  SummaryViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resumes.h"
#import <CoreData/CoreData.h>

@interface SummaryViewController : UIViewController 
{

}

@property (nonatomic, retain) IBOutlet UIButton*                    homePhone;
@property (nonatomic, retain) IBOutlet UIButton*                    mobilePhone;
@property (nonatomic, retain) IBOutlet UILabel*                     summaryLabel;
@property (nonatomic, retain)          Resumes*                     selectedResume;

@property (nonatomic, retain)          NSManagedObjectContext*      managedObjectContext;
@property (nonatomic, retain)          NSFetchedResultsController*  fetchedResultsController;

- (IBAction)phoneTapped:(id)sender;

@end
