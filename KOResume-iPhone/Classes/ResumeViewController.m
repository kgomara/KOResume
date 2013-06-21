//
//  ResumeViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "ResumeViewController.h"
#import "JobsDetailViewController.h"
#import "SummaryViewController.h"
#import "EducationViewController.h"
#import "Jobs.h"
#import "Accomplishments.h"
#import "Education.h"
#import "KOExtensions.h"

#define k_SummarySection	0
#define	k_JobsSection       1
#define k_EducationSection	2

@interface ResumeViewController ()
{
@private
    NSMutableArray      *_jobArray;
    NSMutableArray      *_educationArray;
    NSString            *_jobName;
    
    UIBarButtonItem     *editBtn;
    UIBarButtonItem     *cancelBtn;
    UIBarButtonItem     *saveBtn;
    UIBarButtonItem     *backBtn;
    UIButton            *addJobBtn;
    UIButton            *addEducationBtn;
}

@property (nonatomic, strong) NSMutableArray    *jobArray;
@property (nonatomic, strong) NSMutableArray    *educationArray;
@property (nonatomic, strong) NSString          *jobName;

- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *)indexPath;
- (void)configureDefaultNavBar;
- (void)sortTables;
- (void)resequenceTables;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

@end

@implementation ResumeViewController

@synthesize tblView                         = _tblView;
@synthesize selectedResume                  = _selectedResume;

@synthesize managedObjectContext            = __managedObjectContext;
@synthesize fetchedResultsController        = __fetchedResultsController;

@synthesize jobArray                        = _jobArray;
@synthesize educationArray                  = _educationArray;
@synthesize jobName                         = _jobName;

#pragma mark - View lifecycle methods

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    DLog(@"job count %d", [self.selectedResume.job count]);

	self.navigationItem.title = NSLocalizedString(@"Resume", @"Resume");	
	self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"background.png"]];
    
    // Set up button items
    backBtn     = self.navigationItem.leftBarButtonItem;    // keep track of where "back" is
    editBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                                target: self 
                                                                action: @selector(editAction)];
    saveBtn     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                                target: self
                                                                action: @selector(saveAction)];
    cancelBtn   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                target: self
                                                                action: @selector(cancelAction)];
    addJobBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [addJobBtn setBackgroundImage: [UIImage imageNamed:@"addButton.png"] 
                         forState: UIControlStateNormal];
    [addJobBtn setFrame:CGRectMake(280, 0, KOAddButtonWidth, KOAddButtonHeight)];
    [addJobBtn addTarget: self 
                  action: @selector(getJobName) 
        forControlEvents: UIControlEventTouchUpInside];
    
    addEducationBtn = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
    [addEducationBtn setBackgroundImage: [UIImage imageNamed:@"addButton.png"] 
                               forState: UIControlStateNormal];
    [addEducationBtn setFrame: CGRectMake(280, 0, KOAddButtonWidth, KOAddButtonHeight)];
    [addEducationBtn addTarget: self 
                        action: @selector(getEducationName) 
              forControlEvents: UIControlEventTouchUpInside];
    
    // ...and the NavBar
    [self configureDefaultNavBar];
    
    self.fetchedResultsController.delegate = self;
	
    [self sortTables];
    
    // Set an observer for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadFetchedResults:) 
                                                 name: NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object: [self.managedObjectContext persistentStoreCoordinator]];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    
	self.tblView        = nil;
    self.jobArray       = nil;
    self.educationArray = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_tblView release];
    [_selectedResume release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    [_jobArray release];
    [_educationArray release];
    [addJobBtn release];
    [addEducationBtn release];
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
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
    // Sort jobs in the order they should appear in the table  
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey: KOSequenceNumberAttributeName
                                                                    ascending: YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sortDescriptor];
    self.jobArray = [NSMutableArray arrayWithArray: [self.selectedResume.job sortedArrayUsingDescriptors: sortDescriptors]];
    // ...sort the Education and Certification array
    self.educationArray = [NSMutableArray arrayWithArray: [self.selectedResume.education sortedArrayUsingDescriptors: sortDescriptors]];
}


