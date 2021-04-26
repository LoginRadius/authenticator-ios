//
//  StringOperations.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-12-10.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *const kBase32Charset = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
static NSString *const kBase32Synonyms =
    @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";
static NSString *const kBase32Sep = @" -";
static NSString *const kOTPKeychainEntriesArray = @"OTPKeychainEntries";

@interface StringOperations : NSObject
+ (void) initialize ;
+ (NSDictionary *)dictionaryWithQueryString: (NSString *)queryString;
+ (NSString *)queryStringFromDcit:(NSDictionary *)dict;
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(NSString*) string;
+ (NSString *) URLDecodedString:(NSString*) string;
+ (NSString *) URLEncodedString:(NSString*) string;

@end

