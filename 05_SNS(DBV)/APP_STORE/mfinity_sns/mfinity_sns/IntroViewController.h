//
//  IntroViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"
#include "TargetConditionals.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MFUtil.h"
#import "UIDevice-Hardware.h"
#import "LoginViewController.h"
#import "MyViewController.h"
#import "RMQServerViewController.h"
#import "NewsFeedViewController.h"
#import "ShareSelectViewController.h"

@interface IntroViewController : UIViewController <MFURLSessionDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    int count;
    int endCount;
    NSTimer *myTimer;
    
    NSString *dvcId;
    NSString *dvcKind;
    NSString *dvcOs;
    NSString *appVersion;
    NSString *dvcVer;
    NSString *carrier;
    NSString *extRam;
    NSString *extTotVol;
    NSString *extUseVol;
    NSString *useVol;
    NSString *pushId1;
    NSString *isRooted;
    NSString *userId;
    NSString *userPwd;
    NSString *legacyNm;
    NSString *cpnCode;
}

@property (strong, nonatomic) IBOutlet UIImageView *introBg;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImgView;

@property (strong, nonatomic) IBOutlet UILabel *verLabel;

+(void)nextPage;

@end
