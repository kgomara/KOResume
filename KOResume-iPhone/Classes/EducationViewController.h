//
//  EducationViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Education.h"
#import <CoreData/CoreData.h>

@interface EducationViewController : UIViewController 
{

}

@property (nonatomic, retain)               Education*                  selectedEducation;

@property (nonatomic, retain)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, retain)               NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, strong) IBOutlet  UITextField*                    nameFld;
@property (nonatomic, strong) IBOutlet  UITextField*                    degreeDateFld;
@property (nonatomic, strong) IBOutlet  UITextField*                    cityFld;
@property (nonatomic, strong) IBOutlet  UITextField*                    stateFld;
@property (nonatomic, strong) IBOutlet  UITextField*                    titleFld;


@end
