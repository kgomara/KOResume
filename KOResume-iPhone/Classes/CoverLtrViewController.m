//
//  CoverLtrViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "CoverLtrViewController.h"
#import	"KOExtensions.h"
#import <CoreData/CoreData.h>

@implementation CoverLtrViewController

@synthesize coverLtrLbl;
@synthesize coverLtrView;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// get the cover letter into the view
	NSBundle* bundle		= [NSBundle mainBundle];
	NSString* coverLtrPath	= [bundle pathForResource:@"CoverLtrStandard" ofType:@"txt"];
    NSError*  error         = nil;
	NSString* coverLtr		= [[NSString alloc] initWithContentsOfFile:coverLtrPath 
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
    if (error) {
        ELog(error, @"Failed to read CoverLtrStandard.txt");
    }
    
	self.coverLtrLbl.text	= coverLtr;
	[coverLtr release];
	
	// Size coverLtrLbl to fit the string
	[self.coverLtrLbl sizeToFitFixedWidth:kLabelWidth];	
	
	// Re-size the sub-view to allow for the number of lines in jobResponsibilities
	CGRect coverLtrLblFrame	= self.coverLtrLbl.frame;
	CGRect viewFrame		= self.coverLtrView.frame;
	viewFrame.size.height  += coverLtrLblFrame.size.height + kLabelHeight;
	
	self.coverLtrView.frame = viewFrame;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	self.coverLtrLbl = nil;
	self.coverLtrView = nil;
	
    [super dealloc];
}


@end
