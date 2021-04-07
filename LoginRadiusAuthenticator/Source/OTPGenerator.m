//
//  HOTPGenerator.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "OTPGenerator.h"

#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>


static NSUInteger kPinModTable[] = {
  0,
  10,
  100,
  1000,
  10000,
  100000,
  1000000,
  10000000,
  100000000,
};

NSString *const kOTPGeneratorSHA1Algorithm = @"SHA1";
NSString *const kOTPGeneratorSHA256Algorithm = @"SHA256";
NSString *const kOTPGeneratorSHA512Algorithm = @"SHA512";
NSString *const kOTPGeneratorSHAMD5Algorithm = @"MD5";

@interface OTPGenerator ()

@end

@implementation OTPGenerator

+ (NSString *)defaultAlgorithm {
  return kOTPGeneratorSHA1Algorithm;
}

+ (NSUInteger)defaultDigits {
  return 6;
}

@synthesize algorithm = algorithm_;
@synthesize secret = secret_;
@synthesize digits = digits_;

- (id)init {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (id)initWithSecret:(NSData *)secret
           algorithm:(NSString *)algorithm
              digits:(NSUInteger)digits {
  if ((self = [super init])) {
    algorithm_ = [algorithm copy];
    secret_ = [secret copy];
    digits_ = digits;

    BOOL goodAlgorithm
      = ([algorithm isEqualToString:kOTPGeneratorSHA1Algorithm] ||
         [algorithm isEqualToString:kOTPGeneratorSHA256Algorithm] ||
         [algorithm isEqualToString:kOTPGeneratorSHA512Algorithm] ||
         [algorithm isEqualToString:kOTPGeneratorSHAMD5Algorithm]);
    if (!goodAlgorithm || digits_ > 8 || digits_ < 6 || !secret_) {
      NSLog(@"Bad args digits(min 6, max 8): %ld secret: %@ algorithm: %@",
                 digits_, secret_, algorithm_);
      self = nil;
    }
  }
  return self;
}

// Must be overriden by subclass.
- (NSString *)generateOTP {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString *)generateOTPForCounter:(uint64_t)counter {
  CCHmacAlgorithm alg;
  NSUInteger hashLength = 0;
  if ([algorithm_ isEqualToString:kOTPGeneratorSHA1Algorithm]) {
    alg = kCCHmacAlgSHA1;
    hashLength = CC_SHA1_DIGEST_LENGTH;
  } else if ([algorithm_ isEqualToString:kOTPGeneratorSHA256Algorithm]) {
    alg = kCCHmacAlgSHA256;
    hashLength = CC_SHA256_DIGEST_LENGTH;
  } else if ([algorithm_ isEqualToString:kOTPGeneratorSHA512Algorithm]) {
    alg = kCCHmacAlgSHA512;
    hashLength = CC_SHA512_DIGEST_LENGTH;
  } else if ([algorithm_ isEqualToString:kOTPGeneratorSHAMD5Algorithm]) {
    alg = kCCHmacAlgMD5;
    hashLength = CC_MD5_DIGEST_LENGTH;
  } else {
  //  _LRDevAssert(NO, @"Unknown algorithm");
    return nil;
  }

  NSMutableData *hash = [NSMutableData dataWithLength:hashLength];

  counter = NSSwapHostLongLongToBig(counter);
  NSData *counterData = [NSData dataWithBytes:&counter
                                       length:sizeof(counter)];
  CCHmacContext ctx;
  CCHmacInit(&ctx, alg, [secret_ bytes], [secret_ length]);
  CCHmacUpdate(&ctx, [counterData bytes], [counterData length]);
  CCHmacFinal(&ctx, [hash mutableBytes]);

  const char *ptr = [hash bytes];
  unsigned char offset = ptr[hashLength-1] & 0x0f;
  uint32_t truncatedHash =
    NSSwapBigIntToHost(*((uint32_t *)&ptr[offset])) & 0x7fffffff;
  uint32_t pinValue = truncatedHash % kPinModTable[digits_];

//  NSLog(@"secret: %@", secret_);
//  NSLog(@"counter: %llu", counter);
//  NSLog(@"hash: %@", hash);
//  NSLog(@"offset: %d", offset);
//  NSLog(@"truncatedHash: %d", truncatedHash);
//  NSLog(@"pinValue: %d", pinValue);

  return [NSString stringWithFormat:@"%0*u", (int)digits_, pinValue];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.algorithm = [decoder decodeObjectForKey:@"algorithm"];
    self.secret = [decoder decodeObjectForKey:@"secret"];
    self.digits = [decoder decodeIntForKey:@"digits"];
   
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.digits forKey:@"digits"];
    [encoder encodeObject:self.algorithm forKey:@"algorithm"];
    [encoder encodeObject:self.secret forKey:@"secret"];
   
}
@end
