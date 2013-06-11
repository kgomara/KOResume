//
//  RootViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UIViewController <UITableViewDelegate, 
                                                  NSFetchedResultsControllerDelegate,
                                                  UIAlertViewDelegate> 
{
    NSManagedObjectContext*     __managedObjectContext;
}

@property (nonatomic, strong) IBOutlet UITableView      *tblView;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;

@end
