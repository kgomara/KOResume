//
//  Accomplishment.h
//  KOResume
//
//  Created by Kevin O'Mara on 6/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Job;

@interface Accomplishment : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * accomplishmentDesc;
@property (nonatomic, retain) Job * job;

@end