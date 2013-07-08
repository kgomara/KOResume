//
//  InfoViewController.h
//  KOResume
//
//  Created by Kevin O'Mara on 7/6/13.
//  Copyright (c) 2013 O'Mara Consulting Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton     *OK_Btn;
@property (nonatomic, strong) IBOutlet UIImageView  *contentPaneBackground;

- (IBAction)handleOKBtn:(id)sender;

@end
