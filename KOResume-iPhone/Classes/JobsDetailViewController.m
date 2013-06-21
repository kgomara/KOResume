//
//  JobsDetailViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "JobsDetailViewController.h"
#import "KOExtensions.h"
#import "Accomplishments.h"
#import "AccomplishmentViewController.h"

#define k_startDateTextFld  6
#define k_endDateTextFld    7

@interface JobsDetailViewController ()
{
    
@private
    NSMutableArray      *_jobAccomplishmentsArray;
    NSString            *_accomplishmentName;

    UIBarButtonItem     *backBtn;
    UIBarButtonItem     *doneBtn;
    UIBarButtonItem     *clearBtn;
    UIBarButtonItem     *editBtn;
    UIBarButtonItem     *saveBtn;
    UIBarButtonItem     *cancelBtn;
    NSDateFormatter     *dateFormatter;
    
    UIButton            *addAccompBtn;
    int                 activeDateFld;
    UIView              *_activeFld;
}

@property (nonatomic, strong) NSMutableArray    *jobAccomplishmentsArray;
@property (nonatomic, strong) NSString          *accomplishmentName;

- (void)loadData;
- (void)sortTables;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;
- (void)animateDatePickerOn;
- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *)indexPath;
- (void)resequenceTables;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

@end

@implementation JobsDetailViewController

@synthesize	selectedJob                 = _selectedJob;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize	jobView                     = _jobView;
@synthesize	jobCompany                  = _jobCompany;
@synthesize jobCompanyUrl               = _jobCompanyUrl;
@synthesize	jobCompanyUrlBtn            = _jobCompanyUrlBtn;
@synthesize	jobCity                     = _jobCity;
@synthesize jobState                    = _jobState;
@synthesize	jobTitle                    = _jobTitle;
@synthesize	jobStartDate                = _jobStartDate;
@synthesize	jobEndDate                  = _jobEndDate;
@synthesize	jobResponsibilities         = _jobResponsibilities;

@synthesize tblView                     = _tblView;
@synthesize datePicker                  = _datePicker;

@synthesize jobAccomplishmentsArray     = _jobAccomplishmentsArray;
@synthesize accomplishmentName          = _accomplishmentName;


#pragma mark Application lifecycle methods

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor		= [UIColor colorWithPatternImage: [UIImage imageNamed: @"background.png"]];
	self.jobView.image              = [[UIImage imageNamed: @"contentpane_details.png"] stretchableImageWithLeftCapWidth: 20 
                                                                                                            topCapHeight: 20];
    self.fetchedResultsController.delegate = self;
    
    activeDateFld                   = 0;
    [self.datePicker setDatePickerMode: UIDatePickerModeDate];
    
    [self loadData];

    _activeFld = nil;

    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self     
                                             selector: @selector(keyboardWillBeHidden:)     
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    // Set up button items
    addAccompBtn = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
    [addAccompBtn setBackgroundImage: [UIImage imageNamed: @"addButton.png"] 
                            forState: UIControlStateNormal];
    [addAccompBtn setFrame: CGRectMake(280, 0, KOAddButtonWidth, KOAddButtonHeight)];
    [addAccompBtn addTarget: self 
                     action: @selector(getAccomplishmentName) 
           forControlEvents: UIControlEventTouchUpInside];

    backBtn     = self.navigationItem.leftBarButtonItem;    
    editBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                                target: self 
                                                                action: @selector(editAction)];
    saveBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                                target: self
                                                                action: @selector(saveAction)];
    cancelBtn   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                target: self
                                                                action: @selector(cancelAction)];
    doneBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                target: self
                                                                action: @selector(doneAction)];
    clearBtn    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemUndo
                                                                target: self
                                                                action: @selector(clearAction)];
    
    [self configureDefaultNavBar];
    
    // Set an observer for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadFetchedResults:) 
                                                 name: KOApplicationDidMergeChangesFrom_iCloudNotification
                                               object: [self.managedObjectContext persistentStoreCoordinator]];
}


