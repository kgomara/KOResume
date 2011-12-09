//
//  CoverLtrViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Packages.h"

@interface CoverLtrViewController : UIViewController <UITextViewDelegate>
{	

}

@property (nonatomic, strong) IBOutlet  UIScrollView*       scrollView;
@property (nonatomic, strong) IBOutlet	UITextView*         coverLtrFld;
@property (nonatomic, strong) IBOutlet	UIView*             coverLtrView;
@property (nonatomic, strong) IBOutlet  UIImageView*        contentPaneBackground;
@property (nonatomic, strong) Packages*                     selectedPackage;

@property (nonatomic, strong) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController*   fetchedResultsController;

@end
