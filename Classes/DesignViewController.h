//
//  DesignViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DesignViewController : UIViewController <UIScrollViewDelegate> {

	UIView*         designView;
	UIScrollView*   designScrollView;
}

@property (nonatomic, retain) IBOutlet	UIView*         designView;
@property (nonatomic, retain) IBOutlet	UIScrollView*   designScrollView;

@end
