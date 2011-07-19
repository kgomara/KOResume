//
//  RootViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UIViewController <UITableViewDelegate> {
	UITableView*            tblView;
    
    NSMutableArray*         submissionsArray;
    NSManagedObjectContext* managedObjectContext;
    
    UIBarButtonItem*        addButton;
}

@property (nonatomic, retain) IBOutlet UITableView*     tblView;

@property (nonatomic, retain) NSMutableArray*           submissionsArray;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* addButton;

- (void)addPackage;
- (NSString *)getSubmissionName;

@end
