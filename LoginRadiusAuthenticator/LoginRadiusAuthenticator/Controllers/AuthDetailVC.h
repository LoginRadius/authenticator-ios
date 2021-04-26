//
//  AuthDetailVC.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-20.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthDetailVC : UIViewController
//detail of particular account selected from list
@property(nonatomic,strong) OTPURL * authURL;

@end

NS_ASSUME_NONNULL_END
