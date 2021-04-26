//
//  URLEntryController.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "URLEntryController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OTPURL.h"
#import "HOTPGenerator.h"
#import "TOTPGenerator.h"

@interface URLEntryController ()
@property(nonatomic, readwrite, assign) UITextField *activeTextField;
@property(nonatomic, readwrite, assign) UIBarButtonItem *doneButtonItem;

- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end

@implementation URLEntryController
@synthesize doneButtonItem = doneButtonItem_;
@synthesize accountName = accountName_;
@synthesize accountKey = accountKey_;
@synthesize accountNameLabel = accountNameLabel_;
@synthesize accountKeyLabel = accountKeyLabel_;
@synthesize accountType = accountType_;
@synthesize scrollView = scrollView_;
@synthesize activeTextField = activeTextField_;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    if(@available(ios 13.0, *)) {
        accountType_.selectedSegmentTintColor = [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0];
        accountType_.layer.backgroundColor = [UIColor whiteColor].CGColor;
        accountType_.layer.borderWidth = 1.0;
        accountType_.layer.borderColor = [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0].CGColor;
        UIImage *tintColorImage = [self imageWithColor: [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0]];
        [accountType_ setBackgroundImage:[self imageWithColor: [UIColor whiteColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [accountType_ setBackgroundImage:tintColorImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [accountType_ setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0], NSForegroundColorAttributeName,[UIFont systemFontOfSize:14.0 weight:UIFontWeightBold],NSFontAttributeName,
          nil]
                                    forState: UIControlStateNormal];
        
        [accountType_ setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor], NSForegroundColorAttributeName,
          nil]
                                    forState: UIControlStateSelected];
    }
    else {
        accountType_.backgroundColor = [UIColor whiteColor];
        accountType_.tintColor = [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0];
    }
    
    self.title = [@"Manual account entry" capitalizedString];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.accountName.placeholder
    = @"Enter account name";
    
    self.accountKey.placeholder
    = @"Enter your key";
    
    
    [self.accountType setTitle:[@"Time based" capitalizedString]
             forSegmentAtIndex:0];
    [self.accountType setTitle:[@"Counter based" capitalizedString]
             forSegmentAtIndex:1];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWasShown:)
               name:UIKeyboardDidShowNotification object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillBeHidden:)
               name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.accountName.text = @"";
    self.accountKey.text = @"";
    self.doneButtonItem
    = self.navigationController.navigationBar.topItem.rightBarButtonItem;
    self.doneButtonItem.enabled = NO;
    
}


- (UIImage *)imageWithColor: (UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGFloat offset = 0;
    
    // UIKeyboardFrameBeginUserInfoKey does not exist on iOS 3.1.3
    if (UIKeyboardFrameBeginUserInfoKey != NULL) {
        NSValue *sizeValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGSize keyboardSize = [sizeValue CGRectValue].size;
        BOOL isLandscape
        = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
        offset = isLandscape ? keyboardSize.width : keyboardSize.height;
    } else {
        NSValue *sizeValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
        CGSize keyboardSize = [sizeValue CGRectValue].size;
        // The keyboard size value appears to rotate correctly on iOS 3.1.3.
        offset = keyboardSize.height;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, offset, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible.
    CGRect aRect = self.view.frame;
    aRect.size.height -= offset;
    if (self.activeTextField) {
        CGPoint origin = self.activeTextField.frame.origin;
        origin.y += CGRectGetHeight(self.activeTextField.frame);
        if (!CGRectContainsPoint(aRect, origin) ) {
            CGPoint scrollPoint =
            CGPointMake(0.0, - (self.activeTextField.frame.origin.y - offset));
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    // Scrolling is only enabled when in landscape.
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.scrollView.contentSize = self.view.bounds.size;
    } else {
        self.scrollView.contentSize = CGSizeZero;
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)done:(id)sender {
    // Force the keyboard away.
    [self.activeTextField resignFirstResponder];
    
    NSString *encodedSecret = self.accountKey.text;
    NSData *secret = [OTPURL base64Decode:encodedSecret];
    
    if ([secret length]) {
        Class authURLClass = Nil;
        if ([accountType_ selectedSegmentIndex] == 0) {
            authURLClass = [TOTPAuth class];
        } else {
            authURLClass = [HOTPAuth class];
        }
        NSString *name = self.accountName.text;
        OTPURL *authURL
        = [[authURLClass alloc] initWithSecret:secret
                                          name:name] ;
        NSString *checkCode = authURL.checkCode;
        if (checkCode) {
            [authURL saveToKeychain];
            OTPURLSession *session = [[OTPURLSession alloc] init];
            NSMutableArray * authURLs = [session getKeychainArray];
            [authURLs addObject:authURL];
            [CommonOps showToastOnVC:[[UIApplication sharedApplication]delegate].window.rootViewController message:@"Secret saved"];
            
            [session saveKeychainArray:authURLs];
            [self performSegueWithIdentifier:@"AddAccounttoList" sender:authURLs];
        }
    } else {
        NSString *title = @"Invalid Key";
        NSString *message ;
        if ([encodedSecret length]) {
            message = [NSString stringWithFormat:
                       @"The key '%@' is invalid.",
                       encodedSecret];
        } else {
            message = @"You must enter a key.";
        }
        [CommonOps showAlertMsgController:self title:title message:message button:@"Try Again"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AuthListVC *vc = (AuthListVC *)segue.destinationViewController;
    vc.authURLs = sender;
}

#pragma mark -
#pragma mark UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField == self.accountKey) {
        NSMutableString *key
        = [NSMutableString stringWithString:self.accountKey.text];
        [key replaceCharactersInRange:range withString:string];
        self.doneButtonItem.enabled = [key length] > 0;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return (newString.length<=32);
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:85/255.0 blue:153/255.0 alpha:1.0]}];
    }
    return true;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1.0]}];
    return true;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.activeTextField = textField;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == accountName_) {
        [accountKey_ becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    self.activeTextField = nil;
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
