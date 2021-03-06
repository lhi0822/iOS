//
//  PushReceivedHandler.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MFURLSession.h"
#import <sqlite3.h>
#import "ChatRoomImgDivision.h"

@interface PushReceivedHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;
@property (weak, nonatomic) NSString *myUserNo;

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *roomNoti;

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSString *recvRoomNo;
@property (strong, nonatomic) NSString *recvRoomNm;
@property (strong, nonatomic) NSMutableArray *tempArr;

@property (strong, nonatomic) NSDictionary *apsDict;

@property (strong, nonatomic) NSDictionary *returnDictionary;

@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *wsName;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) UIImage *returnImg;

@end
