//
//  HOTPGenerator.h


#import "OTPGenerator.h"

@interface HOTPGenerator : OTPGenerator<NSCoding>

// The counter, incremented on each generated OTP.
@property(assign, nonatomic) uint64_t counter;

+ (uint64_t)defaultInitialCounter;

- (id)initWithSecret:(NSData *)secret
           algorithm:(NSString *)algorithm
              digits:(NSUInteger)digits
             counter:(uint64_t)counter;
@end
