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

#define kSummaryInfoTbl		0
#define	kMgmtJobsInfoTbl	1
#define kProgJobsInfoTbl	2
#define kEducationInfoTbl	3

@interface ResumeViewController ()
{
@private
    NSArray*        mgmtJobsArray;
    NSArray*        progJobsArray;
}
@end

@implementation ResumeViewController

@synthesize tblView                     = _tblView;
@synthesize mgmtJobsDict                = _mgmtJobsDict;
@synthesize selectedPackage             = _selectedPackage;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle methods


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Resume", @"Resume");	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	
	// get the jobs.plist dictionary into mgmtJobsDict
	NSBundle* bundle    = [NSBundle mainBundle];
	NSString* plistPath = [bundle pathForResource:@"jobs" ofType:@"plist"];
	NSDictionary* dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	self.mgmtJobsDict = dictionary;
	[dictionary release];
	
	// List the jobs in the order they should appear in the table.  Strings must match keys in jobs.plist
    // TODO get from database
	mgmtJobsArray = [[NSArray alloc] initWithObjects:@"Appiction, LLC", @"Macy's West", 
                     @"O'Mara Consulting Associates", @"Loquendo",
					 @"Per-Se Technologies", @"Tenth Planet", @"Apple Computer", @"Jostens Learning Corp.",
					 nil];
	progJobsArray = [[NSArray alloc] initWithObjects:@"Intrepid Software Development, Inc.", 
                     @"National Semiconductor Corp.", @"NCR Corp.", @"California First Bank", @"IBM Corp.", 
					 nil];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	switch (section) {
		case kSummaryInfoTbl:
			return 1;
			break;
		case kMgmtJobsInfoTbl:
			return [mgmtJobsArray count];
			break;
		case kProgJobsInfoTbl:
			return [progJobsArray count];
			break;
		case kEducationInfoTbl:
			return 1;
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
	switch (indexPath.section) {
		case kSummaryInfoTbl:
            // TODO this should come from database
			cell.textLabel.text = @"Kevin O'Mara";          // There is only 1 row in this section
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kMgmtJobsInfoTbl:
			cell.textLabel.text = [mgmtJobsArray objectAtIndex:indexPath.row];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kProgJobsInfoTbl:
			cell.textLabel.text = [progJobsArray objectAtIndex:indexPath.row];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kEducationInfoTbl:
			cell.textLabel.text = NSLocalizedString(@"Education & Certs.", @"Education & Certs.");    // There is only 1 row in this section
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
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
		case kSummaryInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Summary", @"Summary");
			return sectionLabel;
		}
		case kMgmtJobsInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Management History", @"Management History");
			return sectionLabel;
		}
		case kProgJobsInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Programming History", @"Programming History");
			return sectionLabel;
		}
		case kEducationInfoTbl: {
			sectionLabel.text = NSLocalizedString(@"Education & Certifications", @"Education & Certifications");
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.section) {
		case kSummaryInfoTbl: {			// There is only 1 row in this section, so ignore row.
			SummaryViewController* summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" 
                                                                                                   bundle:nil];
			summaryViewController.title = NSLocalizedString(@"Summary", @"Summary");
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:summaryViewController 
                                                 animated:YES];
			[summaryViewController release];
			break;
		}
		case kMgmtJobsInfoTbl: {
			JobsDetailViewController* detailViewController = [[JobsDetailViewController alloc] initWithNibName:@"JobsDetailViewController" 
                                                                                                        bundle:nil];
			detailViewController.title = NSLocalizedString(@"Mgmt Hist", @"Mgmt Hist");
			NSString* jobKey = [mgmtJobsArray objectAtIndex:indexPath.row];
			detailViewController.jobDictionary = [self.mgmtJobsDict objectForKey:jobKey];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController 
                                                 animated:YES];
			[detailViewController release];
			break;
		}
		case kProgJobsInfoTbl: {
			JobsDetailViewController* detailViewController = [[JobsDetailViewController alloc] initWithNibName:@"JobsDetailViewController" 
                                                                                                        bundle:nil];
			detailViewController.title = NSLocalizedString(@"Prog Hist", @"Prog Hist");
			NSString* jobKey = [progJobsArray objectAtIndex:indexPath.row];
			detailViewController.jobDictionary = [self.mgmtJobsDict objectForKey:jobKey];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController 
                                                 animated:YES];
			[detailViewController release];
			break;
		}
		case kEducationInfoTbl: {			// There is only 1 row in this section, so ignore row.
			EducationViewController *educationViewController = [[EducationViewController alloc] initWithNibName:@"EducationViewController" 
                                                                                                         bundle:nil];
			educationViewController.title = NSLocalizedString(@"Education", @"Education");
			
			// Pass the selected object to the new view controller.
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
	self.tblView = nil;
    self.mgmtJobsDict  = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	[_tblView release];
	[_mgmtJobsDict release];
    [_selectedPackage release];
    [__managedObjectContext release];
    [__fetchedResultsController release];
	
    [super dealloc];
}

@end

