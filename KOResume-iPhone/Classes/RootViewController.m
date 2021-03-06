//
//  RootViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "RootViewController.h"
#import "KOResumeAppDelegate.h"
#import "PackagesViewController.h"
#import "Packages.h"
#import "Resumes.h"
#import <CoreData/CoreData.h>
#import "KOExtensions.h"
#import "InfoViewController.h"

#define k_tblHdrHeight      50.0f

@interface RootViewController()
{
@private
    NSString                    *_packageName;
    
    NSFetchedResultsController  *fetchedResultsController__;
    NSManagedObjectContext      *managedObjectContext__;
}

- (void)promptForPackageName;
- (void)addPackage;
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;
- (void)configureDefaultNavBar;
- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

@property (nonatomic, strong) NSString                      *packageName;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;

@end

@implementation RootViewController

@synthesize tblView                     = _tblView;

@synthesize packageName                 = _packageName;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

#pragma mark - View lifecycle

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    DLog();
    [super viewDidLoad];
	
    // Set the App name as the Title in the Navigation bar
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
//#ifdef DEBUG
//    // Include the version in the title for debug builds
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
//    self.navigationItem.title = [appName stringByAppendingString: version];
//#else
    self.navigationItem.title = appName;
//#endif
	self.view.backgroundColor = [UIColor clearColor];
    
    // Set up the defaults in the Navigation Bar
    [self configureDefaultNavBar];
   
    // Observe the app delegate telling us when it's finished asynchronously adding the store coordinator
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(reloadFetchedResults:) 
                                                 name: KOApplicationDidAddPersistentStoreCoordinatorNotification
                                               object: nil];
    
    // ...add an observer for asynchronous iCloud merges - not used in this version
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadFetchedResults:)
                                                 name: KOApplicationDidMergeChangesFrom_iCloudNotification
                                               object: nil];

    // Push the InfoViewController onto the stack so the user knows we're waiting for the persistentStoreCoordinator
    // to load the database. The user will be able to dismiss it once the coordinator posts an NSNotification
    // indicating we're ready.
    InfoViewController *infoViewController = [[[InfoViewController alloc] initWithNibName: KOInfoViewController
                                                                                   bundle: nil] autorelease];
    [infoViewController setTitle: NSLocalizedString(@"Loading Database", nil)];
    [infoViewController.navigationItem setHidesBackButton: YES];
    [self.navigationController pushViewController: infoViewController
                                         animated: YES];
    
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    DLog();
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.tblView        = nil;    
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();
    // Apple recommends calling release on the ivar...
	[_tblView release];
    [_packageName release];
    
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
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
    DLog();
    [self.navigationItem setHidesBackButton: NO];
    self.fetchedResultsController.delegate = self;
    
    for (Packages *pkg in [self.fetchedResultsController fetchedObjects]) {
        [pkg logAllFields];
    }
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
- (void)configureDefaultNavBar
{
    DLog();
    // Set up the buttons.
    // Initialize the buttons
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                                                 target: self 
                                                                                 action: @selector(editButtonTapped)] autorelease];
    UIBarButtonItem *addButton  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                                 target: self 
                                                                                 action: @selector(promptForPackageName)] autorelease];
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem  = editButton;
    
    [self.tblView setEditing:NO];
}

#pragma mark - UI handlers

//----------------------------------------------------------------------------------------------------------
- (void)editButtonTapped
{
    DLog();
    [self.tblView setEditing:YES];
    
    // Set up the navigation item and save button
    UIBarButtonItem *saveBtn   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                                                target: self
                                                                                action: @selector(saveButtonTapped)] autorelease];
    UIBarButtonItem *cancelBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                target: self
                                                                                action: @selector(cancelButtonTapped)] autorelease];
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    // Start an undo group...it will either be commited in saveButtonTapped or 
    //    undone in cancelButtonTapped
    [[self.managedObjectContext undoManager] beginUndoGrouping]; 
}