//----------------------------------------------------------------------------------------------------------
- (void)loadData
{
    // Get the data and stuff it into the fields
    self.jobCompany.text                = self.selectedJob.name;
	self.jobCompanyUrl.text             = self.selectedJob.uri;
	self.jobCity.text                   = self.selectedJob.city;
    self.jobState.text                  = self.selectedJob.state;
	self.jobTitle.text                  = self.selectedJob.title;
    dateFormatter                       = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];	//Not shown
	self.jobStartDate.text              = [dateFormatter stringFromDate: self.selectedJob.start_date];
    self.jobEndDate.text                = [dateFormatter stringFromDate: self.selectedJob.end_date];
	self.jobResponsibilities.text       = self.selectedJob.summary;
	
	[self.jobCompanyUrlBtn setTitle: self.selectedJob.name 
						   forState: UIControlStateNormal];
    [self.jobCompanyUrlBtn setBackgroundImage: [UIImage imageNamed: @"companyBtn.png"]
                                     forState: UIControlStateNormal];
    
    [self sortTables];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewDidUnload];

	self.jobView					= nil;
	self.jobCompany					= nil;
	self.jobCompanyUrl				= nil;
	self.jobCompanyUrlBtn			= nil;
	self.jobCity                    = nil;
    self.jobState                   = nil;
	self.jobTitle					= nil;
	self.jobStartDate				= nil;
	self.jobEndDate					= nil;
	self.jobResponsibilities		= nil;
    
    self.tblView                    = nil;
	self.jobAccomplishmentsArray	= nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    // Remove the keyboard observer
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Apple recommends calling release on the ivar...
	[_jobView release];
	[_jobCompany release];
	[_jobCompanyUrl	release];
	[_jobCompanyUrlBtn release];
	[_jobCity release];
    [_jobState release];
	[_jobTitle release];
	[_jobStartDate release];
	[_jobEndDate release];
	[_jobResponsibilities release];
    
    [_tblView release];
    
	[_jobAccomplishmentsArray release];
	[_selectedJob release];
	
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
- (void)viewWillAppear:(BOOL)animated
{
    self.fetchedResultsController.delegate = self;
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    // Save any changes
    DLog();

    [self saveMoc: self.managedObjectContext];
}


//----------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//----------------------------------------------------------------------------------------------------------
- (void)sortTables
{
    // Sort accomplishments in the order they should appear in the table  
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey: KOSequenceNumberAttributeName
                                                                    ascending: YES] autorelease];
    NSArray *sortDescriptors        = [NSArray arrayWithObject: sortDescriptor];
    self.jobAccomplishmentsArray    = [NSMutableArray arrayWithArray: [self.selectedJob.accomplishment sortedArrayUsingDescriptors: sortDescriptors]];
}


//----------------------------------------------------------------------------------------------------------
- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    // Set table editing off
    [self.tblView               setEditing: NO];
    // ...hide the add button
    [addAccompBtn               setHidden: YES];
    // ...and hide/disable the fields
    [self.jobCompany            setHidden: YES];
    [self.jobCompanyUrl         setHidden: YES];
    [self.jobCompanyUrlBtn      setHidden: NO];
    [self.jobCity               setEnabled: NO];
    [self.jobState              setEnabled: NO];
    [self.jobTitle              setEnabled: NO];
    [self.jobStartDate          setEnabled: NO];
    [self.jobEndDate            setEnabled: NO];
    [self.jobResponsibilities   setEditable: NO];
    [self.datePicker            setHidden: YES];
}

#pragma mark - UI handlers

