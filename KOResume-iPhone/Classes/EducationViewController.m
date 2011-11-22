//
//  EducationViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "EducationViewController.h"
#import "KOExtensions.h"

#define k_degreeDateFldTag          99

@interface EducationViewController()
{
@private
    UIBarButtonItem* backBtn;
    UIBarButtonItem* doneBtn;
    UIBarButtonItem* editBtn;
    UIBarButtonItem* saveBtn;
    UIBarButtonItem* cancelBtn;
    NSDateFormatter* dateFormatter;
}

- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;
- (void)animateDatePickerOn;

@end

@implementation EducationViewController

@synthesize selectedEducation           = _selectedEducation;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize scrollView                  = _scrollView;
@synthesize nameFld                     = _nameFld;
@synthesize degreeDateFld               = _degreeDateFld;
@synthesize cityFld                     = _cityFld;
@synthesize stateFld                    = _stateFld;
@synthesize titleFld                    = _titleFld;

@synthesize datePicker                  = _datePicker;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self.datePicker setHidden:YES];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    self.nameFld.text               = self.selectedEducation.name;
    dateFormatter                   = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];	//Not shown
	self.degreeDateFld.text         = [dateFormatter stringFromDate:self.selectedEducation.earned_date];
    self.cityFld.text               = self.selectedEducation.city;
    self.stateFld.text              = self.selectedEducation.state;
    self.titleFld.text              = self.selectedEducation.title;
    
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
    doneBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(doneAction)];

    [self configureDefaultNavBar];
}

- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.nameFld setEnabled:NO];
    [self.degreeDateFld setEnabled:NO];
    [self.cityFld setEnabled:NO];
    [self.stateFld setEnabled:NO];
    [self.titleFld setEnabled:NO];
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
    [self.nameFld setEnabled:YES];
    [self.degreeDateFld setEnabled:YES];
    [self.cityFld setEnabled:YES];
    [self.stateFld setEnabled:YES];
    [self.titleFld setEnabled:YES];

    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}

- (void)saveAction
{
    DLog();    
    // Save the changes
    self.selectedEducation.name         = self.nameFld.text;
    self.selectedEducation.earned_date  = [dateFormatter dateFromString:self.degreeDateFld.text];
    self.selectedEducation.city         = self.cityFld.text;
    self.selectedEducation.state        = self.stateFld.text;
    self.selectedEducation.title        = self.titleFld.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    NSError* error = nil;
    NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error])
    {
        // Fatal Error
        NSString* msg = [[NSString alloc] initWithFormat:NSLocalizedString(@"Unresolved error %@, %@", 
                                                                           @"Unresolved error %@, %@"), error, [error userInfo]];
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
    [self configureDefaultNavBar];
    [self resetView];
}

- (void)doneAction
{
    DLog();
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];    
    CGRect endFrame = self.datePicker.frame;
    
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    // Start the slide down animation
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.datePicker.frame = endFrame;
                         [self.scrollView setContentOffset:CGPointZero
                                                  animated:NO];
                     }];
    
    // Reset the UI
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.navigationItem.leftBarButtonItem  = cancelBtn;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
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
    
    self.nameFld        = nil;
    self.degreeDateFld  = nil;
    self.cityFld        = nil;
    self.stateFld       = nil;
    self.titleFld       = nil;
    self.scrollView     = nil;
}


- (void)dealloc 
{
    [_nameFld release];
    [_degreeDateFld release];
    [_cityFld release];
    [_stateFld release];
    [_titleFld release];
    [_scrollView release];
    
    [_selectedEducation release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == k_degreeDateFldTag) {
        // we are in the date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [self.datePicker setDate:self.selectedEducation.earned_date];
        [self animateDatePickerOn];
//        [self scrollToViewTextField:textField];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollToViewTextField:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField 
{
	// Validate fields
	
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField 
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

- (void)animateDatePickerOn
{
    DLog();
    [self.datePicker setHidden:NO];
    [self.view bringSubviewToFront:self.datePicker];
    // Size up the picker view to our screen and compute the start/end frame origin for our slide up animation
    // ... compute the start frame        
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];        
    CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];        
    CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height, pickerSize.width, pickerSize.height);        
    self.datePicker.frame = startRect;   
    
    // ... compute the end frame        
    CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
    
    // Start the slide up animation        
    [UIView animateWithDuration:0.3
                     animations:^ {
                         self.datePicker.frame = pickerRect;
                         [self.scrollView setContentOffset:CGPointMake(0.0f, 100.0f)];
                     }];
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = doneBtn;
    // ...and clear the cancel button
    self.navigationItem.leftBarButtonItem = nil;
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

- (IBAction)getEarnedDate:(id)sender
{
    // Update the database
    self.selectedEducation.earned_date  = [self.datePicker date];
    // ...and the textField
	self.degreeDateFld.text             = [dateFormatter stringFromDate:self.selectedEducation.earned_date];
}


@end
