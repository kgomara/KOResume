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

#define kHomePhoneTag	1
#define kMobilePhoneTag	2

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

- (void)updateDataFields;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

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
    DLog();

    [super viewDidLoad];
    
    [self updateDataFields];

    _activeFld = nil;
    
	self.contentPaneBackground.image    = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth: 44 
                                                                                                               topCapHeight: 44];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self     
                                             selector: @selector(keyboardWillBeHidden:)     
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    // Set up btn items
    backBtn     = self.navigationItem.leftBarButtonItem;    
    editBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                                target: self 
                                                                action: @selector(editButtonTapped)];
    saveBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                                target: self
                                                                action: @selector(saveButtonTapped)];
    cancelBtn   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                target: self
                                                                action: @selector(cancelButtonTapped)];
    
    [self configureDefaultNavBar];
    
    // Register for iCloud updates
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadFetchedResults:) 
                                                 name: KOApplicationDidMergeChangesFrom_iCloudNotification
                                               object: nil];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    DLog();

    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
    DLog();

    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
    DLog();

    // Save any changes
    [self saveMoc: self.managedObjectContext];
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//----------------------------------------------------------------------------------------------------------
- (void)updateDataFields
{
    DLog();

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
    
    [self.nameFld           setEnabled: NO];
    [self.street1Fld        setEnabled: NO];
    [self.cityFld           setEnabled: NO];
    [self.stateFld          setEnabled: NO];
    [self.zipFld            setEnabled: NO];
    [self.homePhoneFld      setEnabled: NO];
    [self.mobilePhoneFld    setEnabled: NO];
    [self.emailFld          setEnabled: NO];
    [self.summaryFld        setEditable: NO];
}

#pragma mark - UI handlers

