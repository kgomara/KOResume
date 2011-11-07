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
#import "EditCoverLtrViewController.h"

@interface CoverLtrViewController()
{
@private
    
}

@end

@implementation CoverLtrViewController

@synthesize coverLtrLbl                 = _coverLtrLbl;
@synthesize coverLtrView                = _coverLtrView;
@synthesize selectedPackage             = _selectedPackage;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// get the cover letter into the view
    // TODO clean up database initialization
    if ([self.selectedPackage.cover_ltr length] == 0) {
        NSBundle* bundle		= [NSBundle mainBundle];
        NSString* coverLtrPath	= [bundle pathForResource:@"CoverLtrStandard" ofType:@"txt"];
        NSError*  error         = nil;
        NSString* coverLtr		= [[NSString alloc] initWithContentsOfFile:coverLtrPath 
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];
        if (error) {
            ELog(error, @"Failed to read CoverLtrStandard.txt");
        }
        self.selectedPackage.cover_ltr = coverLtr;
        [coverLtr release];
    }
    
	self.coverLtrLbl.text	= self.selectedPackage.cover_ltr;
	
	// Size coverLtrLbl to fit the string
	[self.coverLtrLbl sizeToFitFixedWidth:kLabelWidth];	
	
	// Re-size the sub-view to allow for the number of lines in jobResponsibilities
	CGRect coverLtrLblFrame	= self.coverLtrLbl.frame;
	CGRect viewFrame		= self.coverLtrView.frame;
	viewFrame.size.height  += coverLtrLblFrame.size.height + kLabelHeight;
	
	self.coverLtrView.frame = viewFrame;
    UIBarButtonItem* editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                 target:self 
                                                                                 action:@selector(editAction)] autorelease];
    
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Re-load the text in case we're coming back from editing
	self.coverLtrLbl.text	= self.selectedPackage.cover_ltr;    
}

#pragma mark UI handlers

- (void)editAction
{
    DLog();
    EditCoverLtrViewController* editCoverLtrViewController = [[[EditCoverLtrViewController alloc] init] autorelease];
    editCoverLtrViewController.selectedPackage = self.selectedPackage;
    editCoverLtrViewController.managedObjectContext = self.managedObjectContext;
    editCoverLtrViewController.fetchedResultsController = self.fetchedResultsController;
    
    [self.navigationController pushViewController:editCoverLtrViewController
                                         animated:YES];
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
    // Apple recommends calling release on the ivar...
	[_coverLtrLbl release];
	[_coverLtrView release];
    [_selectedPackage release];

    [__fetchedResultsController release];
    [__managedObjectContext release];
	
    [super dealloc];
}


@end
