//
//  LRURL.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "LRURL.h"
#import "HOTPGenerator.h"
#import "TOTPGenerator.h"
#import "LRStringOperations.h"

static NSString *const kLRScheme = @"otpauth";
static NSString *const kTLRScheme = @"totp";
static NSString *const kOTPService = @"com.google.otp.authentication";
static NSString *const kQueryAlgorithmKey = @"algorithm";
static NSString *const kQuerySecretKey = @"secret";
static NSString *const kQueryCounterKey = @"counter";
static NSString *const kQueryDigitsKey = @"digits";
static NSString *const kQueryPeriodKey = @"period";
static NSString *const kQueryCategoryKey = @"category";
static const NSTimeInterval kTOTPDefaultSecondsBeforeChange = 30;
NSString *const LRURLWillGenerateNewOTPWarningNotification
= @"LRURLWillGenerateNewOTPWarningNotification";
NSString *const LRURLDidGenerateNewOTPNotification
= @"LRURLDidGenerateNewOTPNotification";
NSString *const LRURLSecondsBeforeNewOTPKey
= @"LRURLSecondsBeforeNewOTP";

@interface LRURL ()

// re-declare readwrite

// Initialize an LRURL with a dictionary of attributes from a keychain.
+ (LRURL *)authURLWithKeychainDictionary:(NSDictionary *)dict;

// Initialize an LRURL object with an LR:// NSURL object.
- (id)initWithOTPGenerator:(OTPGenerator *)generator
                      name:(NSString *)name;

@end

@interface TOTPAuth ()
@property (nonatomic, readwrite, assign) NSTimeInterval lastProgress;
@property (nonatomic, readwrite, assign) BOOL warningSent;

+ (void)totpTimer:(NSTimer *)timer;
- (id)initWithTOTPURL:(NSURL *)url;
- (id)initWithName:(NSString *)name
            secret:(NSData *)secret
         algorithm:(NSString *)algorithm
            digits:(NSUInteger)digits
             query:(NSDictionary *)query;
@end

@interface HOTPAuth ()
+ (BOOL)isValidCounter:(NSString *)counter;
- (id)initWithName:(NSString *)name
            secret:(NSData *)secret
         algorithm:(NSString *)algorithm
            digits:(NSUInteger)digits
             query:(NSDictionary *)query;
@property(readwrite, copy, nonatomic) NSString *otpCode;

@end

@implementation LRURL
@synthesize category = category_;

@synthesize name = name_;
@synthesize keychainItemRef = keychainItemRef_;
@synthesize generator = generator_;
@dynamic checkCode;
@dynamic otpCode;
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.category = [decoder decodeObjectForKey:@"category"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.keychainItemRef = [decoder decodeObjectForKey:@"keychainItemRef"];
    self.generator = [decoder decodeObjectForKey:@"generator"];
    //    self.otpCode = [decoder decodeObjectForKey:@"otpCode"];
    //    self.checkCode = [decoder decodeObjectForKey:@"checkCode"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.keychainItemRef forKey:@"keychainItemRef"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.generator forKey:@"generator"];
    //    [encoder encodeObject:self.otpCode forKey:@"otpCode"];
    //    [encoder encodeObject:self.checkCode forKey:@"checkCode"];
    
}
+ (LRURL *)authURLWithURL:(NSURL *)url
                   secret:(NSData *)secret {
    LRURL *authURL = nil;
    NSString *urlScheme = [url scheme];
    if ([urlScheme isEqualToString:kTLRScheme]) {
        // Convert totp:// into otpauth://
        authURL = [[TOTPAuth alloc] initWithTOTPURL:url] ;
    } else if (![urlScheme containsString:kLRScheme]) {
        // Required (otpauth://)
    } else {
        NSString *path = [url path];
        if ([path length] > 1) {
            // Optional UTF-8 encoded human readable description (skip leading "/")
            NSString *name = [[url path] substringFromIndex:1];
            
            NSDictionary *query =
            [LRStringOperations dictionaryWithQueryString:[url query]];
            
            // Optional algorithm=(SHA1|SHA256|SHA512|MD5) defaults to SHA1
            NSString *algorithm = [query objectForKey:kQueryAlgorithmKey];
            if (!algorithm) {
                algorithm = [OTPGenerator defaultAlgorithm];
            }
            if (!secret) {
                // Required secret=Base32EncodedKey
                if([query objectForKey:kQuerySecretKey]){
                    NSString *secretString = [query objectForKey:kQuerySecretKey];
                    secret = [LRStringOperations decode:secretString];
                }
                else {
                    return nil;
                }
            }
            // Optional digits=[68] defaults to 8
            NSString *digitString = [query objectForKey:kQueryDigitsKey];
            NSUInteger digits = 0;
            if (!digitString) {
                digits = [OTPGenerator defaultDigits];
            } else {
                digits = [digitString intValue];
            }
            
            NSString *type = [url host];
            if ([type isEqualToString:@"hotp"]) {
                authURL = [[HOTPAuth alloc] initWithName:name
                                                  secret:secret
                                               algorithm:algorithm
                                                  digits:digits
                                                   query:query] ;
            } else if ([type isEqualToString:@"totp"]) {
                authURL = [[TOTPAuth alloc] initWithName:name
                                                  secret:secret
                                               algorithm:algorithm
                                                  digits:digits
                                                   query:query] ;
            }
            if([query objectForKey:kQueryCategoryKey])
                authURL.category = [query objectForKey:kQueryCategoryKey];
        }
        
        
    }
    return authURL;
}

