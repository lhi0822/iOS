//
//  LoginViewController.h
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 24..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

#import "SessionHTTP.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Base64.h"
#import "FBEncryptorAES.h"
#import "NSData+AES256.h"
#import "SecurityManager.h"
#import "BeaconManager_Reco.h"
#import "BeaconManager_Minew.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>

#import <SystemConfiguration/CaptiveNetwork.h>
//#import "AppProxyProvider.h"

//getIPAddress
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface LoginViewController : UIViewController<NSURLConnectionDataDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate, UIScrollViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,SessionHTTPDelegate>{

    IBOutlet UITextField *idTextField;
    IBOutlet UITextField *pwTextField;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *logoView;
    IBOutlet UILabel *idLabel;
    IBOutlet UILabel *pwLabel;
    IBOutlet UILabel *verLabel;
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *idSaveButton;
    IBOutlet UIButton *pwSaveButton;
    
    CGRect idTextFieldRect;
    CGRect pwTextFieldRect;
    CGRect idSaveButtonRect;
    CGRect pwSaveButtonRect;
    CGRect idLabelRect;
    CGRect pwLabelRect;
    CGRect loginButtonRect;
    CLLocationManager *locationManager;
    
    AppDelegate *appDelegate;
    NSString *urlString;
    NSString *compCode;
    NSString *returnCode;
    NSString *isBeacon;
    UILabel *label;
    BOOL isIdSave;
    BOOL isPwSave;
    BOOL isRotate;
    
    BOOL getBadge;
    NSString *isBadge;

}
@property (nonatomic, retain) NSString *compCode;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) NSDictionary *compDic;
@property (nonatomic, retain) NSString *compName;
- (void)usingData:(NSString *)compNm;
-(IBAction)hidden:(id)sender;
-(IBAction)Login:(id)sender;
-(IBAction)idSave:(id)sender;
-(IBAction)pwSave:(id)sender;
@end
@interface NSString(URLEncoding2)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
@end


