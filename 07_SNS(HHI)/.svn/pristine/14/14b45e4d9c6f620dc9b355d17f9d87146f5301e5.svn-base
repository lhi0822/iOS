//
//  RMQServerViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 5. 4..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RMQClient/RMQClient.h>

#import "AppDelegate.h"
#import "MFURLSession.h"

#import <sqlite3.h>

@interface RMQServerViewController : NSObject <MFURLSessionDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) NSMutableDictionary *recvDict;
@property (strong, nonatomic) NSString *roomName;
@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSString *recvRoomNo;
@property (strong, nonatomic) NSString *recvRoomNm;
@property (strong, nonatomic) NSMutableArray *tempArr;
@property (strong, nonatomic) NSString *myUserNo;
@property (strong, nonatomic) NSMutableDictionary *readCntDic;
@property (strong, nonatomic) NSDictionary *rmqDict;

-(void)connectMQServer :(NSDictionary *)dic;
-(void)disconnectMQServer;

+(void)sendChangeRoomNamePush:(NSString *)roomNm roomNo:(NSString *)roomNo;

@end