+ (LRURL *)authURLWithKeychainItemRef:(NSData *)data {
    LRURL *authURL = nil;
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, kSecClass,
                           data, (id)kSecValuePersistentRef,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           (id)kCFBooleanTrue, kSecReturnData,
                           nil];
    NSDictionary *result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,(void *)&result);
    
    if (status == noErr) {
        authURL = [self authURLWithKeychainDictionary:result];
        [authURL setKeychainItemRef:data];
    }
    return authURL;
}

+ (LRURL *)authURLWithKeychainDictionary:(NSDictionary *)dict {
    NSData *urlData = [dict objectForKey:(id)kSecAttrGeneric];
    NSData *secretData = [dict objectForKey:(id)kSecValueData];
    NSString *urlString = [[NSString alloc] initWithData:urlData
                                                encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    return  [self authURLWithURL:url secret:secretData];
}
+ (NSData *)base64Decode:(NSString *)string {
    return [LRStringOperations decode:string];
    
}
+ (NSString *)encodeBase64:(NSData *)data {
    return  [LRStringOperations encode:data];
}
- (id)initWithOTPGenerator:(OTPGenerator *)generator
                      name:(NSString *)name {
    if ((self = [super init])) {
        if (!generator || !name) {
            self = nil;
        } else {
            self.generator = generator;
            self.name = name;
        }
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURL *)url {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

//single item in keychain
- (BOOL)saveToKeychain {
    NSString *urlString = [[self url] absoluteString];
    NSData *urlData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *attributes =
    [NSMutableDictionary dictionaryWithObject:urlData
                                       forKey:(id)kSecAttrGeneric];
    OSStatus status;
    
    if ([self isInKeychain]) {
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               (id)kSecClassGenericPassword, (id)kSecClass,
                               self.keychainItemRef, (id)kSecValuePersistentRef
                               ,
                               nil];
        
        status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
        
        NSLog(@"SecItemUpdate(%@, %@) = %ld", query, attributes, status);
    } else {
        [attributes setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [attributes setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnPersistentRef];
        [attributes setObject:self.generator.secret forKey:(id)kSecValueData];
        
        [attributes setObject:kOTPService forKey:(id)kSecAttrService];
        NSData *ref = nil;
        
        // The name here has to be unique or else we will get a errSecDuplicateItem
        // so if we have two items with the same name, we will just append a
        // random number on the end until we get success. We will try at max of
        // 1000 times so as to not hang in shut down.
        // We do not display this name to the user, so anything will do.
        NSString *name = self.name;
        for (int i = 0; i < 1000; i++) {
            [attributes setObject:name forKey:(id)kSecAttrAccount];
            status = SecItemAdd((__bridge CFDictionaryRef)attributes,(void *)&ref);
            
            if (status == errSecDuplicateItem) {
                name = [NSString stringWithFormat:@"%@.%ld", self.name, random()];
            } else {
                break;
            }
        }
        NSLog(@"SecItemAdd(%@, %@) = %ld", attributes, ref, status);
        
        if (status == noErr) {
            self.keychainItemRef = ref;
        }
    }
    
    return status == noErr;
}

- (BOOL)removeFromKeychain {
    if (![self isInKeychain]) {
        return NO;
    }
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           [self keychainItemRef], (id)kSecValuePersistentRef,
                           nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    
    NSLog(@"SecItemDelete(%@) = %ld", query, status);
    
    if (status == noErr) {
        [self setKeychainItemRef:nil];
    }
    return status == noErr;
}

- (BOOL)isInKeychain {
    return self.keychainItemRef != nil;
}

- (void)generateNextOTPCode {
    NSLog(@"Called generateNextOTPCode on a non-HOTP generator");
}

- (NSString*)checkCode {
    return [self.generator generateOTPForCounter:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> Name: %@ ref: %p checkCode: %@",
            [self class], self, self.name, self.keychainItemRef, self.checkCode];
}

#pragma mark -
#pragma mark URL Validation

@end

@implementation TOTPAuth
static NSString *const TOTPAuthTimerNotification
= @"TOTPAuthTimerNotification";

@synthesize generationAdvanceWarning = generationAdvanceWarning_;
@synthesize lastProgress = lastProgress_;
@synthesize warningSent = warningSent_;

+ (void)initialize {
    static NSTimer *sTOTPTimer = nil;
    if (!sTOTPTimer) {
        sTOTPTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(totpTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}
+ (void)totpTimer:(NSTimer *)timer {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TOTPAuthTimerNotification object:self];
}

- (id)initWithOTPGenerator:(OTPGenerator *)generator
                      name:(NSString *)name {
    if ((self = [super initWithOTPGenerator:generator
                                       name:name])) {
        [self setGenerationAdvanceWarning:kTOTPDefaultSecondsBeforeChange];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(totpTimerFunc:)
                                                     name:TOTPAuthTimerNotification
                                                   object:nil];
    }
    return self;
}
- (id)initWithSecret:(NSData *)secret name:(NSString *)name {
    TOTPGenerator *generator
    = [[TOTPGenerator alloc] initWithSecret:secret
                                  algorithm:[TOTPGenerator defaultAlgorithm]
                                     digits:[TOTPGenerator defaultDigits]
                                     period:[TOTPGenerator defaultPeriod]];
    return [self initWithOTPGenerator:generator
                                 name:name];
}
// totp:// urls are generated by the GAIA smsauthconfig page and implement
// a subset of the functionality available in LR:// urls, so we just
// translate to that internally.
- (id)initWithTOTPURL:(NSURL *)url {
    NSMutableString *name = nil;
    if ([[url user] length]) {
        name = [NSMutableString stringWithString:[url user]];
    }
    if ([url host]) {
        [name appendFormat:@"@%@", [url host]];
    }
    NSData *secret = [LRStringOperations decode:[url fragment]];
    return [self initWithSecret:secret name:name];
}

- (id)initWithName:(NSString *)name
            secret:(NSData *)secret
         algorithm:(NSString *)algorithm
            digits:(NSUInteger)digits
             query:(NSDictionary *)query {
    NSString *periodString = [query objectForKey:kQueryPeriodKey];
    NSTimeInterval period = 0;
    if (periodString) {
        period = [periodString doubleValue];
    } else {
        period = [TOTPGenerator defaultPeriod];
    }
    
    TOTPGenerator *generator
    = [[TOTPGenerator alloc] initWithSecret:secret
                                  algorithm:algorithm
                                     digits:digits
                                     period:period] ;
    
    if ((self = [self initWithOTPGenerator:generator
                                      name:name])) {
        self.lastProgress = period;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)otpCode {
    return [self.generator generateOTP];
}

- (void)totpTimerFunc:(NSTimer *)timer {
    TOTPGenerator *generator = (TOTPGenerator *)[self generator];
    NSTimeInterval delta = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval period = [generator period];
    uint64_t progress = (uint64_t)delta % (uint64_t)period;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (progress == 0 || progress > self.lastProgress) {
        [nc postNotificationName:LRURLDidGenerateNewOTPNotification object:self];
        self.lastProgress = period;
        self.warningSent = NO;
    } else if (progress > period - self.generationAdvanceWarning
               ) {
        NSNumber *warning = [NSNumber numberWithInt:ceil(period - progress)];
        NSDictionary *userInfo
        = [NSDictionary dictionaryWithObject:warning
                                      forKey:LRURLSecondsBeforeNewOTPKey];
        
        [nc postNotificationName:LRURLWillGenerateNewOTPWarningNotification
                          object:self
                        userInfo:userInfo];
        self.warningSent = YES;
    }
}

- (NSURL *)url {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    TOTPGenerator *generator = (TOTPGenerator *)[self generator];
    Class generatorClass = [generator class];
    
    NSString *algorithm = [generator algorithm];
    if (![algorithm isEqualToString:[generatorClass defaultAlgorithm]]) {
        [query setObject:algorithm forKey:kQueryAlgorithmKey];
    }
    
    NSUInteger digits = [generator digits];
    if (digits != [generatorClass defaultDigits]) {
        id val = [NSNumber numberWithUnsignedInteger:digits];
        [query setObject:val forKey:kQueryDigitsKey];
    }
    
    NSTimeInterval period = [generator period];
    if (fpclassify(period - [generatorClass defaultPeriod]) != FP_ZERO) {
        id val = [NSNumber numberWithUnsignedInteger:period];
        [query setObject:val forKey:kQueryPeriodKey];
    }
    if(self.category)
        [query setObject:self.category forKey:kQueryCategoryKey];
    NSLog(@"%@",[NSString stringWithFormat:@"%@://totp/%@?%@",
                 kLRScheme,
                 [LRStringOperations URLEncodedString:self.name],
                 [LRStringOperations queryStringFromDcit:query]]);
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://totp/%@?%@",
                                 kLRScheme,
                                 [LRStringOperations URLEncodedString:self.name],
                                 [LRStringOperations queryStringFromDcit:query]]];
}

@end

@implementation HOTPAuth

@synthesize otpCode = otpCode_;

- (id)initWithOTPGenerator:(OTPGenerator *)generator
                      name:(NSString *)name {
    if ((self = [super initWithOTPGenerator:generator name:name])) {
        uint64_t counter = [(HOTPGenerator *)generator counter];
        self.otpCode = [generator generateOTPForCounter:counter];
    }
    return self;
}


- (id)initWithSecret:(NSData *)secret name:(NSString *)name {
    HOTPGenerator *generator
    = [[HOTPGenerator alloc] initWithSecret:secret
                                  algorithm:[HOTPGenerator defaultAlgorithm]
                                     digits:[HOTPGenerator defaultDigits]
                                    counter:[HOTPGenerator defaultInitialCounter]];
    return [self initWithOTPGenerator:generator name:name];
}

- (id)initWithName:(NSString *)name
            secret:(NSData *)secret
         algorithm:(NSString *)algorithm
            digits:(NSUInteger)digits
             query:(NSDictionary *)query {
    NSString *counterString = [query objectForKey:kQueryCounterKey];
    if ([[self class] isValidCounter:counterString]) {
        NSScanner *scanner = [NSScanner scannerWithString:counterString];
        uint64_t counter;
        BOOL goodScan = [scanner scanUnsignedLongLong:&counter];
        // Good scan should always be good based on the isValidCounter check above.
        NSAssert(goodScan, @"goodscan should be true: %c", goodScan);
        HOTPGenerator *generator
        = [[HOTPGenerator alloc] initWithSecret:secret
                                      algorithm:algorithm
                                         digits:digits
                                        counter:counter] ;
        self = [self initWithOTPGenerator:generator
                                     name:name];
    } else {
        NSLog(@"invalid counter: %@", counterString);
        self = [super initWithOTPGenerator:nil name:nil];
        self = nil;
    }
    return self;
}

- (void)generateNextOTPCode {
    self.otpCode = [[self generator] generateOTP];
    [self saveToKeychain];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:LRURLDidGenerateNewOTPNotification object:self];
}

- (NSURL *)url {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    HOTPGenerator *generator = (HOTPGenerator *)[self generator];
    Class generatorClass = [generator class];
    
    NSString *algorithm = [generator algorithm];
    if (![algorithm isEqualToString:[generatorClass defaultAlgorithm]]) {
        [query setObject:algorithm forKey:kQueryAlgorithmKey];
    }
    
    NSUInteger digits = [generator digits];
    if (digits != [generatorClass defaultDigits]) {
        id val = [NSNumber numberWithUnsignedInteger:digits];
        [query setObject:val forKey:kQueryDigitsKey];
    }
    if(self.category)
        [query setObject:self.category forKey:kQueryCategoryKey];
    
    uint64_t counter = [generator counter];
    id val = [NSNumber numberWithUnsignedLongLong:counter];
    [query setObject:val forKey:kQueryCounterKey];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://hotp/%@?%@",
                                 kLRScheme,
                                 [LRStringOperations URLEncodedString:self.name],
                                 [LRStringOperations queryStringFromDcit:query] ]];
}

+ (BOOL)isValidCounter:(NSString *)counter {
    NSCharacterSet *nonDigits =
    [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange pos = [counter rangeOfCharacterFromSet:nonDigits];
    return pos.location == NSNotFound;
}

@end

