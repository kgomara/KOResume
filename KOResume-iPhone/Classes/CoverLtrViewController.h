//
//  CoverLtrViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CoverLtrViewController : UIViewController {
	
	UILabel*    coverLtrLbl;
	UIView*     coverLtrView;

}

@property (nonatomic, retain) IBOutlet	UILabel*    coverLtrLbl;
@property (nonatomic, retain) IBOutlet	UIView*     coverLtrView;

@end