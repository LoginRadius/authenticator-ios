//
//  OTPURL.h

#import <Foundation/Foundation.h>

@class OTPGenerator;

// This class encapsulates the parsing of :// urls, the creation of
// either HOTPGenerator or TOTPGenerator objects, and the persistence of the
// objects state to the iPhone keychain in a secure fashion.
//
// The secret key is stored as the "password" in the keychain item, and the
// re-constructed URL is stored in an attribute.
@interface OTPURL : NSObject<NSCoding>

// |name| is an arbitrary UTF8 text string extracted from the url path.
@property(readwrite, copy, nonatomic) NSString *name;
//OTP facilitates category
@property(readwrite, copy, nonatomic) NSString *category;
@property( readonly,nonatomic) NSString *otpCode;
@property( readonly,nonatomic) NSString *checkCode;
@property( retain, nonatomic) NSData *keychainItemRef;
@property(readwrite, retain, nonatomic) OTPGenerator *generator;

// Standard base32 alphabet.
// Input is case insensitive.
// No padding is used.
// Ignore space and hyphen (-).
// For details on use, see android app:

+ (NSData *)base64Decode:(NSString *)string;
+ (NSString *)encodeBase64:(NSData *)data;

+ (OTPURL *)authURLWithURL:(NSURL *)url
                   secret:(NSData *)secret;
+ (OTPURL *)authURLWithKeychainItemRef:(NSData *)keychainItemRef;

// Returns a reconstructed NSURL object representing the current state of the
// |generator|.
- (NSURL *)url;

// Saves the current object state to the keychain.
- (BOOL)saveToKeychain;

// Removes the current object state from the keychain.
- (BOOL)removeFromKeychain;

// Returns true if the object was loaded from or subsequently added to the
// iPhone keychain.
// It does not assert that the keychain is up to date with the latest
// |generator| state.
- (BOOL)isInKeychain;

- (NSString*)checkCode;

@end

@interface TOTPAuth : OTPURL  {
@private
    NSTimeInterval generationAdvanceWarning_;
    NSTimeInterval lastProgress_;
    BOOL warningSent_;
}

@property(readwrite, assign, nonatomic) NSTimeInterval generationAdvanceWarning;

- (id)initWithSecret:(NSData *)secret name:(NSString *)name;

@end

@interface HOTPAuth : OTPURL {
@private
    NSString *otpCode_;
}
- (id)initWithSecret:(NSData *)secret name:(NSString *)name;
- (void)generateNextOTPCode;

@end

// Notification sent out |otpGenerationAdvanceWarning_| before a new OTP is
// generated. Only applies to TOTP Generators. Has a
// |URLSecondsBeforeNewOTPKey| key which is a NSNumber with the
// number of seconds remaining before the new OTP is generated.
extern NSString *const OTPURLWillGenerateNewOTPWarningNotification;
extern NSString *const OTPURLSecondsBeforeNewOTPKey;
extern NSString *const OTPURLDidGenerateNewOTPNotification;
