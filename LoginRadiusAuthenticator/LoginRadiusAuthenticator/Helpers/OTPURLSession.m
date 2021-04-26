//
//  OTPURLSession.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-08.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "OTPURLSession.h"
#import "OTPURL.h"
static NSString *const kOTPKeychainEntriesArray = @"OTPKeychainEntries";

static NSString *const kCategoriesArray = @"categories";

@implementation OTPURLSession

-(id)init
{
    self = [super init];
    
    if(self) {
        
    }
    return self;
}
- (void)saveCategoriesArray:(NSArray *)keychainReferences {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:keychainReferences forKey:kCategoriesArray];
    [ud synchronize];
}
- (NSMutableArray *)getCategoriesArray {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *savedKeychainReferences = [ud arrayForKey:kCategoriesArray];
    return [NSMutableArray arrayWithArray: savedKeychainReferences];
}
//array of keychain items in userdefaults
- (void)saveKeychainArray:(NSArray *)arrAll {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *keychainReferences = [arrAll valueForKeyPath:@"keychainItemRef"];
    [ud setObject:keychainReferences forKey:kOTPKeychainEntriesArray];
    [ud synchronize];
}
- (NSMutableArray *)getKeychainArray {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *savedKeychainReferences = [ud arrayForKey:kOTPKeychainEntriesArray];
    NSMutableArray* authURLs
    = [NSMutableArray arrayWithCapacity:[savedKeychainReferences count]];
    for (NSData *keychainRef in savedKeychainReferences) {
        OTPURL *authURL = [OTPURL authURLWithKeychainItemRef:keychainRef];
        if (authURL) {
            [authURLs addObject:authURL];
        }
    }
    return authURLs;
}
@end
