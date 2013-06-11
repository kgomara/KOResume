//
//  SummaryViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "SummaryViewController.h"
#import "KOExtensions.h"
#import <CoreData/CoreData.h>

#define kHomePhoneTag	0
#define kMobilePhoneTag	1

@interface SummaryViewController()
{
@private
    UIBarButtonItem     *backBtn;
    UIBarButtonItem     *editBtn;
    UIBarButtonItem     *saveBtn;
    UIBarButtonItem     *cancelBtn;

    NSString            *phoneNumber;
    UIView              *_activeFld;
}

@property (nonatomic, strong)	NSString    *phoneNumber;

- (void)loadData;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;

@end

@implementation SummaryViewController

@synthesize selectedResume              = _selectedResume;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize scrollView                  = _scrollView;
@synthesize contentPaneBackground       = _contentPaneBackground;
@synthesize phoneNumber                 = _phoneNumber;
@synthesize nameFld                     = _nameFld;
@synthesize street1Fld                  = _street1Fld;
@synthesize cityFld                     = _cityFld;
@synthesize stateFld                    = _stateFld;
@synthesize zipFld                      = _zipFld;
@synthesize homePhoneFld                = _homePhoneFld;
@synthesize mobilePhoneFld              = _mobilePhoneFld;
@synthesize emailFld                    = _emailFld;
@synthesize summaryFld                  = _summaryFld;

#pragma mark - Life Cycle methods

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];

    _activeFld = nil;
    
	self.contentPaneBackground.image    = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth:44 
                                                                                                               topCapHeight:44];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self     
                                             selector:@selector(keyboardWillBeHidden:)     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set up btn items
    backBtn     = self.navigationItem.leftBarButtonItem;    
    editBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                target:self 
                                                                action:@selector(editAction)];
    saveBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                target:self
                                                                action:@selector(saveAction)];
    cancelBtn   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self
                                                                action:@selector(cancelAction)];
    
    [self configureDefaultNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFetchedResults:) 
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];

    self.scrollView             = nil;
    self.contentPaneBackground  = nil;
    self.nameFld                = nil;
    self.street1Fld             = nil;
    self.cityFld                = nil;
    self.stateFld               = nil;
    self.zipFld                 = nil;
	self.homePhoneFld           = nil;
	self.mobilePhoneFld         = nil;
    self.emailFld               = nil;
	self.summaryFld             = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Apple recommends calling release on the ivar...
    [_scrollView release];
    [_nameFld release];
    [_street1Fld release];
    [_cityFld release];
    [_stateFld release];
    [_zipFld release];
	[_homePhoneFld release];
	[_mobilePhoneFld release];
    [_emailFld release];
	[_summaryFld release];
    
    [_selectedResume release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    ALog();
}


//----------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    // Save any changes
    DLog();
    NSError *error = nil;
    NSManagedObjectContext* moc = self.managedObjectContext;
    
    if (moc)
    {
        if ([moc hasChanges])
        {
            if (![moc save:&error])
            {
                ELog(error, @"Failed to save");
                abort();
            }
        }
    }
    else
    {
        ALog(@"managedObjectContext is null");
    }
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//----------------------------------------------------------------------------------------------------------
- (void)loadData
{
    self.nameFld.text        = self.selectedResume.name;
    self.street1Fld.text     = self.selectedResume.street1;
    self.cityFld.text        = self.selectedResume.city;
    self.stateFld.text       = self.selectedResume.state;
    self.zipFld.text         = self.selectedResume.postal_code;
    self.homePhoneFld.text   = self.selectedResume.home_phone;
    self.mobilePhoneFld.text = self.selectedResume.mobile_phone;
    self.emailFld.text       = self.selectedResume.email;
    self.summaryFld.text     = self.selectedResume.summary;
}


//----------------------------------------------------------------------------------------------------------
- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.nameFld setEnabled:NO];
    [self.street1Fld setEnabled:NO];
    [self.cityFld setEnabled:NO];
    [self.stateFld setEnabled:NO];
    [self.zipFld setEnabled:NO];
    [self.homePhoneFld setEnabled:NO];
    [self.mobilePhoneFld setEnabled:NO];
    [self.emailFld setEnabled:NO];
    [self.summaryFld setEditable:NO];
}

#pragma mark - UI handlers

