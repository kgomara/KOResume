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

- (void)loadData;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UIView *)textField;
- (void)resetView;

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
    [super viewDidLoad];
    
    _activeFld = nil;
    
    [self loadData];
    
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

    // Register for iCloud notifications
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
    
    self.accomplishmentName     = nil;
    self.accomplishmentSummary  = nil;
    self.scrollView             = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    // Save any changes
    DLog();
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    
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
    
    [self.accomplishmentName setEnabled:NO];
    [self.accomplishmentSummary setEditable:NO];
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
    [self.accomplishmentName setEnabled:YES];
    [self.accomplishmentSummary setEditable:YES];
    
    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveAction
{
    DLog();    
    // Save the changes
    self.selectedAccomplishment.name    = self.accomplishmentName.text;
    self.selectedAccomplishment.summary = self.accomplishmentSummary.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    NSError *error = nil;
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    
    if (![moc save:&error])
    {
        // Fatal Error
        NSString* msg = [[NSString alloc] initWithFormat:NSLocalizedString(@"Unresolved error %@, %@", @"Unresolved error %@, %@"), error, [error userInfo]];
        [KOExtensions showErrorWithMessage:msg];
        [msg release];
        ELog(error, @"Failed to save to data store");
        abort();
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
    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
    [self loadData];
    [self configureDefaultNavBar];
    [self resetView];
}

#pragma mark - Keyboard handlers

//----------------------------------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // Get the size of the keyboard
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect         = self.view.frame;
    CGRect viewRect      = _activeFld.frame;
    viewRect.origin.y   += viewRect.size.height / 2;
    aRect.size.height   -= kbSize.height;
    
    // calculate the contentOffset for the scroller
    // ...to get the middle of the active field into the middle of the available view area
    CGPoint scrollPoint = CGPointMake(0.0, (_activeFld.frame.origin.y + (_activeFld.frame.size.height / 2)) - (aRect.size.height /  2));        
    [self.scrollView setContentOffset:scrollPoint animated:YES];        
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
    [self scrollToViewTextField:textView];
    
    return YES;
}


//----------------------------------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _activeFld = nil;
    
    DLog();;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

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
- (void)scrollToViewTextField:(UIView *)textField
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
