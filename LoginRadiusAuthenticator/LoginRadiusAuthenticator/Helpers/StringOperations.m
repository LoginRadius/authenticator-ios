//
//  StringOperations.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-12-10.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "StringOperations.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#import "StringEncoding.h"

@implementation StringOperations
#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))




+ (NSDictionary *)dictionaryWithQueryString: (NSString *)queryString {
    if (queryString.length == 0) {
        return @{};
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count == 2)
        {
            NSString *key = elements[0];
            NSString *value = elements[1];
            NSString *decodedKey = [self URLDecodedString:key];
            NSString *decodedValue = [self URLDecodedString:value];
            
            if (![key isEqualToString:decodedKey])
                key = decodedKey;
            
            if (![value isEqualToString:decodedValue])
                value = decodedValue;
            
            [dictionary setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

+ (NSString*) encode:(NSData*) rawBytes {
    StringEncoding *coder =
    [StringEncoding stringEncodingWithString:kBase32Charset];
    [coder addDecodeSynonyms:kBase32Synonyms];
    [coder ignoreCharacters:kBase32Sep];
    return [coder encode:rawBytes error:nil];
}
+ (NSData*) decode:(NSString*) string {
    StringEncoding *coder =
    [StringEncoding stringEncodingWithString:kBase32Charset];
    [coder addDecodeSynonyms:kBase32Synonyms];
    [coder ignoreCharacters:kBase32Sep];
    return [coder decode:string error:nil];
}

+ (NSString *) URLDecodedString:(NSString*) string  {
    NSMutableString *resultString = [NSMutableString stringWithString:string];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByRemovingPercentEncoding];
}

+ (NSString *) URLEncodedString:(NSString*) string  {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
#if defined(__has_feature) && __has_feature(objc_arc)
    return CFBridgingRelease(escaped);
#else
    return (NSString *)escaped;
#endif
}
+ (NSString *)queryStringFromDcit:(NSDictionary *)dict
{
    NSMutableArray* arguments = [NSMutableArray arrayWithCapacity:[dict count]];
    NSString* key;
    for (key in dict) {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                              [self URLEncodedString:key],
                              [self URLEncodedString: [[dict objectForKey:key] description]
                               ]]];
    }
    
    return [arguments componentsJoinedByString:@"&"];
}
@end
