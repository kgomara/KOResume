//
//  JobsDetailViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011, 2012 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jobs.h"


@interface JobsDetailViewController : UIViewController <UIScrollViewDelegate,
                                                        UITableViewDelegate,
                                                        UITextFieldDelegate, UITextViewDelegate,
                                                        NSFetchedResultsControllerDelegate> 
{
    Jobs*                       _selectedJob;
    NSManagedObjectContext*     __managedObjectConext;
    NSFetchedResultsController* __fetchedResultsController;
}

@property (nonatomic, strong) Jobs*                         selectedJob;
@property (nonatomic, strong) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController*   fetchedResultsController;

@property (nonatomic, strong) IBOutlet	UIImageView*        jobView;
@property (nonatomic, strong) IBOutlet  UITextField*        jobCompany;
@property (nonatomic, strong) IBOutlet  UITextField*        jobCompanyUrl;
@property (nonatomic, strong) IBOutlet	UIButton*           jobCompanyUrlBtn;
@property (nonatomic, strong) IBOutlet	UITextField*        jobCity;
@property (nonatomic, strong) IBOutlet	UITextField*        jobState;
@property (nonatomic, strong) IBOutlet	UITextField*        jobTitle;
@property (nonatomic, strong) IBOutlet	UITextField*        jobStartDate;
@property (nonatomic, strong) IBOutlet	UITextField*        jobEndDate;
@property (nonatomic, strong) IBOutlet	UITextView*         jobResponsibilities;

@property (nonatomic, strong) IBOutlet  UIDatePicker*       datePicker;
@property (nonatomic, strong) IBOutlet  UITableView*        tblView;

- (IBAction)companyTapped:(id)sender;

@end
