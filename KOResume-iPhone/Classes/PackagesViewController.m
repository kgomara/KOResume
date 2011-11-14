//
//  PackagesViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import "PackagesViewController.h"
#import "CoverLtrViewController.h"
#import "ResumeViewController.h"
#import "Resumes.h"

#define kSummaryTableCell   0
#define kResumeTableCell    1

@implementation PackagesViewController

@synthesize tblView                     = _tblView;
@synthesize selectedPackage             = _selectedPackage;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.navigationItem.title = self.selectedPackage.name;
	self.view.backgroundColor = [UIColor clearColor];
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
	return 2;
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
	switch (indexPath.row) {				// There is only 1 section, so ignore it.
		case kSummaryTableCell:
			cell.textLabel.text = NSLocalizedString(@"Cover Letter", 
                                                    @"Cover Letter");
            cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case kResumeTableCell:
			cell.textLabel.text = NSLocalizedString(@"Resume", 
                                                    @"Resume");
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
            ALog(@"Unexpected row %d", indexPath.row);
			break;
	}
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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

#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{	
	UILabel* sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" 
                                          size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
	
	sectionLabel.text = NSLocalizedString(@"Package Contents:", 
                                          @"Package Contents:");
	return sectionLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    switch (indexPath.row) {				// There is only 1 section, so ignore it.
		case kSummaryTableCell: {
			CoverLtrViewController* coverLtrViewController = [[CoverLtrViewController alloc] initWithNibName:@"CoverLtrViewController" 
                                                                                                      bundle:nil];
			coverLtrViewController.title = NSLocalizedString(@"Cover Letter", 
                                                             @"Cover Letter");
            coverLtrViewController.selectedPackage          = self.selectedPackage;
            coverLtrViewController.managedObjectContext     = self.managedObjectContext;
            coverLtrViewController.fetchedResultsController = self.fetchedResultsController;
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:coverLtrViewController 
                                                 animated:YES];
			[coverLtrViewController release];
			break;
		}
		case kResumeTableCell: {
			ResumeViewController* resumeViewController = [[ResumeViewController alloc] initWithNibName:@"ResumeViewController" 
                                                                                                bundle:nil];
			resumeViewController.title = NSLocalizedString(@"Resume", 
                                                           @"Resume");
            resumeViewController.selectedResume             = self.selectedPackage.resume;
            resumeViewController.managedObjectContext       = self.managedObjectContext;
            resumeViewController.fetchedResultsController   = self.fetchedResultsController;
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:resumeViewController 
                                                 animated:YES];
			[resumeViewController release];
			break;
		}
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
}


- (void)dealloc 
{
    // Apple recommends calling release on the ivar...
	[_tblView release];
    [_selectedPackage release];
    
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

@end

