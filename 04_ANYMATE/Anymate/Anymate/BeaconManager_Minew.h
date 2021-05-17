//
//  BeaconManager_Minew.h
//  Anymate
//
//  Created by hilee on 2020/11/26.
//  Copyright © 2020 Kyeong In Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <PushKit/PushKit.h>

#import <CoreLocation/CoreLocation.h>

#import "BeaconManager_Minew.h"

#import "SessionHTTP.h"
#import "NSData+Base64.h"
#import "FBEncryptorAES.h"
#import "NSData+AES256.h"
#import "MinewBeaconManager.h"
#import "MinewBeaconConnection.h"
#import "SecurityManager.h"
#import "LoginViewController.h"
#import "UrlSettingViewController.h"

@protocol MinewBeaconDelegate;

@interface BeaconManager_Minew : NSObject <MinewBeaconManagerDelegate, MinewBeaconConnectionDelegate, SessionHTTPDelegate, UIAlertViewDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate>{
    NSArray *_scannedBeacons;
}

@property (nonatomic, assign) BOOL isBeacon;
@property (nonatomic, assign) NSString *key;

@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;


@property (assign, nonatomic) id <MinewBeaconDelegate> delegate;

@end

@protocol MinewBeaconDelegate <NSObject>
@optional
-(BOOL)beaconSetting;
@end
