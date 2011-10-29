// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Packages.m instead.

#import "_Packages.h"

@implementation PackagesID
@end

@implementation _Packages

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Packages" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Packages";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Packages" inManagedObjectContext:moc_];
}

- (PackagesID*)objectID {
	return (PackagesID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic cover_ltr;






@dynamic created_date;






@dynamic name;






@dynamic resume;

	





@end
