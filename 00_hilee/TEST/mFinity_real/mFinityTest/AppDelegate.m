//
//  AppDelegate.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "AppDelegate.h"
#import "loginController.h"
#import "SplashViewController2.h"
#import "ViewController.h"

@implementation AppDelegate

#pragma mark
#pragma mark Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        loginController* controller = [[loginController alloc] initWithNibName:@"loginController" bundle:nil];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //    self.window.frame = [[UIScreen mainScreen] bounds];

        [self.window setRootViewController:controller];
        [self.window makeKeyAndVisible];
//
//    introViewController = [[IntroViewController alloc]init];
//    _navigationController = [[UINavigationController alloc]initWithRootViewController:introViewController];
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//
//    self.window.rootViewController = _navigationController;
//    [self.window makeKeyAndVisible];
    
    
    return YES;
}

@end
