//
//  AuthListVC.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-02.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthListVC : UIViewController
//list of account details with name otp generated
@property(nonatomic,strong) NSMutableArray * authURLs;
//category name, if selected from sidenav as list of particular category
@property(nonatomic,strong) NSString * strCategory;
//true if coming from a screen or false if directly from navigation menu
@property(nonatomic,assign)BOOL isBack;
@end

NS_ASSUME_NONNULL_END
