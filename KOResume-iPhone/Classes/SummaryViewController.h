//
//  SummaryViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 KevinGOMara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resumes.h"
#import <CoreData/CoreData.h>

@interface SummaryViewController : UIViewController 
{

}

@property (nonatomic, strong) IBOutlet UITextField*                 nameFld;
@property (nonatomic, strong) IBOutlet UITextField*                 street1Fld;
@property (nonatomic, strong) IBOutlet UITextField*                 cityFld;
@property (nonatomic, strong) IBOutlet UITextField*                 stateFld;
@property (nonatomic, strong) IBOutlet UITextField*                 zipFld;
@property (nonatomic, strong) IBOutlet UITextField*                 homePhoneFld;
@property (nonatomic, strong) IBOutlet UITextField*                 mobilePhoneFld;
@property (nonatomic, strong) IBOutlet UITextField*                 emailFld;
@property (nonatomic, strong) IBOutlet UITextView*                  summaryFld;
@property (nonatomic, strong)          Resumes*                     selectedResume;

@property (nonatomic, strong)          NSManagedObjectContext*      managedObjectContext;
@property (nonatomic, strong)          NSFetchedResultsController*  fetchedResultsController;

- (IBAction)phoneTapped:(id)sender;
- (IBAction)emailTapped:(id)sender;

@end
