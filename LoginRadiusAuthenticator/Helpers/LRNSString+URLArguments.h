//
//  LRNSString+URLArguments.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Utilities for encoding and decoding URL arguments.
@interface NSString (LRNSStringURLArgumentsAdditions)

/// Returns a string that is escaped properly to be a URL argument.
///
/// This differs from stringByAddingPercentEscapesUsingEncoding: in that it
/// will escape all the reserved characters (per RFC 3986
/// <http://www.ietf.org/rfc/rfc3986.txt>) which
/// stringByAddingPercentEscapesUsingEncoding would leave.
///
/// This will also escape '%', so this should not be used on a string that has
/// already been escaped unless double-escaping is the desired result.
///
/// NOTE: Apps targeting iOS 8 or OS X 10.10 and later should use
///       NSURLComponents and NSURLQueryItem to create properly-escaped
///       URLs instead of using these category methods.
- (NSString*)gtm_stringByEscapingForURLArgument NS_DEPRECATED(10_0, 10_10, 2_0, 8_0, "Use NSURLComponents.");

/// Returns the unescaped version of a URL argument
///
/// This has the same behavior as stringByReplacingPercentEscapesUsingEncoding:,
/// except that it will also convert '+' to space.
- (NSString*)gtm_stringByUnescapingFromURLArgument NS_DEPRECATED(10_0, 10_10, 2_0, 8_0, "Use NSURLComponents.");

@end
