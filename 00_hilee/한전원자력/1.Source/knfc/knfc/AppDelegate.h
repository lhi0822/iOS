//
//  AppDelegate.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 18..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDKCommandLineApp.h"

@class loginController;
@class ViewController;
@class SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *naviController;
    loginController *login;
    ViewController *viewController;
    SplashViewController *splashController;
    NSString *deviceToken, *deviceID;
    
    SDKCommandLineApp *commndLineApp;
    
}
@property (nonatomic, retain) NSString *deviceToken, *deviceID;
@property (nonatomic, retain) UINavigationController *naviController;
@property (nonatomic, retain) loginController *login;
@property (nonatomic, retain) ViewController *viewController;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SDKCommandLineApp *commndLineApp;

- (void)loadmain;
- (void)logout;
@end
extern AppDelegate *appDelegate;