//----------------------------------------------------------------------------------------------------------
- (void)saveButtonTapped
{
    DLog();

    // Save the changes
    [[self.managedObjectContext undoManager] endUndoGrouping];
    
    if (![self saveMoc: [self.fetchedResultsController managedObjectContext]]) {
        ALog(@"Failed to save data");
        NSString* msg = NSLocalizedString(@"Failed to save data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }
    
    // Cleanup the undoManager
    [[self.managedObjectContext undoManager] removeAllActionsWithTarget: self];
    // ...and reset the NavigationBar defaults
    [self configureDefaultNavBar];
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)cancelButtonTapped
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
    // ...and reset Packages tableView
    [self configureDefaultNavBar];
    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)addPackage
{
    DLog();
    Packages *package = (Packages *)[NSEntityDescription insertNewObjectForEntityForName: KOPackagesEntity
                                                                  inManagedObjectContext: self.managedObjectContext];
    package.name            = self.packageName;
    package.created_date    = [NSDate date];
    
    //  Add a Resume for the package
    Resumes *resume  = (Resumes *)[NSEntityDescription insertNewObjectForEntityForName: KOResumesEntity
                                                                inManagedObjectContext: self.managedObjectContext];
    resume.name                 = NSLocalizedString(@"Resume", nil);
    resume.created_date         = [NSDate date];
    resume.sequence_numberValue = 1;
    package.resume              = resume;

    NSError *error = nil;
    if (![self.managedObjectContext save: &error]) {
        ELog(error, @"Failed to save");
        NSString* msg = NSLocalizedString(@"Failed to save data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }

    [self.tblView reloadData];
}


//----------------------------------------------------------------------------------------------------------
- (void)promptForPackageName
{
    DLog();
    UIAlertView *packageNameAlert = [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Enter Package Name", nil)
                                                                message: nil
                                                               delegate: self 
                                                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                      otherButtonTitles: NSLocalizedString(@"OK", nil), nil] autorelease];
    packageNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [packageNameAlert show];
}


//----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog();
    if (buttonIndex == 1) {
        // OK
        self.packageName = [[alertView textFieldAtIndex: 0] text];            
        [self addPackage];
    } else {
        // User cancelled
        [self configureDefaultNavBar];
    }
}

#pragma mark - Table view data source

//----------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}


//----------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section 
{	
    DLog(@"section=%d", section);
    
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex: section];
    return [sectionInfo numberOfObjects];
}


//----------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DLog();

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: KOCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                       reuseIdentifier: KOCellID] autorelease];
    }
    
	// Configure the cell.
    [self configureCell: cell
            atIndexPath: indexPath];

    return cell;
}


//----------------------------------------------------------------------------------------------------------
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    DLog();
    
    Packages *thePackage = (Packages *) [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = [thePackage name];
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark -
#pragma mark Table view delegates

//----------------------------------------------------------------------------------------------------------
-  (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section 
{
    DLog();
    
    // TODO - this won't rotate well...
    UIView *sectionView = [[[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.tblView.bounds.size.width, k_tblHdrHeight)] autorelease];
    [sectionView setBackgroundColor: [UIColor clearColor]];
    
    // Create a label for the section
	UILabel *sectionLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10.0f, 10.0f, 170.0f, 24.0f)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName: @"Helvetica-Bold" 
                                          size: 16.0]];
	[sectionLabel setTextColor: [UIColor whiteColor]];
	[sectionLabel setBackgroundColor: [UIColor clearColor]];
	
	sectionLabel.text = NSLocalizedString(@"Packages Available:", nil);
    // Add label to sectionView
    [sectionView addSubview: sectionLabel];

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
    DLog();

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self editButtonTapped];
        // Delete the managed object at the given index path.
        NSManagedObject *packageToDelete = [self.fetchedResultsController objectAtIndexPath: indexPath];
        [self.managedObjectContext deleteObject: packageToDelete];

        [tableView reloadData];
    }   
}


