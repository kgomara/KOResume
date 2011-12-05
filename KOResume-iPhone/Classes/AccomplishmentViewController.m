//
//  AccomplishmentViewController.m
//  KOResume
//
//  Created by OMARA KEVIN on 12/4/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import "AccomplishmentViewController.h"

@implementation AccomplishmentViewController

@synthesize accomplishmentName;
@synthesize accomplishmentSummary;

@synthesize selectedAccomplishment      = _selectedAccomplishment;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
