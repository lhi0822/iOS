//
//  AppDelegate.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import "seedcbc.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import <AddressBook/AddressBook.h>
#import <UserNotifications/UserNotifications.h>
#import "IntroViewController.h"

@import FirebaseAnalytics;
@import FirebaseCore;
@import FirebaseCoreDiagnostics;
@import FirebaseInstallations;
@import FirebaseMessaging;
@import FirebaseInstanceID;

@interface MFinityAppDelegate : UIResponder <NSURLConnectionDataDelegate, UIApplicationDelegate, UITabBarControllerDelegate, UITabBarDelegate, UIAlertViewDelegate,AVAudioSessionDelegate,UNUserNotificationCenterDelegate, FIRMessagingDelegate>{
    NSString *_main_url;
    NSString *_appDeviceToken;
    NSString *_AES256Key;
    NSString *_AES256Key2;
    //NSDictionary *controllers;
    
    NSString *_noticeTabBarNumber;
    NSString *_menu_title;
    NSString *_target_url;
    
    NSInteger _pre_tabID;
    
    NSArray *urlArray;
    NSArray *tabArray;
    IntroViewController *introViewController;
    
    NSString *menuNo;
    NSMutableDictionary *executeMenuInfo;
    
}

@property (strong, nonatomic) NSDictionary *controllers;

@property (assign, nonatomic) BOOL isExit;
@property (assign, nonatomic) BOOL isLogout;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (assign, nonatomic) BOOL receivePush;
@property (strong, nonatomic) NSString *receiveMenuNo;

@property (strong, nonatomic) NSMutableData *receiveData;

@property (assign, nonatomic) BOOL changeURL;
@property (strong, nonatomic) NSString *isDMS;
@property (strong, nonatomic) NSString *fileSyncURL;

@property (strong, nonatomic) NSString *dmsHost;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *appNo;
@property (strong, nonatomic) NSString *moreCount;
@property (strong, nonatomic) NSString *noticeTitle;
@property (strong, nonatomic) NSString *uploadURL;
@property (strong, nonatomic) NSString *mediaControl;
@property (strong, nonatomic) NSString *noticeTabBarNumber;
@property (strong, nonatomic) NSString *menu_title;
@property (strong, nonatomic) NSString *target_url;
@property (strong, nonatomic) NSString *target_param;
@property (strong, nonatomic) NSString *target_method;

@property (assign, nonatomic) BOOL isOffLine;
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isLogin;
@property (assign, nonatomic) BOOL isAES256;
@property (strong, nonatomic) NSString *noAuth;
@property (assign, nonatomic) BOOL isMainWebView;
@property (strong, nonatomic) UITabBar *uiTabBar;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSString *main_url;
@property (strong, nonatomic) NSString *appDeviceToken;
@property (strong, nonatomic) NSString *AES256Key;
@property (strong, nonatomic) NSString *AES256Key2;
@property (strong, nonatomic) NSString *passWord;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *mainType;
@property (strong, nonatomic) NSString *user_no;
@property (strong, nonatomic) NSString *comp_no;
@property (strong, nonatomic) NSString *root_menu_no;
@property (strong, nonatomic) NSString *app_name;
@property (strong, nonatomic) NSString *app_no;
@property (strong, nonatomic) NSString *demo;
@property (strong, nonatomic) NSString *menu_no;
@property (strong, nonatomic) NSString *comp_name;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *badgeCount;
@property (strong, nonatomic) NSString *bgImagePath;

@property (strong, nonatomic) NSString *mainFontColor;
@property (strong, nonatomic) NSString *mainIsShadow;
@property (strong, nonatomic) NSString *mainShadowColor;
@property (strong, nonatomic) NSString *mainShadowOffset;

@property (strong, nonatomic) NSString *subBgImagePath;

@property (strong, nonatomic) NSString *subFontColor;
@property (strong, nonatomic) NSString *subIsShadow;
@property (strong, nonatomic) NSString *subShadowColor;
@property (strong, nonatomic) NSString *subShadowOffset;

@property (strong, nonatomic) NSString *naviFontColor;
@property (strong, nonatomic) NSString *naviShadowColor;
@property (strong, nonatomic) NSString *naviShadowOffset;
@property (strong, nonatomic) NSString *naviIsShadow;
@property (strong, nonatomic) NSString *naviBarColor;

@property (strong, nonatomic) NSString *introImagePath;
@property (strong, nonatomic) NSString *introCount;
@property (strong, nonatomic) NSString *loginImagePath;

@property (strong, nonatomic) NSString *tabBarColor;
@property (strong, nonatomic) NSString *tabFontColor;

@property (strong, nonatomic) NSString *htmlPath;
@property (strong, nonatomic) NSString *offLineInfo;
@property (strong, nonatomic) NSString *serverVersion;
@property (strong, nonatomic) NSString *paramString;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *tabNumberArray;

@property (strong, nonatomic) NSString *preURL;
@property (strong, nonatomic) NSString *preTitleName;
@property (strong, nonatomic) NSString *preThirdTitle;
@property (strong, nonatomic) NSString *preMainTitle;

@property (strong, nonatomic) NSMutableArray *msgUserInfo;
@property (strong, nonatomic) NSString *bgIconImagePath;

@property (assign, nonatomic) BOOL useAutoLogin;

@property (strong, nonatomic) NSString *fcmToken;

- (UIColor *) myRGBfromHex: (NSString *) code;
+ (UIColor *) myRGBfromHex: (NSString *) code;
+ (NSString *)getAES256Key;
+ (NSData *) getDecodeData:(NSData *)data;
- (NSDictionary *)contracts;
- (void)setTabBar:(NSDictionary *)dic;
- (void) chageTabBarColor:(BOOL)isSub;
+ (NSDictionary *)getAllValueUrlDecoding:(NSDictionary *)dic;
+ (NSString *) getUUID;
+ (BOOL)isRooted;
- (void)initTabController;
+ (NSString *)deviceNetworkingType;

- (BOOL) canMakePhoneCalls;
- (BOOL) gpsAvailable;
- (BOOL) accelerometerAvailable;
- (BOOL) gyroscopeAvailable;
- (BOOL) compassAvailable;
- (BOOL) retinaDisplayCapable;
- (BOOL) frontCameraAvailable;
- (BOOL) linearCameraAvailable;
- (BOOL) cameraFlashAvailable;


@end
@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
- (NSString *)AES256EncryptWithKeyString:(NSString *)key;
- (NSString *)AES256DecryptWithKeyString:(NSString *)key;
@end
@interface NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
