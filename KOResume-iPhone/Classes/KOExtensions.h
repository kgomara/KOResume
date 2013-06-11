//
//  KOExtensions.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011-2013 O'Mara Consulting Associates. All rights reserved.
//

#import <Foundation/Foundation.h>


// Categories added to UIImage
@interface UIImage (KOExtensions)

+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end

// Categories added to UIView
@interface UIView (KOExtensions)

- (void)fadeSubViewIn:(UIView*)subView;
- (void)fadeSubViewOut:(UIView*)subView;

@end

/****************************************************************************************
 * Category for UILabel to calculate a frame size that will allow a long string to wrap
 * within a fixed label width
 ****************************************************************************************
 */
@interface UILabel (KOExtensions)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth;

@end

@interface KOExtensions : NSObject 

+ (void)showAlertWithMessageAndType:(NSString*)theMessage 
                          alertType:(NSString*)theType;
+ (void)showErrorWithMessage:(NSString*)theMessage;
+ (void)showWarningWithMessage:(NSString*)theMessage;
+ (void)dismissKeyboard;

@end

