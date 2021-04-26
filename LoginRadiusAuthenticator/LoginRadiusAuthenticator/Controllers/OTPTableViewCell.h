//
//  OTPTableViewCell.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTPURL;
@class OTPTableViewCellBackView;

@interface OTPTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIView *viewBG;

@end
