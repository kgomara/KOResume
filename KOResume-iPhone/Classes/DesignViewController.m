//
//  DesignViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/16/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "DesignViewController.h"
#import "KOExtensions.h"
#import <CoreData/CoreData.h>

@implementation DesignViewController

@synthesize designView;
@synthesize designScrollView;
@synthesize designExplanationLbl;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
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
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	self.designView.image     = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth:20 
                                                                                                     topCapHeight:20];

    // get the cover letter into the view
	NSBundle* bundle		= [NSBundle mainBundle];
	NSString* resourcePath	= [bundle pathForResource:@"DesignExplanation" ofType:@"txt"];
    NSError* error          = nil;
    NSString* labelTxt      = [[NSString alloc] initWithContentsOfFile:resourcePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];
    if (error) {
        ELog(error, @"Could not read DesignExplanation");
    }
    
    DLog(@"text = %@", labelTxt);
	self.designExplanationLbl.text	= labelTxt;
	[labelTxt release];
	
	// Size jobResponsibilities Label to fit the string
	[self.designExplanationLbl sizeToFitFixedWidth:kLabelWidth];
    
    // Adjust the height of the containing view
    CGRect designViewFrame = self.designView.frame;
    designViewFrame.size.height += self.designExplanationLbl.frame.size.height;
    self.designView.frame = designViewFrame;
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
	self.designView = nil;
	self.designScrollView = nil;
    self.designExplanationLbl = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	self.designView = nil;
	self.designScrollView = nil;
    self.designExplanationLbl = nil;
    
    [super dealloc];
}

@end
