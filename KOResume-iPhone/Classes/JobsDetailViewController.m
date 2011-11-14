//
//  JobsDetailViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "JobsDetailViewController.h"
#import "KOExtensions.h"
#import "Accomplishments.h"

@implementation JobsDetailViewController

@synthesize	jobCompany;
@synthesize jobCompanyUrl;
@synthesize	jobCity;
@synthesize jobState;
@synthesize	jobTitle;
@synthesize	jobStartDate;
@synthesize	jobEndDate;
@synthesize	jobResponsibilities;
@synthesize	jobAccomplishmentsArray;
@synthesize	jobView;
@synthesize jobScrollView;
@synthesize	jobCompanyUrlBtn;
@synthesize	selectedJob;
//@synthesize selectedResume              = _selectedResume;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;


#pragma mark Application lifecycle methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.view.backgroundColor		= [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	self.jobView.image              = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth:20 
                                                                                                           topCapHeight:20];

	// Get the data from the jobDictionary and stuff it into the fields
	[self.jobCompanyUrlBtn setTitle:self.selectedJob.uri 
						   forState:UIControlStateNormal];

	self.jobCompanyUrl				= self.selectedJob.uri;
	self.jobCity.text               = self.selectedJob.city;
    self.jobState.text              = self.selectedJob.state;
	self.jobTitle.text				= self.selectedJob.title;
    NSDateFormatter* dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];	//Not shown
	self.jobStartDate.text			= [dateFormatter stringFromDate:self.selectedJob.start_date];
    self.jobEndDate.text            = [dateFormatter stringFromDate:self.selectedJob.end_date];
	self.jobResponsibilities.text	= self.selectedJob.summary;
	
	// Size jobResponsibilities Label to fit the string
	[self.jobResponsibilities sizeToFitFixedWidth:kLabelWidth];
	
	// Re-size the sub-view to allow for the number of lines in jobResponsibilities
	CGRect jobItemFrame       = self.jobResponsibilities.frame;
	CGRect jobViewFrame       = self.jobView.frame;
	jobViewFrame.size.height += jobItemFrame.size.height - kLabelHeight;
		
	// Add the Accomplishments (if any) to the View and adjust size accordingly
	if ([self.selectedJob.accomplishment count] > 0) {
		// Create a label for the Accomplishment items
		jobItemFrame.origin.y		 = jobViewFrame.size.height;
		jobItemFrame.origin.x		-= jobViewFrame.origin.x;
		jobItemFrame.size.height	 = kLabelHeight;
		UILabel* accomplishment = [[[UILabel alloc] initWithFrame:jobItemFrame] autorelease];
		[accomplishment setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                                size:14.0]];
		[accomplishment setBackgroundColor:[UIColor clearColor]];
        
        // Set the text, add the label to the view, and adjust the frames
		accomplishment.text = NSLocalizedString(@"Accomplishments:", @"Accomplishments:");
        [self.jobView addSubview:accomplishment];
		jobItemFrame.origin.y		+= kLabelHeight;
		jobViewFrame.size.height	+= kLabelHeight * 2;
		
		// Loop through the accomplishment adding accomplishment items to the view
        NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequence_number"
                                                                        ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.jobAccomplishmentsArray = [NSMutableArray arrayWithArray:[self.selectedJob.accomplishment sortedArrayUsingDescriptors:sortDescriptors]];

        for (Accomplishments* accomp in self.jobAccomplishmentsArray) {
			// handle an accomplishment
			UILabel* accomplishment = [[[UILabel alloc] initWithFrame:jobItemFrame] autorelease];
			[accomplishment setFont:[UIFont fontWithName:@"Helvetica" 
                                                    size:14.0]];
			[accomplishment setBackgroundColor:[UIColor clearColor]];
			accomplishment.text = accomp.summary;
			[accomplishment sizeToFitFixedWidth:kLabelWidth];
			[self.jobView addSubview:accomplishment];
			jobItemFrame.origin.y		+= accomplishment.frame.size.height;
			jobViewFrame.size.height	+= accomplishment.frame.size.height;
		}
	}
	
	//set the zooming properties of the scroll view
	self.jobScrollView.minimumZoomScale = 1.0;
	self.jobScrollView.maximumZoomScale = 2.0;
	
	self.jobView.frame = jobViewFrame;
	self.jobScrollView.contentSize = jobViewFrame.size;
}


- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    ALog();
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	self.jobCompany					= nil;
	self.jobCompanyUrl				= nil;
	self.jobCity                    = nil;
    self.jobState                   = nil;
	self.jobTitle					= nil;
	self.jobStartDate				= nil;
	self.jobEndDate					= nil;
	self.jobResponsibilities		= nil;
	self.jobAccomplishmentsArray	= nil;
	self.jobView					= nil;
	self.jobScrollView				= nil;
	self.jobCompanyUrlBtn			= nil;
	self.selectedJob				= nil;
	
    [super dealloc];
}

#pragma mark User generated events

- (IBAction)companyTapped:(id)sender 
{
	if (self.jobCompanyUrl == NULL || [self.jobCompanyUrl rangeOfString:@"://"].location == NSNotFound) {
		return;
	}

	// Open the Url in Safari
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.jobCompanyUrl]];
}

#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	return self.jobView;
}

@end
