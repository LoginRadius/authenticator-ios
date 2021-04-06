//
//  CommonOps.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReachabilityCheck.h"
#import "AppDelegate.h"
#import "LRAuthListVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    about,
    contact,
    privacy
}WebViewMenus;

@interface CommonOps : NSObject
+ (void) showAlertMsgController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message button:(NSString *)button;
+(void)dissmissHudFromView:(UIView *)view;
+ (void)showToastOnVC:(UIViewController *)vc message:(NSString *)message;
+ (void)goToHome ;
+ (void)showHudToView:(UIView *)view ;
@end

NS_ASSUME_NONNULL_END
