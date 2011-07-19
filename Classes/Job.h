//
//  Job.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Accomplishment, Address, Resume;

@interface Job : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * responsibilities;
@property (nonatomic, retain) NSString * companyURL;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSDate * etartDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Resume * resume;
@property (nonatomic, retain) Address * address;
@property (nonatomic, retain) Accomplishment * accomplishment;

@end
