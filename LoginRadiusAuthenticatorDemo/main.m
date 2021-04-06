//
//  main.m
//  LoginRadiusAuthenticator
//
//  Created by Tanvi Jain on 2020-10-30.
//  Copyright © 2020 Tavni Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
       
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
