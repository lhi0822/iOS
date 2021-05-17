//
//  AppDelegate.h
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 14..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import <UserNotifications/UserNotifications.h>
#import <PushKit/PushKit.h>

#import <Firebase/Firebase.h>

@class WebViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioSessionDelegate,UIAlertViewDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>{
    NSString *appDeviceToken;
    NSString *_urlString;

}
- (UIColor *) myRGBfromHex: (NSString *) code;

@property (nonatomic, retain) NSString *pushURL;
@property (nonatomic, retain) NSString *gwID;
@property (nonatomic, retain) NSString *gwPW;
@property (nonatomic, retain) NSString *compNm;
@property (nonatomic, retain) NSString *isSet;
@property (nonatomic, retain) NSString *appDeviceToken;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) BOOL isLogout;
@property (nonatomic, readwrite) BOOL isLogin;
@property (nonatomic, readwrite) BOOL isPush;
@property (nonatomic, readwrite) BOOL isSetting;
@property (nonatomic, readwrite) BOOL isSetPush;
@property (nonatomic, retain) NSString *model_nm;
@property (nonatomic, retain) NSString *appVersion;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *beaconMajor;
@property (nonatomic, retain) NSString *beaconMinor;
@property (strong, nonatomic) UIViewController *viewController;
@property (nonatomic, retain) UIViewController *viewController2;
@property (nonatomic, retain) NSArray *supportedUUIDs;
@property (nonatomic, readwrite) BOOL isLoad;

@property (nonatomic, retain) NSString *fcmToken;

@end
@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
- (NSString *)AES256EncryptWithKeyString:(NSString *)key;
- (NSString *)AES256DecryptWithKeyString:(NSString *)key;
@end

