//
//  ResumeViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResumeViewController.h"
#import "JobsDetailViewController.h"
#import "SummaryViewController.h"
#import "EducationViewController.h"

#define kSummaryInfoTbl		0
#define	kMgmtJobsInfoTbl	1
#define kProgJobsInfoTbl	2
#define kEducationInfoTbl	3

@implementation ResumeViewController

@synthesize mgmtJobsArray;
@synthesize progJobsArray;
@synthesize mgmtJobsDict;

#pragma mark -
#pragma mark View lifecycle methods


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Resume";
	self.view.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	
	// get the jobs.plist dictionary into mgmtJobsDict
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *plistPath = [bundle pathForResource:@"jobs" ofType:@"plist"];
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	self.mgmtJobsDict = dictionary;
	[dictionary release];
	
	// List the jobs in the order they should appear in the table.  Strings must match keys in jobs.plist
	mgmtJobsArray = [[NSArray alloc] initWithObjects:@"Appiction, LLC", @"Macy's West", @"O'Mara Consulting Associates", @"Loquendo",
					 @"Per-Se Technologies", @"Tenth Planet", @"Apple Computer", @"Jostens Learning Corp.",
					 nil];
	progJobsArray = [[NSArray alloc] initWithObjects:@"Intrepid Software Development, Inc.", @"National Semiconductor Corp.", @"NCR Corp.",
					 @"California First Bank", @"IBM Corp.", 
					 nil];
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
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
			NSLog(@"RootViewController: numberOfRowsInSection - unexpected section = %d", section);
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	switch (indexPath.section) {
		case kSummaryInfoTbl:			// There is only 1 row in this section, so ignore it.
			cell.textLabel.text = @"Kevin O'Mara";
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kMgmtJobsInfoTbl:
			cell.textLabel.text = [self.mgmtJobsArray objectAtIndex:indexPath.row];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kProgJobsInfoTbl:
			cell.textLabel.text = [self.progJobsArray objectAtIndex:indexPath.row];
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kEducationInfoTbl:			// There is only 1 row in this section, so ignore it.
			cell.textLabel.text = @"Education & Certs.";
			cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
			break;
	}

    return cell;
}



#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UILabel *sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];

	switch (section) {
		case kSummaryInfoTbl: {
			sectionLabel.text = @"Summary";
			return sectionLabel;
		}
		case kMgmtJobsInfoTbl: {
			sectionLabel.text = @"Management History";
			return sectionLabel;
		}
		case kProgJobsInfoTbl: {
			sectionLabel.text = @"Programming History";
			return sectionLabel;
		}
		case kEducationInfoTbl: {
			sectionLabel.text = @"Education & Certifications";
			return sectionLabel;
		}
		default:
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
		case kSummaryInfoTbl: {			// There is only 1 row in this section, so ignore it.
			SummaryViewController *summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" 
																								   bundle:nil];
			summaryViewController.title = @"Summary";
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:summaryViewController animated:YES];
			[summaryViewController release];
			break;
		}
		case kMgmtJobsInfoTbl: {
			JobsDetailViewController *detailViewController = [[JobsDetailViewController alloc] initWithNibName:@"JobsDetailViewController" 
																										bundle:nil];
			detailViewController.title = @"Mgmt Hist";
			NSString *jobKey = [self.mgmtJobsArray objectAtIndex:indexPath.row];
			detailViewController.jobDictionary = [self.mgmtJobsDict objectForKey:jobKey];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
			[detailViewController release];
			break;
		}
		case kProgJobsInfoTbl: {
			JobsDetailViewController *detailViewController = [[JobsDetailViewController alloc] initWithNibName:@"JobsDetailViewController" 
																										bundle:nil];
			detailViewController.title = @"Prog Hist";
			NSString *jobKey = [self.progJobsArray objectAtIndex:indexPath.row];
			detailViewController.jobDictionary = [self.mgmtJobsDict objectForKey:jobKey];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
			[detailViewController release];
			break;
		}
		case kEducationInfoTbl: {			// There is only 1 row in this section, so ignore it.
			EducationViewController *educationViewController = [[EducationViewController alloc] initWithNibName:@"EducationViewController" 
																										 bundle:nil];
			educationViewController.title = @"Education";
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:educationViewController animated:YES];
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.mgmtJobsArray = nil;
	self.progJobsArray = nil;
	self.mgmtJobsDict  = nil;
	
    [super dealloc];
}


@end

