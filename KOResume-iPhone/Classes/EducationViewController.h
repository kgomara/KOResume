//
//  EducationViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resumes.h"
#import <CoreData/CoreData.h>

@interface EducationViewController : UIViewController 
{

}

@property (nonatomic, retain)               Resumes*                    selectedResume;

@property (nonatomic, retain)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, retain)               NSFetchedResultsController* fetchedResultsController;


@end
