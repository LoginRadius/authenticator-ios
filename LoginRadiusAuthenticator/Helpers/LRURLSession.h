//
//  LRURLSession.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-08.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LRURLSession : NSObject
//save keychain item's array in userdefault
- (void)saveKeychainArray:(NSArray *)keychainReferences ;
//get keychain item's array from userdefault
- (NSMutableArray *)getKeychainArray ;
- (NSMutableArray *)getCategoriesArray ;
- (void)saveCategoriesArray:(NSArray *)keychainReferences ;
@end

NS_ASSUME_NONNULL_END
