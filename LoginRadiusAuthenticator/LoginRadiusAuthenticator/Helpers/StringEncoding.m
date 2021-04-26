//
//  StringEncoding.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "StringEncoding.h"

// Give ourselves a consistent way to do inlines.  Apple's macros even use
// a few different actual definitions, so we're based off of the foundation
// one.
#if !defined(LR_INLINE)
#if (defined (__GNUC__) && (__GNUC__ == 4)) || defined (__clang__)
#define LR_INLINE static __inline__ __attribute__((always_inline))
#else
#define LR_INLINE static __inline__
#endif
#endif
NSString *const StringEncodingErrorDomain = @"com.google.StringEncodingErrorDomain";
NSString *const StringEncodingBadCharacterIndexKey = @"StringEncodingBadCharacterIndexKey";

enum {
    kUnknownChar = -1,
    kPaddingChar = -2,
    kIgnoreChar = -3
};

@implementation StringEncoding

+ (id)binaryStringEncoding {
    return [self stringEncodingWithString:@"01"];
}

+ (id)hexStringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"0123456789ABCDEF"];
    [ret addDecodeSynonyms:@"AaBbCcDdEeFf"];
    return ret;
}

+ (id)rfc4648Base32StringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"];
    [ret setPaddingChar:'='];
    [ret setDoPad:YES];
    return ret;
}

+ (id)rfc4648Base32HexStringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"0123456789ABCDEFGHIJKLMNOPQRSTUV"];
    [ret setPaddingChar:'='];
    [ret setDoPad:YES];
    return ret;
}

+ (id)crockfordBase32StringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"0123456789ABCDEFGHJKMNPQRSTVWXYZ"];
    [ret addDecodeSynonyms:
     @"0oO1iIlLAaBbCcDdEeFfGgHhJjKkMmNnPpQqRrSsTtVvWwXxYyZz"];
    return ret;
}

+ (id)rfc4648Base64StringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"];
    [ret setPaddingChar:'='];
    [ret setDoPad:YES];
    return ret;
}

+ (id)rfc4648Base64WebsafeStringEncoding {
    StringEncoding *ret = [self stringEncodingWithString:
                             @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"];
    [ret setPaddingChar:'='];
    [ret setDoPad:YES];
    return ret;
}

LR_INLINE int lcm(int a, int b) {
    for (int aa = a, bb = b;;) {
        if (aa == bb)
            return aa;
        else if (aa < bb)
            aa += a;
        else
            bb += b;
    }
}

+ (id)stringEncodingWithString:(NSString *)string {
    return [[self alloc] initWithString:string] ;
}

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        charMapData_ = [string dataUsingEncoding:NSASCIIStringEncoding] ;
        if (!charMapData_) {
            return nil;
        }
        charMap_ = (char *)[charMapData_ bytes];
        NSUInteger length = [charMapData_ length];
        if (length < 2 || length > 128 || length & (length - 1)) {
            return nil;
        }
        
        memset(reverseCharMap_, kUnknownChar, sizeof(reverseCharMap_));
        for (unsigned int i = 0; i < length; i++) {
            if (reverseCharMap_[(int)charMap_[i]] != kUnknownChar) {
                return nil;
            }
            reverseCharMap_[(int)charMap_[i]] = i;
        }
        
        for (NSUInteger i = 1; i < length; i <<= 1)
        shift_++;
        mask_ = (1 << shift_) - 1;
        padLen_ = lcm(8, shift_) / shift_;
    }
    return self;
}

- (NSString *)description {
    // TODO(iwade) track synonyms
    return [NSString stringWithFormat:@"<Base%d StringEncoder: %@>",
            1 << shift_, charMapData_];
}

- (void)addDecodeSynonyms:(NSString *)synonyms {
    char *buf = (char *)[synonyms cStringUsingEncoding:NSASCIIStringEncoding];
    int val = kUnknownChar;
    while (*buf) {
        int c = *buf++;
        if (reverseCharMap_[c] == kUnknownChar) {
            reverseCharMap_[c] = val;
        } else {
            val = reverseCharMap_[c];
        }
    }
}

- (void)ignoreCharacters:(NSString *)chars {
    char *buf = (char *)[chars cStringUsingEncoding:NSASCIIStringEncoding];
    while (*buf) {
        int c = *buf++;
        
        reverseCharMap_[c] = kIgnoreChar;
    }
}

- (BOOL)doPad {
    return doPad_;
}

- (void)setDoPad:(BOOL)doPad {
    doPad_ = doPad;
}

- (void)setPaddingChar:(char)c {
    paddingChar_ = c;
    reverseCharMap_[(int)c] = kPaddingChar;
}

- (NSString *)encode:(NSData *)inData {
    return [self encode:inData error:NULL];
}