//----------------------------------------------------------------------------------------------------------
- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;

    // Set table editing off
    [self.tblView       setEditing: NO];
    
    // ...and hide the add buttons
    [addJobBtn          setHidden: YES];
    [addEducationBtn    setHidden: YES];
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
    
    // ...and show the add buttons
    [addJobBtn          setHidden: NO];
    [addEducationBtn    setHidden: NO];
    
    // Start an undo group...it will either be commited in saveAction or undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveAction
{
    DLog();
    // Reset the sequence_number of the Job and Education items in case they were re-ordered during the edit
    [self resequenceTables];
    
    // Save the changes
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
    [self.tblView reloadData];
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
    [self configureDefaultNavBar];
    [self sortTables];
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)resequenceTables
{
    // The job array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the job's sequence_number attribute
    for (int i = 0; i < [self.jobArray count]; i++) {
        if ([[self.jobArray objectAtIndex: i] isDeleted]) {
            // no need to update the sequence number of deleted objects
        } else {
            [[self.jobArray objectAtIndex:i] setSequence_numberValue: i];
        }
    }
    // ...same for the education array
    for (int i = 0; i < [self.educationArray count]; i++) {
        if ([[self.educationArray objectAtIndex: i] isDeleted]) {
            // no need to update the sequence number of deleted objects
        } else {
            [[self.educationArray objectAtIndex:i] setSequence_numberValue: i];
        }
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)addJob
{
    DLog();
    Jobs *job = (Jobs *)[NSEntityDescription insertNewObjectForEntityForName: KOJobsEntity
                                                      inManagedObjectContext: self.managedObjectContext];
    job.name            = self.jobName;
    job.created_date    = [NSDate date];
    job.resume          = self.selectedResume;
        
    NSError *error = nil;
    if (![self.managedObjectContext save: &error]) {
        ELog(error, @"Failed to save");
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    [self.jobArray insertObject: job 
                        atIndex: 0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: 0 
                                                inSection: k_JobsSection];
    
    [self.tblView insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                        withRowAnimation: UITableViewRowAnimationFade];
    [self.tblView scrollToRowAtIndexPath: indexPath 
                        atScrollPosition: UITableViewScrollPositionTop 
                                animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)getJobName
{
    UIAlertView *jobNameAlert = [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Enter Job Name", @"Enter Job Name")
                                                            message: nil
                                                           delegate: self 
                                                  cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") 
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil] autorelease];
    jobNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    jobNameAlert.tag            = k_JobsSection;
    
    [jobNameAlert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)addEducation
{
    DLog();
    Education *education = (Education *)[NSEntityDescription insertNewObjectForEntityForName: KOEducationEntity
                                                                      inManagedObjectContext: self.managedObjectContext];
    education.name            = self.jobName;
    education.created_date    = [NSDate date];
    education.resume          = self.selectedResume;
    
    NSError *error = nil;
    if (![self.managedObjectContext save: &error]) {
        ELog(error, @"Failed to save");
        NSString* msg = NSLocalizedString(@"Failed to save data.", @"Failed to save data.");
        [KOExtensions showErrorWithMessage: msg];
    }
    
    [self.educationArray insertObject: education 
                              atIndex: 0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: 0 
                                                inSection: k_EducationSection];
    
    [self.tblView insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                        withRowAnimation: UITableViewRowAnimationFade];
    [self.tblView scrollToRowAtIndexPath: indexPath 
                        atScrollPosition: UITableViewScrollPositionTop 
                                animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)getEducationName
{
    UIAlertView *educationNameAlert = [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Enter Institution Name", @"Enter Institution Name")
                                                                  message: nil
                                                                 delegate: self 
                                                        cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") 
                                                        otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil] autorelease];
    educationNameAlert.alertViewStyle   = UIAlertViewStylePlainTextInput;
    educationNameAlert.tag              = k_EducationSection;
    
    [educationNameAlert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // OK button was tapped
        self.jobName = [[alertView textFieldAtIndex: 0] text];
        if (alertView.tag == k_JobsSection) {
            [self addJob];
        } else {
            [self addEducation];
        }
    } else {
        // User cancelled
        [self configureDefaultNavBar];
    }
}

#pragma mark - Table view data source


//----------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


//----------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection;
    
	switch (section) {
		case k_SummarySection:
			rowsInSection = 1;
			break;
		case k_JobsSection:
			rowsInSection = [self.jobArray count];
			break;
		case k_EducationSection:
			rowsInSection = [self.educationArray count];
			break;
		default:
			ALog(@"Unexpected section = %d", section);
			rowsInSection = 0;
			break;
	}
    
    return rowsInSection;
}


//----------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: KOCellID];
    if (!cell) {
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
    switch (indexPath.section) {
		case k_SummarySection:
			cell.textLabel.text = self.selectedResume.name;          // There is only 1 row in this section
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case k_JobsSection:
			cell.textLabel.text = [[self.jobArray objectAtIndex: indexPath.row] name];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case k_EducationSection:
			cell.textLabel.text = [[self.educationArray objectAtIndex: indexPath.row] name];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
			ALog(@"Unexpected section = %d", indexPath.section);
			break;
	}
    
    return cell;

}

#pragma mark - Table view delegates


//----------------------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel *sectionLabel = [[[UILabel alloc] initWithFrame: CGRectMake(0, 0, 260.0f, KOAddButtonHeight)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName: @"Helvetica-Bold" 
                                          size: 18.0]];
	[sectionLabel setTextColor: [UIColor whiteColor]];
	[sectionLabel setBackgroundColor: [UIColor clearColor]];

	switch (section) {
		case k_SummarySection: {
			sectionLabel.text = NSLocalizedString(@"Summary", @"Summary");
			return sectionLabel;
		}
		case k_JobsSection: {
			sectionLabel.text = NSLocalizedString(@"Professional History", @"Professional History");
            UIView *sectionView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 280.0f, KOAddButtonHeight)] autorelease];
            [sectionView addSubview: sectionLabel];
            [sectionView addSubview: addJobBtn];
			return sectionView;
		}
		case k_EducationSection: {
			sectionLabel.text = NSLocalizedString(@"Education & Certifications", @"Education & Certifications");
            UIView *sectionView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 280.0f, KOAddButtonHeight)] autorelease];
            [sectionView addSubview: sectionLabel];
            [sectionView addSubview: addEducationBtn];
			return sectionView;
		}
		default:
			ALog(@"Unexpected section = %d", section);
			return nil;
	}
}


