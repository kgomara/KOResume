// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Resumes.m instead.

#import "_Resumes.h"

@implementation ResumesID
@end

@implementation _Resumes

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Resumes" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Resumes";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Resumes" inManagedObjectContext:moc_];
}

- (ResumesID*)objectID {
	return (ResumesID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic city;






@dynamic created_date;






@dynamic home_phone;






@dynamic mobile_phone;






@dynamic name;






@dynamic postal_code;






@dynamic state;






@dynamic street1;






@dynamic street2;






@dynamic summary;






@dynamic education;

	

@dynamic job;

	

@dynamic package;

	





@end
