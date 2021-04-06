//
//  TutorialVCViewController.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-03.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "TutorialVCViewController.h"

@interface TutorialVCViewController ()
@property(nonatomic, readwrite, retain) IBOutlet UIScrollView *scrlVContainer;

//page1
@property(nonatomic, readwrite, retain) IBOutlet UIImageView *imgVIcon1;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblDesc1;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblCaption1;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *btnNext1;
//page2
@property(nonatomic, readwrite, retain) IBOutlet UIImageView *imgVIcon2;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblDesc2;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblCaption2;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *btnNext2;
//page3
@property(nonatomic, readwrite, retain) IBOutlet UIImageView *imgVIcon3;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblDesc3;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *lblCaption3;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *btnNext3;
@end

@implementation TutorialVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                                                           style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                                          action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.title = @"Authenticator";
    [self.btnNext1 setTitle:[@"Next" capitalizedString] forState:UIControlStateNormal];
    self.lblCaption1.text = @"To sign in, you'll enter your password.";
    self.lblDesc1.text = @"However, if you're at a new computer or device, Provider will ask you for a special code to make sure it's really you.";
    
    [self.btnNext2 setTitle:[@"Next" capitalizedString] forState:UIControlStateNormal];
      self.lblCaption2.text = @"If you're on a new computer, enter a code from your phone.";
      self.lblDesc2.text = @"This app will generate the code needed to proceed with sign in.";
    
    [self.btnNext3 setTitle:[@"Exit" capitalizedString] forState:UIControlStateNormal];
      self.lblCaption3.text = @"Then you're signed in.";
      self.lblDesc3.text = @"You can also choose to remember the computer and Provider won't ask you for a code there again.";
    self.navigationController.navigationItem.title = @"Authenticator";
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)pressNextBtn:(UIButton *)sender {
    if(sender.tag == 3) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        _scrlVContainer.contentOffset = CGPointMake(SCREEN_WIDTH*sender.tag, 0);
    }
}

@end
