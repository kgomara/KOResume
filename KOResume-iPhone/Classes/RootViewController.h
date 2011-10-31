//
//  RootViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UIViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate> {
	UITableView*            tblView;
    
    NSMutableArray*         packagesArray;
    
//    UIButton*               addButton;
//    UIBarButtonItem*        editButton;
}

@property (nonatomic, retain) IBOutlet UITableView*         tblView;

@property (nonatomic, retain) NSMutableArray*               packagesArray;
@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

//@property (nonatomic, retain) IBOutlet UIButton*            addButton;
//@property (nonatomic, retain) IBOutlet UIBarButtonItem*     editButton;

@end
