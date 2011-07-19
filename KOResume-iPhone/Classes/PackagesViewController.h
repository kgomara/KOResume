//
//  PackagesViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface PackagesViewController : UIViewController <UITableViewDelegate> {
    UITableView*            tblView;
    NSManagedObjectContext* managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UITableView*     tblView;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;


@end
