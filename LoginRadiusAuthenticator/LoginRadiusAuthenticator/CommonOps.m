//
//  CommonOps.m
//  LoginRadiusAuthenticator
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "CommonOps.h"
#import "MBProgressHUD.h"

@implementation CommonOps
+ (void)showHudToView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
  
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.color = [UIColor colorWithRed:0 green:142/255.0 blue:207/255.0 alpha:1.0];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;

    hud.contentColor = [UIColor whiteColor];
    });
}

+(void)dissmissHudFromView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{

    [MBProgressHUD hideHUDForView:view animated:YES];
    });
}
+ (void)goToHome {
    OTPURLSession *url = [[OTPURLSession alloc] init];
    NSMutableArray *arr = [url getKeychainArray];
    dispatch_async(dispatch_get_main_queue(), ^{

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                                                                  bundle: nil];
    SWRevealViewController * rvlVC = (SWRevealViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"RevealVC"];
    UINavigationController * frstVC;

    if(arr.count){
                                                                                              frstVC = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"AuthListVCNav"];

        AuthListVC *listVC = (AuthListVC *)frstVC.viewControllers[0];
        listVC.authURLs = arr;
        listVC.isBack = false;
        
    }
    else {
        frstVC = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"WelcomeVCNav"];
    }

    frstVC.navigationItem.title = @"Authenticator";
    [rvlVC setFrontViewController:frstVC animated:YES];
    AppDelegate *aappD = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [aappD.window setRootViewController:rvlVC];
    [aappD.window makeKeyAndVisible];
        });

}
+ (void)showToastOnVC:(UIViewController *)vc message:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.margin = 10.f;
   // hud.offset = CGPointMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/2);
    hud.removeFromSuperViewOnHide = YES;

    [hud hideAnimated:YES afterDelay:2];
    });
}
+ (void) showAlertMsgController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message button:(NSString *)button{
    dispatch_async(dispatch_get_main_queue(), ^{

    UIAlertController * alert = [UIAlertController alertControllerWithTitle : title
                                                                    message : message
                                                             preferredStyle : UIAlertControllerStyleAlert];

    UIAlertAction * ok = [UIAlertAction
                          actionWithTitle:button
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          { }];

    [alert addAction:ok];
        [viewController presentViewController:alert animated:YES completion:nil];
    });

}

@end
