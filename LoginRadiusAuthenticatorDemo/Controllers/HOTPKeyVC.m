//
//  HOTPKeyVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-12-04.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "HOTPKeyVC.h"
#import "HOTPGenerator.h"
@interface HOTPKeyVC ()
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UIButton *btnCode;
@property (nonatomic,weak) IBOutlet UIButton *btnCounter;
@end

@implementation HOTPKeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Authenticator";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                                                           style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                                          action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [_btnCode setImage:[UIImage imageNamed:@"smalllock"] forState:UIControlStateNormal];
    [_btnCounter setImage:[UIImage imageNamed:@"smallclock"] forState:UIControlStateNormal];
    [_btnCode setTitle:_authURL.checkCode forState:UIControlStateNormal];
    [_btnCounter setTitle:[NSString stringWithFormat:@"%llu",((HOTPGenerator *)_authURL.generator).counter] forState:UIControlStateNormal];
    _lblTitle.text = [NSString stringWithFormat:@"To check that you have the correct key value for %@ verify that the value here matches the integrity check value provided by the server:", _authURL.name];
}
- (IBAction)back:(id)sender {
    [CommonOps  goToHome];
}
@end
