//
//  InfoViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 7/6/13.
//  Copyright (c) 2013 O'Mara Consulting Associates. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize contentPaneBackground       = _contentPaneBackground;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.contentPaneBackground.image    = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth: 44
                                                                                                               topCapHeight: 44];
    [self.navigationItem hidesBackButton];
    [self.navigationController setTitle: NSLocalizedString(@"Loading Database", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enableOKButton:)
                                                 name: KOApplicationDidAddPersistentStoreCoordinatorNotification
                                               object: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_OK_Btn release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [self setOK_Btn:nil];
    [super viewDidUnload];
}
- (IBAction)handleOKBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)enableOKButton:(NSNotification *)note
{
    [self.OK_Btn setEnabled: YES];
}
@end
