//
//  CoverLtrViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Packages.h"

@interface CoverLtrViewController : UIViewController 
{	

}

@property (nonatomic, retain) IBOutlet	UILabel*            coverLtrLbl;
@property (nonatomic, retain) IBOutlet	UIView*             coverLtrView;
@property (nonatomic, retain) Packages*                     selectedPackage;

@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

@end
