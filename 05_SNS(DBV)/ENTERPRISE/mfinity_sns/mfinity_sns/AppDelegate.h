//
//  AppDelegate.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import <PushKit/PushKit.h>
#import <BackgroundTasks/BackgroundTasks.h>

#import "UIViewController+Utils.h"
#import "MFUtil.h"
#import "AFNetworkReachabilityManager.h"

#import "IntroViewController.h"
#import "PushReceivedHandler.h"
#import "RMQServerViewController.h"

@import FirebaseAnalytics;
@import FirebaseCore;
@import FirebaseCoreDiagnostics;
@import FirebaseInstallations;
@import FirebaseMessaging;
@import FirebaseInstanceID;

@class MFDBHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate, UITabBarControllerDelegate, UITabBarDelegate, NSURLConnectionDataDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSUserDefaults *appPrefs;
@property (strong, nonatomic) MFDBHelper *dbHelper;

@property (strong, nonatomic) NSString *appDeviceToken;

@property (strong, nonatomic) NSDictionary *inactivePushInfo;
@property (strong, nonatomic) NSDictionary *inactiveChatPushInfo;
@property (strong, nonatomic) NSDictionary *inactivePostPushInfo;

@property (strong, nonatomic) NSMutableArray *tabItemArr;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UITabBar *uiTabBar;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NSString *networkStatus;
@property (strong, nonatomic) NSString *currChatRoomNo; //현재 보고있는방에 메시지가 올 경우 노티를 띄우지 않기 위해 사용
@property (strong, nonatomic) NSString *compareAppVer;
@property (strong, nonatomic) NSString *downAppUrl;

@property (strong, nonatomic) NSString *mdmCallAPI;

@property (strong, nonatomic) NSString *toolBarBtnTitle;
@property (strong, nonatomic) NSString *ipAddr;

@property (strong, nonatomic) NSString *simplePwdFlag;
@property (strong, nonatomic) NSString *simplePwd;

@property (strong, nonatomic) NSString *sessionFlag;
@property (strong, nonatomic) NSString *sessionTerm;
@property (strong, nonatomic) NSString *sessionAlrm;

@property (strong, nonatomic) NSString *singleOnlineFlag;

@property (strong, nonatomic) NSString *fcmToken;

@property int errorExecCnt;
@property BOOL isLogin;
@property BOOL mqConnect; //mq 중복 연결 방지 위해 사용
@property BOOL isChatViewing; //채팅 뷰가 화면 최상단에 나타났는지(읽음처리를 위해 사용)
@property BOOL canFeedRefresh;
@property BOOL teamListRefresh; //팀룸목록 새로고침 시 디비처리때문에 시간이 오래걸려서 첫 실행때는 디비저장X

@property BOOL isExcuteMDM;

-(void)dataNetworkCheck;
-(NSString *)setPreferencesKey:(NSString *)keyName;

- (void)exitWorkApp;

-(void)setPrefsData;

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
