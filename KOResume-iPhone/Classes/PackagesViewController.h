//
//  PackagesViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Packages.h"


@interface PackagesViewController : UIViewController <UITableViewDelegate> 
{

}

@property (nonatomic, retain) IBOutlet UITableView*         tblView;
@property (nonatomic, retain) Packages*                     selectedPackage;

@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

@end
