// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Jobs.m instead.

#import "_Jobs.h"

@implementation JobsID
@end

@implementation _Jobs

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Jobs" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Jobs";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Jobs" inManagedObjectContext:moc_];
}

- (JobsID*)objectID {
	return (JobsID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic city;






@dynamic created_date;






@dynamic end_date;






@dynamic name;






@dynamic start_date;






@dynamic state;






@dynamic summary;






@dynamic title;






@dynamic uri;






@dynamic accomplishment;

	

@dynamic resume;

	





@end
