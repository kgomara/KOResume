//
//  Education.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Resume;

@interface Education : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * schoolName;
@property (nonatomic, retain) NSString * degreeName;
@property (nonatomic, retain) NSDate * graduationDate;
@property (nonatomic, retain) Address * address;
@property (nonatomic, retain) Resume * resume;

@end
