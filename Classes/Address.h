//
//  Address.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Education, Job, Resume;

@interface Address : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSString * Sstate;
@property (nonatomic, retain) NSNumber * zipCode;
@property (nonatomic, retain) NSString * street1;
@property (nonatomic, retain) NSNumber * mobilePhone;
@property (nonatomic, retain) NSNumber * homePhone;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) Resume * resume;
@property (nonatomic, retain) Job * job;
@property (nonatomic, retain) Education * education;

@end
