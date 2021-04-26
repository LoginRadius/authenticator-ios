//
//  WebViewContainerVC.m
//  astroguru
//
//  Created by PCV_MD8 on 5/3/18.
//  Copyright © 2018 PCV_MD8. All rights reserved.
//

#import "WebViewContainerVC.h"
#import <WebKit/WebKit.h>
@interface WebViewContainerVC ()<WKNavigationDelegate,SWRevealViewControllerDelegate>{
}
    @property(nonatomic, copy) NSString* provider;
    @property(nonatomic, copy) NSURL * serviceURL;
    @property(nonatomic, weak) WKWebView* webView;
    @property(nonatomic, weak) UIView *retryView;
    @property(nonatomic, weak) UILabel *retryLabel;
    @property(nonatomic, weak) UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;

    @end

    @implementation WebViewContainerVC


    - (void)viewDidLoad {
        [super viewDidLoad];
       
           [self.sideBarButton addTarget:self action:@selector(goToHome) forControlEvents:UIControlEventTouchUpInside];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];

        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;


        WKWebView* webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:wkWebConfig];
        webView.navigationDelegate = self;
         NSURLRequest *request;
           if(_webMenu == contact){
               self.title = @"Contact Us";
               request = [NSURLRequest requestWithURL:[NSURL URLWithString: @"https://www.loginradius.com/contact-us/"]];
           }
           else  if(_webMenu == about){
           self.title = @"About Us";
               request = [NSURLRequest requestWithURL:[NSURL URLWithString: @"https://www.loginradius.com/"]];
           }
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                                                                style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                                               action:@selector(back:)];
         self.navigationItem.leftBarButtonItem = backButton;
        [CommonOps showHudToView:self.view];
        [webView loadRequest:request];
        UIView * retryView = [[UIView alloc] initWithFrame:self.view.frame];
        retryView.backgroundColor = [UIColor whiteColor];
        retryView.hidden = YES;
        
        [self.view addSubview:webView];
        [self.view addSubview:retryView];
        [self.view bringSubviewToFront:retryView];
        
        UILabel * retryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        retryLabel.textColor = [UIColor grayColor];
        retryLabel.text = @"Please check your network connection and try again.";
        retryLabel.numberOfLines = 0;
        retryLabel.textAlignment = NSTextAlignmentCenter;
        retryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        retryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [retryView addSubview:retryLabel];
        
        UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [retryButton setTitle:@"Retry" forState:UIControlStateNormal];
        [retryButton sizeToFit];
        retryButton.translatesAutoresizingMaskIntoConstraints = NO;
        [retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
        [retryView addSubview:retryButton];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:retryView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:retryView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:retryView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:retryView attribute:NSLayoutAttributeWidth multiplier:0.7f constant:0.0f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:retryLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:retryButton attribute:NSLayoutAttributeTop multiplier:1.0f constant:-50.0f]];
        
        self.webView = webView;
        self.retryView = retryView;
        self.retryLabel = retryLabel;
        self.retryButton = retryButton;
    }

    - (void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];

        [self startMonitoringNetwork];
    }
- (void)goToHome {
    [CommonOps goToHome];
}

    - (void)startMonitoringNetwork {
        ReachabilityCheck* reach = [ReachabilityCheck reachabilityWithHostname:@"cdn.loginradius.com"];
        reach.unreachableBlock = ^(ReachabilityCheck*reach) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.retryLabel.text = @"Please check your network connection and try again.";
                self.retryView.hidden = NO;
            });
        };
        
        [reach startNotifier];
    }

    - (void) retry: (id) sender {
        [self.webView stopLoading];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.serviceURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60]];
        dispatch_async(dispatch_get_main_queue(), ^{

        self.retryView.hidden = YES;
        });
    }

    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }

    - (void)viewDidLayoutSubviews {
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.retryView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }

    #pragma mark - Web View Delegates
    - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
          
               decisionHandler(WKNavigationActionPolicyAllow);
    }
    - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CommonOps dissmissHudFromView:self.view];
        });
    }
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
        dispatch_async(dispatch_get_main_queue(), ^{

        [CommonOps dissmissHudFromView:self.view];
        });
    }
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    dispatch_async(dispatch_get_main_queue(), ^{

    if(position == FrontViewPositionLeft) {
     self.webView.userInteractionEnabled = true;

        revealController.frontViewController.view.alpha = 1.0;;
        
    } else {
        [CommonOps dissmissHudFromView:self.view];
        self.webView.userInteractionEnabled = false;
        revealController.frontViewController.view.alpha = 0.5;
    }
    });
}
- (IBAction)back:(id)sender {
    [CommonOps goToHome];
}
@end
