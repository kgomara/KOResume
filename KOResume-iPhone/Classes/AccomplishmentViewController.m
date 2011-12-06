//
//  AccomplishmentViewController.m
//  KOResume
//
//  Created by OMARA KEVIN on 12/4/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import "AccomplishmentViewController.h"
#import "KOExtensions.h"

@interface AccomplishmentViewController()
{
@private
    UIBarButtonItem* backBtn;
    UIBarButtonItem* editBtn;
    UIBarButtonItem* saveBtn;
    UIBarButtonItem* cancelBtn;
}

- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
    
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
}

- (void)didReceiveMemoryWarning
{
    ALog();
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    self.accomplishmentName        = nil;
    self.accomplishmentSummary  = nil;
    self.scrollView     = nil;
}


- (void)dealloc 
{
    [_accomplishmentName release];
    [_accomplishmentSummary release];
    [_scrollView release];
    
    [_selectedAccomplishment release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.accomplishmentName setEnabled:NO];
    [self.accomplishmentSummary setEditable:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Save any changes
    DLog();
    NSError* error = nil;
    NSManagedObjectContext* moc = self.managedObjectContext;
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
            ELog(error, @"Failed to save");
            abort();
        }
    } else {
        ALog(@"managedObjectContext is null");
    }
}

#pragma mark UI handlers

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

- (void)saveAction
{
    DLog();    
    // Save the changes
    self.selectedAccomplishment.name    = self.accomplishmentName.text;
    self.selectedAccomplishment.summary = self.accomplishmentSummary.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    NSError* error = nil;
    NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error])
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

- (void)cancelAction
{
    DLog();
    // Undo any changes the user has made
    [[self.managedObjectContext undoManager] setActionName:@"Packages Editing"];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    if ([[self.managedObjectContext undoManager] canUndo]) {
        [[self.managedObjectContext undoManager] undoNestedGroup];
    } else {
        DLog(@"User cancelled, nothing to undo");
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget:self];
    // ...and reset the UI defaults
    self.accomplishmentName.text    = self.selectedAccomplishment.name;
    self.accomplishmentSummary.text = self.selectedAccomplishment.summary;
    [self configureDefaultNavBar];
    [self resetView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollToViewTextField:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField 
{
	// Validate fields - nothing to do in this version
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	int nextTag = [textField tag] + 1;
	UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
	
	if (nextResponder) {
        [nextResponder becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
        [self resetView];
	}
	
	return NO;
}

- (void)scrollToViewTextField:(UITextField *)textField 
{
	float textFieldOriginY = textField.frame.origin.y;
	[self.scrollView setContentOffset:CGPointMake(0.0f, textFieldOriginY - 20.0f) 
                             animated:YES];
}

- (void)resetView
{
    DLog();
    [self.scrollView setContentOffset:CGPointZero
                             animated:YES];
}

@end
