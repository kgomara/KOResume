//
//  EditCoverLtrViewController.h
//  KOResume
//
//  Created by OMARA KEVIN on 11/5/11.
//  Copyright (c) 2011 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Packages.h"

@interface EditCoverLtrViewController : UIViewController <UITextViewDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet UIView*              contentView;
@property (nonatomic, retain) IBOutlet UIImageView*         contentImage;
@property (nonatomic, retain) IBOutlet UITextView*          textView;
@property (nonatomic, retain) Packages*                     selectedPackage;

@property (nonatomic, retain) NSManagedObjectContext*       managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController*   fetchedResultsController;

@end
