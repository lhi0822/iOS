//
//  SendChatHandler.h
//  mfinity_sns
//
//  Created by hilee on 30/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MFUtil.h"
#import "ChatMessageData.h"

@interface SendChatHandler : NSObject

@property int tmpMsgIdx;
//@property int missedCnt;
//@property int tmpMissedCnt;

@property int uploadCnt;

@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *myUserNo;

@property (strong, nonatomic) NSMutableArray *resultArr;

@property (strong, nonatomic) NSMutableDictionary *firstAddMsg;
@property (strong, nonatomic) NSMutableDictionary *editInfoDic;

-(void)sendTextData:(NSString *)content msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary*))completion;

-(void)setVideoData:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary *resultDic))completion;
-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary *resultDic))completion;

@end

