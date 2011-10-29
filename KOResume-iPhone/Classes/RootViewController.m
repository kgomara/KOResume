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


@implementation RootViewController

@synthesize tblView;

@synthesize packagesArray;  
@synthesize managedObjectContext;

@synthesize addButton;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    // TODO get from database
	self.navigationItem.title = @"Kevin O'Mara";
	self.view.backgroundColor = [UIColor clearColor];
    
    // Set up the buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target:self 
                                                              action:@selector(addPackage)];
    addButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Create a fetch request object to get all the Packages
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Packages"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // Create a sort descriptor to sort the Packages by creationDate
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_date" 
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];    
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];    
    [sortDescriptor release];
    
    // Execute the request
    NSError *error = nil;    
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request
                                                                               error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        ELog(error, @"Failed to fetch Packages");
        abort();
    }
    
    // Update packagesArray and clean up
    [self setPackagesArray:mutableFetchResults];
    [mutableFetchResults release];    
    [request release];
}

#pragma mark UI handlers

- (void)addPackage 
{
    Packages *package = (Packages *)[NSEntityDescription insertNewObjectForEntityForName:@"Packages"
                                                                         inManagedObjectContext:managedObjectContext];
    [package setName:[self getPackageName]];
    [package setCreated_date:[NSDate date]];
    
    NSError* error = nil;
    if (![managedObjectContext save:&error]) {
        ELog(error, @"Failed to save");
        abort();
    }
    
    [packagesArray insertObject:package 
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
	return [packagesArray count];
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
    Packages* package = (Packages *)[packagesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = package.name;
    
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{	
	UILabel* sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
	
	sectionLabel.text = @"Resumes Available:";
	return sectionLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.row) {				// There is only 1 section, so ignore it.
		case 0: {
			PackagesViewController* packagesViewController = [[PackagesViewController alloc] initWithNibName:@"PackagesViewController" 
                                                                                                      bundle:nil];
			packagesViewController.title = NSLocalizedString(@"Resumes", @"Resumes");
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:packagesViewController 
                                                 animated:YES];
			[packagesViewController release];
			break;
		}
		default:
            ALog(@"Unexpected row %d", indexPath.row);
			break;
	}
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
	self.tblView = nil;
    self.addButton = nil;
}


- (void)dealloc 
{
	self.tblView = nil;
    
    self.packagesArray = nil;
    self.managedObjectContext = nil;
    
    self.addButton = nil;
    
    [super dealloc];
}

@end

