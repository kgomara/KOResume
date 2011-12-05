//
//  EditCoverLtrViewController.m
//  KOResume
//
//  Created by OMARA KEVIN on 11/5/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import "EditCoverLtrViewController.h"
#import "KOExtensions.h"

@interface EditCoverLtrViewController()
{
    
@private
    UITextView*    _activeView;
}

@property (nonatomic, retain) UITextView*  activeView;
@end

@implementation EditCoverLtrViewController

@synthesize contentView                 = _contentView;
@synthesize contentImage                = _contentImage;
@synthesize textView                    = _textView;
@synthesize selectedPackage             = _selectedPackage;
@synthesize activeView                  = _activeView;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get the cover letter from the package
    
    self.textView.text = self.selectedPackage.cover_ltr;
    
    self.view.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
//    self.contentImage.image     = [[UIImage imageNamed:@"contentpane_details"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    
	self.contentImage.image    = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth:44 
                                                                                                      topCapHeight:44];

    // Set up the navigation item and save button
    UIBarButtonItem* saveBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction)] autorelease];
    UIBarButtonItem* cancelBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancelAction)] autorelease];
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self     
                                             selector:@selector(keyboardWillBeHidden:)     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Start an undo group...it will either be commited or 
    //    undone in requestModalViewDismissal
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
    
    // Get cover letter from the selectedPackage
    self.textView.text = self.selectedPackage.cover_ltr;
}


- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // Get the size of the keyboard
    NSDictionary* info = [aNotification userInfo];    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    // ...and adjust the contentInset for its height
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    self.textView.contentInset           = contentInsets;
    self.textView.scrollIndicatorInsets  = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect = self.view.frame;    
    aRect.size.height -= kbSize.height;    
    if (!CGRectContainsPoint(aRect, self.activeView.frame.origin) ) {
        // calculate the contentOffset for the scroller
        CGPoint scrollPoint = CGPointMake(0.0, self.activeView.frame.origin.y - kbSize.height);        
        [self.textView setContentOffset:scrollPoint animated:YES];        
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.textView.contentInset = contentInsets;    
    self.textView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{    
    self.activeView = textView;
    
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeView = nil;
}

- (void)saveAction
{
    DLog();
    // Save the changes
    self.selectedPackage.cover_ltr = self.textView.text;
    
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
    // ...and pop the navigation stack to return to caller
    [self.navigationController popViewControllerAnimated:YES];
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
    // ...and pop the navigation stack to return to caller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_contentView release];
    [_contentImage release];
    [_textView release];
    [_selectedPackage release];
    
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
