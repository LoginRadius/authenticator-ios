//
//  TOTPGenerator.m


#import "TOTPGenerator.h"

@interface TOTPGenerator ()
@property(assign, nonatomic, readwrite) NSTimeInterval period;
@end

@implementation TOTPGenerator
@synthesize period = period_;

+ (NSTimeInterval)defaultPeriod {
    return 30;
}

- (id)initWithSecret:(NSData *)secret
           algorithm:(NSString *)algorithm
              digits:(NSUInteger)digits
              period:(NSTimeInterval)period {
    if ((self = [super initWithSecret:secret
                            algorithm:algorithm
                               digits:digits])) {
        
        if (period <= 0 || period > 300) {
            self = nil;
        } else {
            self.period = period;
        }
    }
    return self;
}

- (NSString *)generateOTP {
    return [self generateOTPForDate:[NSDate date]];
}

- (NSString *)generateOTPForDate:(NSDate *)date {
    if (!date) {
        // If no now date specified, use the current date.
        date = [NSDate date];
    }
    
    NSTimeInterval seconds = [date timeIntervalSince1970];
    uint64_t counter = (uint64_t)(seconds / self.period);
    return [super generateOTPForCounter:counter];
}
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    self.period = [decoder decodeDoubleForKey:@"period"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.period forKey:@"period"];
    
}
@end
