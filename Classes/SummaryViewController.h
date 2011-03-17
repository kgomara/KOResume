//
//  SummaryViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SummaryViewController : UIViewController {

	UIButton*  homePhone;
	UIButton*  mobilePhone;
	UILabel*   summaryLabel;

}

@property (nonatomic, retain) IBOutlet UIButton*    homePhone;
@property (nonatomic, retain) IBOutlet UIButton*    mobilePhone;
@property (nonatomic, retain) IBOutlet UILabel*     summaryLabel;

- (IBAction)phoneTapped:(id)sender;

@end
