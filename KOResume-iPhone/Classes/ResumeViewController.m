//
//  ResumeViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "ResumeViewController.h"
#import "JobsDetailViewController.h"
#import "SummaryViewController.h"
#import "EducationViewController.h"
#import "Jobs.h"
#import "Accomplishments.h"
#import "Education.h"
#import "KOExtensions.h"

#define k_SummaryInfoTbl	0
#define	k_JobsInfoTbl       1
#define k_EducationInfoTbl	2

@interface ResumeViewController ()
{
@private
    NSMutableArray*     _jobArray;
    NSMutableArray*     _educationArray;
    
    NSString*           _jobName;
    
    UIBarButtonItem*    editBtn;
    UIBarButtonItem*    cancelBtn;
    UIBarButtonItem*    saveBtn;
    UIBarButtonItem*    backBtn;
}

@property (nonatomic, strong) NSMutableArray*     jobArray;
@property (nonatomic, strong) NSMutableArray*     educationArray;
@property (nonatomic, strong) NSString*           jobName;

- (Jobs *)createJob:(NSDictionary *)jobDict;
- (Accomplishments *)createAccomplishment:(NSString *)accomp;
- (Education *)createEducation:(NSString *)eduName 
                    dateEarned:(NSString *)dateEarned 
                        inCity:(NSString *)inCity 
                       inState:(NSString *)inState 
                 atInstitution:(NSString *)atInstitution 
                  withSequence:(int)withSequence;
- (UITableViewCell *)configureCell:(UITableViewCell *)cell
                       atIndexPath:(NSIndexPath *)indexPath;
- (void)configureDefaultNavBar;
- (void)sortTables;

@end

@implementation ResumeViewController

@synthesize tblView                         = _tblView;
@synthesize mgmtJobsDict                    = _mgmtJobsDict;
@synthesize selectedResume                  = _selectedResume;

@synthesize managedObjectContext            = __managedObjectContext;
@synthesize fetchedResultsController        = __fetchedResultsController;

@synthesize jobArray                        = _jobArray;
@synthesize educationArray                  = _educationArray;
@synthesize jobName                         = _jobName;

#pragma mark -
#pragma mark View lifecycle methods


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    DLog(@"job count %d", [self.selectedResume.job count]);

	self.navigationItem.title = NSLocalizedString(@"Resume", 
                                                  @"Resume");	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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
    // ...and the NavBar
    [self configureDefaultNavBar];
    
    self.fetchedResultsController.delegate = self;
	
    if ([self.selectedResume.job count] == 0) {
        // Load the test database
        // get the jobs.plist dictionary into mgmtJobsDict
        NSBundle* bundle    = [NSBundle mainBundle];
        NSString* plistPath = [bundle pathForResource:@"jobs" ofType:@"plist"];
        NSDictionary* dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.mgmtJobsDict = dictionary;
        [dictionary release];
        for (NSString* key in self.mgmtJobsDict) {
            NSDictionary* jobDict = [self.mgmtJobsDict objectForKey:key];
            [self.selectedResume addJobObject:[self createJob:jobDict]];
        }
    }
    if ([self.selectedResume.education count] == 0) {
        [self.selectedResume addEducationObject:[self createEducation:@"B.A. Business Administration" 
                                                           dateEarned:@"Jun 1972" 
                                                               inCity:@"Columbia" 
                                                              inState:@"MO" 
                                                        atInstitution:@"University of Missouri" 
                                                         withSequence:1]];
        [self.selectedResume addEducationObject:[self createEducation:@"MBA" 
                                                           dateEarned:@"Jun 1978" 
                                                               inCity:@"San Diego" 
                                                              inState:@"CA" 
                                                        atInstitution:@"San Diego State University" 
                                                         withSequence:2]];
        [self.selectedResume addEducationObject:[self createEducation:@"Certified Scrum Master" 
                                                           dateEarned:@"Jan 2009" 
                                                               inCity:@"San Francisco" 
                                                              inState:@"CA" 
                                                        atInstitution:@"Scrum Alliance" 
                                                         withSequence:3]];
        [self.selectedResume addEducationObject:[self createEducation:@"Sun Certified Java Programmer" 
                                                           dateEarned:@"Apr 2009" 
                                                               inCity:@"San Francisco" 
                                                              inState:@"CA" 
                                                        atInstitution:@"Sun" 
                                                         withSequence:4]];
    }
    [self sortTables];
}

- (void)sortTables
{
    // Sort jobs in the order they should appear in the table.  
    NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequence_number"
                                                                    ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.jobArray = [NSMutableArray arrayWithArray:[self.selectedResume.job sortedArrayUsingDescriptors:sortDescriptors]];
    // ...and the Education and Certification array
    self.educationArray = [NSMutableArray arrayWithArray:[self.selectedResume.education sortedArrayUsingDescriptors:sortDescriptors]];

}

