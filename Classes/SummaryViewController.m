//
//  SummaryViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"
#import "KOExtensions.h"

#define kHomePhoneTag	0
#define kMobilePhoneTag	1
#define kLabelWidth		280

@implementation SummaryViewController

@synthesize homePhone;
@synthesize mobilePhone;
@synthesize summaryLabel;

	NSString	*phoneNumber;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.summaryLabel.text = @"Award winning, creative, Product Development Leader with expertise in Agile development, web applications, and database systems.  Built strong development teams and processes from scratch for hi-tech start up organizations, and played major roles in execution of their exit strategies.";

	// Size jobResponsibilities Label to fit the string
	[self.summaryLabel sizeToFitFixedWidth:kLabelWidth];

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
	self.homePhone = nil;
	self.mobilePhone = nil;
	self.summaryLabel = nil;
	
    [super dealloc];
}

#pragma mark User event methods

- (IBAction)phoneTapped:(id)sender {
	
	UIButton *phoneButton = (UIButton *)sender;
	phoneNumber = phoneButton.currentTitle;
    UIAlertView*        alert = [[[UIAlertView alloc] initWithTitle:@"Phone" 
                                                            message:[NSString stringWithFormat:@"Call %@?", phoneNumber]
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"Call", nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        NSLog(@"Calling %@", phoneNumber);
        NSMutableString *strippedString = [NSMutableString stringWithCapacity:10];
        for (int i=0; i<[phoneNumber length]; i++) {
            if (isdigit([phoneNumber characterAtIndex:i])) {
                [strippedString appendFormat:@"%c",[phoneNumber characterAtIndex:i]];
            }
        }
        
        NSURL *phoneURL = [NSURL URLWithString: [NSString stringWithFormat: @"tel:%@", strippedString]];
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
	phoneNumber = nil;
}




@end
