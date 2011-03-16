//
//  JobsDetailViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JobsDetailViewController.h"
#import "KOExtensions.h"



@implementation JobsDetailViewController

@synthesize	jobCompany;
@synthesize jobCompanyUrl;
@synthesize	jobLocation;
@synthesize	jobTitle;
@synthesize	jobStartDate;
@synthesize	jobEndDate;
@synthesize	jobResponsibilities;
@synthesize	jobAccomplishmentsArray;
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
	self.jobAccomplishmentsArray	= [jobDictionary objectForKey:@"Accomplishments"];
	
	// Size jobResponsibilities Label to fit the string
	[self.jobResponsibilities sizeToFitFixedWidth:kLabelWidth];
	
	// Re-size the sub-view to allow for the number of lines in jobResponsibilities
	CGRect jobItemFrame = self.jobResponsibilities.frame;
	CGRect jobViewFrame = self.jobView.frame;
	jobViewFrame.size.height += jobItemFrame.size.height - kLabelHeight;
	
	// Get the jobAccomplishmentsArray
	self.jobAccomplishmentsArray	= [jobDictionary objectForKey:@"Accomplishments"];
	
	// Add the Accomplishments (if any) to the View and adjust size accordingly
	if ([self.jobAccomplishmentsArray count] > 0) {
		// Create a label for the Accomplishment items
		jobItemFrame.origin.y		 = jobViewFrame.size.height;
		jobItemFrame.origin.x		-= jobViewFrame.origin.x;
		jobItemFrame.size.height	 = kLabelHeight;
		UILabel *accomplishment = [[[UILabel alloc] initWithFrame:jobItemFrame] autorelease];
		[accomplishment setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
		[accomplishment setBackgroundColor:[UIColor clearColor]];
		accomplishment.text = @"Accomplishments:";
		[self.jobView addSubview:accomplishment];
		jobItemFrame.origin.y		+= kLabelHeight;
		jobViewFrame.size.height	+= kLabelHeight * 2;
		
		// Loop through the jobAccomplishmentsArray adding accomplishment items to the view
		NSEnumerator *jobEnum = [jobAccomplishmentsArray objectEnumerator];
		NSString *item;
		while (item = [jobEnum nextObject]) {
			// handle an accomplishment
			UILabel *accomplishment = [[[UILabel alloc] initWithFrame:jobItemFrame] autorelease];
			[accomplishment setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
			[accomplishment setBackgroundColor:[UIColor clearColor]];
			accomplishment.text = item;
			[accomplishment sizeToFitFixedWidth:kLabelWidth];
			[self.jobView addSubview:accomplishment];
			jobItemFrame.origin.y		+= accomplishment.frame.size.height;
			jobViewFrame.size.height	+= accomplishment.frame.size.height;
		}
	}
	self.jobView.frame = jobViewFrame;
//	NSLog(@"contentSize = %@", [self.jobView contentSize]);
//	self.jobView.contentSize = jobViewFrame.size;
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
	self.jobCompany					= nil;
	self.jobCompanyUrl				= nil;
	self.jobLocation				= nil;
	self.jobTitle					= nil;
	self.jobStartDate				= nil;
	self.jobEndDate					= nil;
	self.jobResponsibilities		= nil;
	self.jobAccomplishmentsArray	= nil;
	self.jobView					= nil;
	self.jobCompanyUrlBtn			= nil;
	self.jobDictionary				= nil;
	
    [super dealloc];
}

#pragma mark User generated events

- (IBAction)companyTapped:(id)sender {
	
	if (self.jobCompanyUrl == NULL || [self.jobCompanyUrl rangeOfString:@"://"].location == NSNotFound) {
		return;
	}

	// Open the Url in Safari
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.jobCompanyUrl]];
	
}


@end
