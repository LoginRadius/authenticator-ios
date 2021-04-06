//
//  LRAuthDetailVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-20.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "LRAuthDetailVC.h"

@interface LRAuthDetailVC (){
    CGFloat startAngle;
       CGFloat endAngle;
    float percent;
    CAShapeLayer *layer;
    int onceForViewTImer;
}
@property (nonatomic,weak) IBOutlet UIView *imgKey;
@property (nonatomic,weak) IBOutlet UIImageView *imgRefresh;
@property (nonatomic,weak) IBOutlet UILabel *lblCode;
@property (nonatomic,weak) IBOutlet UILabel *lblTime;
@property (nonatomic,weak) IBOutlet UILabel *lblEmail;
@property (nonatomic,weak) IBOutlet UIView *viewTime;
@end

@implementation LRAuthDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    onceForViewTImer = 0;
    percent = 30;
    _imgKey.layer.masksToBounds = true;
    _imgKey.layer.cornerRadius = SCREEN_WIDTH * .3 / 2;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                                                           style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                                          action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"copy"]
                                                                                            style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                                           action:@selector(copy:)];
       self.navigationItem.rightBarButtonItem = copyButton;
    self.title = @"Authenticator";
    if ([_authURL isMemberOfClass:[TOTPAuth class]]) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
        selector:@selector(otpAuthURLWillGenerateWarnNewOTP:)
            name:LRURLWillGenerateNewOTPWarningNotification
          object:self.authURL];
     //   [self showTimerView];
        _imgRefresh.hidden = YES;
        _viewTime.hidden = NO;
 //  _lblTime.text = [NSString stringWithFormat:@"%d",29];

      // [bezierPath stroke];
    }
    else {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
                selector:@selector(otpAuthURLDidGenerateNewOTP:)
                    name:LRURLDidGenerateNewOTPNotification
                 object:self.authURL];
        [(HOTPAuth *)self.authURL generateNextOTPCode];
        _imgRefresh.hidden = NO;
               _viewTime.hidden = YES;
        _imgRefresh.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer =
                  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshAuthURL:)];
              
              [_imgRefresh addGestureRecognizer:tapRecognizer];
    }
    _lblCode.text = _authURL.otpCode;
    NSArray *arr = [_authURL.name componentsSeparatedByString:@":"];
    if(arr.count > 1){
        
       _lblEmail.text = arr[1];
       }
    else
    _lblEmail.text = _authURL.name;
    [UINavigationBar appearance].topItem.title = @"List";

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:LRURLWillGenerateNewOTPWarningNotification
                object:self.authURL];
    [nc removeObserver:self
                  name:LRURLDidGenerateNewOTPNotification
                object:self.authURL];
}
- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification {
    HOTPAuth * url = (HOTPAuth *)notification.object;
    _lblCode.text = url.otpCode;
}
- (void)otpAuthURLWillGenerateWarnNewOTP:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
   TOTPAuth * url = (TOTPAuth *)notification.object;
  NSNumber *nsSeconds
    = [userInfo objectForKey:LRURLSecondsBeforeNewOTPKey];
  NSUInteger seconds = [nsSeconds unsignedIntegerValue];
    _lblTime.text = [NSString stringWithFormat:@"%ld",seconds];
    _lblCode.text = url.otpCode;
   
  float strokeEnd = seconds/30.0;
   if(!onceForViewTImer){

           // Display our percentage as a string
       onceForViewTImer ++;
              UIBezierPath* bezierPath = [UIBezierPath bezierPath];
              // Create our arc, with the correct angles
        [bezierPath addArcWithCenter:CGPointMake(self.viewTime.frame.size.width / 2, self.viewTime.frame.size.height / 2)
               radius:50
           startAngle:(M_PI/2 * 3)
             endAngle:(M_PI/2 * 3) + (2.0*M_PI)
            clockwise:YES];


              // Set the display for the path, and stroke it
                layer = [CAShapeLayer layer];
               layer.path = bezierPath.CGPath;
              layer.lineWidth = 10;
        layer.strokeEnd = strokeEnd;
        layer.fillColor = [UIColor clearColor].CGColor;
               layer.strokeColor = [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0].CGColor;
       // layer.transform = CATransform3DRotate(CATransform3DIdentity, -(M_PI * 2), 0, 0, 1);
               [_viewTime.layer addSublayer:layer];
    }
    layer.strokeEnd = strokeEnd;
}
- (IBAction)copy:(id)sender {
  UIPasteboard *pb = [UIPasteboard generalPasteboard];
  [pb setValue:self.lblCode.text forPasteboardType:@"public.utf8-plain-text"];
    [CommonOps showToastOnVC:self message:@"Copied"];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refreshAuthURL:(id)sender {
    AppDelegate *del = [UIApplication sharedApplication].delegate;
    NSTimeInterval current = [[NSDate date] timeIntervalSinceDate:del.dateLatestHOTP];
    //more than 5 seconds of difference
    if(!del.dateLatestHOTP || current>=5.0){
        del.dateLatestHOTP = [NSDate date];
  [(HOTPAuth *)self.authURL generateNextOTPCode];
    }
}

@end
