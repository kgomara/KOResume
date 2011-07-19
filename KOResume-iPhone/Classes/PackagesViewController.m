//
//  PackagesViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PackagesViewController.h"
#import "CoverLtrViewController.h"
#import "ResumeViewController.h"
#import "DesignViewController.h"

#define kSummaryTableCell   0
#define kResumeTableCell    1
#define kDesignTableCell    2

@implementation PackagesViewController

@synthesize tblView;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Kevin O'Mara";
	self.view.backgroundColor = [UIColor clearColor];
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	switch (indexPath.row) {				// There is only 1 section, so ignore it.
		case kSummaryTableCell:
			cell.textLabel.text = @"Cover Letter";
			break;
		case kResumeTableCell:
			cell.textLabel.text = @"Resume";
			break;
		case kDesignTableCell:
			cell.textLabel.text = @"Design Explanation";
			break;
		default:
			break;
	}
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UILabel* sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]];
	[sectionLabel setTextColor:[UIColor whiteColor]];
	[sectionLabel setBackgroundColor:[UIColor clearColor]];
	
	sectionLabel.text = @"Package Contents:";
	return sectionLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {				// There is only 1 section, so ignore it.
		case kSummaryTableCell: {
			CoverLtrViewController* coverLtrViewController = [[CoverLtrViewController alloc] 
                                                              initWithNibName:@"CoverLtrViewController" 
                                                              bundle:nil];
			coverLtrViewController.title = @"Cover Letter";
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:coverLtrViewController animated:YES];
			[coverLtrViewController release];
			break;
		}
		case kResumeTableCell: {
			ResumeViewController* resumeViewController = [[ResumeViewController alloc] 
                                                          initWithNibName:@"ResumeViewController" 
                                                          bundle:nil];
			resumeViewController.title = @"Resume";
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:resumeViewController animated:YES];
			[resumeViewController release];
			break;
		}
		case kDesignTableCell: {
			NSLog(@"Explanation");
			DesignViewController* designViewController = [[DesignViewController alloc] 
                                                          initWithNibName:@"DesignViewController" 
                                                          bundle:nil];
			designViewController.title = @"Design";
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:designViewController animated:YES];
			[designViewController release];
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
	self.tblView = nil;
}


- (void)dealloc {
	self.tblView = nil;
    self.managedObjectContext = nil;
    
    [super dealloc];
}


@end

