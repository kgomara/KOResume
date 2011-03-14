//
//  JobsDetailViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JobsDetailViewController : UIViewController {
	IBOutlet	UILabel			*jobCompany;
				NSString		*jobCompanyUrl;
	IBOutlet	UILabel			*jobLocation;
	IBOutlet	UILabel			*jobTitle;
	IBOutlet	UILabel			*jobStartDate;
	IBOutlet	UILabel			*jobEndDate;
	IBOutlet	UILabel			*jobResponsibilities;
				NSArray			*jobAccomplishments;
	IBOutlet	UIView			*jobView;
	IBOutlet	UIButton		*jobCompanyUrlBtn;
	
	NSDictionary	*jobDictionary;

}

@property (nonatomic, retain) UILabel		*jobCompany;
@property (nonatomic, retain) NSString		*jobCompanyUrl;
@property (nonatomic, retain) UILabel		*jobLocation;
@property (nonatomic, retain) UILabel		*jobTitle;
@property (nonatomic, retain) UILabel		*jobStartDate;
@property (nonatomic, retain) UILabel		*jobEndDate;
@property (nonatomic, retain) UILabel		*jobResponsibilities;
@property (nonatomic, retain) NSArray		*jobAccomplishments;
@property (nonatomic, retain) UIView			*jobView;
@property (nonatomic, retain) UIButton		*jobCompanyUrlBtn;

@property (nonatomic, retain) NSDictionary	*jobDictionary;

- (IBAction)companyTapped:(id)sender;

@end