//----------------------------------------------------------------------------------------------------------
- (void)editAction
{
    DLog();
    
    // Enable table editing
    [self.tblView setEditing: YES];

    // Set up the cancel and save buttons
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    // ...show the add button
    [addAccompBtn               setHidden: NO];    
    // ...and show/enable the fields
    [self.jobCompany            setHidden: NO];
    [self.jobCompanyUrl         setHidden: NO];
    [self.jobCompanyUrlBtn      setHidden: YES];
    [self.jobCity               setEnabled: YES];
    [self.jobState              setEnabled: YES];
    [self.jobTitle              setEnabled: YES];
    [self.jobStartDate          setEnabled: YES];
    [self.jobEndDate            setEnabled: YES];
    [self.jobResponsibilities   setEditable: YES];
    [self.datePicker            setHidden: NO];
    
    // Start an undo group...it will either be commited in saveAction or undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveAction
{
    DLog();    
    // Reset the sequence_number of the Accomplishments items in case they were re-ordered during the edit
    [self resequenceTables];
    
    // Save the changes
    self.selectedJob.name           = self.jobCompany.text;
    self.selectedJob.uri            = self.jobCompanyUrl.text;
    self.selectedJob.end_date       = [dateFormatter dateFromString: self.jobEndDate.text];
    self.selectedJob.start_date     = [dateFormatter dateFromString: self.jobStartDate.text];
    self.selectedJob.city           = self.jobCity.text;
    self.selectedJob.state          = self.jobState.text;
    self.selectedJob.title          = self.jobTitle.text;
    self.selectedJob.summary        = self.jobResponsibilities.text;
    
    // TODO need to resequence the accomplishments
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if (![self saveMoc: [self.fetchedResultsController managedObjectContext]]) {
        // Serious Error!
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget: self];
    // ...and reset the UI defaults
    [self configureDefaultNavBar];
    [self resetView];
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)resequenceTables
{
    // The job array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the job's sequence_number attribute
    for (int i = 0; i < [self.jobAccomplishmentsArray count]; i++) {
        if ([[self.jobAccomplishmentsArray objectAtIndex: i] isDeleted]) {
            // no need to update the sequence number of deleted objects
        } else {
            [[self.jobAccomplishmentsArray objectAtIndex: i] setSequence_numberValue:i];
        }
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)cancelAction
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
    [self loadData];
    [self configureDefaultNavBar];
    [self resetView];
    [self sortTables];
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)doneAction
{
    DLog();
    CGRect screenRect   = [[UIScreen mainScreen] applicationFrame];    
    CGRect endFrame     = self.datePicker.frame;
    
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    // Start the slide down animation
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.datePicker.frame = endFrame;
                         [self.tblView setContentOffset: CGPointZero
                                               animated: NO];
                     }];
    
    // Reset the UI
    [KOExtensions dismissKeyboard];
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.navigationItem.leftBarButtonItem  = cancelBtn;
}


//----------------------------------------------------------------------------------------------------------
- (void)clearAction
{
    DLog();

    if (activeDateFld == k_startDateTextFld) {
        self.selectedJob.start_date = NULL;
        self.jobStartDate.text      = @"";
    } else {
        self.selectedJob.end_date   = NULL;
        self.jobEndDate.text        = @"";
    }
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)companyTapped:(id)sender
{
	if (self.selectedJob.uri == NULL ||
       [self.selectedJob.uri rangeOfString: @"://"].location == NSNotFound) {
		return;
	}
    
	// Open the Url in Safari
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.selectedJob.uri]];
}


//----------------------------------------------------------------------------------------------------------
- (IBAction)getEndDate:(id)sender
{
    if (activeDateFld == k_startDateTextFld) {
        // Update the database
        self.selectedJob.start_date = [self.datePicker date];
        // ...and the textField
        self.jobStartDate.text      = [dateFormatter stringFromDate: self.selectedJob.start_date];
    } else {
        // Update the database
        self.selectedJob.end_date   = [self.datePicker date];
        // ...and the textField
        self.jobEndDate.text        = [dateFormatter stringFromDate: self.selectedJob.end_date];
    }
}

#pragma mark - Keyboard handlers

