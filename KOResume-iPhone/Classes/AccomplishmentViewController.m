//
//  AccomplishmentViewController.m
//  KOResume
//
//  Created by OMARA KEVIN on 12/4/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "AccomplishmentViewController.h"
#import "KOExtensions.h"

@interface AccomplishmentViewController()
{
@private
    UIBarButtonItem     *backBtn;
    UIBarButtonItem     *editBtn;
    UIBarButtonItem     *saveBtn;
    UIBarButtonItem     *cancelBtn;

    UIView              *_activeFld;
}

- (void)updateDataFields;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UIView *)textField;
- (void)resetView;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

@end

@implementation AccomplishmentViewController

@synthesize selectedAccomplishment      = _selectedAccomplishment;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize scrollView                  = _scrollView;
@synthesize accomplishmentName          = _accomplishmentName;
@synthesize accomplishmentSummary       = _accomplishmentSummary;

#pragma mark - View lifecycle

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    DLog();

    [super viewDidLoad];
    
    _activeFld = nil;
    
    [_selectedAccomplishment logAllFields];
    
    [self updateDataFields];
    
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

    // Register for iCloud notifications
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
    
    self.accomplishmentName     = nil;
    self.accomplishmentSummary  = nil;
    self.scrollView             = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();

    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Apple recommends calling release on the ivar...
    [_accomplishmentName release];
    [_accomplishmentSummary release];
    [_scrollView release];
    
    [_selectedAccomplishment release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    ALog();
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
}


//----------------------------------------------------------------------------------------------------------
- (void)configureDefaultNavBar
{
    DLog();
    
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.accomplishmentName    setEnabled: NO];
    [self.accomplishmentSummary setEditable: NO];
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
    [self.accomplishmentName    setEnabled: YES];
    [self.accomplishmentSummary setEditable: YES];
    
    // Start an undo group...it will either be commited in saveButtonTapped or 
    //    undone in cancelButtonTapped
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveButtonTapped
{
    DLog();
    
    // Save the changes
    self.selectedAccomplishment.name    = self.accomplishmentName.text;
    self.selectedAccomplishment.summary = self.accomplishmentSummary.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if (![self saveMoc: [self.fetchedResultsController managedObjectContext]]) {
        ALog(@"Failed to save data");
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
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
    [[self.managedObjectContext undoManager] setActionName:KOUndoActionName];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if ([[self.managedObjectContext undoManager] canUndo]) {
        [[self.managedObjectContext undoManager] undoNestedGroup];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget: self];
    // ...and reset the UI defaults
    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
    [self updateDataFields];
    [self configureDefaultNavBar];
    [self resetView];
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
    CGRect aRect         = self.view.frame;
    CGRect viewRect      = _activeFld.frame;
    viewRect.origin.y   += viewRect.size.height / 2;
    aRect.size.height   -= kbSize.height;
    
    // calculate the contentOffset for the scroller
    // ...to get the middle of the active field into the middle of the available view area
    CGPoint scrollPoint = CGPointMake(0.0, (_activeFld.frame.origin.y + (_activeFld.frame.size.height / 2)) - (aRect.size.height /  2));        
    [self.scrollView setContentOffset: scrollPoint
                             animated: YES];
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
    [self scrollToViewTextField: textView];
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();

    _activeFld = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

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

	[self scrollToViewTextField: textField];
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
- (void)scrollToViewTextField:(UIView *)textField
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
        NSString* msg = NSLocalizedString(@"Failed to reload data.", @"Failed to reload data.");
        [KOExtensions showErrorWithMessage: msg];
    }

    [self updateDataFields];

//    if (note) {
//        // The notification is on an async thread, so block while the UI updates
//        [self.managedObjectContext performBlock:^{
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
