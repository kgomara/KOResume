//
//  CoverLtrViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "CoverLtrViewController.h"
#import	"KOExtensions.h"
#import <CoreData/CoreData.h>
#import "EditCoverLtrViewController.h"

@interface CoverLtrViewController()
{
@private
    UIBarButtonItem* backBtn;
    UIBarButtonItem* editBtn;
    UIBarButtonItem* saveBtn;
    UIBarButtonItem* cancelBtn;
}

- (void)configureDefaultNavBar;
- (void)resetView;

@end

@implementation CoverLtrViewController

@synthesize selectedPackage             = _selectedPackage;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize contentPaneBackground       = _contentPaneBackground;
@synthesize scrollView                  = _scrollView;
@synthesize coverLtrFld                 = _coverLtrFld;

#pragma mark - Life Cycle methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// get the cover letter into the view
    // TODO clean up database initialization
    if ([self.selectedPackage.cover_ltr length] == 0) {
        NSBundle* bundle		= [NSBundle mainBundle];
        NSString* coverLtrPath	= [bundle pathForResource:@"CoverLtrStandard" ofType:@"txt"];
        NSError*  error         = nil;
        NSString* coverLtr		= [[NSString alloc] initWithContentsOfFile:coverLtrPath 
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];
        if (error) {
            ELog(error, @"Failed to read CoverLtrStandard.txt");
        }
        self.selectedPackage.cover_ltr = coverLtr;
        [coverLtr release];
    }
    
	self.coverLtrFld.text	= self.selectedPackage.cover_ltr;
    
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
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    self.contentPaneBackground  = nil;
    self.scrollView             = nil;
    self.coverLtrFld            = nil;
}

- (void)dealloc 
{
    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Apple recommends calling release on the ivar...
    [_contentPaneBackground release];
    [_scrollView release];
	[_coverLtrFld release];
    [_selectedPackage release];
    
    [__fetchedResultsController release];
    [__managedObjectContext release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    ALog();
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.coverLtrFld setEditable:NO];
}

#pragma mark - UI handlers

- (void)editAction
{
    DLog();
    
    // Set up the navigation item and save button
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Enable the fields for editing
    [self.coverLtrFld setEditable:YES];
    
    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}

- (void)saveAction
{
    DLog();    
    // Save the changes
    self.selectedPackage.cover_ltr    = self.coverLtrFld.text;
    
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
    self.coverLtrFld.text    = self.selectedPackage.cover_ltr;
    [self configureDefaultNavBar];
    [self resetView];
}

#pragma mark - Keyboard handlers

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // Get the size of the keyboard
    NSDictionary* info = [aNotification userInfo];    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    // ...and adjust the contentInset for its height
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    self.coverLtrFld.contentInset           = contentInsets;
    self.coverLtrFld.scrollIndicatorInsets  = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect = self.view.frame;    
    aRect.size.height -= kbSize.height;    
    if (!CGRectContainsPoint(aRect, self.coverLtrFld.frame.origin) ) {
        // calculate the contentOffset for the scroller
        CGPoint scrollPoint = CGPointMake(0.0, self.coverLtrFld.frame.origin.y - kbSize.height);        
        [self.coverLtrFld setContentOffset:scrollPoint animated:YES];        
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.coverLtrFld.contentInset = contentInsets;    
    self.coverLtrFld.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextView delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();;
}

- (void)resetView
{
    DLog();
    [self.scrollView setContentOffset:CGPointZero
                             animated:YES];
}

@end