//----------------------------------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // Get the size of the keyboard
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible    
    CGRect aRect       = self.view.frame;    
    aRect.size.height -= kbSize.height;
    DLog(@"point= %f, %f", _activeFld.frame.origin.x, _activeFld.frame.origin.y);
    if (!CGRectContainsPoint(aRect, _activeFld.frame.origin)) {
        // calculate the contentOffset for the scroller
        // ...to get the middle of the active field into the middle of the available view area
        CGPoint scrollPoint = CGPointMake(0.0, (_activeFld.frame.origin.y + (_activeFld.frame.size.height / 2)) - (aRect.size.height /  2));        
        [self.tblView setContentOffset: scrollPoint
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
    if (textField.tag == k_startDateTextFld) {
        // we are in the start date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [KOExtensions dismissKeyboard];
        if (!self.selectedJob.start_date) {
            self.selectedJob.start_date = [NSDate date];
        }
        [self.datePicker setDate: self.selectedJob.start_date];
        [self animateDatePickerOn];
        // remember which date field we're editing
        activeDateFld = k_startDateTextFld;
        return NO;
    } else if (textField.tag == k_endDateTextFld) {
        // we are in the end date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [KOExtensions dismissKeyboard];
        if (!self.selectedJob.end_date) {
            self.selectedJob.end_date = [NSDate date];
        }
        [self.datePicker setDate: self.selectedJob.end_date];
        [self animateDatePickerOn];
        // remember which date field we're editing
        activeDateFld = k_endDateTextFld;
        return NO;
    }
    
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
	UIResponder *nextResponder = [textField.superview viewWithTag: nextTag];
	
	if (nextResponder) {
        [nextResponder becomeFirstResponder];
	} else {
		[textField resignFirstResponder];       // Dismisses the keyboard
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
    CGRect screenRect = [self.view bounds];        
    CGSize pickerSize = [self.datePicker sizeThatFits: CGSizeZero];        
    CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height, pickerSize.width, pickerSize.height);        
    self.datePicker.frame = startRect;   
    
    // ... compute the end frame        
    CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
    
    // Start the slide up animation        
    [UIView animateWithDuration: 0.3
                     animations: ^ {
                         self.datePicker.frame = pickerRect;
                         [self.tblView setContentOffset: CGPointMake(0.0f, 80.f)];
                     }];
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = doneBtn;
    // ...and clear the cancel button
    self.navigationItem.leftBarButtonItem = clearBtn;
}


//----------------------------------------------------------------------------------------------------------
- (void)scrollToViewTextField:(UITextField *)textField
{
	float textFieldOriginY = textField.frame.origin.y;
	[self.tblView setContentOffset: CGPointMake(0.0f, textFieldOriginY - 20.0f) 
                          animated: YES];
}

#pragma mark - Accomplishment methods

//----------------------------------------------------------------------------------------------------------
- (void)addAccomplishment
{
    DLog();
    Accomplishments *accomp = (Accomplishments *)[NSEntityDescription insertNewObjectForEntityForName: KOAccomplishmentsEntity
                                                                               inManagedObjectContext: self.managedObjectContext];
    accomp.name         = self.accomplishmentName;
    accomp.summary      = self.accomplishmentName;
    accomp.created_date = [NSDate date];
    accomp.job          = self.selectedJob;
    
    NSError *error = nil;
    if (![self.managedObjectContext save: &error]) {
        ELog(error, @"Failed to save");
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    [self.jobAccomplishmentsArray insertObject: accomp 
                                       atIndex: 0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: 0 
                                                inSection: 0];
    
    [self.tblView insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                        withRowAnimation: UITableViewRowAnimationFade];
    [self.tblView scrollToRowAtIndexPath: indexPath 
                        atScrollPosition: UITableViewScrollPositionTop 
                                animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)getAccomplishmentName
{
    UIAlertView *accompSummaryAlert = [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Enter Accomplishment", @"Enter Accomplishment")
                                                                  message: nil
                                                                 delegate: self 
                                                        cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") 
                                                        otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil] autorelease];
    accompSummaryAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [accompSummaryAlert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // OK
        self.accomplishmentName = [[alertView textFieldAtIndex: 0] text];
        [self addAccomplishment];
    } else {
        // User cancelled
        [self configureDefaultNavBar];
    }
}

#pragma mark - Table view data source


//----------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


//----------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section 
{	
    return [self.jobAccomplishmentsArray count];
}


//----------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: KOCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                       reuseIdentifier: KOCellID] autorelease];
    }
    
	// Configure the cell.
    cell = [self configureCell: cell 
                   atIndexPath: indexPath];
    
    return cell;
}


//----------------------------------------------------------------------------------------------------------
- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *) indexPath
{
    if ([[self.jobAccomplishmentsArray objectAtIndex: indexPath.row] name]) {
        cell.textLabel.text = [[self.jobAccomplishmentsArray objectAtIndex: indexPath.row] name];
    } else {
        cell.textLabel.text = [[self.jobAccomplishmentsArray objectAtIndex: indexPath.row] summary];
    }
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegates

//----------------------------------------------------------------------------------------------------------
-  (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section 
{
    DLog();
	UILabel *sectionLabel = [[[UILabel alloc] initWithFrame: CGRectMake(0, 0, 260.0f, KOAddButtonHeight)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName: @"Helvetica-Bold" 
                                          size: 18.0]];
	[sectionLabel setTextColor: [UIColor whiteColor]];
	[sectionLabel setBackgroundColor: [UIColor clearColor]];
    
    sectionLabel.text = NSLocalizedString(@"Accomplishments", @"Accomplishments");
    UIView *sectionView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 280.0f, KOAddButtonHeight)] autorelease];
    [sectionView addSubview: sectionLabel];
    [sectionView addSubview: addAccompBtn];
    
    return sectionView;
}


