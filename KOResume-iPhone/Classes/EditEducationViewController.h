//
//  EditEducationViewController.h
//  KOResume
//
//  Created by OMARA KEVIN on 11/13/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EditEducationViewController : UITableViewController
{
    
}

@property (nonatomic, strong)           NSMutableArray*             educationArray;

@property (nonatomic, strong)           NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, strong)           NSFetchedResultsController* fetchedResultsController;

// TableViewCell fields
@property (nonatomic, strong) IBOutlet  UILabel*                    nameLbl;
@property (nonatomic, strong) IBOutlet  UILabel*                    degreeDate;
@property (nonatomic, strong) IBOutlet  UILabel*                    cityLbl;
@property (nonatomic, strong) IBOutlet  UILabel*                    stateLbl;
@property (nonatomic, strong) IBOutlet  UILabel*                    titleLbl;

@end
