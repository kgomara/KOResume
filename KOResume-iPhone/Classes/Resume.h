//
//  Resume.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Certification, Education, Job, Submission;

@interface Resume : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * resumeName;
@property (nonatomic, retain) Address * address;
@property (nonatomic, retain) Certification * cert;
@property (nonatomic, retain) Education * education;
@property (nonatomic, retain) Job * job;
@property (nonatomic, retain) Submission * submission;

@end
