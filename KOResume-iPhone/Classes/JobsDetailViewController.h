//
//  JobsDetailViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jobs.h"


@interface JobsDetailViewController : UIViewController <UIScrollViewDelegate,
                                                        UITableViewDelegate,
                                                        UITextFieldDelegate, UITextViewDelegate,
                                                        NSFetchedResultsControllerDelegate> 
{

}

@property (nonatomic, retain)           Jobs*           selectedJob;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, retain) IBOutlet	UIImageView*    jobView;
@property (nonatomic, retain) IBOutlet	UIScrollView*   jobScrollView;
@property (nonatomic, retain) IBOutlet  UITextField*    jobCompany;
@property (nonatomic, retain) IBOutlet  UITextField*    jobCompanyUrl;
@property (nonatomic, retain) IBOutlet	UIButton*       jobCompanyUrlBtn;
@property (nonatomic, retain) IBOutlet	UITextField*    jobCity;
@property (nonatomic, retain) IBOutlet	UITextField*    jobState;
@property (nonatomic, retain) IBOutlet	UITextField*    jobTitle;
@property (nonatomic, retain) IBOutlet	UILabel*        jobStartDate;
@property (nonatomic, retain) IBOutlet	UILabel*        jobEndDate;
@property (nonatomic, retain) IBOutlet	UITextView*     jobResponsibilities;

@property (nonatomic, strong) IBOutlet  UIDatePicker*   datePicker;
@property (nonatomic, strong) IBOutlet  UITableView*    tblView;

- (IBAction)companyTapped:(id)sender;


@end
