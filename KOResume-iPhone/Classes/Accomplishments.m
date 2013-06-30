#import "Accomplishments.h"
#import "Jobs.h"

@implementation Accomplishments

NSString *const KOAccomplishmentsEntity      = @"Accomplishments";

-(void)logAllFields
{
    DLog();
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    
    NSString *first30   = [self.summary substringWithRange: NSMakeRange(0, 29)];
    
    NSLog(@"======================= Accomplishments =======================");
    NSLog(@"   name              = %@", self.name);
    NSLog(@"   created_date      = %@", [dateFormatter stringFromDate: self.created_date]);
    NSLog(@"   sequence_number   = %@", [self.sequence_number stringValue]);
    NSLog(@"   in job            = %@", self.job.name);
    NSLog(@"   summary           = %@", first30);
    NSLog(@"===================== end Accomplishments =====================");
    
}

@end
