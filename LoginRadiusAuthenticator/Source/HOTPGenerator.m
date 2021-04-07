//
//  HOTPGenerator.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "HOTPGenerator.h"

@implementation HOTPGenerator
@synthesize counter = counter_;

+ (uint64_t)defaultInitialCounter {
  return 1;
}

- (id)initWithSecret:(NSData *)secret
           algorithm:(NSString *)algorithm
              digits:(NSUInteger)digits
             counter:(uint64_t)counter {
  if ((self = [super initWithSecret:secret
                          algorithm:algorithm
                             digits:digits])) {
    counter_ = counter;
  }
  return self;
}

- (NSString *)generateOTP {
  NSUInteger counter = [self counter];
  counter += 1;
  NSString *otp = [super generateOTPForCounter:counter];
  [self setCounter:counter];
  return otp;
}
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    self.counter = [decoder decodeInt64ForKey:@"counter"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt64:self.counter forKey:@"counter"];
   
}
@end
