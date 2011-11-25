//
//  RootViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "RootViewController.h"
#import "PackagesViewController.h"
#import "Packages.h"
#import "Resumes.h"
#import <CoreData/CoreData.h>
#import "KOExtensions.h"

#define k_addBtnWidth       29.0f
#define k_tblHdrHeight      50.0f

@interface RootViewController()
{
    @private
    NSString*                   _packageName;    
    NSMutableArray*             _packagesArray;
    
    NSFetchedResultsController* __fetchedResultsController;
}

- (void)getPackageName;
- (void)addPackage;
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;
- (void)configureDefaultNavBar;
- (void)loadPackages;

@property (nonatomic, retain) NSString*                     packageName;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;
@property (nonatomic, retain) NSMutableArray*               packagesArray;

@end

@implementation RootViewController

@synthesize tblView                     = _tblView;

@synthesize packagesArray               = _packagesArray;  
@synthesize packageName                 = _packageName;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    DLog();
    [super viewDidLoad];
	
    // Set the App name as the Title in the Navigation bar
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
#ifdef DEBUG
    // Include the version in the title for debug builds
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.navigationItem.title = [appName stringByAppendingString: version];
#else
    self.navigationItem.title = appName;
#endif
	self.view.backgroundColor = [UIColor clearColor];
    
    // Set up the defaults in the Navigation Bar
    [self configureDefaultNavBar];
    // ...and load the Packages
    [self loadPackages];
}

- (void)loadPackages
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest* request         = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription* entity     = [NSEntityDescription entityForName:@"Packages"
                                                  inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Create a sort descriptor to sort the Packages by sequence_number
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequence_number" 
                                                                    ascending:YES] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];    
    [request setSortDescriptors:sortDescriptors];
    
    // Execute the request
    NSError *error = nil;    
    NSMutableArray *mutableFetchResults = [[[context executeFetchRequest:request
                                                                   error:&error] mutableCopy] autorelease];
    if (mutableFetchResults == nil) {
        NSString* msg = [[NSString alloc] initWithFormat:NSLocalizedString(@"A fatal error occured fetching the story %@", 
                                                                           @"A fatal error occured fetching the story %@"), [error code]];
        [KOExtensions showErrorWithMessage:msg];
        ELog(error, @"Failed to fetch Packages");
        abort();
    }
    
    // Update packagesArray and clean up
    self.packagesArray = mutableFetchResults;
}

- (void)configureDefaultNavBar
{
    DLog();
    // Set up the buttons.
    // Initialize the buttons
    UIBarButtonItem* editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                 target:self 
                                                                                 action:@selector(editAction)] autorelease];
    UIBarButtonItem* addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self 
                                                                                action:@selector(getPackageName)] autorelease];
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem  = editButton;
    
    [self.tblView setEditing:NO];
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
    [self.tblView setEditing:YES];
    
    // Set up the navigation item and save button
    UIBarButtonItem* saveBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction)] autorelease];
    UIBarButtonItem* cancelBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancelAction)] autorelease];
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Start an undo group...it will either be commited in saveAction or 
    //    undone in cancelAction
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}

- (void)saveAction
{
    DLog();
    // The sorted package array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the packages' sequence_number attribute
    for (int i = 0; i < [self.packagesArray count]; i++) {
        if ([[self.packagesArray objectAtIndex:i] isDeleted]) {
            // skip it
        } else {
            [(Packages *)[self.packagesArray objectAtIndex:i] setSequence_numberValue:i];
        }
    }
    
    // Save the changes
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
    // ...and reset the NavigationBar defaults
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
    // ...and reset Packages tableView
    [self configureDefaultNavBar];
    [self loadPackages];
    [self.tblView reloadData];
}

- (void)addPackage
{
    DLog();
    Packages *package = (Packages *)[NSEntityDescription insertNewObjectForEntityForName:@"Packages"
                                                                  inManagedObjectContext:self.managedObjectContext];
    package.name            = self.packageName;
    package.created_date    = [NSDate date];
    
    //  Add a Resume for the package
    Resumes* resume  = (Resumes *)[NSEntityDescription insertNewObjectForEntityForName:@"Resumes"
                                                                inManagedObjectContext:self.managedObjectContext];
    resume.name                 = NSLocalizedString(@"Resume", @"Resume");
    resume.created_date         = [NSDate date];
    resume.sequence_numberValue = 1;
    package.resume              = resume;

    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        ELog(error, @"Failed to save");
        abort();
    }
    
    [self.packagesArray insertObject:package 
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

- (void)getPackageName 
{
    UIAlertView* packageNameAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Package Name", @"Enter Package Name") 
                                                                message:nil
                                                               delegate:self 
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") 
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil] autorelease];
    packageNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [packageNameAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // OK
        self.packageName = [[alertView textFieldAtIndex:0] text];            
        [self addPackage];
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
	return [self.packagesArray count];
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
    cell.textLabel.text = [[self.packagesArray objectAtIndex:indexPath.row] name];
    
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    DLog();
    // TODO - this won't rotate well...
    UIView* sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblView.bounds.size.width, k_tblHdrHeight)] autorelease];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    
    // Create a label for the section
	UILabel* sectionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 170.0f, 24.0f)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:16.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
	
	sectionLabel.text = NSLocalizedString(@"Packages Available:", 
                                          @"Packages Available:");
    // Add label to sectionView
    [sectionView addSubview:sectionLabel];

	return sectionView;
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
        NSManagedObject *packageToDelete = [self.packagesArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:packageToDelete];
        [self.packagesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Get the from and to Rows of the table
    NSUInteger fromRow  = [fromIndexPath row];
    NSUInteger toRow    = [toIndexPath row];
    
    // Get the Scene at the fromRow 
    Packages* movedPackage = [[self.packagesArray objectAtIndex:fromRow] retain];
    // ...remove it from that "order"
    [self.packagesArray removeObjectAtIndex:fromRow];
    // ...and insert it where the user wants
    [self.packagesArray insertObject:movedPackage
                             atIndex:toRow];
    [movedPackage release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    PackagesViewController* packagesViewController = [[[PackagesViewController alloc] initWithNibName:@"PackagesViewController" 
                                                                                               bundle:nil] autorelease];
    // Pass the selected object to the new view controller.
    packagesViewController.title                    = [[self.packagesArray objectAtIndex:indexPath.row] name];
    packagesViewController.selectedPackage          = [self.packagesArray objectAtIndex:indexPath.row];
    packagesViewController.managedObjectContext     = self.managedObjectContext;
    packagesViewController.fetchedResultsController = self.fetchedResultsController;
    [self.navigationController pushViewController:packagesViewController 
                                         animated:YES];
    
    // Clear the selected row
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.tblView        = nil;    
    self.packagesArray  = nil;
}


- (void)dealloc 
{
    // Apple recommends calling release on the ivar...
	[_tblView release];
    [_packagesArray release];
    
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    DLog();
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Create the fetch request for the entity
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity  = [NSEntityDescription entityForName:@"Packages"
                                               inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number
    [fetchRequest setFetchBatchSize:5];
    // Sort by package sequence_number
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence_number"
                                                                   ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Alloc and initialize the controller
    NSFetchedResultsController* aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
     
    return __fetchedResultsController;
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DLog();
    [self.tblView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    DLog();
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tblView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                        withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                        withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            ALog();
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    DLog();
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tblView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tblView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tblView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
            [self.tblView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLog();
    [self.tblView endUpdates];
}

#pragma mark - tableView helpers

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    DLog();
}

@end

