//
//  Certification.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Resume;

@interface Certification : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * certName;
@property (nonatomic, retain) NSDate * certDate;
@property (nonatomic, retain) NSString * certID;
@property (nonatomic, retain) Resume * resume;

@end
