//
//  PushReceiver.m
//  mFinity
//
//  Created by hilee on 2021/03/25.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import "PushReceiver.h"

typedef void(^PushReceiverExtLoadHandler)(BOOL success, NSString *richData, NSError *error);

@interface PushReceiver () <PushManagerDelegate>

@end

@implementation PushReceiver

- (void)dealloc {
    NSLog( @"PushReceiver - dealloc" );
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog( @"PushReceiver - init" );

        //PushManger에서 메시지 전달유무 설정값
        //모피어스 PUSH meap버전을 위해 필요(일반버전의 경우 YES)
        //NO일 경우엔 PushManager에서 메시지를 가지고 있다가 YES가 되는 시점에 딜리게이트로 전달 처리
        [PushManager defaultManager].enabled = YES;
        
        //APNS_MODE설정을 위한 값(4.0이상)
        [[PushManager defaultManager].info changeMode:@"DEV"];
    }
    return self;
}

- (void)manager:(PushManager *)manager didLoadPushInfo:(PushManagerInfo *)pushInfo {
    NSLog( @"PushReceiver - manager didLoadPushInfo: %@", pushInfo );
}

- (void)managerDidRegisterForRemoteNotifications:(PushManager *)manager userInfo:(NSDictionary *)userInfo {
    NSLog( @"PushReceiver - managerDidRegisterForRemoteNotifications userInfo: %@", userInfo );
}

- (void)manager:(PushManager *)manager didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog( @"PushReceiver - didFailToRegisterForRemoteNotificationsWithError error: %@", error );
}

- (void)manager:(PushManager *)manager didReceiveUserNotification:(NSDictionary *)userInfo status:(NSString *)status messageUID:(NSString *)messageUID {
    NSLog( @"PushReceiver - didReceiveUserNotification: %@ status: %@ messageUID:%@", userInfo, status, messageUID );
    
    NSString *extHTML = [[userInfo objectForKey:@"mps"] objectForKey:@"ext"];

    NSLog( @"PushReceiver - extHTML :%@", extHTML );
    
    if ( extHTML != nil && ([extHTML hasSuffix:@"_msp.html"] || [extHTML hasSuffix:@"_ext.html"]) ) {
        [self loadExtData:extHTML handler:^(BOOL success, NSString *richData, NSError *error) {
            NSLog( @"PushReceiver - richData : %@", richData );
        
            NSMutableDictionary *notification = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSMutableDictionary *mspData = [NSMutableDictionary dictionaryWithDictionary:[notification objectForKey:@"mps"]];
            [mspData setObject:richData forKey:@"ext"];
            [notification setObject:mspData forKey:@"mps"];
            
            //NSLog( @"notification: %@", notification );
            
            [self onReceiveNotification:[NSDictionary dictionaryWithDictionary:notification] status:status messageUID:messageUID];
        }];
    }
    else {
        //NSLog( @"notification: %@", userInfo );

        [self onReceiveNotification:userInfo status:status messageUID:messageUID];
    }
}

- (void)loadExtData:(NSString *)extHTML handler:(PushReceiverExtLoadHandler)handler {

    NSURL *url = [NSURL URLWithString:extHTML];
    
    if (!url) {
        handler(NO, extHTML, nil);
        return;
    }

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:extHTML]]
                            queue:[NSOperationQueue mainQueue]
                            completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if ( connectionError != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, extHTML, connectionError);
            });
            return;
        }
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
            
        if ( httpResponse.statusCode != 200 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, extHTML, nil);
            });
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *richData = [NSString stringWithString:result];
        
        richData = [richData stringByRemovingPercentEncoding];
        
        #if ! __has_feature(objc_arc)
        [result release];
        #endif
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(YES, richData, nil);
        });
    }];
}

- (void)onReceiveNotification:(NSDictionary *)payload status:(NSString *)status messageUID:(NSString *)messageUID {
    NSString *pushType = @"APNS";

    NSDictionary *apsInfo = [payload objectForKey:@"aps"];
    NSDictionary *alert = [apsInfo objectForKey:@"alert"];
    NSString *message = [alert objectForKey:@"body"];
    NSNumber *badge = [apsInfo objectForKey:@"badge"];

    NSDictionary *notificationInfo = @{@"status":status, @"payload":payload, @"type":pushType, @"messageUID": messageUID};

    NSLog( @"PushReceiver - notificationInfo: %@", notificationInfo );

    [[PushManager defaultManager].notificationCenter setBadgeNumber:badge];
    [[PushManager defaultManager] read:nil notification:payload completionHandler:^(BOOL success) {

    }];

    NSString *title = [NSString stringWithFormat:@"PUSH (%@)", status];

    if ( NSClassFromString(@"UIAlertController") ) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }]];

        UIViewController *viewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
        if ( viewController.presentedViewController ) {
            viewController = viewController.presentedViewController;
        }

        [viewController presentViewController:alert animated:YES completion:^{

        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
        [alert show];
    }
}
@end
