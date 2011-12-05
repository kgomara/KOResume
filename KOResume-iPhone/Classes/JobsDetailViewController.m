//
//  JobsDetailViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "JobsDetailViewController.h"
#import "KOExtensions.h"
#import "Accomplishments.h"
#import "AccomplishmentViewController.h"

#define k_addBtnWidth       29.0f
#define k_addBtnHeight      29.0f
#define k_startDateTextFld  6
#define k_endDateTextFld    7

@interface JobsDetailViewController ()
{
    
@private
    NSMutableArray*     _jobAccomplishmentsArray;
    NSString*           _accomplishmentSummary;

    // These ivars are singletons and do not have properties
    UIBarButtonItem* backBtn;
    UIBarButtonItem* doneBtn;
    UIBarButtonItem* editBtn;
    UIBarButtonItem* saveBtn;
    UIBarButtonItem* cancelBtn;
    NSDateFormatter* dateFormatter;
    
    UIButton*        addAccompBtn;
    int              activeDateFld;
}

@property (nonatomic, strong) NSMutableArray*   jobAccomplishmentsArray;
@property (nonatomic, strong) NSString*         accomplishmentSummary;

- (void)sortTables;
- (void)configureDefaultNavBar;
- (void)scrollToViewTextField:(UITextField *)textField;
- (void)resetView;
- (void)animateDatePickerOn;
- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *)indexPath;
- (void)resequenceTables;

@end

@implementation JobsDetailViewController

@synthesize	jobView;
@synthesize	jobCompany;
@synthesize jobCompanyUrl;
@synthesize	jobCompanyUrlBtn;
@synthesize	jobCity;
@synthesize jobState;
@synthesize	jobTitle;
@synthesize	jobStartDate;
@synthesize	jobEndDate;
@synthesize	jobResponsibilities;

@synthesize tblView                     = _tblView;
@synthesize datePicker                  = _datePicker;

@synthesize	selectedJob                 = _selectedJob;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

@synthesize jobAccomplishmentsArray     = _jobAccomplishmentsArray;
@synthesize accomplishmentSummary       = _accomplishmentSummary;

#pragma mark Application lifecycle methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.view.backgroundColor		= [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	self.jobView.image              = [[UIImage imageNamed:@"contentpane_details.png"] stretchableImageWithLeftCapWidth:20 
                                                                                                           topCapHeight:20];
    self.fetchedResultsController.delegate = self;
    
    activeDateFld                   = 0;

	// Get the data and stuff it into the fields
    self.jobCompany.text                = self.selectedJob.name;
	self.jobCompanyUrl.text             = self.selectedJob.uri;
	self.jobCity.text                   = self.selectedJob.city;
    self.jobState.text                  = self.selectedJob.state;
	self.jobTitle.text                  = self.selectedJob.title;
    dateFormatter                       = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];	//Not shown
	self.jobStartDate.text              = [dateFormatter stringFromDate:self.selectedJob.start_date];
    self.jobEndDate.text                = [dateFormatter stringFromDate:self.selectedJob.end_date];
	self.jobResponsibilities.text       = self.selectedJob.summary;
	
    // Set up button items
	[self.jobCompanyUrlBtn setTitle:self.selectedJob.name 
						   forState:UIControlStateNormal];
    [self.jobCompanyUrlBtn setBackgroundImage:[UIImage imageNamed:@"companyBtn.png"]
                                     forState:UIControlStateNormal];
    addAccompBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [addAccompBtn setBackgroundImage:[UIImage imageNamed:@"addButton.png"] 
                            forState:UIControlStateNormal];
    [addAccompBtn setFrame:CGRectMake(280, 0, k_addBtnWidth, k_addBtnHeight)];
    [addAccompBtn addTarget:self 
                     action:@selector(getAccomplishmentSummary) 
           forControlEvents:UIControlEventTouchUpInside];

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

		// Loop through the accomplishment adding accomplishment items to the view
        NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequence_number"
                                                                        ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.jobAccomplishmentsArray = [NSMutableArray arrayWithArray:[self.selectedJob.accomplishment sortedArrayUsingDescriptors:sortDescriptors]];
	
    [self sortTables];
}

- (void)sortTables
{
    // Sort accomplishments in the order they should appear in the table  
    NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequence_number"
                                                                    ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.jobAccomplishmentsArray = [NSMutableArray arrayWithArray:[self.selectedJob.accomplishment sortedArrayUsingDescriptors:sortDescriptors]];
}


- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;
    
    // Set table editing off
    [self.tblView setEditing:NO];
    // ...hide the add button
    [addAccompBtn setHidden:YES];
    // ...and hide/disable the fields
    [self.jobCompany setHidden:YES];
    [self.jobCompanyUrl setHidden:YES];
    [self.jobCompanyUrlBtn setHidden:NO];
    [self.jobCity setEnabled:NO];
    [self.jobState setEnabled:NO];
    [self.jobTitle setEnabled:NO];
    [self.jobStartDate setEnabled:NO];
    [self.jobEndDate setEnabled:NO];
    [self.jobResponsibilities setEditable:NO];
    [self.datePicker setHidden:YES];
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
    
    // Enable table editing
    [self.tblView setEditing:YES];

    // Set up the cancel and save buttons
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    // ...show the add button
    [addAccompBtn setHidden:NO];    
    // ...and show/enable the fields
    [self.jobCompany setHidden:NO];
    [self.jobCompanyUrl setHidden:NO];
    [self.jobCompanyUrlBtn setHidden:YES];
    [self.jobCity setEnabled:YES];
    [self.jobState setEnabled:YES];
    [self.jobTitle setEnabled:YES];
    [self.jobStartDate setEnabled:YES];
    [self.jobEndDate setEnabled:YES];
    [self.jobResponsibilities setEditable:YES];
    [self.datePicker setHidden:NO];
    
    // Start an undo group...it will either be commited in saveAction or undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}

- (void)saveAction
{
    DLog();    
    // Reset the sequence_number of the Accomplishments items in case they were re-ordered during the edit
    [self resequenceTables];
    
    // Save the changes
    self.selectedJob.name           = self.jobCompany.text;
    self.selectedJob.uri            = self.jobCompanyUrl.text;
    self.selectedJob.end_date       = [dateFormatter dateFromString:self.jobEndDate.text];
    self.selectedJob.start_date     = [dateFormatter dateFromString:self.jobStartDate.text];
    self.selectedJob.city           = self.jobCity.text;
    self.selectedJob.state          = self.jobState.text;
    self.selectedJob.title          = self.jobTitle.text;
    self.selectedJob.summary        = self.jobResponsibilities.text;
    
    // TODO need to resequence the accomplishments
    
    [[self.managedObjectContext undoManager] endUndoGrouping];
    NSError* error = nil;
    NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error]) {
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
    [self.tblView reloadData];
}

- (void)resequenceTables
{
    // The job array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the job's sequence_number attribute
    for (int i = 0; i < [self.jobAccomplishmentsArray count]; i++) {
        if ([[self.jobAccomplishmentsArray objectAtIndex:i] isDeleted]) {
            // skip it
        } else {
            [[self.jobAccomplishmentsArray objectAtIndex:i] setSequence_numberValue:i];
        }
    }
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
    [self sortTables];
    [self.tblView reloadData];
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
                         [self.tblView setContentOffset:CGPointZero
                                               animated:NO];
                     }];
    
    // Reset the UI
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.navigationItem.leftBarButtonItem  = cancelBtn;
}

- (void)addAccomplishment
{
    DLog();
    Accomplishments *accomp = (Accomplishments *)[NSEntityDescription insertNewObjectForEntityForName:@"Accomplishments"
                                                                               inManagedObjectContext:self.managedObjectContext];
    accomp.summary      = self.accomplishmentSummary;
    accomp.created_date = [NSDate date];
    accomp.job          = self.selectedJob;
    
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        ELog(error, @"Failed to save");
        abort();
    }
    
    [self.jobAccomplishmentsArray insertObject:accomp 
                                       atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 
                                                inSection:0];
    
    [self.tblView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                        withRowAnimation:UITableViewRowAnimationFade];
    [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 
                                                            inSection:0] 
                        atScrollPosition:UITableViewScrollPositionTop 
                                animated:YES];
}

