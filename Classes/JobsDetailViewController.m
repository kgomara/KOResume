//
//  JobsDetailViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JobsDetailViewController.h"
#import "KOExtensions.h"

#define kLabelWidth			280
#define kLabelHeight		21



@implementation JobsDetailViewController

@synthesize	jobCompany;
@synthesize jobCompanyUrl;
@synthesize	jobLocation;
@synthesize	jobTitle;
@synthesize	jobStartDate;
@synthesize	jobEndDate;
@synthesize	jobResponsibilities;
@synthesize	jobAccomplishments;
@synthesize	jobView;
@synthesize	jobCompanyUrlBtn;
@synthesize	jobDictionary;


#pragma mark Application lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Get the data from the jobDictionary and stuff it into the fields
	[self.jobCompanyUrlBtn setTitle:[jobDictionary objectForKey:@"Company"] 
						   forState:UIControlStateNormal];

	self.jobCompanyUrl				= [jobDictionary objectForKey:@"CompanyUrl"];
	self.jobLocation.text			= [jobDictionary objectForKey:@"Location"];
	self.jobTitle.text				= [jobDictionary objectForKey:@"Title"];
	self.jobStartDate.text			= [jobDictionary objectForKey:@"StartDate"];
	self.jobEndDate.text			= [jobDictionary objectForKey:@"EndDate"];
	self.jobResponsibilities.text	= [jobDictionary objectForKey:@"Responsibilities"];
	self.jobAccomplishments			= [jobDictionary objectForKey:@"Accomplishments"];
	
	// Size jobResponsibilities Label to fit the string
	[self.jobResponsibilities sizeToFitFixedWidth:kLabelWidth];
	
	// Re-size the sub-view to allow for the number of lines in jobResponsibilities
	CGRect jobRespFrame = self.jobResponsibilities.frame;
	CGRect jobViewFrame = self.jobView.frame;
	jobViewFrame.size.height += jobRespFrame.size.height - kLabelHeight;
	self.jobView.frame = jobViewFrame;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.jobCompany				= nil;
	self.jobCompanyUrl			= nil;
	self.jobLocation			= nil;
	self.jobTitle				= nil;
	self.jobStartDate			= nil;
	self.jobEndDate				= nil;
	self.jobResponsibilities	= nil;
	self.jobAccomplishments		= nil;
	self.jobView				= nil;
	self.jobCompanyUrlBtn		= nil;
	self.jobDictionary			= nil;
	
    [super dealloc];
}

#pragma mark User generated events

- (IBAction)companyTapped:(id)sender {
	
	NSLog(@"companyTapped:");
	if (self.jobCompanyUrl == NULL || [self.jobCompanyUrl rangeOfString:@"://"].location == NSNotFound) {
		return;
	}

	// Open the Url in Safari
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.jobCompanyUrl]];
	
}


@end
