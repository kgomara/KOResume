//
//  AccomplishmentViewController.h
//  KOResume
//
//  Created by OMARA KEVIN on 12/4/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Accomplishments.h"

@interface AccomplishmentViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate,
                                                            UIScrollViewDelegate>
{
    Accomplishments*                    _selectedAccomplishment;
    NSManagedObjectContext*             __managedObjectContext;
    NSFetchedResultsController*         __fetchedResultsController;
}

@property (nonatomic, strong) Accomplishments*              selectedAccomplishment;
@property (nonatomic, strong) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController*   fetchedResultsController;

@property (nonatomic, strong) IBOutlet UIScrollView*        scrollView;
@property (nonatomic, strong) IBOutlet UITextField*         accomplishmentName;
@property (nonatomic, strong) IBOutlet UITextView*          accomplishmentSummary;

@end
