//
//  KOExtensions.m
//  KOResume
//
//  Created by Kevin O'Mara on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KOExtensions.h"


@implementation KOExtensions

@end

@implementation UILabel (KOExtensions)		// Category for UILabel

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

