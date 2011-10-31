// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Resumes.h instead.

#import <CoreData/CoreData.h>


@class Education;
@class Jobs;
@class Packages;













@interface ResumesID : NSManagedObjectID {}
@end

@interface _Resumes : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResumesID*)objectID;




@property (nonatomic, retain) NSString *city;


//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *created_date;


//- (BOOL)validateCreated_date:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *home_phone;


//- (BOOL)validateHome_phone:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *mobile_phone;


//- (BOOL)validateMobile_phone:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *postal_code;


//- (BOOL)validatePostal_code:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *sequence_number;


@property short sequence_numberValue;
- (short)sequence_numberValue;
- (void)setSequence_numberValue:(short)value_;

//- (BOOL)validateSequence_number:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *state;


//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *street1;


//- (BOOL)validateStreet1:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *street2;


//- (BOOL)validateStreet2:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *summary;


//- (BOOL)validateSummary:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) Education* education;

//- (BOOL)validateEducation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Jobs* job;

//- (BOOL)validateJob:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Packages* package;

//- (BOOL)validatePackage:(id*)value_ error:(NSError**)error_;




@end

@interface _Resumes (CoreDataGeneratedAccessors)

@end

@interface _Resumes (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSDate*)primitiveCreated_date;
- (void)setPrimitiveCreated_date:(NSDate*)value;




- (NSString*)primitiveHome_phone;
- (void)setPrimitiveHome_phone:(NSString*)value;




- (NSString*)primitiveMobile_phone;
- (void)setPrimitiveMobile_phone:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePostal_code;
- (void)setPrimitivePostal_code:(NSString*)value;




- (NSNumber*)primitiveSequence_number;
- (void)setPrimitiveSequence_number:(NSNumber*)value;

- (short)primitiveSequence_numberValue;
- (void)setPrimitiveSequence_numberValue:(short)value_;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveStreet1;
- (void)setPrimitiveStreet1:(NSString*)value;




- (NSString*)primitiveStreet2;
- (void)setPrimitiveStreet2:(NSString*)value;




- (NSString*)primitiveSummary;
- (void)setPrimitiveSummary:(NSString*)value;





- (Education*)primitiveEducation;
- (void)setPrimitiveEducation:(Education*)value;



- (Jobs*)primitiveJob;
- (void)setPrimitiveJob:(Jobs*)value;



- (Packages*)primitivePackage;
- (void)setPrimitivePackage:(Packages*)value;


@end