- (void)configureDefaultNavBar
{
    DLog();
    // Set the buttons.    
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem  = backBtn;

    // Set table editing off
    [self.tblView setEditing:NO];
}

- (Jobs *)createJob:(NSDictionary *)jobDict
{
    DLog();
    Jobs *newJob = (Jobs *)[NSEntityDescription insertNewObjectForEntityForName:@"Jobs"
                                                         inManagedObjectContext:self.managedObjectContext];
    newJob.created_date = [NSDate date];
	newJob.name			= [jobDict objectForKey:@"Company"];
	newJob.uri			= [jobDict objectForKey:@"CompanyUrl"];
	newJob.city			= [jobDict objectForKey:@"Location"];
	newJob.title		= [jobDict objectForKey:@"Title"];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MMM yyyy"];
	newJob.start_date   = [dateFormatter dateFromString:[jobDict objectForKey:@"StartDate"]];
	newJob.end_date		= [dateFormatter dateFromString:[jobDict objectForKey:@"EndDate"]];
	newJob.summary      = [jobDict objectForKey:@"Responsibilities"];
    newJob.resume       = self.selectedResume;
    NSArray* accomplishments = [jobDict objectForKey:@"Accomplishments"];
    for (NSString* accomp in accomplishments) {
        [newJob addAccomplishmentObject:[self createAccomplishment:accomp]];
    }
    
    DLog(@"accomplishment count %d", [[newJob accomplishment] count]);
    return newJob;
}

- (Accomplishments *)createAccomplishment:(NSString *)accomp
{
    Accomplishments* newAccomp = (Accomplishments *)[NSEntityDescription insertNewObjectForEntityForName:@"Accomplishments"
                                                                                  inManagedObjectContext:self.managedObjectContext];
    newAccomp.created_date  = [NSDate date];
    newAccomp.summary       = accomp;
    
    return newAccomp;
}

- (Education *)createEducation:(NSString *)eduName 
                    dateEarned:(NSString *)dateEarned 
                        inCity:(NSString *)inCity 
                       inState:(NSString *)inState 
                 atInstitution:(NSString *)atInstitution 
                  withSequence:(int)withSequence
{
    DLog();
    Education *newEdu = (Education *)[NSEntityDescription insertNewObjectForEntityForName:@"Education"
                                                                   inManagedObjectContext:self.managedObjectContext];
    newEdu.created_date             = [NSDate date];
    newEdu.name                     = eduName;
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MMM yyyy"];
    newEdu.earned_date              = [dateFormatter dateFromString:dateEarned];
    newEdu.city                     = inCity;
    newEdu.state                    = inState;
    newEdu.title                    = atInstitution;
    newEdu.resume                   = self.selectedResume;

    return newEdu;
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog();
    NSError* error = nil;
    NSManagedObjectContext* moc = self.managedObjectContext;
    if (moc != nil) {
        if (![moc save:&error]) {
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
    
    // Set up the navigation item and done button
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}

- (void)addAction
{
    DLog();
}

- (void)saveAction
{
    DLog();    
    // The job array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the job's sequence_number attribute
    for (int i = 0; i < [self.jobArray count]; i++) {
        if ([[self.jobArray objectAtIndex:i] isDeleted]) {
            // skip it
        } else {
            [(Jobs *)[self.jobArray objectAtIndex:i] setSequence_numberValue:i];
        }
    }
    // ...same for the education array
    for (int i = 0; i < [self.educationArray count]; i++) {
        if ([[self.educationArray objectAtIndex:i] isDeleted]) {
            // skip it
        } else {
            [(Education *)[self.educationArray objectAtIndex:i] setSequence_numberValue:i];
        }
    }
    
    // Save the changes
    [[self.managedObjectContext undoManager] endUndoGrouping];
    NSError* error = nil;
    NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error]) {
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
    [self.tblView reloadData];
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
    [self sortTables];
    [self.tblView reloadData];
}

- (void)addJob
{
    DLog();
    Jobs *job = (Jobs *)[NSEntityDescription insertNewObjectForEntityForName:@"Jobs"
                                                      inManagedObjectContext:self.managedObjectContext];
    job.name            = self.jobName;
    job.created_date    = [NSDate date];
        
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        ELog(error, @"Failed to save");
        abort();
    }
    
    [self.jobArray insertObject:job 
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

- (void)getJobName 
{
    UIAlertView* jobNameAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Job Name", 
                                                                                      @"Enter Job Name") 
                                                            message:nil
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                                      @"Cancel") 
                                                  otherButtonTitles:NSLocalizedString(@"OK",
                                                                                      @"OK"), nil] autorelease];
    jobNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [jobNameAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // OK
        self.jobName = [[alertView textFieldAtIndex:0] text];            
        [self addJob];
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
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	switch (section) {
		case k_SummaryInfoTbl:
			return 1;
			break;
		case k_JobsInfoTbl:
			return [self.selectedResume.job count];
			break;
		case k_EducationInfoTbl:
			return [self.selectedResume.education count];
			break;
		default:
			ALog(@"Unexpected section = %d", section);
			return 0;
			break;
	}
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
    switch (indexPath.section) {
		case k_SummaryInfoTbl:
			cell.textLabel.text = self.selectedResume.name;          // There is only 1 row in this section
			cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case k_JobsInfoTbl:
			cell.textLabel.text = [[self.jobArray objectAtIndex:indexPath.row] name];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case k_EducationInfoTbl:
			cell.textLabel.text = [(Education *)[self.educationArray objectAtIndex:indexPath.row] name];
			cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		default:
			ALog(@"Unexpected section = %d", indexPath.section);
			break;
	}
    
    return cell;

}


