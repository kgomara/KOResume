//
//  EducationViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "EducationViewController.h"
#import "KOExtensions.h"

#define k_degreeDateFldTag          99

@interface EducationViewController()
{
@private
    UIBarButtonItem     *backBtn;
    UIBarButtonItem     *doneBtn;
    UIBarButtonItem     *editBtn;
    UIBarButtonItem     *saveBtn;
    UIBarButtonItem     *cancelBtn;
    NSDateFormatter     *dateFormatter;
}

- (void)updateDataFields;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;
- (void)animateDatePickerOn;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

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

#pragma mark - Life Cycle methods

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    DLog();

    [super viewDidLoad];
    
    [self.datePicker setHidden: YES];
    [self.datePicker setDatePickerMode: UIDatePickerModeDate];
    
    [self updateDataFields];
    
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
    doneBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                target: self
                                                                action: @selector(doneButtonTapped)];

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
    
    self.nameFld        = nil;
    self.degreeDateFld  = nil;
    self.cityFld        = nil;
    self.stateFld       = nil;
    self.titleFld       = nil;
    self.scrollView     = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();

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
- (void)configureDefaultNavBar
{
    DLog();
    
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    [self.nameFld       setEnabled: NO];
    [self.degreeDateFld setEnabled: NO];
    [self.cityFld       setEnabled: NO];
    [self.stateFld      setEnabled: NO];
    [self.titleFld      setEnabled: NO];
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
    [self.nameFld       setEnabled: YES];
    [self.degreeDateFld setEnabled: YES];
    [self.cityFld       setEnabled: YES];
    [self.stateFld      setEnabled: YES];
    [self.titleFld      setEnabled: YES];

    // Start an undo group...it will either be commited in saveButtonTapped or 
    //    undone in cancelButtonTapped
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveButtonTapped
{
    DLog();
    
    // Save the changes
    self.selectedEducation.name         = self.nameFld.text;
    self.selectedEducation.earned_date  = [dateFormatter dateFromString: self.degreeDateFld.text];
    self.selectedEducation.city         = self.cityFld.text;
    self.selectedEducation.state        = self.stateFld.text;
    self.selectedEducation.title        = self.titleFld.text;
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if (![self saveMoc: [self.fetchedResultsController managedObjectContext]]) {
        // Serious Error!
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget:self];
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
    [self updateDataFields];
    [self configureDefaultNavBar];
    [self resetView];
}


//----------------------------------------------------------------------------------------------------------
- (void)doneButtonTapped
{
    DLog();
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];    
    CGRect endFrame = self.datePicker.frame;
    
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    // Start the slide down animation
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.datePicker.frame = endFrame;
                         [self.scrollView setContentOffset: CGPointZero
                                                  animated: NO];
                     }];
    
    // Reset the UI
    [KOExtensions dismissKeyboard];
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.navigationItem.leftBarButtonItem  = cancelBtn;
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)datePickerDidUpdate:(id)sender
{
    DLog();

    // Update the database
    self.selectedEducation.earned_date  = [self.datePicker date];
    // ...and the textField
	self.degreeDateFld.text             = [dateFormatter stringFromDate: self.selectedEducation.earned_date];
}


//----------------------------------------------------------------------------------------------------------
- (void)updateDataFields
{
    DLog();

    self.nameFld.text               = self.selectedEducation.name;
    dateFormatter                   = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];	//Not shown
	self.degreeDateFld.text         = [dateFormatter stringFromDate:self.selectedEducation.earned_date];
    self.cityFld.text               = self.selectedEducation.city;
    self.stateFld.text              = self.selectedEducation.state;
    self.titleFld.text              = self.selectedEducation.title;
}


#pragma mark - UITextFieldDelegate methods

//----------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    DLog();

    if (textField.tag == k_degreeDateFldTag) {
        // we are in the date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [KOExtensions dismissKeyboard];
        if (!self.selectedEducation.earned_date) {
            self.selectedEducation.earned_date = [NSDate date];
        }
        [self.datePicker setDate: self.selectedEducation.earned_date];
        [self animateDatePickerOn];
        return NO;
    } else {
        if (self.datePicker) {
            [self.datePicker setHidden:YES];
        }
    }
    
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
- (void)animateDatePickerOn
{
    DLog();
    
    [self.datePicker setHidden: NO];
    [self.view bringSubviewToFront: self.datePicker];
    
    // Size up the picker view to our screen and compute the start/end frame origin for our slide up animation
    // ... compute the start frame        
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];        
    CGSize pickerSize = [self.datePicker sizeThatFits: CGSizeZero];        
    CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height, pickerSize.width, pickerSize.height);        
    self.datePicker.frame = startRect;   
    
    // ... compute the end frame        
    CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
    
    // Start the slide up animation        
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.datePicker.frame = pickerRect;
                         [self.scrollView setContentOffset: CGPointMake(0.0f, 100.0f)];
                     }];
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = doneBtn;
    // ...and clear the cancel button
    self.navigationItem.leftBarButtonItem = nil;
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
