//
//  RootViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UIViewController <UITableViewDelegate, 
                                                  NSFetchedResultsControllerDelegate,
                                                  UIAlertViewDelegate> 
{

}

@property (nonatomic, retain) IBOutlet UITableView*         tblView;
@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;

@end
