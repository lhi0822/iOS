//
//  SSLVPNConnect.m
//  mFinity
//
//  Created by hilee on 2021/03/22.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import "SSLVPNConnect.h"

@implementation SSLVPNConnect {
    NSString *profileName;
    NSString *otpNumber;
    NSString *userId;
    NSString *userPwd;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        profileName = @"SSLVPN Profile";
        otpNumber = @"";
        userId = @"test02";
        userPwd = @"admin123!";
        
        [SSLVPNConfig setApiHost:@"211.42.97.33"];
        [SSLVPNConfig setApiPort:443];
        
        [self checkClientViersion];
    }
    return self;
}

-(void)checkClientViersion{
    
    NSLog(@"SSL api Version : %@",[SSLVPNConfig getApiVersion]);
    
    [SSLVPN checkVersionWithCompleteBlock:^(NSError * _Nullable error, NSString* latestVersion, NSString* downloadURL, BOOL isAutoUpdate)
    {
        if(error) {
            //error 처리
            NSLog(@"checkClientViersion error : %@", error);
        } else {
            NSLog(@"latestVersion : %@", latestVersion);
//            BOOL canUpdate = ![latestVersion isEqualToString:currentAppVersion];
//
//            if(isAutoUpdate && canUpdate){
//                // 업데이트 알림
//
//                NSURL *url = [[NSURL alloc] initWithString:downloadURL];
//                [[UIApplication sharedApplication] openURL:url];
//            } else {
//                // 업데이트를 알리지 않음
//            }
        }
        
        [self checkAuthType];
    }];
}

-(void)checkAuthType{
    [SSLVPN checkServerWithCompleteBlock:^(NSError * _Nullable error, INNER_AUTH_RTYPE authType, LOGIN_RTYPE loginType)
     {
        NSLog(@"authType : %ld  loginType : %ld", (long)authType, (long)loginType);
        if(error) {
            //error 처리
            NSLog(@"checkServerWithCompleteBlock error : %@", error);
        } else {
            // UI처리
            switch (authType) {
                case AUTH_LOCAL_DB:
                    NSLog(@"AUTH_LOCAL_DB");
                    break;
                case AUTH_INTERNAL_OTP:
                    NSLog(@"AUTH_INTERNAL_OTP");
                    break;
                case AUTH_LOCAL_DB_AND_INTERNAL_OTP:
                    NSLog(@"AUTH_LOCAL_DB_AND_INTERNAL_OTP");
                    break;
            }
            switch (loginType) {
                case LOGIN_PASS:
                    NSLog(@"LOGIN_PASS");
                    break;
                case LOGIN_CERT:
                    NSLog(@"LOGIN_CERT");
                    break;
                case LOGIN_PASS_OR_CERT:
                    NSLog(@"LOGIN_PASS_OR_CERT");
                    break;
                case LOGIN_PASS_AND_CERT:
                    NSLog(@"LOGIN_PASS_AND_CERT");
                    break;
            }
            
            [self startTunnel];
        }
    }];
}

-(void)startTunnel{
    [SSLVPN checkServerWithCompleteBlock:^(NSError * _Nullable error, INNER_AUTH_RTYPE authType, LOGIN_RTYPE loginType) {
        if(error){
            NSLog(@"인증방식(로그인) 정보 가져오기 실패: %@", [error localizedDescription]);
        
        } else {
//            if([SSLVPN checkTunnelExistWithUserID:userId])// 동일한 터널이 존재하는지 검사
//            {
//                // authType이 AUTH_LOCAL_DB일 경우 다음과 같이 ID/PW로 로그인
//                [SSLVPN easyAuthWithUserId:userId withUserPwd:userPwd withSharing:false withProfileName:profileName withVPNStatuBlock:^(NEVPNStatus status) {
//                    switch(status){
//                        case NEVPNStatusInvalid:
//                            NSLog(@"status : NEVPNStatusInvalid");
//                            break;
//                        case NEVPNStatusDisconnected:
//                            NSLog(@"status : NEVPNStatusDisconnected");
//                            break;
//                        case NEVPNStatusConnecting:
//                            NSLog(@"status : NEVPNStatusConnecting");
//                            break;
//                        case NEVPNStatusConnected:
//                            NSLog(@"status : NEVPNStatusConnected");
//                            break;
//                        case NEVPNStatusReasserting:
//                            NSLog(@"status : NEVPNStatusReasserting");
//                            break;
//                        case NEVPNStatusDisconnecting:
//                            NSLog(@"status : NEVPNStatusDisconnecting");
//                            break;
//                    }
//                } withCompleteBlock:^(NSError * _Nullable error) {
//                    if(error)
//                        NSLog(@"터널링 에러: %@", [error localizedDescription]);
//                    else
//                        NSLog(@"터널링 성공");
//                }];
//
//            } else {
//                NSLog(@"터널링 에러 : 같은 터널 열려있지 않음");
//            }
            
            // authType이 AUTH_LOCAL_DB일 경우 다음과 같이 ID/PW로 로그인
            [SSLVPN easyAuthWithUserId:userId withUserPwd:userPwd withSharing:false withProfileName:profileName withVPNStatuBlock:^(NEVPNStatus status) {
                switch(status){
                    case NEVPNStatusInvalid:
                        NSLog(@"status : NEVPNStatusInvalid");
                        break;
                    case NEVPNStatusDisconnected:
                        NSLog(@"status : NEVPNStatusDisconnected");
                        break;
                    case NEVPNStatusConnecting:
                        NSLog(@"status : NEVPNStatusConnecting");
                        break;
                    case NEVPNStatusConnected:
                        NSLog(@"status : NEVPNStatusConnected");
                        break;
                    case NEVPNStatusReasserting:
                        NSLog(@"status : NEVPNStatusReasserting");
                        break;
                    case NEVPNStatusDisconnecting:
                        NSLog(@"status : NEVPNStatusDisconnecting");
                        break;
                }
            } withCompleteBlock:^(NSError * _Nullable error) {
                if(error)
                    NSLog(@"터널링 에러: %@", [error localizedDescription]);
                else
                    NSLog(@"터널링 성공");
            }];
        }
    }];
}

-(void)stopTunnel{
    if([SSLVPN checkTunnelExistWithUserID:userId])// 동일한 터널이 존재하는지 검사
    {
        [SSLVPNProfile stopVPNTunnelwithProfileName:profileName withCompleteBlock:^(NSError * _Nullable error) {
            if(error) {
                if([error code] == 702)
                    NSLog(@"터널링 종료 실패: 동일한 터널이지만 이 앱이 만든 터널이 아님");
                else
                    NSLog(@"터널링 종료 실패: %@", [error localizedDescription]);
            } else
                NSLog(@"터널링 종료 성공");
        }];
    } else {
        NSLog(@"터널링 종료 에러 : 같은 터널 열려있지 않음");
    }
}

@end
