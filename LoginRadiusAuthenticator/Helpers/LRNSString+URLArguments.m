//
//  LRNSString+URLArguments.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "LRNSString+URLArguments.h"

@implementation NSString (LRNSStringURLArgumentsAdditions)

- (NSString *)gtm_stringByEscapingForURLArgument {
  // Encode all the reserved characters, per RFC 3986
  // (<http://www.ietf.org/rfc/rfc3986.txt>)
  CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
#if defined(__has_feature) && __has_feature(objc_arc)
  return CFBridgingRelease(escaped);
#else
  return [(NSString *)escaped autorelease];
#endif
}

- (NSString *)gtm_stringByUnescapingFromURLArgument {
  NSMutableString *resultString = [NSMutableString stringWithString:self];
  [resultString replaceOccurrencesOfString:@"+"
                                withString:@" "
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [resultString length])];
  return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
