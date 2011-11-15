//
//  EducationViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "EducationViewController.h"


@implementation EducationViewController

@synthesize selectedEducation           = _selectedEducation;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize nameFld                     = _nameFld;
@synthesize degreeDateFld               = _degreeDateFld;
@synthesize cityFld                     = _cityFld;
@synthesize stateFld                    = _stateFld;
@synthesize titleFld                    = _titleFld;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.nameFld.text               = self.selectedEducation.name;
    NSDateFormatter* dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];	//Not shown
	self.degreeDateFld.text         = [dateFormatter stringFromDate:self.selectedEducation.earned_date];
    self.cityFld.text               = self.selectedEducation.city;
    self.stateFld.text              = self.selectedEducation.state;
    self.titleFld.text              = self.selectedEducation.title;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
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
    
    self.nameFld        = nil;
    self.degreeDateFld  = nil;
    self.cityFld        = nil;
    self.stateFld       = nil;
    self.titleFld       = nil;
}


- (void)dealloc 
{
    [_nameFld release];
    [_degreeDateFld release];
    [_cityFld release];
    [_stateFld release];
    [_titleFld release];
    
    [_selectedEducation release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

@end