//----------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{	
	return 44;
}


//----------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object at the given index path.
        if (indexPath.section == k_JobsSection) {
            NSManagedObject *jobToDelete = [self.jobArray objectAtIndex: indexPath.row];
            [self.managedObjectContext deleteObject: jobToDelete];
            [self.jobArray removeObjectAtIndex: indexPath.row];
        } else {
            NSManagedObject *jobToDelete = [self.educationArray objectAtIndex: indexPath.row];
            [self.managedObjectContext deleteObject: jobToDelete];
            [self.educationArray removeObjectAtIndex: indexPath.row];
        }
        // ...delete the object from the tableView
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] 
                         withRowAnimation: UITableViewRowAnimationFade];
        // ...and reload the table
        [tableView reloadData];
    }   
}


//----------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
       toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section != toIndexPath.section) {
        // Cannot move between sections
        [KOExtensions showAlertWithMessageAndType: NSLocalizedString(@"Sorry, move not allowed", @"Sorry, move not allowed")
                                        alertType: UIAlertViewStyleDefault];
        [self.tblView reloadData];
        return;
    }
    
    // Get the from and to Rows of the table
    NSUInteger fromRow  = [fromIndexPath row];
    NSUInteger toRow    = [toIndexPath row];
    
    if (toIndexPath.section == k_JobsSection) {
        // Get the Job at the fromRow 
        Jobs *movedJob = [[self.jobArray objectAtIndex: fromRow] retain];
        // ...remove it from that "order"
        [self.jobArray removeObjectAtIndex: fromRow];
        // ...and insert it where the user wants
        [self.jobArray insertObject: movedJob
                            atIndex: toRow];
        [movedJob release];
    } else {
        // Get the Education at the fromRow 
        Education *movedEducation = [[self.educationArray objectAtIndex: fromRow] retain];
        // ...remove it from that "order"
        [self.educationArray removeObjectAtIndex: fromRow];
        // ...and insert it where the user wants
        [self.educationArray insertObject: movedEducation
                                  atIndex: toRow];
        [movedEducation release];
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
		case k_SummarySection: {
            // There is only 1 row in this section, so ignore row.
			SummaryViewController *summaryVC = [[SummaryViewController alloc] initWithNibName: KOSummaryViewController
                                                                                       bundle: nil];
            summaryVC.selectedResume            = self.selectedResume;
            summaryVC.managedObjectContext      = self.managedObjectContext;
            summaryVC.fetchedResultsController  = self.fetchedResultsController;
			summaryVC.title                     = NSLocalizedString(@"Summary", @"Summary");
			
			[self.navigationController pushViewController: summaryVC 
                                                 animated: YES];
			[summaryVC release];
			break;
		}
		case k_JobsSection: {
			JobsDetailViewController *detailVC = [[JobsDetailViewController alloc] initWithNibName: KOJobsDetailViewController
                                                                                            bundle: nil];
			// Pass the selected object to the new view controller.
			detailVC.title                      = NSLocalizedString(@"Jobs", @"Jobs");
			detailVC.selectedJob                = [self.jobArray objectAtIndex: indexPath.row];
            detailVC.managedObjectContext       = self.managedObjectContext;
            detailVC.fetchedResultsController   = self.fetchedResultsController;
			
			[self.navigationController pushViewController: detailVC 
                                                 animated: YES];
			[detailVC release];
			break;
		}
		case k_EducationSection: {
			EducationViewController *educationVC = [[EducationViewController alloc] initWithNibName: KOEducationViewController
                                                                                             bundle: nil];
			// Pass the selected object to the new view controller.
            educationVC.selectedEducation           = [self.educationArray objectAtIndex: indexPath.row];
            educationVC.managedObjectContext        = self.managedObjectContext;
            educationVC.fetchedResultsController    = self.fetchedResultsController;
			educationVC.title                       = NSLocalizedString(@"Education", @"Education");
			
			[self.navigationController pushViewController: educationVC 
                                                 animated: YES];
			[educationVC release];
			break;
		}
		default:
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
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
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] 
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
    if (![[self fetchedResultsController] performFetch:&error]) {
        ELog(error, @"Fetch failed!");
        abort();
    }             
    
    [self sortTables];
    [self.tblView reloadData];

//    if (note) {
//        [self sortTables];
//        [self.tblView reloadData];
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

@end

