//
//  HOTPGenerator.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

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