- (void)getAccomplishmentSummary 
{
    UIAlertView* accompSummaryAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Accomplishment", @"Enter Accomplishment") 
                                                                  message:nil
                                                                 delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
                                                        otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil] autorelease];
    accompSummaryAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [accompSummaryAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // OK
        self.accomplishmentSummary = [[alertView textFieldAtIndex:0] text];
        [self addAccomplishment];
    } else {
        // cancel
        [self configureDefaultNavBar];
    }
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
    return [self.jobAccomplishmentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
    cell = [self configureCell:cell 
                   atIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *) indexPath
{
    cell.textLabel.text = [[self.jobAccomplishmentsArray objectAtIndex:indexPath.row] summary];
    cell.accessoryType  = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    DLog();
	UILabel *sectionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260.0f, k_addBtnHeight)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
    
    sectionLabel.text = NSLocalizedString(@"Accomplishments", @"Accomplishments");
    UIView* sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, k_addBtnHeight)] autorelease];
    [sectionView addSubview:sectionLabel];
    [sectionView addSubview:addAccompBtn];
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object at the given index path.
        NSManagedObject *accompToDelete = [self.jobAccomplishmentsArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:accompToDelete];
        [self.jobAccomplishmentsArray removeObjectAtIndex:indexPath.row];
        // ...delete the object from the tableView
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        // ...and reload the table
        [tableView reloadData];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Get the from and to Rows of the table
    NSUInteger fromRow  = [fromIndexPath row];
    NSUInteger toRow    = [toIndexPath row];
    
        // Get the Accomplishment at the fromRow 
        Jobs* movedAccomp = [[self.jobAccomplishmentsArray objectAtIndex:fromRow] retain];
        // ...remove it from that "order"
        [self.jobAccomplishmentsArray removeObjectAtIndex:fromRow];
        // ...and insert it where the user wants
        [self.jobAccomplishmentsArray insertObject:movedAccomp
                                           atIndex:toRow];
        [movedAccomp release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DLog();
    AccomplishmentViewController* accomplishmentViewController = [[AccomplishmentViewController alloc] initWithNibName:@"AccomplishmentViewController" 
                                                                                                                bundle:nil];
    accomplishmentViewController.selectedAccomplishment = [self.jobAccomplishmentsArray objectAtIndex:indexPath.row];
    accomplishmentViewController.managedObjectContext      = self.managedObjectContext;
    accomplishmentViewController.fetchedResultsController  = self.fetchedResultsController;
    accomplishmentViewController.title = accomplishmentViewController.selectedAccomplishment.name;
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:accomplishmentViewController 
                                         animated:YES];
    [accomplishmentViewController release];

	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
}

#pragma mark - Fetched Results Controller delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tblView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblView endUpdates];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
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
	self.selectedJob				= nil;
	
    [super dealloc];
}

#pragma mark User generated events

- (IBAction)companyTapped:(id)sender 
{
	if (self.selectedJob.uri == NULL || [self.selectedJob.uri rangeOfString:@"://"].location == NSNotFound) {
		return;
	}

	// Open the Url in Safari
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.selectedJob.uri]];
}

#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	return self.jobView;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == k_startDateTextFld) {
        // we are in the start date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [self.datePicker setDate:self.selectedJob.start_date];
        [self animateDatePickerOn];
        // remember which date field we're editing
        activeDateFld = k_startDateTextFld;
        return NO;
    }
    if (textField.tag == k_endDateTextFld) {
        // we are in the end date field, dismiss the keyboard and show the data picker
        [textField resignFirstResponder];
        [self.datePicker setDate:self.selectedJob.end_date];
        [self animateDatePickerOn];
        // remember which date field we're editing
        activeDateFld = k_endDateTextFld;
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
                         [self.tblView setContentOffset:CGPointMake(0.0f, 100.0f)];
                     }];
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = doneBtn;
    // ...and clear the cancel button
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)scrollToViewTextField:(UITextField *)textField 
{
	float textFieldOriginY = textField.frame.origin.y;
	[self.tblView setContentOffset:CGPointMake(0.0f, textFieldOriginY - 20.0f) 
                          animated:YES];
}

- (void)resetView
{
    DLog();
    [self.tblView setContentOffset:CGPointZero
                          animated:YES];
}

- (IBAction)getEndDate:(id)sender
{
    if (activeDateFld == k_startDateTextFld) {
        // Update the database
        self.selectedJob.start_date = [self.datePicker date];
        // ...and the textField
        self.jobStartDate.text      = [dateFormatter stringFromDate:self.selectedJob.start_date];

    } else {
        // Update the database
        self.selectedJob.end_date   = [self.datePicker date];
        // ...and the textField
        self.jobEndDate.text        = [dateFormatter stringFromDate:self.selectedJob.end_date];
    }
}

@end