//----------------------------------------------------------------------------------------------------------
- (void)editButtonTapped
{
    DLog();
    
    // Set up the navigation item and save button
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Enable the fields for editing
    [self.nameFld           setEnabled: YES];
    [self.street1Fld        setEnabled: YES];
    [self.cityFld           setEnabled: YES];
    [self.stateFld          setEnabled: YES];
    [self.zipFld            setEnabled: YES];
    [self.homePhoneFld      setEnabled: YES];
    [self.mobilePhoneFld    setEnabled: YES];
    [self.emailFld          setEnabled: YES];
    [self.summaryFld        setEditable: YES];
    
    // Start an undo group...it will either be commited in saveButtonTapped or 
    //    undone in cancelButtonTapped
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveButtonTapped
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
    
    if (![self saveMoc: [self.fetchedResultsController managedObjectContext]]) {
        // Serious Error!
        NSString* msg = NSLocalizedString(@"Failed to save data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget: self];
    // ...and reset the UI defaults
    [self configureDefaultNavBar];
    [self resetView];
}


//----------------------------------------------------------------------------------------------------------
- (void)cancelButtonTapped
{
    DLog();
    
    // Undo any changes the user has made
    [[self.managedObjectContext undoManager] setActionName: KOUndoActionName];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if ([[self.managedObjectContext undoManager] canUndo]) {
        // Changes were made - discard them
        [[self.managedObjectContext undoManager] undoNestedGroup];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget: self];
    // ...and reset the UI defaults
    [self updateDataFields];
    [self configureDefaultNavBar];
    [self resetView];
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)phoneButtonTapped:(id)sender
{
    DLog();
    
	if ([sender tag] == kHomePhoneTag) {
        self.phoneNumber = self.selectedResume.home_phone;
    } else {
        self.phoneNumber = self.selectedResume.mobile_phone;
    }
    
    NSString *fmtString = NSLocalizedString(@"Call %@?", @"Prompt to show user what phone number will be called");
    UIAlertView *alert  = [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Place a call", nil)
                                                      message: [NSString stringWithFormat:fmtString, self.phoneNumber]
                                                     delegate: self 
                                            cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                            otherButtonTitles: NSLocalizedString(@"Call", nil), nil] autorelease];
    [alert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    DLog();

    if (buttonIndex != alertView.cancelButtonIndex) {
        DLog(@"Calling %@", self.phoneNumber);
        // Loop through the phoneNumber and remove non-numeric characters
        NSMutableString *strippedString = [NSMutableString stringWithCapacity: 10];
        for (int i = 0; i < [self.phoneNumber length]; i++) {
            if (isdigit([self.phoneNumber characterAtIndex:i])) {
                [strippedString appendFormat:@"%c", [self.phoneNumber characterAtIndex: i]];
            }
        }
        
        // Ask the system to make a call
        NSURL *phoneURL = [NSURL URLWithString: [NSString stringWithFormat: @"tel:%@", strippedString]];
        [[UIApplication sharedApplication] openURL: phoneURL];
    }
	self.phoneNumber = nil;
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)emailButtonTapped:(id)sender
{
    DLog();
    
    // Ask the system to send an email
    NSURL *emailURL = [NSURL URLWithString: [NSString stringWithFormat: @"mailto:%@", self.selectedResume.email]];
    [[UIApplication sharedApplication] openURL: emailURL];
}

#pragma mark - Keyboard handlers

//----------------------------------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    DLog();

    // Get the size of the keyboard
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect = self.view.frame;    
    aRect.size.height -= kbSize.height;
    DLog(@"point= %f, %f", _activeFld.frame.origin.x, _activeFld.frame.origin.y);
    if (!CGRectContainsPoint(aRect, _activeFld.frame.origin)) {
        // calculate the contentOffset for the scroller
        // ...to get the middle of the active field into the middle of the available view area
        CGPoint scrollPoint = CGPointMake(0.0, (_activeFld.frame.origin.y + (_activeFld.frame.size.height / 2)) - (aRect.size.height /  2));        
        [self.scrollView setContentOffset: scrollPoint
                                 animated: YES];
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
    DLog();

    _activeFld = textView;
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();

    _activeFld = nil;
}

#pragma mark - UITextFieldDelegate methods

//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    DLog();

    _activeFld = textField;
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    DLog();

	[self scrollToViewTextField:textField];
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    DLog();

    _activeFld = nil;
	// Validate fields - nothing to do in this version
	
	return YES;
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog();

	int nextTag = [textField tag] + 1;
	UIResponder *nextResponder = [textField.superview viewWithTag: nextTag];
	
	if (nextResponder) {
        [nextResponder becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
        [self resetView];
	}
	
	return NO;
}


//----------------------------------------------------------------------------------------------------------
- (void)scrollToViewTextField:(UITextField *)textField
{
    DLog();

	float textFieldOriginY = textField.frame.origin.y;
	[self.scrollView setContentOffset: CGPointMake(0.0f, textFieldOriginY - 20.0f) 
                             animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)resetView
{
    DLog();
    
    [self.scrollView setContentOffset: CGPointZero
                             animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)reloadFetchedResults:(NSNotification*)note
{
    DLog();
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch: &error]) {
        ELog(error, @"Fetch failed!");
        NSString* msg = NSLocalizedString(@"Failed to reload data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }

    [self updateDataFields];

//    if (note) {
//        // The notification is on an async thread, so block while the UI updates
//        [self.managedObjectContext performBlock: ^{
//            [self updateDataFields];
//        }];
//    }
}

//----------------------------------------------------------------------------------------------------------
- (BOOL)saveMoc:(NSManagedObjectContext *)moc
{
    DLog();

    BOOL result = YES;
    NSError *error = nil;
    
    if (moc) {
        if ([moc hasChanges]) {
            if (![moc save: &error]) {
                ELog(error, @"Failed to save");
                result = NO;
            } else {
                DLog(@"Save successful");
            }
        } else {
            DLog(@"No changes to save");
        }
    } else {
        ALog(@"managedObjectContext is null");
        result = NO;
    }
    
    return result;
}

@end
