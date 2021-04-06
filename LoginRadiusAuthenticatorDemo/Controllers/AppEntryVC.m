//
//  AppEntryVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-01.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "AppEntryVC.h"
#import <MessageUI/MessageUI.h>

@interface AppEntryVC ()<UITextFieldDelegate> {
    int counter;
    NSString *strPasscode;
}
@property (nonatomic,weak) IBOutlet UILabel *lblCaption;
@property (nonatomic,weak) IBOutlet UITextField *txtFPasscode;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *cnstrntCenterOfView;
@end

@implementation AppEntryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _lblCaption.textColor = [UIColor blackColor];

    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = YES;
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 40)];// Here you can set View width and height as per your requirement for displaying titleImageView position in navigationbar
    [backView setBackgroundColor:[UIColor clearColor]];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navlogo"]];
    titleImageView.frame = CGRectMake(0, 0,backView.frame.size.width , backView.frame.size.height - 5); // Here I am passing origin as (45,5) but can pass them as your requirement.
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;

    [backView addSubview:titleImageView];
    //titleImageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.titleView = backView;
    _lblCaption.text = @"Enter Passcode";
    counter = 0;
     UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.translucent = YES;
    numberToolbar.backgroundColor = [UIColor colorWithRed:53/255.0 green:66/255.0 blue:81/255.0 alpha:1.0];
    numberToolbar.tintColor = [UIColor whiteColor];
    numberToolbar.barTintColor = [UIColor colorWithRed:53/255.0 green:66/255.0 blue:81/255.0 alpha:1.0];
        numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithNumberPad)]];
        [numberToolbar sizeToFit];
        _txtFPasscode.inputAccessoryView = numberToolbar;
    }

-(void)doneWithNumberPad
{
    NSString *strSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"lrauthpasscode"];

    if(counter==0) {
        if(strSaved.length) {
            if([strSaved isEqualToString:_txtFPasscode.text]) {
            [self goAhead];
        }
        else {
            _lblCaption.textColor = [UIColor redColor];
            _lblCaption.text = @"Wrong Passcode! Try again.";
            _txtFPasscode.text = @"";
            [_txtFPasscode becomeFirstResponder];
        }
        }
        else {
            if(_txtFPasscode.text.length < 4) {
                [CommonOps showToastOnVC:self message:@"Invalid Passcode!"];
            }
            else {
            _lblCaption.textColor = [UIColor blackColor];
            strPasscode = _txtFPasscode.text;
        [[NSUserDefaults standardUserDefaults] setObject:strPasscode forKey:@"lrauthpasscode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        counter++;
        _lblCaption.text = @"Confirm Passcode";
        _txtFPasscode.text = @"";
        [_txtFPasscode becomeFirstResponder];
            }
        }
    }

    else if(counter == 1){
        if([strSaved isEqualToString:_txtFPasscode.text]) {
            [self goAhead];
        }
        else {
            _lblCaption.textColor = [UIColor redColor];
            _lblCaption.text = @"Wrong Passcode! Try again.";
            _txtFPasscode.text = @"";
            [_txtFPasscode becomeFirstResponder];
        }
    }
}
    -(void)cancelNumberPad{
        [_txtFPasscode resignFirstResponder];
        _txtFPasscode.text = @"";
    }
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
      self.navigationController.navigationBarHidden = NO;

}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Textfield methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    float v = (SCREEN_HEIGHT/2 - 240 - 120);
    if(v < 0)
    _cnstrntCenterOfView.constant = _cnstrntCenterOfView.constant + (SCREEN_HEIGHT/2 - 240 - 120);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!(textField.text.length<4)) {
        [textField resignFirstResponder];
        return true;
    }
    else {
        return false;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Handle backspace/delete
    if (!string.length)
    {
        // Backspace detected, allow text change, no need to process the text any further
        return YES;
    }

    // Input Validation
    // Prevent invalid character input, if keyboard is numberpad
   
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
    

    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return !(newString.length>4);
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    _cnstrntCenterOfView.constant = 0;

}
- (void)goAhead {
   
 
    [_txtFPasscode resignFirstResponder];

    [CommonOps goToHome];

}


@end
