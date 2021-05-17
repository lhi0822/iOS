//
//  AppDelegate.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <WebKit/WebKit.h>

@import FirebaseAnalytics;
@import FirebaseCore;
@import FirebaseCoreDiagnostics;
@import FirebaseInstallations;
@import FirebaseMessaging;
@import FirebaseInstanceID;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *appDeviceToken;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSDictionary *inactivePushInfo;

@property (strong, nonatomic) NSString *fcmToken;

@end

