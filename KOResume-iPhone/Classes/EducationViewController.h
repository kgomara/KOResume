//
//  EducationViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011, 2012 KevinGOMara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Education.h"
#import <CoreData/CoreData.h>

@interface EducationViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>
{
    Education*                      _selectedEducation;
    NSManagedObjectContext*         __managedObjectContext;
    NSFetchedResultsController*     __fetchedResultsController;
}

@property (nonatomic, strong)               Education*                  selectedEducation;
@property (nonatomic, strong)               NSManagedObjectContext*     managedObjectContext;
@property (nonatomic, strong)               NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, strong) IBOutlet      UIScrollView*               scrollView;
@property (nonatomic, strong) IBOutlet      UITextField*                nameFld;
@property (nonatomic, strong) IBOutlet      UITextField*                degreeDateFld;
@property (nonatomic, strong) IBOutlet      UITextField*                cityFld;
@property (nonatomic, strong) IBOutlet      UITextField*                stateFld;
@property (nonatomic, strong) IBOutlet      UITextField*                titleFld;

@property (nonatomic, strong) IBOutlet      UIDatePicker*               datePicker;

- (IBAction)getEarnedDate:(id)sender;

@end
