//
//  StringEncoding.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>

// A generic class for arbitrary base-2 to 128 string encoding and decoding.
@interface StringEncoding : NSObject {
 @private
  NSData *charMapData_;
  char *charMap_;
  int reverseCharMap_[128];
  int shift_;
  int mask_;
  BOOL doPad_;
  char paddingChar_;
  int padLen_;
}

// Create a new, autoreleased StringEncoding object with a standard encoding.
+ (id)binaryStringEncoding;
+ (id)hexStringEncoding;
+ (id)rfc4648Base32StringEncoding;
+ (id)rfc4648Base32HexStringEncoding;
+ (id)crockfordBase32StringEncoding;
+ (id)rfc4648Base64StringEncoding;
+ (id)rfc4648Base64WebsafeStringEncoding;

// Create a new, autoreleased StringEncoding object with the given string,
// as described below.
+ (id)stringEncodingWithString:(NSString *)string;

// Initialize a new StringEncoding object with the string.
//
// The length of the string must be a power of 2, at least 2 and at most 128.
// Only 7-bit ASCII characters are permitted in the string.
//
// These characters are the canonical set emitted during encoding.
// If the characters have alternatives (e.g. case, easily transposed) then use
// addDecodeSynonyms: to configure them.
- (id)initWithString:(NSString *)string;

// Add decoding synonyms as specified in the synonyms argument.
//
// It should be a sequence of one previously reverse mapped character,
// followed by one or more non-reverse mapped character synonyms.
// Only 7-bit ASCII characters are permitted in the string.
//
// e.g. If a LRStringEncoder object has already been initialised with a set
// of characters excluding I, L and O (to avoid confusion with digits) and you
// want to accept them as digits you can call addDecodeSynonyms:@"0oO1iIlL".
- (void)addDecodeSynonyms:(NSString *)synonyms;

// A sequence of characters to ignore if they occur during encoding.
// Only 7-bit ASCII characters are permitted in the string.
- (void)ignoreCharacters:(NSString *)chars;

// Indicates whether padding is performed during encoding.
- (BOOL)doPad;
- (void)setDoPad:(BOOL)doPad;

// Sets the padding character to use during encoding.
- (void)setPaddingChar:(char)c;

// Encode a raw binary buffer to a 7-bit ASCII string.
- (NSString *)encode:(NSData *)data __attribute__((deprecated("Use encode:error:")))
    NS_SWIFT_UNAVAILABLE("Use encode:error: mapped to encode(_ data:) throws");
- (NSString *)encodeString:(NSString *)string __attribute__((deprecated("Use encodeString:error:")))
    NS_SWIFT_UNAVAILABLE("Use encode:error: mapped to encode(_ string:) throws");

- (NSString *)encode:(NSData *)data error:(NSError **)error;
- (NSString *)encodeString:(NSString *)string error:(NSError **)error;

// Decode a 7-bit ASCII string to a raw binary buffer.
- (NSData *)decode:(NSString *)string __attribute__((deprecated("Use decode:error:")))
    NS_SWIFT_UNAVAILABLE("Use decode:error: mapped to decode(_ string:) throws");
- (NSString *)stringByDecoding:(NSString *)string __attribute__((deprecated("Use stringByDecoding:error:")))
    NS_SWIFT_UNAVAILABLE("Use stringByDecoding:error: mapped to string(byDecoding string:) throws");

- (NSData *)decode:(NSString *)string error:(NSError **)error;
- (NSString *)stringByDecoding:(NSString *)string error:(NSError **)error;

@end

FOUNDATION_EXPORT NSString *const StringEncodingErrorDomain;
FOUNDATION_EXPORT NSString *const StringEncodingBadCharacterIndexKey;  // NSNumber

typedef NS_ENUM(NSInteger, StringEncodingError) {
  // Unable to convert a buffer to NSASCIIStringEncoding.
  StringEncodingErrorUnableToConverToAscii = 1024,
  // Unable to convert a buffer to NSUTF8StringEncoding.
  StringEncodingErrorUnableToConverToUTF8,
  // Encountered a bad character.
  // StringEncodingBadCharacterIndexKey will have the index of the character.
  StringEncodingErrorUnknownCharacter,
  // The data had a padding character in the middle of the data. Padding characters
  // can only be at the end.
  StringEncodingErrorExpectedPadding,
  // There is unexpected data at the end of the data that could not be decoded.
  StringEncodingErrorIncompleteTrailingData,
};
