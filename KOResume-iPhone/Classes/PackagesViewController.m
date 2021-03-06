//
//  PackagesViewController.m
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import "PackagesViewController.h"
#import "KOExtensions.h"
#import "CoverLtrViewController.h"
#import "ResumeViewController.h"
#import "Resumes.h"

#define kSummaryTableCell   0
#define kResumeTableCell    1

@interface PackagesViewController()

- (BOOL)saveMoc:(NSManagedObjectContext *)moc;

@end

@implementation PackagesViewController

@synthesize tblView                     = _tblView;
@synthesize selectedPackage             = _selectedPackage;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize fetchedResultsController    = __fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle

//----------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    DLog();

    [super viewDidLoad];
	
    
    [_selectedPackage logAllFields];
	self.navigationItem.title = self.selectedPackage.name;
	self.view.backgroundColor = [UIColor clearColor];

    // Set an observer for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadFetchedResults:) 
                                                 name: KOApplicationDidMergeChangesFrom_iCloudNotification
                                               object: nil];
}


//----------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    DLog();

    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
	self.tblView = nil;
}


//----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    DLog();

    // Apple recommends calling release on the ivar...
	[_tblView release];
    [_selectedPackage release];
    
    [__managedObjectContext release];
    [__fetchedResultsController release];
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    DLog();

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    ALog();
}

#pragma mark -
#pragma mark Table view data source

//----------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


//----------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{	
	return 2;
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
	switch (indexPath.row) {
        // There is only 1 section, so ignore it.
		case kSummaryTableCell:
			cell.textLabel.text = NSLocalizedString(@"Cover Letter", nil);
            cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case kResumeTableCell:
			cell.textLabel.text = NSLocalizedString(@"Resume", nil);
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
            ALog(@"Unexpected row %d", indexPath.row);
			break;
	}
	cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


//----------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    DLog();

    // Save any changes
    [self saveMoc: self.managedObjectContext];
}

#pragma mark -
#pragma mark Table view delegates

//----------------------------------------------------------------------------------------------------------
-  (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section 
{
    DLog();

	UILabel *sectionLabel = [[[UILabel alloc] init] autorelease];
	[sectionLabel setFont:[UIFont fontWithName: @"Helvetica-Bold" 
                                          size: 18.0]];
	[sectionLabel setTextColor: [UIColor whiteColor]];
	[sectionLabel setBackgroundColor: [UIColor clearColor]];
	
	sectionLabel.text = NSLocalizedString(@"Package Contents:", nil);
    
	return sectionLabel;
}


//----------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{	
	return 44;
}


//----------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DLog();

    // There is only 1 section, so ignore it.
    switch (indexPath.row) {
		case kSummaryTableCell: {
			CoverLtrViewController *coverLtrViewController = [[CoverLtrViewController alloc] initWithNibName: KOCoverLtrViewController
                                                                                                      bundle: nil];
			coverLtrViewController.title                    = NSLocalizedString(@"Cover Letter", nil);
            coverLtrViewController.selectedPackage          = self.selectedPackage;
            coverLtrViewController.managedObjectContext     = self.managedObjectContext;
            coverLtrViewController.fetchedResultsController = self.fetchedResultsController;
			
			[self.navigationController pushViewController:coverLtrViewController 
                                                 animated:YES];
			[coverLtrViewController release];
			break;
		}
		case kResumeTableCell: {
			ResumeViewController* resumeViewController = [[ResumeViewController alloc] initWithNibName: KOResumeViewController
                                                                                                bundle: nil];
			resumeViewController.title                      = NSLocalizedString(@"Resume", nil);
            resumeViewController.selectedResume             = self.selectedPackage.resume;
            resumeViewController.managedObjectContext       = self.managedObjectContext;
            resumeViewController.fetchedResultsController   = self.fetchedResultsController;
			
			[self.navigationController pushViewController: resumeViewController 
                                                 animated: YES];
			[resumeViewController release];
			break;
		}
	}
	[tableView deselectRowAtIndexPath: indexPath
							 animated: YES];
}


//----------------------------------------------------------------------------------------------------------
- (void)reloadFetchedResults:(NSNotification*)note
{
    DLog();
    
    NSError *error = nil;

    if (![[self fetchedResultsController] performFetch: &error]) {
        ELog(error, @"Fetch failed!");
        NSString* msg = NSLocalizedString(@"Failed to reload data.", nil);
        [KOExtensions showErrorWithMessage: msg];
    }
    
    [self.tblView reloadData];
    
//    if (note) {
//        // The notification is on an async thread, so block while the UI updates
//        [self.managedObjectContext performBlock:^{
//            [self.tblView reloadData];
//        }];
//    }
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

