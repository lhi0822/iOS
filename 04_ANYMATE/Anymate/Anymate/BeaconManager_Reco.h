//
//  BeaconManager_Reco.h
//  Anymate
//
//  Created by hilee on 2016. 5. 25..
//  Copyright © 2016년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionHTTP.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Base64.h"
#import "FBEncryptorAES.h"
#import "NSData+AES256.h"
#import "SecurityManager.h"
#import "LoginViewController.h"
#import <Reco/Reco.h>
#import "UrlSettingViewController.h"
#import "RecoDefaults.h"

@protocol RecoBeaconDelegate;

@interface BeaconManager_Reco : NSObject <RECOBeaconManagerDelegate, SessionHTTPDelegate, UIAlertViewDelegate>{
    NSArray *_uuidList;
}

@property (nonatomic, assign) BOOL isBackgroundMonitoringOn;
@property (nonatomic, assign) BOOL isBeacon;
@property (nonatomic, assign) NSString *key;

@property (nonatomic, strong) RECOBeacon *beacon;
@property (nonatomic, strong) RecoDefaults *recoDefaults;
- (void) startBackgroundMonitoring;
- (void) stopBackgroundMonitoring;
- (void)_sendEnterLocalNotificationWithMessage:(NSString *)message;
- (void) httpConnect:(BOOL)_flag;

@property (assign, nonatomic) id <RecoBeaconDelegate> delegate;
@end

@protocol RecoBeaconDelegate <NSObject>
@optional
-(BOOL)beaconSetting;
@end


