//
//  SummaryViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SummaryViewController : UIViewController {
	IBOutlet UIButton	*homePhone;
	IBOutlet UIButton	*mobilePhone;
	IBOutlet UILabel	*summaryLabel;

}

@property (nonatomic, retain) UIButton	*homePhone;
@property (nonatomic, retain) UIButton	*mobilePhone;
@property (nonatomic, retain) UILabel	*summaryLabel;

- (IBAction)phoneTapped:(id)sender;

@end
