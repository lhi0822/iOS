//
//  NotificationService.h
//  NotiServiceEx
//
//  Created by hilee on 18/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>

#import "NotiExtensionUtil.h"
#import "MFDBHelper.h"
#import "MFURLSession.h"

@interface NotificationService : UNNotificationServiceExtension  <MFURLSessionDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate>

//@property (strong, nonatomic) NotiExtensionDBHelper *dbHelper;
@property (strong, nonatomic) MFDBHelper *dbHelper;

@property (strong, nonatomic) NSString *myUserNo;

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *roomNoti;

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSString *recvRoomNo;
@property (strong, nonatomic) NSString *recvRoomNm;
@property (strong, nonatomic) NSMutableArray *tempArr;

@property (strong, nonatomic) NSDictionary *returnDictionary;

@end

@interface NSString(URLEncoding)
- (NSString *)AES256EncryptWithKeyString:(NSString *)key;
- (NSString *)AES256DecryptWithKeyString:(NSString *)key;
@end
