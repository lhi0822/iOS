//
//  RMQServerViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 5. 4..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "RMQServerViewController.h"
#import "MFUtil.h"
#import "AFNetworkReachabilityManager.h"
#import "HDNotificationView.h"
#import "MFDBHelper.h"

#import "IntroViewController.h"
#import "MyMessageViewController.h"
#import "TeamSelectController.h"


@interface RMQServerViewController () {
    RMQConnection *conn;
    
    BOOL success;
    BOOL networkFlag;
    //NSString *thumbImagePath;
    NSString *originImagePath;
    
    int channelNo;
    NSMutableArray *dataArray;
}

@end

id<RMQChannel> channel;

@implementation RMQServerViewController {
    AppDelegate *appDelegate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        channelNo = 0;
        dataArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Rabbit MQ (Official)
+(void)sendChangeRoomNamePush :(NSString *)roomNm roomNo:(NSString *)roomNo{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray<RMQValue *> *props = [RMQBasicProperties defaultProperties];
    
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setObject:@"CHANGE_CHAT_ROOM_NAME" forKey:@"TYPE"];
    [msgDict setObject:roomNo forKey:@"ROOM_NO"];
    [msgDict setObject:roomNm forKey:@"ROOM_NM"];
    NSData* msgData = [NSJSONSerialization dataWithJSONObject:msgDict options:kNilOptions error:nil];
    
    [channel basicPublish:msgData routingKey:[NSString stringWithFormat:@"USER.%@",[appDelegate.appPrefs objectForKey:@"USERID"]] exchange:[[MFSingleton sharedInstance] rmq_exTopic] properties:props options:0];
}
- (void)connectMQServer :(NSDictionary *)dic{
    NSLog();
   
    if(!appDelegate.mqConnect&&(conn==nil||[conn isEqual:@"(null)"])){
        appDelegate.mqConnect = YES;
        conn = [[RMQConnection alloc] initWithUri:[NSString stringWithFormat:@"amqp://%@:%@@%@:%d/%@", [[MFSingleton sharedInstance] rmq_user], [[MFSingleton sharedInstance] rmq_pwd], [[MFSingleton sharedInstance] rmq_host], [[MFSingleton sharedInstance] rmq_port], [[MFSingleton sharedInstance] rmq_virtualHost]] delegate:[RMQConnectionDelegateLogger new]];
//        [conn start];
        [conn start:^{
            NSLog(@"MQ 커넥션 연결 완료");
            
            SyncChatInfo *sync = [[SyncChatInfo alloc] init];
            [sync syncChatRoom];
            
            NSLog(@"IS_FIRST_LOGIN : %@", [appDelegate.appPrefs objectForKey:@"IS_FIRST_LOGIN"]);
            if([[appDelegate.appPrefs objectForKey:@"IS_FIRST_LOGIN"] isEqual:@"FIRST"]){
                [appDelegate.appPrefs setObject:@"NOT_FIRST" forKey:@"IS_FIRST_LOGIN"];
                [appDelegate.appPrefs synchronize];

                NSString *paramString = [NSString stringWithFormat:@"usrId=%@&dvcId=%@",[appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
                [self callWebService:@"setUsrRoutingKey" WithParameter:paramString];
            }
        }];
        
        channel = [conn createChannel];
        
        NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
        NSString *dvcID = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
        NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
        NSString *deptNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DEPTNO"]];
        NSString *senderID = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];//[MFUtil getMfpsId];
        
        RMQExchange *fanout = [channel fanout:[[MFSingleton sharedInstance] rmq_exFanout] options:RMQExchangeDeclareDurable];
        RMQExchange *topic1 = [channel topic:[[MFSingleton sharedInstance] rmq_exTopic] options:RMQExchangeDeclareDurable];
        RMQExchange *topic2 = [channel topic:[[MFSingleton sharedInstance] rmq_exTopic] options:RMQExchangeDeclareDurable];
        RMQExchange *topic3 = [channel topic:[[MFSingleton sharedInstance] rmq_exTopic] options:RMQExchangeDeclareDurable];
        RMQExchange *direct1 = [channel direct:[[MFSingleton sharedInstance] rmq_exDirect] options:RMQExchangeDeclareDurable];
        RMQExchange *direct2 = [channel direct:[[MFSingleton sharedInstance] rmq_exDirect] options:RMQExchangeDeclareDurable];
        //RMQExchange *direct3 = [channel direct:[[MFSingleton sharedInstance] rmq_exDirect] options:RMQExchangeDeclareDurable];
        RMQExchange *topic4 = [channel topic:[[MFSingleton sharedInstance] rmq_exTopic] options:RMQExchangeDeclareDurable];
        
        //큐 정책 설정
        NSDictionary *args = [[NSDictionary alloc] init];
//        RMQLongstr *mode = [[RMQLongstr alloc] init:@"all"];
//        RMQLongstr *syncMode = [[RMQLongstr alloc] init:@"automatic"];
        
//        int saveTime = 86400 * 5 * 1000; //5일
        int saveTime = 1000; //1초
        RMQLong *ttl = [[RMQLong alloc] init:saveTime];
        RMQLongstr *deadLetter = [[RMQLongstr alloc] init:@"mfps.dlx"];

        //공용단말기 ip가 여러개일수있음
//        NSMutableArray *ipArr = [NSMutableArray array];
//        NSString *currIp = [appDelegate.ipAddr substringToIndex:5];
//        for(int i=0; i<ipArr.count; i++){
//            NSString *pubDvcIp = [[ipArr objectAtIndex:i] substringToIndex:5];
//            if([currIp isEqualToString:pubDvcIp]){
//                args = @{};
//            } else {
//                args = @{@"x-message-ttl":ttl, @"x-dead-letter-exchange":deadLetter};
//            }
//        }
        
        NSString *pubDvcIp = [appDelegate.ipAddr substringToIndex:5];
        if([pubDvcIp isEqualToString:@"10.40"]){
            //args = @{@"x-ha-mode":mode, @"x-ha-sync-mode":syncMode};
            args = @{};
        } else {
            //args = @{@"x-ha-mode":mode, @"x-ha-sync-mode":syncMode, @"x-message-ttl":ttl, @"x-dead-letter-exchange":deadLetter};
            args = @{@"x-message-ttl":ttl, @"x-dead-letter-exchange":deadLetter};
        }
        
        RMQQueue *rmqQueue = [channel queue:senderID options:RMQQueueDeclareDurable arguments:args];
        
        [rmqQueue bind:fanout routingKey:@""];
        [rmqQueue bind:topic2 routingKey:[NSString stringWithFormat:@"COMP.%@", compNo]];
        [rmqQueue bind:topic3 routingKey:[NSString stringWithFormat:@"DEPT.%@", deptNo]];
        [rmqQueue bind:direct1 routingKey:senderID];
        [rmqQueue bind:direct2 routingKey:[NSString stringWithFormat:@"USER.%@.%@",userID, dvcID]];
        //[rmqQueue bind:direct3 routingKey:[NSString stringWithFormat:@"USER.%@",userID]];
        [rmqQueue bind:topic4 routingKey:[NSString stringWithFormat:@"USER.%@",userID]];
                
//        if(dic!=nil){
//            NSArray *queueArr = [dic objectForKey:@"ROUTING_KEY"];
//
//            for(int i=0; i<queueArr.count; i++){
//                [rmqQueue bind:topic1 routingKey:[queueArr objectAtIndex:i]];
//            }
//        }
        
        [rmqQueue subscribe:RMQBasicConsumeNoOptions handler:^(RMQMessage * _Nonnull message) {
            [channel ack:message.deliveryTag];
            [self receivceMQPush:message];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"getUserQueueInfo DISPATCH_TIME_NOW>>>>>>>>>>>>>>>>");
            NSString *paramString = [NSString stringWithFormat:@"queueName=%@&dvcId=%@",senderID, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            [self callWebService:@"getUserQueueInfo" WithParameter:paramString];

            NSString *dlqUrl = @"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish";
            NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];

            NSDictionary *emptyDict = [NSDictionary dictionary];
            NSString* emptyJson = nil;
            NSData* emptyData = [NSJSONSerialization dataWithJSONObject:emptyDict options:kNilOptions error:nil];
            emptyJson = [[NSString alloc] initWithData:emptyData encoding:NSUTF8StringEncoding];

            NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
            [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
            [dlqDict setObject:@"1" forKey:@"APP_NO"];
            [dlqDict setObject:[[MFSingleton sharedInstance] appType] forKey:@"APP_TYPE"];
            [dlqDict setObject:@"i" forKey:@"DVC_OS"];
            [dlqDict setObject:[[MFSingleton sharedInstance] dvcType] forKey:@"DVC_TYPE"];
            [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] forKey:@"PUSH_ID"];
            [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
            [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]forKey:@"DVC_ID"];
            [dlqDict setObject:mfpsId forKey:@"QUEUE_NAME"];
            NSString* dlqJson = nil;
            NSData* dlqData = [NSJSONSerialization dataWithJSONObject:dlqDict options:kNilOptions error:nil];
            dlqJson = [[NSString alloc] initWithData:dlqData encoding:NSUTF8StringEncoding];
            dlqJson = [dlqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];

            NSMutableDictionary *dlqDict2 = [NSMutableDictionary dictionary];
            [dlqDict2 setObject:dlqDict forKey:@"properties"];
            [dlqDict2 setObject:@"UPDATE_USER_INFO" forKey:@"routing_key"];
            [dlqDict2 setObject:dlqJson forKey:@"payload"];
            [dlqDict2 setObject:@"string" forKey:@"payload_encoding"];
            NSString* dlqJson2 = nil;
            NSData* dlqData2 = [NSJSONSerialization dataWithJSONObject:dlqDict2 options:kNilOptions error:nil];
            dlqJson2 = [[NSString alloc] initWithData:dlqData2 encoding:NSUTF8StringEncoding];

            MFURLSession *dlqSession = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:dlqUrl] option:dlqJson2];
            [dlqSession start];
        });
    }
}
-(void)receivceMQPush:(RMQMessage *)message{
    NSLog(@"RMQ_PUSH>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> :\n%@", [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
    _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    //Receive------------------
    dispatch_async(dispatch_get_main_queue(), ^{
        @try{
            NSData *jsonData = message.body;
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
            [dict2 setDictionary:dict];
            
            NSString *result = [dict objectForKey:@"RESULT"];
            NSString *pushType = [dict objectForKey:@"TYPE"];
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if([pushType isEqualToString:@"ADD_CHAT"]){
                    [self pushAddChat:dict];
                    
                    //미디어 접근권한 테스트
//                    NSString *json = @"{\"MESSAGE\":\"-\",\"RESULT\":\"SUCCESS\",\"TYPE\":\"SYSTEM_MSG\",\"SUB_TYPE\":\"SYSMSG_CHANGE_PERMISSION\", \"DATASET\":[{\"CUSER_NO\":120818, \"PRM_TY\":\"1\", \"PRM_NM\":\"MediaPermission\", \"PRM_STATUS\":true},{\"CUSER_NO\":120818, \"PRM_TY\":\"1\", \"PRM_NM\":\"FilePermission\", \"PRM_STATUS\":false}]}";
//                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//                    [self pushSystemMsg:jsonDict];
                    
                } else if([pushType isEqualToString:@"UPDATE_CHAT_UNREAD_COUNT"]){
                    [self pushUpdateChatUnreadCount:dict];
                    
                } else if([pushType isEqualToString:@"CREATE_CHAT_ROOM"]){
                    [self pushCreateChatRoom:dict];
                    
                } else if([pushType isEqualToString:@"ADD_CHAT_USER"]){
                    [self pushAddChatUser:dict];
                    
                } else if([pushType isEqualToString:@"DELETE_CHAT_USER"]){
                    [self pushDeleteChatUser:dict];
                    
                } else if([pushType isEqualToString:@"CHANGE_USER_PROFILE"]){
                    [self pushChangeUserProfile:dict];
                }
            }
            
            if([pushType isEqualToString:@"NEW_POST"]){
                [self pushNewPost:dict];
                
            } else if([pushType isEqualToString:@"NEW_POST_COMMENT"]){
                [self pushNewPostComment:dict];
                
            } else if([pushType isEqualToString:@"FORCE_DELETE_SNS"]){
                //게시판 강제 탈퇴
                [self pushForceDeleteSNS:dict];
                
            } else if([pushType isEqualToString:@"DELETE_SNS"]){
                //게시판 삭제 푸시
                [self pushDeleteSNS:dict];
                
            } else if([pushType isEqualToString:@"APPROVE_SNS"]){
                //게시판 가입 신청 승인
                [self pushApproveSNS:dict];
                
            } else if([pushType isEqualToString:@"CHANGE_SNS_LEADER"]){
                [self pushChangeSNSLeader:dict];
                
            } else if([pushType isEqualToString:@"NEW_TASK"]){
                [self pushNewTask:dict];
                
            } else if([pushType isEqualToString:@"EDIT_TASK"]){
                [self pushEditTask:dict];
            
            } else if([pushType isEqualToString:@"CHANGE_CHAT_ROOM_NAME"]){
                [self pushChangeChatRoomName:dict];
                
            } else if([pushType isEqualToString:@"APPROVE_REQUEST_SNS"]){
                [self pushApproveReqSNS:dict];
               
            } else if([pushType isEqualToString:@"REJECT_SNS"]){
                [self pushRejectSNS:dict];
                
            } else if([pushType isEqualToString:@"SYSTEM_MSG"]){
                [self pushSystemMsg:dict];
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"system_msg", @"system_msg") message:NSLocalizedString(@"업데이트 하세요~~", @"업데이트 하세요~~") preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                                 handler:^(UIAlertAction * action) {
//                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
//                                                                 }];
//                [alert addAction:okButton];
//                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:NO completion:nil];
            }
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
            
        }
    });
}
-(void)disconnectMQServer {
    NSLog();
    @try{
        appDelegate.mqConnect = NO;
        appDelegate.isChatViewing = NO;
        [conn close];
        conn = nil;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - RMQ Push
-(void)pushAddChat:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
//        NSLog(@"rmq dataSet : %@", dataSet);
        
        //NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
        NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"];
        NSString *decodeFileNm = [NSString urlDecodeString:fileName];
        //NSString *date = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"];
        //NSString *decodeDate = [NSString urlDecodeString:date];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
        self.recvRoomNo = roomNo;
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/", roomNo, [MFUtil getFolderName:contentType], currentTime];
        NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/thumb/", roomNo, [MFUtil getFolderName:contentType], currentTime];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
        if (issue) {
            
        }else{
            NSLog(@"Chat RoomNo directory can't read...Create Folder");
            [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if([contentType isEqualToString:@"IMG"]){
            UIImage *originImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            NSData *originImageData = UIImageJPEGRepresentation(originImage, 0.1);
            
            originImagePath = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",decodeFileNm]];
            [originImageData writeToFile:originImagePath atomically:YES];
            
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeFileThumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            
            //큰이미지 사이즈조절
            if(thumbImage.size.height > thumbImage.size.width*2){
                UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : thumbImage];
                thumbImage = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
                thumbImage = [MFUtil getScaledLowImage:thumbImage scaledToMaxWidth:180.0f];
            }
            
            NSData *thumbImageData = UIImagePNGRepresentation(thumbImage);
            NSString *thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
            
            NSLog(@"### RMQ originImagePath : %@", originImagePath);
            NSLog(@"### RMQ thumbImagePath : %@", thumbImagePath);
        
        } else if([contentType isEqualToString:@"VIDEO"]){
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeFileThumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            
            //큰이미지 사이즈조절
            if(thumbImage.size.height > thumbImage.size.width*2){
                UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : thumbImage];
                thumbImage = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
                thumbImage = [MFUtil getScaledLowImage:thumbImage scaledToMaxWidth:180.0f];
            }
            
            NSData *thumbImageData = UIImagePNGRepresentation(thumbImage);
            NSString *thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
        }
        
        [self readFromDatabase];
        
        if(self.array.count == 0){
            [dataArray insertObject:dict atIndex:0];
            
//            if(sync){
//                sync.delegate = self;
//                NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
//                NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
//                NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&roomNo=%@&dvcId=%@", userID, userNo, roomNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
//                NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getRoomInfo"]];
//                [sync URL:url parameter:paramString :dict];
//
//            } else {
//                sync = [[MFSyncURLSession alloc] init];
//                sync.delegate = self;
//            }
            
            NSLog(@"채팅목록에 없을때 생성하는것 같은데 왜 sync를 쓰는거지");
            NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
            NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&roomNo=%@&dvcId=%@", userID, userNo, roomNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            [self callWebService:@"getRoomInfo" WithParameter:paramString];
            
        } else {
            NSLog(@"채팅방목록에 채팅방번호가 있을때");
            [self addChatExecute:dict];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushUpdateChatUnreadCount:(NSDictionary *)dict{
    NSLog();
   
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *roomNo = [dict objectForKey:@"ROOM_NO"];
        
        for(int i=0; i<dataSet.count; i++){
            NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO_LIST"]];
            NSNumber *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
            
            NSString *sqlString = [appDelegate.dbHelper updateChatUnReadCount:unreadCnt roomNo:roomNo chatNoList:chatNoList];
            [appDelegate.dbHelper crudStatement:sqlString];
        }
        
        NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:roomNo];
        [appDelegate.dbHelper crudStatement:sqlString2];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatReadPush" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushCreateChatRoom:(NSDictionary *)dict{
    @try{
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
//        NSLog(@"pushCreateChatRoom : %@", dataSet);
        
        self.recvRoomNo = [dataSet objectForKey:@"ROOM_NO"];
        self.recvRoomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomNm = [NSString urlDecodeString:self.recvRoomNm];
        NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = decodeRoomNm;
        else resultRoomNm = [MFUtil createChatRoomName:decodeRoomNm roomType:roomType];

        NSArray *users = [dataSet objectForKey:@"USERS"];
        [self readFromDatabase];
        
        //채팅방목록에 채팅방번호가 없으면 새채팅방 생성
        if(self.array.count == 0){
            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
            NSMutableArray *roomImgArr = [NSMutableArray array];
            NSMutableArray *myRoomImgArr = [NSMutableArray array];
            int roomImgCount = 1;
            
            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:self.recvRoomNo roomName:resultRoomNm roomType:roomType];
            for (int i=0; i<users.count; i++) {
                NSString *userNo = [[users objectAtIndex:i] objectForKey:@"USER_NO"];
                NSString *userNm = [[users objectAtIndex:i] objectForKey:@"USER_NM"];
                NSString *decodeUserNm = [NSString urlDecodeString:userNm];
                NSString *userMsg = [[users objectAtIndex:i] objectForKey:@"USER_MSG"];
                NSString *decodeUserMsg = [NSString urlDecodeString:userMsg];
                NSString *userImg = [[users objectAtIndex:i] objectForKey:@"USER_IMG"];
                NSString *decodeUserImg = [NSString urlDecodeString:userImg];
                NSString *userId = [[users objectAtIndex:i] objectForKey:@"USER_ID"];
                NSString *phoneNo = [[users objectAtIndex:i] objectForKey:@"PHONE_NO"];
                NSString *deptNo = [[users objectAtIndex:i] objectForKey:@"DEPT_NO"];
                NSString *userBgImg = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"USER_BACKGROUND_IMG"]];
                
                NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DEPT_NM"]];
                NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
                NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
                NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
                NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
                NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
                NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
                NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                
                if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                    if(roomImgCount<=4){
                        if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [roomImgArr addObject:decodeUserImg];
                        [roomUsers setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                        roomImgCount++;
                    }
                } else {
                    if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [myRoomImgArr addObject:decodeUserImg];
                }
            
                NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:self.recvRoomNo userNo:userNo];
                
                [appDelegate.dbHelper crudStatement:sqlString2];
                [appDelegate.dbHelper crudStatement:sqlString3];
            }
            [appDelegate.dbHelper crudStatement:sqlString1];
            
            if(roomUsers.count>0){
                [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
            } else {
                [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:dict];
        
        self.recvRoomNo = nil;
        self.recvRoomNm = nil;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
-(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSString *imgPath = [MFUtil createChatRoomImg:dict :array :memberCnt :roomNo];
    return imgPath;
}

-(void)pushAddChatUser:(NSDictionary *)dict{
    @try{
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        NSArray *users = [dataSet objectForKey:@"USERS"];
        NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
        NSString *roomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomName = [NSString urlDecodeString:roomNm];
        
        NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
        NSString *decodeUserNm = [NSString urlDecodeString:userNm];
        
        if([decodeRoomName rangeOfString:decodeUserNm].location != NSNotFound){
            decodeRoomName = [decodeRoomName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", decodeUserNm] withString:@""];
        }
        
        NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
        NSMutableArray *roomImgArr = [NSMutableArray array];
        NSMutableArray *myRoomImgArr = [NSMutableArray array];
        int roomImgCount = 1;

        NSString *sqlString1 = [appDelegate.dbHelper updateRoomName:decodeRoomName roomNo:roomNo];
        
        for (int i=0; i<users.count; i++) {
            NSString *userNo = [[users objectAtIndex:i] objectForKey:@"USER_NO"];
            NSString *userNm = [[users objectAtIndex:i] objectForKey:@"USER_NM"];
            NSString *decodeUserNm = [NSString urlDecodeString:userNm];
            NSString *userMsg = [[users objectAtIndex:i] objectForKey:@"USER_MSG"];
            NSString *decodeUserMsg = [NSString urlDecodeString:userMsg];
            NSString *userImg = [[users objectAtIndex:i] objectForKey:@"USER_IMG"];
            NSString *decodeUserImg = [NSString urlDecodeString:userImg];
            NSString *userId = [[users objectAtIndex:i] objectForKey:@"USER_ID"];
            NSString *phoneNo = [[users objectAtIndex:i] objectForKey:@"PHONE_NO"];
            NSString *deptNo = [[users objectAtIndex:i] objectForKey:@"DEPT_NO"];
            NSString *userBgImg = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"USER_BACKGROUND_IMG"]];
            
            NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DEPT_NM"]];
            NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
            NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
            NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
            NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
            NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
            NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
            NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
            NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
            
//            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
//                if(roomImgCount<=4){
//                    if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [roomImgArr addObject:decodeUserImg];
//                    [roomUsers setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
//                    roomImgCount++;
//                }
//            } else {
//                if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [myRoomImgArr addObject:decodeUserImg];
//            }
            
            NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
            NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:userNo];
            
            [appDelegate.dbHelper crudStatement:sqlString2];
            [appDelegate.dbHelper crudStatement:sqlString3];
        }
        [appDelegate.dbHelper crudStatement:sqlString1];
        
        
        NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserNoAndUserImg:[dataSet objectForKey:@"ROOM_NO"]]];
        for(int i=0; i<selectArr.count; i++){
            NSString *chatUserNo = [[selectArr objectAtIndex:i] objectForKey:@"USER_NO"];
            NSString *chatUserImg = [[selectArr objectAtIndex:i] objectForKey:@"USER_IMG"];
            
            if(![[NSString stringWithFormat:@"%@", chatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                if(roomImgCount<=4){
                    if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [roomImgArr addObject:chatUserImg];
                    [roomUsers setObject:chatUserNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                    roomImgCount++;
                }
            } else {
                if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [myRoomImgArr addObject:chatUserImg];
            }
        }
        
        if(roomUsers.count>0){
            [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
        } else {
            [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeRoomName" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushDeleteChatUser:(NSDictionary *)dict{
    @try{
        //DELETE_USER
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        NSDictionary *users = [dataSet objectForKey:@"USERS"];
        NSString *roomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomNm = [NSString urlDecodeString:roomNm];
        NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
        NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = decodeRoomNm;
        else resultRoomNm = [MFUtil createChatRoomName:decodeRoomNm roomType:roomType];
        
        NSString *userNo = [users objectForKey:@"USER_NO"];
    
        NSString *sqlString1 = [appDelegate.dbHelper updateRoomName:resultRoomNm roomNo:[dataSet objectForKey:@"ROOM_NO"]];
        [appDelegate.dbHelper crudStatement:sqlString1];
        
        NSString *sqlString2 = [appDelegate.dbHelper deleteChatUsers:[dataSet objectForKey:@"ROOM_NO"] userNo:userNo];
        [appDelegate.dbHelper crudStatement:sqlString2];
        
        if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
            NSString *sqlString3 = [appDelegate.dbHelper deleteMissedChat:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString3];
            NSString *sqlString4 = [appDelegate.dbHelper deleteChats:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString4];
            NSString *sqlString5 = [appDelegate.dbHelper deleteChatUsers:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString5];
            NSString *sqlString6 = [appDelegate.dbHelper deleteChatRooms:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString6];
            
            NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
            if([currentClass isEqualToString:@"LGSideMenuController"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatExit" object:nil];
            }
            
            [self callDeletePush:roomNo userInfo:userNo type:@"CHAT"];
            
        } else {
            //사용자 나간 후 채팅방 유저 조회
            NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserNoAndUserImg:[dataSet objectForKey:@"ROOM_NO"]]];
            
            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
            NSMutableArray *roomImgArr = [NSMutableArray array];
            NSMutableArray *myRoomImgArr = [NSMutableArray array];
            int roomImgCount = 1;
            
            for(int i=0; i<selectArr.count; i++){
                NSString *chatUserNo = [[selectArr objectAtIndex:i] objectForKey:@"USER_NO"];
                NSString *chatUserImg = [[selectArr objectAtIndex:i] objectForKey:@"USER_IMG"];
                
                if(![[NSString stringWithFormat:@"%@", chatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                    if(roomImgCount<=4){
                        if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [roomImgArr addObject:chatUserImg];
                        [roomUsers setObject:chatUserNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                        roomImgCount++;
                    }
                } else {
                    if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [myRoomImgArr addObject:chatUserImg];
                }
            }
            
            if(roomUsers.count>0){
                [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :[dataSet objectForKey:@"ROOM_NO"]];
            } else {
                [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :[dataSet objectForKey:@"ROOM_NO"]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeRoomName" object:nil userInfo:dict];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushChangeUserProfile:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        //NSLog(@"dataSet : %@", dataSet);
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *userId = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
        //NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_NM"];
        NSString *phoneNo = [[dataSet objectAtIndex:0] objectForKey:@"PHONE_NO"];
        NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
        //NSString *profileImgThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_THUMB"]];
        NSString *deptNo = [[dataSet objectAtIndex:0] objectForKey:@"DEPT_NO"];
        NSString *profileBgImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
        //NSString *profileBgImgThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BACKGROUND_IMG_THUMB"]];
        
        NSString *deptName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DEPT_NM"]];
        NSString *levelName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NM"]];
        NSString *dutyName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DUTY_NM"]];
        NSString *jobGrpName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"JOB_GRP_NM"]];
        NSString *exCompNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY"]];
        NSString *exCompName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"]];
        NSString *levelNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NO"]];
        NSString *dutyNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DUTY_NO"]];
        NSString *userType = [[dataSet objectAtIndex:0] objectForKey:@"SNS_USER_TYPE"];
        
        NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:profileImg userMsg:profileMsg phoneNo:phoneNo deptNo:deptNo userBgImg:profileBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        
        //chat_users에 사용자 있는 방번호 조회
        NSMutableArray *selectRoomArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getRoomNo:userNo]];
        NSUInteger roomArrCnt = selectRoomArr.count;
        for(int i=0; i<(int)roomArrCnt; i++){
            //room_images에서 사용자있는 방 삭제
            NSString *roomNo = [[selectRoomArr objectAtIndex:i] objectForKey:@"ROOM_NO"];
            NSString *deleteRoomImg = [appDelegate.dbHelper deleteRoomImage:roomNo];
            [appDelegate.dbHelper crudStatement:deleteRoomImg];
            
            //다시 데이터 삽입
            NSMutableArray *selectUserArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserNoAndUserImg:roomNo]];
            NSUInteger userArrCnt = selectUserArr.count;
            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
            NSMutableArray *roomImgArr = [NSMutableArray array];
            NSMutableArray *myRoomImgArr = [NSMutableArray array];
            int roomImgCount = 1;
            
            for(int i=0; i<(int)userArrCnt; i++){
                NSString *chatUserNo = [[selectUserArr objectAtIndex:i] objectForKey:@"USER_NO"];
                NSString *chatUserImg = [[selectUserArr objectAtIndex:i] objectForKey:@"USER_IMG"];
                
                if(![[NSString stringWithFormat:@"%@", chatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                    if(roomImgCount<=4){
                        if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [roomImgArr addObject:chatUserImg];
                        [roomUsers setObject:chatUserNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                        roomImgCount++;
                    }
                } else {
                    if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [myRoomImgArr addObject:chatUserImg];
                }
            }
            
            if(roomUsers.count>0){
                [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)userArrCnt] :roomNo];
            } else {
                [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)userArrCnt] :roomNo];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeProfilePush" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushDeleteSNS:(NSDictionary *)dict{
    @try{
        NSLog(@"dict : %@", dict);
        NSString *snsName = [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *snsNo = [dict objectForKey:@"SNS_NO"];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_sns_1", @"delete_sns_1"), snsName, snsName];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:appName message:noticeMsg isAutoHide:YES onTouch:^{
            [HDNotificationView hideNotificationViewOnComplete:nil];
        }];
        
        NSString *sqlString = [appDelegate.dbHelper deleteSns:snsNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
        if([currentClass isEqualToString:@"TeamSelectViewController"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamExit" object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
//        191218_안드로이드쪽 푸시 수정되면 함수 호출 수정 필요
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:nil type:@"POST"];
        [self callDeletePush:snsNo userInfo:nil type:@"COMMENT"];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushNewPost:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NO"];
        //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
        //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
        NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];
        
        NSString *postNoti = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getPostNoti:snsNo]];
        NSLog(@"RMQ POST NOTI : %@", postNoti);
        
        if([postNoti isEqualToString:@"1"]||postNoti==nil){
            if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                NSString *noticeMsg = @"";
                if([[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWPOST"]] isEqualToString:@"0"]){
                    noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1_2", @"new_post1_2"), snsName, writerNm];
                } else {
                    noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1_4", @"new_post1_4"), snsName, writerNm, summary];
                }

                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]; //[[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
                [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                            title:appName
                                                          message:noticeMsg
                                                       isAutoHide:YES
                                                          onTouch:^{
                                                              [HDNotificationView hideNotificationViewOnComplete:nil];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:dict];
                                                          }];
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushNewPostComment:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *snsName =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        //NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NO"];
        //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
        //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
        NSNumber *cWriterNo = [[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NO"];
        NSString *cWriterNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NM"]];
        //NSString *cWriterId = [[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_ID"];
        NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];
        
        NSString *isTag = [NSString stringWithFormat:@"%@",[[dataSet objectAtIndex:0] objectForKey:@"IS_TAG"]];
        NSString *jsonTag = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TARGET_LIST"]];
        NSData *jsonData = [jsonTag dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSString *myName = [jsonDict objectForKey:[appDelegate.appPrefs objectForKey:@"USERID"]];
        
//        NSLog(@"pushNewPostComment dataSet : %@", dataSet);
        
        NSString *commNoti = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getCommentNoti:snsNo]];
        if([commNoti isEqualToString:@"1"]||commNoti==nil){
            if(![[NSString stringWithFormat:@"%@", cWriterNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                NSString *noticeMsg = @"";
                
                if([isTag isEqualToString:@"0"]){
                    if([[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1_2", @"new_post_comment1_2"), snsName, cWriterNm, writerNm];
                    } else {
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1_4", @"new_post_comment1_4"), snsName, cWriterNm, summary]; //내용표시해야함
                    }

                    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                                title:appName
                                                              message:noticeMsg
                                                           isAutoHide:YES
                                                              onTouch:^{
                                                                  [HDNotificationView hideNotificationViewOnComplete:nil];
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:dict];
                                                              }];
                } else {
                    if([[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2_2", @"new_post_comment2_2"), snsName, cWriterNm, myName];
                    } else {
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2_4", @"new_post_comment2_4"), snsName, cWriterNm, myName, summary]; //내용표시해야함
                    }
                    
                    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]; //[[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
                    [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                                title:appName
                                                              message:noticeMsg
                                                           isAutoHide:YES
                                                              onTouch:^{
                                                                  [HDNotificationView hideNotificationViewOnComplete:nil];
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:dict];
                                                              }];
                }
                
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushForceDeleteSNS:(NSDictionary *)dict{
    @try{
        //강제탈퇴 되었을 때 게시판목록, 게시판, 게시판정보, 게시판멤버정보 새로고침
        //로컬DB에서 SNS삭제
        NSLog(@"dict : %@", dict);
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *snsNo =  [dict objectForKey:@"SNS_NO"];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"force_delete_sns_2", @"force_delete_sns_2"), snsName];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:appName message:noticeMsg isAutoHide:YES onTouch:^{
            [HDNotificationView hideNotificationViewOnComplete:nil];
        }];
        
        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
        if([currentClass isEqualToString:@"TeamSelectViewController"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamExit" object:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];

//        191218_안드로이드쪽 푸시 수정되면 함수 호출 수정 필요
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:nil type:@"POST"];
        [self callDeletePush:snsNo userInfo:nil type:@"COMMENT"];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushApproveSNS:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast1_1", @"join_sns_toast1_1"), snsName];
        //NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:appName message:noticeMsg isAutoHide:YES onTouch:^{
            [HDNotificationView hideNotificationViewOnComplete:nil];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushChangeSNSLeader:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"change_sns_leader_2", @"change_sns_leader_2"), snsName];
        //NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                    title:appName
                                                  message:noticeMsg
                                               isAutoHide:YES
                                                  onTouch:^{
                                                      [HDNotificationView hideNotificationViewOnComplete:nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
                                                  }];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushNewTask:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NO"];
        //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NM"]];
        //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
        
        NSString *postNoti = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getPostNoti:snsNo]];
        if([postNoti isEqualToString:@"1"]){
            if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                NSString *noticeMsg = [NSString stringWithFormat:@"[%@] %@님이 새로운 업무를 생성하였습니다.", snsName, writerNm];
                //NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                            title:appName
                                                          message:noticeMsg
                                                       isAutoHide:YES
                                                          onTouch:^{
                                                              [HDNotificationView hideNotificationViewOnComplete:nil];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewTaskPush" object:nil userInfo:dict];
                                                          }];
            }
            
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushEditTask:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NO"];
        //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NM"]];
        //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
        
        NSString *postNoti = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getPostNoti:snsNo]];
        if([postNoti isEqualToString:@"1"]){
            if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                NSString *noticeMsg = [NSString stringWithFormat:@"[%@] %@님이 업무를 수정하였습니다.", snsName, writerNm];
                //NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                            title:appName
                                                          message:noticeMsg
                                                       isAutoHide:YES
                                                          onTouch:^{
                                                              [HDNotificationView hideNotificationViewOnComplete:nil];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewTaskPush" object:nil userInfo:dict];
                                                          }];
            }
            
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushChangeChatRoomName:(NSDictionary *)dict{
    @try{
        NSString *roomNo = [dict objectForKey:@"ROOM_NO"];
        NSString *changeRoomNm = [NSString urlDecodeString:[dict objectForKey:@"ROOM_NM"]];
        
        NSString *sqlString = [appDelegate.dbHelper updateCustomRoomName:changeRoomNm roomNo:roomNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeCustomRoomName" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeRoomName" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeCustomRoomName" object:nil userInfo:@{@"RESULT":@"FAIL"}];
    }
}

-(void)pushApproveReqSNS:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *reqUserName =  [NSString urlDecodeString:[dict objectForKey:@"REQUEST_USER_NM"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast13", @"join_sns_toast13"), reqUserName];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:snsName message:noticeMsg isAutoHide:YES onTouch:^{
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ApproveReqPush" object:nil userInfo:dict];
            [HDNotificationView hideNotificationViewOnComplete:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
        }];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}
-(void)pushRejectSNS:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *rejectMsg =  [NSString urlDecodeString:[dict objectForKey:@"REJECT_MESSAGE"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast14_1", @"join_sns_toast14_1"), snsName, rejectMsg];
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:snsName message:noticeMsg isAutoHide:YES onTouch:^{
            [HDNotificationView hideNotificationViewOnComplete:nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
        }];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

-(void)pushSystemMsg:(NSDictionary *)dict{
    NSLog(@"pushSysDict : %@", dict);
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *subType = [dict objectForKey:@"SUB_TYPE"];
        
       if([subType isEqualToString:@"SYSMSG_CHANGE_PERMISSION"]){
           NSArray *dataSet = [dict objectForKey:@"DATASET"];
           
           NSMutableArray *statusTrueArr = [[NSMutableArray alloc] init];
           NSMutableArray *statusFalseArr = [[NSMutableArray alloc] init];
           NSString *grantMsg;
           NSString *revokeMsg;
           NSString *resultMsg = @"";
           
           for(int i=0; i<dataSet.count; i++){
               NSString *prmUserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
               if([[NSString stringWithFormat:@"%@", prmUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                   NSString *prmNm = [[dataSet objectAtIndex:i] objectForKey:@"PRM_NM"];
                   NSString *prmStatus = [[dataSet objectAtIndex:i] objectForKey:@"PRM_STATUS"];
                   if([prmNm isEqualToString:@"MediaPermission"]){
                       if([prmStatus isEqual:@YES]) {
                           [statusTrueArr addObject:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                           [prefs setObject:@"1" forKey:@"MEDIA_AUTH"];
                       
                       } else if([prmStatus isEqual:@NO]) {
                           [statusFalseArr addObject:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                           [prefs setObject:@"0" forKey:@"MEDIA_AUTH"];
                       }
                       
                       [prefs synchronize];
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshProfilePush" object:nil];
                       
                   } /*else if([prmNm isEqualToString:@"FilePermission"]){ //임의로 만든거임
                       if([prmStatus isEqual:@YES]) {
                           [statusTrueArr addObject:@"파일 업로드 권한"];
                       
                       } else if([prmStatus isEqual:@NO]) {
                           [statusFalseArr addObject:@"파일 업로드 권한"];
                       }
                   }*/
               }
           }
           
           if(statusTrueArr.count>0){
               NSString *trueStr = [[statusTrueArr valueForKey:@"description"] componentsJoinedByString:@", "];
               grantMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_msg", @"user_permission_grant_msg"), trueStr];
           }
           
           if(statusFalseArr.count>0){
               NSString *falseStr = [[statusFalseArr valueForKey:@"description"] componentsJoinedByString:@", "];
               revokeMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_msg", @"user_permission_revoke_msg"), falseStr];
           }
           
           if(grantMsg!=nil&&revokeMsg!=nil) resultMsg = [NSString stringWithFormat:@"%@ \n%@", grantMsg, revokeMsg];
           else if(grantMsg!=nil&&revokeMsg==nil) resultMsg = grantMsg;
           else if(grantMsg==nil&&revokeMsg!=nil) resultMsg = revokeMsg;
           
           NSLog(@"resultMSG : %@", resultMsg);
           [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"] title:NSLocalizedString(@"user_permission_change", @"user_permission_change") message:resultMsg isAutoHide:YES onTouch:^{
               [HDNotificationView hideNotificationViewOnComplete:nil];
           }];
           
       } else if([subType isEqualToString:@"SYSMSG_CHANGE_EASY_PWD"]){
//           {"MESSAGE":"-","RESULT":"SUCCESS","EASY_PWD":"111111","EASY_PWD_FLAG":"Y","SUB_TYPE":"SYSMSG_CHANGE_EASY_PWD","TYPE":"SYSTEM_MSG"}
           NSString *easyPwdFlag = [dict objectForKey:@"EASY_PWD_FLAG"];
           NSString *easyPwd = [dict objectForKey:@"EASY_PWD"];
           appDelegate.simplePwdFlag = easyPwdFlag;
           appDelegate.simplePwd = easyPwd;
       
       } else if([subType isEqualToString:@"SYSMSG_CHANGE_LOGIN_MOBILE_USER"]){
           NSString *currUserId = [appDelegate.appPrefs objectForKey:@"USERID"];
           NSString *userId = [dict objectForKey:@"USER_ID"];
           NSString *currDvcId = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
           NSString *dvcId = [dict objectForKey:@"DEVICE_ID"];
           if([currUserId isEqualToString:userId] && ![currDvcId isEqualToString:dvcId]){
               NSString *userNm = [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]];
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"system_change_login_user", @"system_change_login_user"), userNm, userId] message:nil preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 exit(0);
                                                             }];
               [alert addAction:okButton];
               [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
           }
       }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

#pragma mark -
//채팅방목록조회
- (void)readFromDatabase {
    NSString *sqlString = [appDelegate.dbHelper getRoomList];

    self.tempArr = [NSMutableArray array];
    self.tempArr = [appDelegate.dbHelper selectMutableArray:sqlString];

    //기존 채팅방목록에 새채팅방번호가 있는지 비교
    self.array = [NSMutableArray array];
    for (int i=0; i<self.tempArr.count; i++) {
        NSDictionary *dictionary = [self.tempArr objectAtIndex:i];
        NSString *roomNoStr = [dictionary objectForKey:@"ROOM_NO"];
        
        if ([roomNoStr isEqualToString:[NSString stringWithFormat:@"%@", self.recvRoomNo]]) {
            [self.array addObject:roomNoStr];
        }
    }
}

- (void)chatRoomListCount :(NSString *)roomNo :(NSString *)userNo{
    @try{
        self.tempArr = [NSMutableArray array];
        [self readFromDatabase];
        
        int badgeCnt=0;
//        NSLog(@"tempArr : %@", self.tempArr);
        for(int i=0; i<self.tempArr.count; i++){
            int notReadCnt = [[[self.tempArr objectAtIndex:i]objectForKey:@"NOT_READ_COUNT"] intValue];
            badgeCnt+=notReadCnt;
        }
        
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            NSMutableDictionary *badgeDict = [NSMutableDictionary dictionary];
            [badgeDict setObject:[NSString stringWithFormat:@"%d", badgeCnt] forKey:@"CNT"];
            NSLog();
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:badgeDict];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addChatListExecute{
    @try{
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
        [dict2 setDictionary:[dataArray objectAtIndex:0]];
        
        NSArray *dataSet = [[dataArray objectAtIndex:0] objectForKey:@"DATASET"];
        
        NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
        NSString *date = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"];
        NSString *decodeDate = [NSString urlDecodeString:date];
        NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
        if ([contentType isEqualToString:@"INVITE"]) {
            content = [NSString urlDecodeString:content];
        }
        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *roomType = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomType:roomNo]];
        
        NSMutableString *contentStr = nil;
        NSDictionary *aditInfo = [[dataSet objectAtIndex:0] objectForKey:@"ADITINFO"];
        
        NSString *tmpNo = [aditInfo objectForKey:@"TMP_NO"];
        NSInteger tmpIdx = [[aditInfo objectForKey:@"TMP_IDX"] intValue];
        
        //시스템메시지일 경우
        if([contentType isEqualToString:@"SYS"]){
            NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
            NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
            
            if([sysMsgType isEqualToString:@"ADD_USER"]){
                NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                if([addSysMsg rangeOfString:@","].location != NSNotFound){
                    addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                }
                contentStr = [[NSMutableString alloc]initWithString:addSysMsg];
            } else {
                //DELETE_USER
                NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                contentStr = [[NSMutableString alloc]initWithString:deleteSysMsg];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:[dataArray objectAtIndex:0]];
            
        } else {
            contentStr = [[NSMutableString alloc]initWithString:content];
        }
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setValue:tmpNo forKey:@"TMP_NO"];
        [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
        [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
                
                [appDelegate.dbHelper crudStatement:sqlString];
            }
            
            if(![contentType isEqualToString:@"SYS"]){
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
        } else {
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }
        
        [self chatRoomListCount:roomNo :userNo];
        
        if([roomType isEqualToString:@"0"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NoticeChat" object:nil userInfo:[dataArray objectAtIndex:0]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Chat" object:nil userInfo:[dataArray objectAtIndex:0]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatList" object:nil userInfo:[dataArray objectAtIndex:0]];
        
        [dataArray removeObjectAtIndex:0];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addChatExecute:(NSDictionary *)dict{
    @try{
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
        [dict2 setDictionary:dict];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        
        NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
        NSString *date = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"];
        NSString *decodeDate = [NSString urlDecodeString:date];
        NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
//        if ([contentType isEqualToString:@"INVITE"]) {
            content = [NSString urlDecodeString:content];
//        }
        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *roomType = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomType:roomNo]];
        
        NSMutableString *contentStr = nil;
        NSDictionary *aditInfo = [[dataSet objectAtIndex:0] objectForKey:@"ADITINFO"];
        
        NSString *tmpNo = [aditInfo objectForKey:@"TMP_NO"];
        NSInteger tmpIdx = [[aditInfo objectForKey:@"TMP_IDX"] intValue];
        
        //시스템메시지일 경우
        if([contentType isEqualToString:@"SYS"]){
            NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
            NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
            
            if([sysMsgType isEqualToString:@"ADD_USER"]){
                NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                if([addSysMsg rangeOfString:@","].location != NSNotFound){
                    addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                }
                contentStr = [[NSMutableString alloc]initWithString:addSysMsg];
            } else {
                //DELETE_USER
                NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                contentStr = [[NSMutableString alloc]initWithString:deleteSysMsg];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:dict];
            
        } else {
            contentStr = [[NSMutableString alloc]initWithString:content];
            
            //상대방이보낸메시지
            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                
                NSString *msg = content;
                NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
                
                NSString *sqlString = [appDelegate.dbHelper getRoomNoti:roomNo];
                NSString *roomNoti = [appDelegate.dbHelper selectString:sqlString];
                
                //현재 보고있는방에 메시지가 올 경우 노티를 띄우지 않기 위한 로직
                //남이 보낸메시지 && 현재 보고있는방이 아닌 다른방으로 온 메시지
                if(![[NSString stringWithFormat:@"%@", appDelegate.currChatRoomNo] isEqualToString:[NSString stringWithFormat:@"%@", roomNo]]){
                    if([roomNoti isEqualToString:@"1"]){
                        [dict2 setObject:@"NOTI" forKey:@"NOTI"];
                        
                        if([contentType isEqualToString:@"IMG"]){
                            msg = NSLocalizedString(@"chat_receive_image", @"chat_receive_image");
                        } else if([contentType isEqualToString:@"VIDEO"]){
                            msg = NSLocalizedString(@"chat_receive_video", @"chat_receive_video");
                        } else if([contentType isEqualToString:@"FILE"]){
                            msg = NSLocalizedString(@"chat_receive_file", @"chat_receive_file");
                        } else if([contentType isEqualToString:@"INVITE"]){
                            msg = NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite");
                        } else { }
                        
                        NSString *noticeMsg = @"";
                        if([[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCHAT"]] isEqualToString:@"0"]){
                            noticeMsg = NSLocalizedString(@"new_chat_no_prev", @"new_chat_no_prev");
                        } else {
                            noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_chat_msg", @"new_chat_msg"), userName, msg];
                        }
                        
                        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"appVerIcon.png"]
                                                                    title:userName
                                                                  message:noticeMsg
                                                               isAutoHide:YES
                                                                  onTouch:^{
                                                                      [HDNotificationView hideNotificationViewOnComplete:nil];
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatPush" object:nil userInfo:dict2];
                                                                  }];
                    }
                }
            }
        }
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setValue:tmpNo forKey:@"TMP_NO"];
        [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
        [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"RMQ JsonSring : %@", jsonString);
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                NSLog(@"RMQ PUSH 받은메시지 로컬 저장");
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
              
                [appDelegate.dbHelper crudStatement:sqlString];
            }
            
            if(![contentType isEqualToString:@"SYS"]){
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
        } else {
            NSLog(@"내가보낸메시지");
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr]; //원래 isRead1
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                NSLog(@"RMQ PUSH 보낸메시지 로컬 저장 : 헐 여기지?!?!");
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""]; //원래 isRead1
                
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }
        [self chatRoomListCount:roomNo :userNo];
        
        if([roomType isEqualToString:@"0"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NoticeChat" object:nil userInfo:dict];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Chat" object:nil userInfo:dict];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatList" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}


#pragma mark -
- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
        NSLog(@"error : %@",errorMsg);
        
    }else{
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        NSDictionary *dic = session.returnDictionary;
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getUserQueueInfo"]) {
                @try{
                    NSString *dataStr = [dic objectForKey:@"DATASET"];
                    
                    NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                    
                    NSArray *consumerDetails = [dict objectForKey:@"consumer_details"];
                    
                    NSMutableArray *arr = [NSMutableArray array];
                    
                    for(int i=0; i<consumerDetails.count; i++){
                        NSDictionary *channelDetails = [[consumerDetails objectAtIndex:i]objectForKey:@"channel_details"];
                        NSString *connName = [channelDetails objectForKey:@"connection_name"];
                        NSString *connNo = [channelDetails objectForKey:@"number"];
                        
                        if(channelNo != [connNo intValue]){
                            [arr addObject:connName];
                        }
                    }
                    
                    if(arr.count>0){
                        NSData* connData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
                        NSString* connJsonData = [[NSString alloc] initWithData:connData encoding:NSUTF8StringEncoding];
                        NSLog(@"[getUserQueueInfo] connJsonData : %@", connJsonData);
                        
                        //이전의 커넥션 닫는 웹서비스 호출
                        [self callWebService:@"forceCloseConnection" WithParameter:[NSString stringWithFormat:@"connectionName=%@&dvcId=%@",connJsonData,[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]]];
                    }
                    
                } @catch(NSException *exception){
                    NSLog(@"Exception : %@", exception);
                }
                
            } else if ([wsName isEqualToString:@"forceCloseConnection"]) {
                NSLog(@"forceCloseConnection dic : %@", dic);
                
            } else if([wsName isEqualToString:@"getRoomInfo"]){
                @try{
                    NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
                    
                    NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
                    NSString *roomNm = [NSString urlDecodeString:[dataSet objectForKey:@"ROOM_NM"]];
                    NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
                    
                    NSString *resultRoomNm = @"";
                    if([roomType isEqualToString:@"3"]) resultRoomNm = roomNm;
                    else resultRoomNm = [MFUtil createChatRoomName:roomNm roomType:roomType];
                    
                    NSArray *users = [dataSet objectForKey:@"USERS"];
                    
                    NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
                    NSMutableArray *roomImgArr = [NSMutableArray array];
                    NSMutableArray *myRoomImgArr = [NSMutableArray array];
                    int roomImgCount = 1;
                    
                    NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:resultRoomNm roomType:roomType];
                    for (int i=0; i<users.count; i++) {
                        NSString *userNo = [[users objectAtIndex:i] objectForKey:@"USER_NO"];
                        NSString *userNm = [[users objectAtIndex:i] objectForKey:@"USER_NM"];
                        NSString *decodeUserNm = [NSString urlDecodeString:userNm];
                        NSString *userMsg = [[users objectAtIndex:i] objectForKey:@"USER_MSG"];
                        NSString *decodeUserMsg = [NSString urlDecodeString:userMsg];
                        NSString *userImg = [[users objectAtIndex:i] objectForKey:@"USER_IMG"];
                        NSString *decodeUserImg = [NSString urlDecodeString:userImg];
                        NSString *userId = [[users objectAtIndex:i] objectForKey:@"USER_ID"];
                        NSString *phoneNo = [[users objectAtIndex:i] objectForKey:@"PHONE_NO"];
                        NSString *deptNo = [[users objectAtIndex:i] objectForKey:@"DEPT_NO"];
                        NSString *userBgImg = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"USER_BACKGROUND_IMG"]];
                        
                        NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DEPT_NM"]];
                        NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
                        NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
                        NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
                        NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
                        NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
                        NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
                        NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                        NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                        
                        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                            if(roomImgCount<=4){
                                if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [roomImgArr addObject:decodeUserImg];
                                [roomUsers setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                                roomImgCount++;
                            }
                        } else {
                            if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) [myRoomImgArr addObject:decodeUserImg];
                        }
                        
                        NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                        NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:userNo];
                        
                        [appDelegate.dbHelper crudStatement:sqlString2];
                        [appDelegate.dbHelper crudStatement:sqlString3];
                    }
                    [appDelegate.dbHelper crudStatement:sqlString1];
                    
                    if(roomUsers.count>0){
                        [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
                    } else {
                        [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:dic];
             
                    [self addChatListExecute];
                    
                } @catch(NSException *exception){
                    NSLog(@"Exception : %@", exception);
                }
            } else if ([wsName isEqualToString:@"setUsrRoutingKey"]) {
                NSLog(@"setUsrRoutingKey dic : %@", dic);
            }
            
        } else{
            NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
            NSLog(@"error : %@",errorMsg);
        }
    }
    [SVProgressHUD dismiss];
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
    NSLog(@"error : %@",errorMsg);

    [SVProgressHUD dismiss];
    if(error.code == -1009){
        //Code=-1009 : 인터넷연결 꺼져있을경우?
        
    } if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
}

- (void)callDeletePush:(NSString *)num userInfo:(NSString *)userNo type:(NSString *)type{
    //내가 사용하는 다른 기기에서 동기화 시키기위해 호출
    @try {
        NSString *urlStr = @"";
        
        NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        if([type isEqualToString:@"CHAT"]){
            if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
                urlStr = [NSString stringWithFormat:@"http://mfps2.hhi.co.kr:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.CHAT.%@.%@",mfpsId,[[MFSingleton sharedInstance] appType],[appDelegate.appPrefs objectForKey:@"COMP_NO"],num];
            }
        } else {
            urlStr = [NSString stringWithFormat:@"http://mfps2.hhi.co.kr:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.BOARD.%@.%@.%@",mfpsId,[[MFSingleton sharedInstance] appType],type,[appDelegate.appPrefs objectForKey:@"COMP_NO"],num];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0f];
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
        
        __block NSData *data = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
            data = taskData;
            if (!data) {
                NSLog(@"%@", error);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

@end

