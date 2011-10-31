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
#import <CoreData/CoreData.h>
#import "KOExtensions.h"

#define k_addBtnWidth       29.0f
#define k_tblHdrHeight      50.0f

@interface RootViewController()

- (IBAction)addPackage:(id)sender;
- (NSString *)getPackageName;
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;
- (void)configureDefaultNavBar;
- (void)loadPackages;

@end

@implementation RootViewController

@synthesize tblView = _tableView;

@synthesize packagesArray;  
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

//@synthesize addButton;
//@synthesize editButton;

UIButton*               addButton;
UIBarButtonItem*        editButton;


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
    
    // Initialize the buttons
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                               target:self 
                                                               action:@selector(editAction)];
    // Create an add button for the table header
    addButton  = [[UIButton alloc] init];
    // ...put if toward the right edge
    // TODO - won't rotate correctly
    CGFloat xOffset = self.tblView.bounds.size.width - k_addBtnWidth - 5.0f;
    CGFloat yOffset = (k_tblHdrHeight - k_addBtnWidth) / 2;
    [addButton setFrame:CGRectMake(xOffset, yOffset, k_addBtnWidth, k_addBtnWidth)];
    [addButton setBackgroundColor:[UIColor clearColor]];
    [addButton setImage:[UIImage imageNamed:@"addButton.png"] 
               forState:UIControlStateNormal];
    [addButton addTarget:self
                  action:@selector(addPackage:) 
        forControlEvents:UIControlEventTouchUpInside];

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
        NSString* msg = [[NSString alloc] initWithFormat:@"A fatal error occured fetching the story %@", [error code]];
        [KOExtensions showErrorWithMessage:msg];
        ELog(error, @"Failed to fetch Packages");
        abort();
    }
    
    // Update packagesArray and clean up
    [self setPackagesArray:mutableFetchResults];
}

- (void)configureDefaultNavBar
{
    DLog();
    // Set up the buttons.
    [editButton setEnabled:YES];
    [addButton  setHidden:YES];
    
    self.navigationItem.rightBarButtonItem = nil;           // Release the save button if there is one
    self.navigationItem.rightBarButtonItem = editButton;
    self.navigationItem.leftBarButtonItem  = nil;
    
    [_tableView setEditing:NO];
}

#pragma mark UI handlers

- (void)editAction
{
    DLog();
    [_tableView setEditing:YES];
    
    // Set up the navigation item and done button
    UIBarButtonItem* saveBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction)] autorelease];
    UIBarButtonItem* cancelBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancelAction)] autorelease];
    self.navigationItem.leftBarButtonItem  = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    [addButton setHidden:NO];
    
    // Start an undo group...it will either be commited or 
    //    undone in requestModalViewDismissal
    [[[self managedObjectContext] undoManager] beginUndoGrouping]; 
}

- (void)saveAction
{
    DLog();
    // The sorted package array is in the order (including deletes) the user wants
    // ...loop through the array by index resetting the packages' sequence_number attribute
    for (int i = 0; i < [packagesArray count]; i++) {
        if ([[self.packagesArray objectAtIndex:i] isDeleted]) {
            // skip it
        } else {
            [(Packages *)[self.packagesArray objectAtIndex:i] setSequence_numberValue:i];
        }
    }
    
    // Save the changes
    [[[self managedObjectContext] undoManager] endUndoGrouping];
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
    [[[self managedObjectContext] undoManager] removeAllActionsWithTarget:self];
    // ...and reset the NavigationBar defaults
    [self configureDefaultNavBar];
    [self.tblView reloadData];
}

- (void)cancelAction
{
    DLog();
    // Undo any changes the user has made
    [[[self managedObjectContext] undoManager] setActionName:@"Packages Editing"];
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    if ([[[self managedObjectContext] undoManager] canUndo]) {
        [[[self managedObjectContext] undoManager] undoNestedGroup];
    } else {
        DLog(@"User cancelled, nothing to undo");
    }
    
    // Cleanup the undoManager
    [[[self managedObjectContext] undoManager] removeAllActionsWithTarget:self];
    // ...and reset Packages tableView
    [self configureDefaultNavBar];
    [self loadPackages];
    [self.tblView reloadData];
}

- (IBAction)addPackage:(id)sender
{
    DLog();
    Packages *package = (Packages *)[NSEntityDescription insertNewObjectForEntityForName:@"Packages"
                                                                  inManagedObjectContext:__managedObjectContext];
    [package setName:[self getPackageName]];
    [package setCreated_date:[NSDate date]];
    
    NSError* error = nil;
    if (![__managedObjectContext save:&error]) {
        ELog(error, @"Failed to save");
        abort();
    }
    
    [self.packagesArray insertObject:package 
                             atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 
                                                inSection:0];
    
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                      withRowAnimation:UITableViewRowAnimationFade];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 
                                                          inSection:0] 
                      atScrollPosition:UITableViewScrollPositionTop 
                              animated:YES];
}

- (NSString *)getPackageName 
{    
    return NSLocalizedString(@"temp", @"temp");
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
    UIView* sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblView.bounds.size.width, k_tblHdrHeight)] autorelease];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    
    // Create a label for the section
	UILabel* sectionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 170.0f, 24.0f)] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:16.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
	
	sectionLabel.text = NSLocalizedString(@"Packages Available:", @"Packages Available:");
    // Add label to sectionView
    [sectionView addSubview:sectionLabel];
    // ...and addButton to sectionView
    [sectionView addSubview:addButton];

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
        NSManagedObject *packageToDelete = [packagesArray objectAtIndex:indexPath.row];
        [__managedObjectContext deleteObject:packageToDelete];
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
    packagesViewController.title = [[self.packagesArray objectAtIndex:indexPath.row] name];
    packagesViewController.selectedPackage = [self.packagesArray objectAtIndex:indexPath.row];
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
    // For example: self.myOutlet = nil;
	_tableView = nil;
    
    self.packagesArray = nil;
    addButton = nil;
    editButton = nil;
}


- (void)dealloc 
{
	_tableView = nil;
    
    self.packagesArray = nil;
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    addButton = nil;
    editButton = nil;
    
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
                                               inManagedObjectContext:__managedObjectContext];
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
                                                                                                managedObjectContext:__managedObjectContext
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
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    DLog();
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
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
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLog();
    [_tableView endUpdates];
}

#pragma mark - tableView helpers

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    DLog();
}

@end

