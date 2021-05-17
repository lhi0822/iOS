//
//  AppDelegate.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 18..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "AppDelegate.h"
#import "loginController.h"
#import "ViewController.h"
#import "SplashViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SSKeychain.h"

#define IS_iOS_8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8

AppDelegate *appDelegate = nil;

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize login, naviController, viewController, deviceToken, deviceID;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //motp
    appDelegate = self;
    self.commndLineApp = [[SDKCommandLineApp alloc] init];
    [self.commndLineApp loadIdentity];

    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    NSError *error = nil;
    self.deviceID = [SSKeychain passwordForService:@"cancer" account:@"uuid" error:&error];
    if ([error code] == SSKeychainErrorNotFound) {
        NSLog(@"Password not found");
        [SSKeychain setPassword:[self uuid] forService:@"cancer" account:@"uuid"];
        self.deviceID = [SSKeychain passwordForService:@"cancer" account:@"uuid" error:&error];
    }
    
    self.login = [[loginController alloc] initWithNibName:@"loginController" bundle:nil];
    
    self.naviController = [[UINavigationController alloc] initWithRootViewController:self.login];
    if ([self.naviController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self.naviController setNavigationBarHidden:YES];
    self.window.rootViewController = self.naviController;

    splashController = [[SplashViewController alloc] init];
    [self.viewController.view addSubview:splashController.view];
    
//    CUSTOM------------------------------------------------------
    [self.login.view addSubview:splashController.view];
    
    
    return YES;
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

- (void)loadmain {
    NSString *snib = @"ViewController";
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
//        snib = @"ViewController-568";
    }
    self.viewController = [[ViewController alloc] initWithNibName:snib bundle:nil];
    self.naviController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    if ([self.naviController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self.naviController setNavigationBarHidden:YES];
    self.window.rootViewController = self.naviController;
}

//    CUSTOM------------------------------------------------------
- (void)logout {
    //1차 커스텀
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"로그아웃 하시겠습니까?" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction * action) {
//                                                        [alert dismissViewControllerAnimated:YES completion:nil];
//
//                                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                                                        [defaults setObject:@"N" forKey:@"auto"];
//                                                        [defaults setObject:@"" forKey:@"user_id"];
//                                                        [defaults setObject:@"" forKey:@"user_sabun"];
//                                                        [defaults setObject:@"" forKey:@"user_name"];
//                                                        [defaults setObject:@"" forKey:@"user_department"];
//                                                        [defaults setObject:@"" forKey:@"user_positon"];
//                                                        [defaults synchronize];
//
//                                                        self.login = [[loginController alloc] initWithNibName:@"loginController" bundle:nil];
//                                                        self.naviController = [[UINavigationController alloc] initWithRootViewController:self.login];
//                                                        if ([self.naviController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
//                                                            [self.naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibar.png"] forBarMetrics:UIBarMetricsDefault];
//                                                        }
//                                                        [self.naviController setNavigationBarHidden:YES];
//                                                        self.window.rootViewController = self.naviController;
//    }];
//
//    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                            [alert dismissViewControllerAnimated:YES completion:nil];
//    }];
//
//    [alert addAction:cancelButton];
//    [alert addAction:okButton];
//
//    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"N" forKey:@"auto"];
//    [defaults setObject:@"" forKey:@"user_id"];
    [defaults setObject:@"" forKey:@"user_sabun"];
    [defaults setObject:@"" forKey:@"user_name"];
    [defaults setObject:@"" forKey:@"user_department"];
    [defaults setObject:@"" forKey:@"user_positon"];
    [defaults synchronize];
    self.login = [[loginController alloc] initWithNibName:@"loginController" bundle:nil];
    self.naviController = [[UINavigationController alloc] initWithRootViewController:self.login];
    if ([self.naviController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self.naviController setNavigationBarHidden:YES];
    self.window.rootViewController = self.naviController;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
