//
//  KOExtensions.h
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KOExtensions : NSObject {

}

@end

/****************************************************************************************
 * Category for UILabel to calculate a frame size that will allow a long string to wrap
 * within a fixed label width
 ****************************************************************************************/
@interface UILabel (KOExtensions)
- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth;
@end

