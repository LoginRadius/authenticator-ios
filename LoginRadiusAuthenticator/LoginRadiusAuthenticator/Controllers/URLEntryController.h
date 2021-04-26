//
//  URLEntryController.h
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-02-11.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class OTPURL;

@interface URLEntryController : UIViewController
    <UITextFieldDelegate,
     UINavigationControllerDelegate,     UIAlertViewDelegate,
     AVCaptureVideoDataOutputSampleBufferDelegate> {
 @private
  dispatch_queue_t queue_;
}

@property(nonatomic, readwrite, retain) IBOutlet UITextField *accountName;
@property(nonatomic, readwrite, retain) IBOutlet UITextField *accountKey;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *accountNameLabel;
@property(nonatomic, readwrite, retain) IBOutlet UILabel *accountKeyLabel;
@property(nonatomic, readwrite, retain) IBOutlet UISegmentedControl *accountType;
@property(nonatomic, readwrite, retain) IBOutlet UIButton *scanBarcodeButton;
@property(nonatomic, readwrite, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)accountNameDidEndOnExit:(id)sender;
- (IBAction)accountKeyDidEndOnExit:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)scanBarcode:(id)sender;

@end