#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
	UILabel *sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];

	switch (section) {
		case k_SummaryInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Summary",
                                                  @"Summary");
			return sectionLabel;
		}
		case k_JobsInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Professional History", 
                                                  @"Professional History");
			return sectionLabel;
		}
		case k_EducationInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Education & Certifications", 
                                                  @"Education & Certifications");
			return sectionLabel;
		}
		default:
			ALog(@"Unexpected section = %d", section);
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self editAction];
        // Delete the managed object at the given index path.
        NSManagedObject *jobToDelete = [self.jobArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:jobToDelete];
        [self.jobArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section != toIndexPath.section) {
        // Cannot move between sections
        [KOExtensions showAlertWithMessageAndType:NSLocalizedString(@"Sorry, move not allowed", 
                                                                    @"Sorry, move not allowed")
                                        alertType:UIAlertViewStyleDefault];
        [self.tblView reloadData];
        return;
    }
    
    // Get the from and to Rows of the table
    NSUInteger fromRow  = [fromIndexPath row];
    NSUInteger toRow    = [toIndexPath row];
    
    // Get the Job at the fromRow 
    Jobs* movedJob = [[self.jobArray objectAtIndex:fromRow] retain];
    // ...remove it from that "order"
    [self.jobArray removeObjectAtIndex:fromRow];
    // ...and insert it where the user wants
    [self.jobArray insertObject:movedJob
                             atIndex:toRow];
    [movedJob release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.section) {
		case k_SummaryInfoTbl: {			// There is only 1 row in this section, so ignore row.
			SummaryViewController* summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" 
                                                                                                   bundle:nil];
            summaryViewController.selectedResume            = self.selectedResume;
            summaryViewController.managedObjectContext      = self.managedObjectContext;
            summaryViewController.fetchedResultsController  = self.fetchedResultsController;
			summaryViewController.title = NSLocalizedString(@"Summary", @"Summary");
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:summaryViewController 
                                                 animated:YES];
			[summaryViewController release];
			break;
		}
		case k_JobsInfoTbl: {
			JobsDetailViewController* detailViewController = [[JobsDetailViewController alloc] initWithNibName:@"JobsDetailViewController" 
                                                                                                        bundle:nil];
			// Pass the selected object to the new view controller.
			detailViewController.title          = NSLocalizedString(@"Jobs", @"Jobs");
			detailViewController.selectedJob    = [self.jobArray objectAtIndex:indexPath.row];
			
			[self.navigationController pushViewController:detailViewController 
                                                 animated:YES];
			[detailViewController release];
			break;
		}
		case k_EducationInfoTbl: {			
			EducationViewController *educationViewController = [[EducationViewController alloc] initWithNibName:@"EducationViewController" 
                                                                                                                 bundle:nil];
			// Pass the selected object to the new view controller.
            educationViewController.selectedEducation           = [self.educationArray objectAtIndex:indexPath.row];
            educationViewController.managedObjectContext        = self.managedObjectContext;
            educationViewController.fetchedResultsController    = self.fetchedResultsController;
			educationViewController.title = NSLocalizedString(@"Education", @"Education");
			
			[self.navigationController pushViewController:educationViewController 
                                                 animated:YES];
			[educationViewController release];
			break;
		}
		default:
			break;
	}
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


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    ALog();
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.tblView        = nil;
    self.mgmtJobsDict   = nil;
    self.jobArray       = nil;
    self.educationArray = nil;
}


- (void)dealloc 
{
	[_tblView release];
	[_mgmtJobsDict release];
    [_selectedResume release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
    [_jobArray release];
    [_educationArray release];
	
    [super dealloc];
}

@end