- (NSString *)encode:(NSData *)inData error:(NSError **)error {
    NSUInteger inLen = [inData length];
    if (inLen <= 0) {
        return @"";
    }
    unsigned char *inBuf = (unsigned char *)[inData bytes];
    NSUInteger inPos = 0;
    
    NSUInteger outLen = (inLen * 8 + shift_ - 1) / shift_;
    if (doPad_) {
        outLen = ((outLen + padLen_ - 1) / padLen_) * padLen_;
    }
    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;
    
    unsigned int buffer = inBuf[inPos++];
    int bitsLeft = 8;
    while (bitsLeft > 0 || inPos < inLen) {
        if (bitsLeft < shift_) {
            if (inPos < inLen) {
                buffer <<= 8;
                buffer |= (inBuf[inPos++] & 0xff);
                bitsLeft += 8;
            } else {
                int pad = shift_ - bitsLeft;
                buffer <<= pad;
                bitsLeft += pad;
            }
        }
        int idx = (buffer >> (bitsLeft - shift_)) & mask_;
        bitsLeft -= shift_;
        outBuf[outPos++] = charMap_[idx];
    }
    
    if (doPad_) {
        while (outPos < outLen)
            outBuf[outPos++] = paddingChar_;
    }
    
    [outData setLength:outPos];
    
    NSString *value = [[NSString alloc] initWithData:outData
                                            encoding:NSASCIIStringEncoding] ;
    if (!value) {
        if (error) {
            *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                         code:StringEncodingErrorUnableToConverToAscii
                                     userInfo:nil];
            
        }
    }
    return value;
}

- (NSString *)encodeString:(NSString *)inString {
    return [self encodeString:inString error:NULL];
}

- (NSString *)encodeString:(NSString *)inString error:(NSError **)error {
    NSData *data = [inString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                         code:StringEncodingErrorUnableToConverToUTF8
                                     userInfo:nil];
            
        }
        return nil;
    }
    return [self encode:data error:error];
}

- (NSData *)decode:(NSString *)inString {
    return [self decode:inString error:NULL];
}

- (NSData *)decode:(NSString *)inString error:(NSError **)error {
    char *inBuf = (char *)[inString cStringUsingEncoding:NSASCIIStringEncoding];
    if (!inBuf) {
        if (error) {
            *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                         code:StringEncodingErrorUnableToConverToAscii
                                     userInfo:nil];
            
        }
        return nil;
    }
    NSUInteger inLen = strlen(inBuf);
    
    NSUInteger outLen = inLen * shift_ / 8;
    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;
    
    unsigned int buffer = 0;
    int bitsLeft = 0;
    BOOL expectPad = NO;
    for (NSUInteger i = 0; i < inLen; i++) {
        int val = reverseCharMap_[(int)inBuf[i]];
        switch (val) {
            case kIgnoreChar:
                break;
            case kPaddingChar:
                expectPad = YES;
                break;
            case kUnknownChar: {
                if (error) {
                    NSDictionary *userInfo =
                    [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:i]
                                                forKey:StringEncodingBadCharacterIndexKey];
                    *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                                 code:StringEncodingErrorUnknownCharacter
                                             userInfo:userInfo];
                }
                return nil;
            }
            default:
                if (expectPad) {
                    if (error) {
                        NSDictionary *userInfo =
                        [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:i]
                                                    forKey:StringEncodingBadCharacterIndexKey];
                        *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                                     code:StringEncodingErrorExpectedPadding
                                                 userInfo:userInfo];
                    }
                    return nil;
                }
                buffer <<= shift_;
                buffer |= val & mask_;
                bitsLeft += shift_;
                if (bitsLeft >= 8) {
                    outBuf[outPos++] = (unsigned char)(buffer >> (bitsLeft - 8));
                    bitsLeft -= 8;
                }
                break;
        }
    }
    
    if (bitsLeft && buffer & ((1 << bitsLeft) - 1)) {
        if (error) {
            *error = [NSError errorWithDomain:StringEncodingErrorDomain
                                         code:StringEncodingErrorIncompleteTrailingData
                                     userInfo:nil];
            
        }
        return nil;
    }
    
    // Shorten buffer if needed due to padding chars
    [outData setLength:outPos];
    
    return outData;
}

- (NSString *)stringByDecoding:(NSString *)inString {
    return [self stringByDecoding:inString error:NULL];
}

- (NSString *)stringByDecoding:(NSString *)inString error:(NSError **)error {
    NSData *ret = [self decode:inString error:error];
    NSString *value = nil;
    if (ret) {
        value = [[NSString alloc] initWithData:ret
                                      encoding:NSUTF8StringEncoding] ;
    }
    return value;
}

@end