//----------------------------------------------------------------------------------------------------------
- (void)editAction
{
    DLog();
    
    // Set up the navigation item and save button
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Enable the fields for editing
    [self.nameFld setEnabled:YES];
    [self.street1Fld setEnabled:YES];
    [self.cityFld setEnabled:YES];
    [self.stateFld setEnabled:YES];
    [self.zipFld setEnabled:YES];
    [self.homePhoneFld setEnabled:YES];
    [self.mobilePhoneFld setEnabled:YES];
    [self.emailFld setEnabled:YES];
    [self.summaryFld setEditable:YES];
    
    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveAction
{
    DLog();    
    // Save the changes
    self.selectedResume.name            = self.nameFld.text;
    self.selectedResume.street1         = self.street1Fld.text;
    self.selectedResume.city            = self.cityFld.text;
    self.selectedResume.state           = self.stateFld.text;
    self.selectedResume.postal_code     = self.zipFld.text;
    self.selectedResume.home_phone      = self.homePhoneFld.text;
    self.selectedResume.mobile_phone    = self.mobilePhoneFld.text;
    self.selectedResume.email           = self.emailFld.text;
    self.selectedResume.summary         = self.summaryFld.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    NSError *error = nil;
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    
    if (moc)
    {
        if ([moc hasChanges])
        {
            if (![moc save:&error])
            {
                // Fatal Error
                NSString* msg = [[NSString alloc] initWithFormat:NSLocalizedString(@"Unresolved error %@, %@", @"Unresolved error %@, %@"), error, [error userInfo]];
                [KOExtensions showErrorWithMessage:msg];
                [msg release];
                ELog(error, @"Failed to save to data store");
                abort();
            }
        }
    }
    else
    {
        ALog(@"moc is null");
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget:self];
    // ...and reset the UI defaults
    [self configureDefaultNavBar];
    [self resetView];
}


//----------------------------------------------------------------------------------------------------------
- (void)cancelAction
{
    DLog();
    // Undo any changes the user has made
    [[self.managedObjectContext undoManager] setActionName:@"Packages Editing"];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if ([[self.managedObjectContext undoManager] canUndo])
    {
        [[self.managedObjectContext undoManager] undoNestedGroup];
    }
    else
    {
        DLog(@"User cancelled, nothing to undo");
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget:self];
    // ...and reset the UI defaults
    [self loadData];
    [self configureDefaultNavBar];
    [self resetView];
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)phoneTapped:(id)sender
{
    DLog();
	if ([sender tag] == 1)
    {
        self.phoneNumber = self.selectedResume.home_phone;
    }
    else
    {
        self.phoneNumber = self.selectedResume.mobile_phone;
    }
    
    NSString *fmtString     = NSLocalizedString(@"Call %@?", @"Call %@?");
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Phone", @"Phone")
                                                     message:[NSString stringWithFormat:fmtString, self.phoneNumber]
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
                                           otherButtonTitles:NSLocalizedString(@"Call", @"Call"), nil] autorelease];
    [alert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        DLog(@"Calling %@", self.phoneNumber);
        // Loop through the phoneNumber and remove non-numeric characters
        NSMutableString *strippedString = [NSMutableString stringWithCapacity:10];
        for (int i = 0; i < [self.phoneNumber length]; i++)
        {
            if (isdigit([self.phoneNumber characterAtIndex:i]))
            {
                [strippedString appendFormat:@"%c", [self.phoneNumber characterAtIndex:i]];
            }
        }
        
        // Ask the system to make a call
        NSURL *phoneURL = [NSURL URLWithString: [NSString stringWithFormat: NSLocalizedString(@"tel:%@", @"tel:%@"), strippedString]];
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
	self.phoneNumber = nil;
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)emailTapped:(id)sender
{
    DLog();
    // Ask the system to send an email
    NSURL *emailURL = [NSURL URLWithString: [NSString stringWithFormat: NSLocalizedString(@"mailto:%@", @"mailto:%@"), self.selectedResume.email]];
    [[UIApplication sharedApplication] openURL:emailURL];
}

#pragma mark - Keyboard handlers

//----------------------------------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // Get the size of the keyboard
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect = self.view.frame;    
    aRect.size.height -= kbSize.height;
    DLog(@"point= %f, %f", _activeFld.frame.origin.x, _activeFld.frame.origin.y);
    if (!CGRectContainsPoint(aRect, _activeFld.frame.origin))
    {
        // calculate the contentOffset for the scroller
        // ...to get the middle of the active field into the middle of the available view area
        CGPoint scrollPoint = CGPointMake(0.0, (_activeFld.frame.origin.y + (_activeFld.frame.size.height / 2)) - (aRect.size.height /  2));        
        [self.scrollView setContentOffset:scrollPoint animated:YES];        
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{    

}

#pragma mark - UITextView delegate methods

//----------------------------------------------------------------------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _activeFld = textView;
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _activeFld = nil;
    
    DLog();;
}

#pragma mark - UITextFieldDelegate methods

//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _activeFld = textField;
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollToViewTextField:textField];
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _activeFld = nil;
	// Validate fields - nothing to do in this version
	
	return YES;
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	int nextTag = [textField tag] + 1;
	UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
	
	if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
	}
    else
    {
		[textField resignFirstResponder];
        [self resetView];
	}
	
	return NO;
}


//----------------------------------------------------------------------------------------------------------
- (void)scrollToViewTextField:(UITextField *)textField
{
	float textFieldOriginY = textField.frame.origin.y;
	[self.scrollView setContentOffset:CGPointMake(0.0f, textFieldOriginY - 20.0f) 
                             animated:YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)resetView
{
    DLog();
    [self.scrollView setContentOffset:CGPointZero
                             animated:YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)reloadFetchedResults:(NSNotification*)note
{
    DLog();
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        ELog(error, @"Fetch failed!");
        abort();
    }             
    
    if (note)
    {
        // The notification is on an async thread, so block while the UI updates
        [self.managedObjectContext performBlock:^{
            [self loadData];
        }];
    }
}

@end
