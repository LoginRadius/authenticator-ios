//
//  WebViewContainerVC.h
//  astroguru
//
//  Created by PCV_MD8 on 5/3/18.
//  Copyright © 2018 PCV_MD8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface WebViewContainerVC : UIViewController<UIWebViewDelegate>
@property (nonatomic,strong) NSString *strUrlToLoad;
@property (nonatomic,assign) WebViewMenus webMenu;

@end
