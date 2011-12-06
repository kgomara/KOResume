//
//  SummaryViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara. All rights reserved.
//

#import "SummaryViewController.h"
#import "KOExtensions.h"
#import <CoreData/CoreData.h>

#define kHomePhoneTag	0
#define kMobilePhoneTag	1

@implementation SummaryViewController

@synthesize nameFld                     = _nameFld;
@synthesize street1Fld                  = _street1Fld;
@synthesize cityFld                     = _cityFld;
@synthesize stateFld                    = _stateFld;
@synthesize zipFld                      = _zipFld;
@synthesize homePhoneFld                = _homePhoneFld;
@synthesize mobilePhoneFld              = _mobilePhoneFld;
@synthesize emailFld                    = _emailFld;
@synthesize summaryFld                  = _summaryFld;


@synthesize selectedResume              = _selectedResume;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

	NSString*   phoneNumber;


- (void)viewDidLoad 
{
    [super viewDidLoad];

    if (!self.selectedResume.summary) {
        // get the cover letter into the view
        NSBundle* bundle		= [NSBundle mainBundle];
        NSString* summaryPath	= [bundle pathForResource:@"Summary" ofType:@"txt"];
        NSError*  error         = nil;
        NSString* summaryTxt	= [[NSString alloc] initWithContentsOfFile:summaryPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
        if (error) {
            ELog(error, @"Failed to read Summary.txt");
        }
        
        self.selectedResume.summary	= summaryTxt;
        [summaryTxt release];
    }
    
    self.nameFld.text        = self.selectedResume.name;
    self.street1Fld.text     = self.selectedResume.street1;
    self.cityFld.text        = self.selectedResume.city;
    self.stateFld.text       = self.selectedResume.state;
    self.zipFld.text         = self.selectedResume.postal_code;
    self.homePhoneFld.text   = self.selectedResume.home_phone;
    self.mobilePhoneFld.text = self.selectedResume.mobile_phone;
//    self.emailFld.text       = self.selectedResume.email;
    self.summaryFld.text     = self.selectedResume.summary;
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

    self.nameFld            = nil;
    self.street1Fld         = nil;
    self.cityFld            = nil;
    self.stateFld           = nil;
    self.zipFld             = nil;
	self.homePhoneFld       = nil;
	self.mobilePhoneFld     = nil;
    self.emailFld           = nil;
	self.summaryFld         = nil;
}


- (void)dealloc {
    self.nameFld            = nil;
    self.street1Fld         = nil;
    self.cityFld            = nil;
    self.stateFld           = nil;
    self.zipFld             = nil;
	self.homePhoneFld       = nil;
	self.mobilePhoneFld     = nil;
    self.emailFld           = nil;
	self.summaryFld         = nil;
    
    self.selectedResume             = nil;
    self.managedObjectContext       = nil;
    self.fetchedResultsController   = nil;
	
    [super dealloc];
}

#pragma mark User event methods

- (IBAction)phoneTapped:(id)sender 
{
    DLog();
	if ([sender tag] == 1) {
        phoneNumber = self.selectedResume.home_phone;
    } else {
        phoneNumber = self.selectedResume.mobile_phone;
    }
    
    NSString* fmtString     = NSLocalizedString(@"Call %@?", @"Call %@?");
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Phone", @"Phone") 
                                                     message:[NSString stringWithFormat:fmtString, phoneNumber]
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
                                           otherButtonTitles:NSLocalizedString(@"Call", @"Call"), nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        DLog(@"Calling %@", phoneNumber);
        NSMutableString* strippedString = [NSMutableString stringWithCapacity:10];
        for (int i = 0; i < [phoneNumber length]; i++) {
            if (isdigit([phoneNumber characterAtIndex:i])) {
                [strippedString appendFormat:@"%c", [phoneNumber characterAtIndex:i]];
            }
        }
        
        NSURL* phoneURL = [NSURL URLWithString: [NSString stringWithFormat: NSLocalizedString(@"tel:%@", @"tel:%@"), strippedString]];
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
	phoneNumber = nil;
}

- (IBAction)emailTapped:(id)sender
{
    DLog();
}

@end