//----------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}


//----------------------------------------------------------------------------------------------------------
-  (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object at the given index path.
        NSManagedObject *accompToDelete = [self.jobAccomplishmentsArray objectAtIndex: indexPath.row];
        [self.managedObjectContext deleteObject: accompToDelete];
        [self.jobAccomplishmentsArray removeObjectAtIndex: indexPath.row];
        // ...delete the object from the tableView
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] 
                         withRowAnimation: UITableViewRowAnimationFade];
        // ...and reload the table
        [tableView reloadData];
    }   
}

//----------------------------------------------------------------------------------------------------------
-  (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toIndexPath:(NSIndexPath *)toIndexPath
{
    // Get the from and to Rows of the table
    NSUInteger fromRow  = [fromIndexPath row];
    NSUInteger toRow    = [toIndexPath row];
    
    // Get the Accomplishment at the fromRow 
    Jobs *movedAccomp = [[self.jobAccomplishmentsArray objectAtIndex: fromRow] retain];
    // ...remove it from that "order"
    [self.jobAccomplishmentsArray removeObjectAtIndex: fromRow];
    // ...and insert it where the user wants
    [self.jobAccomplishmentsArray insertObject: movedAccomp
                                       atIndex: toRow];
    [movedAccomp release];
}


//----------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DLog();
    AccomplishmentViewController *accomplishmentVC = [[AccomplishmentViewController alloc] initWithNibName: KOAccomplishmentsViewController
                                                                                                    bundle: nil];
    accomplishmentVC.selectedAccomplishment     = [self.jobAccomplishmentsArray objectAtIndex: indexPath.row];
    accomplishmentVC.managedObjectContext       = self.managedObjectContext;
    accomplishmentVC.fetchedResultsController   = self.fetchedResultsController;
    accomplishmentVC.title                      = accomplishmentVC.selectedAccomplishment.name;
    
    [self.navigationController pushViewController: accomplishmentVC 
                                         animated: YES];
    [accomplishmentVC release];

	[tableView deselectRowAtIndexPath: indexPath
							 animated: YES];
}

#pragma mark - Fetched Results Controller delegate methods

//----------------------------------------------------------------------------------------------------------
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblView beginUpdates];
}


//----------------------------------------------------------------------------------------------------------
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    
    UITableView *tableView = self.tblView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject: newIndexPath] 
                             withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] 
                             withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell: [tableView cellForRowAtIndexPath: indexPath] 
                    atIndexPath: indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] 
                             withRowAnimation: UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections: [NSIndexSet indexSetWithIndex: newIndexPath.section] 
                     withRowAnimation: UITableViewRowAnimationFade];
            break;
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type 
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tblView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex] 
                        withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex] 
                        withRowAnimation: UITableViewRowAnimationFade];
            break;
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblView endUpdates];
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
    
    [self.tblView reloadData];
    
//    if (note) {
//        // The notification is on an async thread, so block while the UI updates
//        [self.managedObjectContext performBlock: ^{
//            [self loadData];
//            [self.tblView reloadData];
//        }];
//    }
}

//----------------------------------------------------------------------------------------------------------
- (BOOL)saveMoc:(NSManagedObjectContext *)moc
{
    BOOL result = YES;
    NSError *error = nil;
    
    if (moc) {
        if ([moc hasChanges]) {
            if (![moc save:&error]) {
                ELog(error, @"Failed to save");
                result = NO;
            }
        }
    } else {
        ALog(@"managedObjectContext is null");
        result = NO;
    }
    
    return result;
}
#pragma mark - UIScrollView delegate methods

//----------------------------------------------------------------------------------------------------------
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.jobView;
}


//----------------------------------------------------------------------------------------------------------
- (void)resetView
{
    DLog();
    [self.tblView setContentOffset: CGPointZero
                          animated: YES];
    [KOExtensions dismissKeyboard];
}

@end