//----------------------------------------------------------------------------------------------------------
-  (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toIndexPath:(NSIndexPath *)toIndexPath
{
    DLog();

    NSMutableArray *packages = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    // Grab the item we're moving.
    NSManagedObject *movedPackage = [[self fetchedResultsController] objectAtIndexPath: fromIndexPath];
    
    // Remove the object we're moving from the array.
    [packages removeObject: movedPackage];
    // Now re-insert it at the destination.
    [packages insertObject: movedPackage
                   atIndex: toIndexPath.row];
    
    // All of the objects are now in their correct order. Update each
    // object's sequence_number field by iterating through the array.
    int i = 0;
    for (Packages *package in packages) {
        [package setSequence_numberValue: i++];
    }
    
    [packages release];
    [self saveButtonTapped];
}


//----------------------------------------------------------------------------------------------------------
-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();

    PackagesViewController *packagesViewController = [[[PackagesViewController alloc] initWithNibName: KOPackagesViewController
                                                                                               bundle: nil] autorelease];
    // Pass the selected object to the new view controller.
    packagesViewController.title                    = [[self.fetchedResultsController objectAtIndexPath: indexPath] name];
    packagesViewController.selectedPackage          = [self.fetchedResultsController objectAtIndexPath: indexPath];
    packagesViewController.managedObjectContext     = self.managedObjectContext;
    packagesViewController.fetchedResultsController = self.fetchedResultsController;
    [self.navigationController pushViewController: packagesViewController 
                                         animated: YES];
    
    // Clear the selected row
	[tableView deselectRowAtIndexPath: indexPath
							 animated: YES];
}

#pragma mark - Fetched results controller

//----------------------------------------------------------------------------------------------------------
- (NSFetchedResultsController *)fetchedResultsController
{
    DLog();
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Create the fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity  = [NSEntityDescription entityForName: KOPackagesEntity
                                               inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number
    [fetchRequest setFetchBatchSize:5];
    // Sort by package sequence_number
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: KOSequenceNumberAttributeName
                                                                   ascending: YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Alloc and initialize the controller
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath: nil
                                                                                                           cacheName: @"Root"];
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    
    [fetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
     
    NSError *error = nil;
    if ( ![self.fetchedResultsController performFetch: &error]) {
        ELog(error, @"Fetch failed!");
        NSString* msg = NSLocalizedString(@"Failed to fetch data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }
    
    return __fetchedResultsController;
}


//----------------------------------------------------------------------------------------------------------
- (void)reloadFetchedResults:(NSNotification*)note
{
    DLog();

    // because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
    // the NSManagedObjectContext is set up before any persistent stores are registered
    // we need to fetch again after the persistent store is loaded

    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch: &error]) {
        ELog(error, @"Fetch failed!");
        NSString* msg = NSLocalizedString( @"Failed to reload data after syncing with iCloud.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }
    
    [self.tblView reloadData];
}

#pragma mark - Fetched results controller delegate

//----------------------------------------------------------------------------------------------------------
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DLog();
    
    [self.tblView beginUpdates];
}


//----------------------------------------------------------------------------------------------------------
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type
{
    DLog();
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tblView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex]
                        withRowAnimation: UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex]
                        withRowAnimation: UITableViewRowAnimationFade];
            break;
        default:
            ALog();
            break;
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath
{
    DLog();
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tblView insertRowsAtIndexPaths: [NSArray arrayWithObject: newIndexPath]
                                withRowAnimation: UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tblView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                                withRowAnimation: UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell: [self.tblView cellForRowAtIndexPath: indexPath]
                    atIndexPath: indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tblView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                                withRowAnimation: UITableViewRowAnimationFade];
            [self.tblView insertRowsAtIndexPaths: [NSArray arrayWithObject: newIndexPath]
                                withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


//----------------------------------------------------------------------------------------------------------
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLog();
    
    [self.tblView endUpdates];
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

