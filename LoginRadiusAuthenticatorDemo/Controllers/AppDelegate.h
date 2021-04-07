//
//  AppDelegate.h
//
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject<UIApplicationDelegate>
@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, strong) NSDate *dateLatestHOTP;

@end
