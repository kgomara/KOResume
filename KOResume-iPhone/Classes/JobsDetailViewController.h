//
//  JobsDetailViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jobs.h"


@interface JobsDetailViewController : UIViewController <UIScrollViewDelegate> 
{
//	UILabel*        jobCompany;
//    NSString*       jobCompanyUrl;
//	UILabel*        jobLocation;
//	UILabel*        jobTitle;
//	UILabel*        jobStartDate;
//	UILabel*        jobEndDate;
//	UILabel*        jobResponsibilities;
//    NSArray*        jobAccomplishmentsArray;
//	UIImageView*    jobView;
//	UIScrollView*   jobScrollView;
//	UIButton*       jobCompanyUrlBtn;
//	
//	NSDictionary*   jobDictionary;
}

@property (nonatomic, retain) IBOutlet  UILabel*        jobCompany;
@property (nonatomic, retain)           NSString*		jobCompanyUrl;
@property (nonatomic, retain) IBOutlet	UILabel*        jobCity;
@property (nonatomic, retain) IBOutlet	UILabel*        jobState;
@property (nonatomic, retain) IBOutlet	UILabel*        jobTitle;
@property (nonatomic, retain) IBOutlet	UILabel*        jobStartDate;
@property (nonatomic, retain) IBOutlet	UILabel*        jobEndDate;
@property (nonatomic, retain) IBOutlet	UILabel*        jobResponsibilities;
@property (nonatomic, retain)           NSArray*        jobAccomplishmentsArray;
@property (nonatomic, retain) IBOutlet	UIImageView*    jobView;
@property (nonatomic, retain) IBOutlet	UIScrollView*   jobScrollView;
@property (nonatomic, retain) IBOutlet	UIButton*       jobCompanyUrlBtn;

@property (nonatomic, retain)               Jobs*                       selectedJob;
//@property (nonatomic, retain)               Resumes*                    selectedResume;

@property (nonatomic, retain)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, retain)               NSFetchedResultsController* fetchedResultsController;

- (IBAction)companyTapped:(id)sender;


@end
