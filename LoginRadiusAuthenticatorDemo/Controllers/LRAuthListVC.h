//
//  LRAuthListVC.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-02.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRAuthListVC : UIViewController
@property(nonatomic,strong) NSMutableArray * authURLs;
@property(nonatomic,strong) NSString * strCategory;

@property(nonatomic,assign)BOOL isBack;
@end

NS_ASSUME_NONNULL_END
