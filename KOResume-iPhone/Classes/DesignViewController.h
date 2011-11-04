//
//  DesignViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/16/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Packages.h"

@interface DesignViewController : UIViewController <UIScrollViewDelegate> 
{
	UIImageView*                designView;
	UIScrollView*               designScrollView;
    UILabel*                    designExplanationLbl;
    NSManagedObjectContext*     managedObjectContext;
    Packages*                   selectedPackage;
    NSFetchedResultsController* fetchedResultsController;
}

@property (nonatomic, retain) IBOutlet	UIImageView*        designView;
@property (nonatomic, retain) IBOutlet	UIScrollView*       designScrollView;
@property (nonatomic, retain) IBOutlet  UILabel*            designExplanationLbl;
@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) Packages*                     selectedPackage;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

@end
