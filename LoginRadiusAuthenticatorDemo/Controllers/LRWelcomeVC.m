//
//  LRWelcomeVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-02.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "LRWelcomeVC.h"
#import "DYQRCodeDecoderViewController.h"
#import <AVKit/AVKit.h>
@interface LRWelcomeVC ()<SWRevealViewControllerDelegate>
@property(nonatomic, readwrite, retain) IBOutlet UIImageView *imgVIcon;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblIcon;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblCaption;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *btnFirstOption;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *btnSecOption;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;

@end
@implementation LRWelcomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!_isBack){
    SWRevealViewController *revealViewController = self.revealViewController;
              if ( revealViewController )
              {
                  
                  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
                  [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
                  
                  revealViewController.delegate = self;

              }
        [self.sideBarButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [self.sideBarButton addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
         [self.sideBarButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self.sideBarButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    //[CommonOps setCustomButton:self.navigationController];
}

- (void)viewWillAppear:(BOOL)animated  {
    self.title = @"Authenticator";
    if(_isBack){
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            [_btnSecOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-175)/ 320.0, 0, 0)];
               [_btnFirstOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-200)/ 320.0, 0, 0)];
        }
        else {
            [_btnSecOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-110)/ 320.0, 0, 0)];
               [_btnFirstOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-160)/ 320.0, 0, 0)];
        }
        [_btnSecOption setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
              [_btnFirstOption setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        _lblCaption.textColor = [UIColor blackColor];
      _lblIcon.textAlignment = _lblCaption.textAlignment = NSTextAlignmentLeft;

        self.title = @"Add Account";
        _imgVIcon.hidden = NO;
        _lblIcon.hidden = NO;
        _lblIcon.text   = @"Add Account";
        _lblCaption.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];

        _lblCaption.text  = @"Please add an account by selecting one of the following options.";
         [_btnFirstOption setTitle:[@"Scan barcode" capitalizedString] forState:UIControlStateNormal];
        [_btnSecOption setTitle:[@"Manually add account" capitalizedString] forState:UIControlStateNormal];
    }
    else {
        _lblIcon.textAlignment = _lblCaption.textAlignment = NSTextAlignmentCenter;
       _imgVIcon.hidden = YES;
       _lblIcon.hidden = YES;
       _lblCaption.text   = @"Two Factor Authentication";
       [_btnFirstOption setTitle:@"See How it Works"  forState:UIControlStateNormal];
       [_btnSecOption setTitle:@"Add an Account" forState:UIControlStateNormal];
    _lblCaption.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
       _lblCaption.textColor = [UIColor colorWithRed:26/255.0 green:83/255.0 blue:143/255.0 alpha:1.0];
       [_btnSecOption setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
       [_btnFirstOption setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
       _imgVIcon.hidden = YES;
       _lblIcon.hidden = YES;
    }
}
- (void)showViewToScan {
DYQRCodeDecoderViewController *vc = [[DYQRCodeDecoderViewController alloc] initWithCompletion:^(BOOL succeeded, NSString *result) {
               dispatch_async(dispatch_get_main_queue(), ^{

               if (succeeded) {
                  NSURL *url = [NSURL URLWithString:result];
                  LRURL *authURL = [LRURL authURLWithURL:url
                                                            secret:nil];
           
              if(authURL.checkCode) {
                  [authURL saveToKeychain];
                  LRURLSession *session = [[LRURLSession alloc] init];
                  NSMutableArray * authURLs = [session getKeychainArray];
                  [authURLs addObject:authURL];
                  [CommonOps showToastOnVC:[[UIApplication sharedApplication]delegate].window.rootViewController message:@"Secret saved"];

                  [session saveKeychainArray:authURLs];
                  [CommonOps goToHome];
              }
              else if (!authURL){
                  [CommonOps showToastOnVC:self message:@"Invalid key"];
              }
          }
                    else {
                        [CommonOps showToastOnVC:self message:@"Please scan a valid QR."];
                   }
               });
                   }];
           
           UIImage *image = [UIImage imageNamed:@"navlogo"];
           UIImageView *imgV=[[UIImageView alloc] initWithImage:image];
           imgV.frame = CGRectMake(0, 0, 300, imgV.frame.size.height-20);
             imgV.contentMode = UIViewContentModeScaleAspectFit;
           vc.navigationItem.titleView = imgV;
           UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
           navVC.navigationBar.tintColor = [UIColor whiteColor];
           navVC.navigationBar.backgroundColor = [UIColor colorWithRed:53/255.0 green:66/255.0 blue:81/255.0 alpha:1.0];
           navVC.navigationBar.barTintColor = [UIColor colorWithRed:53/255.0 green:66/255.0 blue:81/255.0 alpha:1.0];

           [self.navigationController presentViewController:navVC animated:YES completion:nil];            }
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)pressOptionButton:(UIButton *)sender {
    if(_imgVIcon.hidden) {
   //first for how works
    if(sender.tag == 10)
    [self performSegueWithIdentifier:@"toTutorialVC" sender:nil];
   //second for adding account
    else {
          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
              {
                  [_btnSecOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-175)/ 320.0, 0, 0)];
                     [_btnFirstOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-200)/ 320.0, 0, 0)];
              }
              else {
                  [_btnSecOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-110)/ 320.0, 0, 0)];
                     [_btnFirstOption setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH* (-160)/ 320.0, 0, 0)];
              }
          [_btnSecOption setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
                [_btnFirstOption setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        _lblCaption.textColor = [UIColor blackColor];
       
        self.title = @"Add Account";
        _imgVIcon.hidden = NO;
        _lblIcon.hidden = NO;
        _lblIcon.text   = @"Add Account";
        _lblCaption.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
        _lblIcon.textAlignment = _lblCaption.textAlignment = NSTextAlignmentLeft;

        _lblCaption.text   = @"Please add an account by selecting one of the following options:";
         [_btnFirstOption setTitle:[@"Scan barcode" capitalizedString] forState:UIControlStateNormal];
        [_btnSecOption setTitle:[@"Manually add account" capitalizedString] forState:UIControlStateNormal];
    }
    }
    else {
        if(sender.tag == 10)
        {
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusAuthorized)
            {               dispatch_async(dispatch_get_main_queue(), ^{

                [self showViewToScan];
            });
            }
                else if(authStatus == AVAuthorizationStatusDenied){
                    dispatch_async(dispatch_get_main_queue(), ^{

                             [CommonOps showAlertMsgController:self title:@"Alert" message:@"Please enable camera permission in device settings for this app to scan." button:@"Ok"];
                    });
              // denied
            } else if(authStatus == AVAuthorizationStatusRestricted){
              // restricted, normally won't happen
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
              // not determined?!
              [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){
                    dispatch_async(dispatch_get_main_queue(), ^{

                    [self showViewToScan];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{

                  [CommonOps showAlertMsgController:self title:@"Alert" message:@"Please enable camera permission in device settings for this app to scan." button:@"Ok"];
                    });
                }
              }];
            } else {
              // impossible, unknown authorization status
            }
           
        }
        else {
            [self performSegueWithIdentifier:@"toAddAccount" sender:nil];
        }
    }
}
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
     self.btnSecOption.userInteractionEnabled = true;
        self.btnFirstOption.userInteractionEnabled = true;

        revealController.frontViewController.view.alpha = 1.0;;
        
    } else {
   self.btnFirstOption.userInteractionEnabled = false;
        self.btnSecOption.userInteractionEnabled = false;

        revealController.frontViewController.view.alpha = 0.5;
    }
}


@end
