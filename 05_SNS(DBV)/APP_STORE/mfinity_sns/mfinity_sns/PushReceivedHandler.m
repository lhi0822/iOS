//
//  PushReceivedHandler.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "PushReceivedHandler.h"
#import "HDNotificationView.h"
#import "MFDBHelper.h"

@implementation PushReceivedHandler {
    NSString *thumbImagePath;
    NSString *originImagePath;
    AppDelegate *appDelegate;
}

- (instancetype)init{
    NSLog();
    
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
//        dataArray = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotificationReceived" object:nil];
        
//        appDelegate.dbHelper = [[MFDBHelper alloc]init:[appDelegate.appPrefs objectForKey:@"USERID"]];
        appDelegate.dbHelper = [[MFDBHelper alloc] init:NO];
    }
    return self;
}

- (void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo : %@", userInfo);
    NSString *message = [userInfo objectForKey:@"MESSAGE"];
    
    @try{
        NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        NSString *pushType = [dict objectForKey:@"TYPE"];
        
        if([pushType isEqualToString:@"ADD_CHAT"]){
            [self pushAddChat:dict];
            
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
        
        if([pushType isEqualToString:@"NEW_POST"]){
            //appDelegate에 있음
            
        } else if([pushType isEqualToString:@"NEW_POST_COMMENT"]){
            //appDelegate에 있음
            
        } else if([pushType isEqualToString:@"FORCE_DELETE_SNS"]){
            //게시판 강제 탈퇴
            [self pushForceDeleteSNS:dict];
            
        } else if([pushType isEqualToString:@"DELETE_SNS"]){
            //게시판삭제 푸시
            [self pushDeleteSNS:dict];
            
        } else if([pushType isEqualToString:@"APPROVE_SNS"]){
            //게시판 가입 신청 승인
            [self pushApproveSNS:dict];
            
        } else if([pushType isEqualToString:@"CHANGE_SNS_LEADER"]){
            [self pushChangeSNSLeader:dict];
            
        } else if([pushType isEqualToString:@"NEW_TASK"]){
            //appDelegate에 있음
            
        } else if([pushType isEqualToString:@"EDIT_TASK"]){
            //appDelegate에 있음
        
        } else if([pushType isEqualToString:@"CHANGE_CHAT_ROOM_NAME"]){
            [self pushChangeChatRoomName:dict];
        
        } else if([pushType isEqualToString:@"APPROVE_REQUEST_SNS"]){
            [self pushApproveReqSNS:dict];
            
        } else if([pushType isEqualToString:@"REJECT_SNS"]){
            [self pushRejectSNS:dict];
            
        } else if([pushType isEqualToString:@"SYSTEM_MSG"]){
            //appDelegate에 있음
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotificationReceived" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}



#pragma mark - APNS Push
-(void)pushAddChat:(NSDictionary *)dict{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSLog(@"DICT : %@", dict);
        
        //NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
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
        
        NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/", self.roomNo, [MFUtil getFolderName:contentType], currentTime];
        NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/thumb/", self.roomNo, [MFUtil getFolderName:contentType], currentTime];
        
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
            
            originImagePath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",decodeFileNm]];
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
            thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
            
            NSLog(@"### APNS originImagePath : %@", originImagePath);
            NSLog(@"### APNS thumbImagePath : %@", thumbImagePath);
        
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
            thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
        }
        
        [self readFromDatabase];
        
        NSLog(@"목록에 있는 채팅방 번호 : %@", self.array);
        if(self.array.count == 0){
            self.dataArray = [NSMutableArray array];
            [self.dataArray insertObject:dict atIndex:0];
            NSLog(@"dataArray : %@", self.dataArray);
            
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
            
            NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
            NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&roomNo=%@&dvcId=%@", userID, userNo, roomNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            paramString = [MFUtil webServiceParamEncrypt:paramString];
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getRoomInfo"]];
            
            self.url = url;
            self.wsName = @"getRoomInfo";
            
            [self requestSynchronousDataWithURLString:url :paramString];
//            [self callWebService:@"getRoomInfo" WithParameter:paramString];
            
        } else {
            [self addChatExecute:dict];
        }
        
    } @catch(NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushUpdateChatUnreadCount:(NSDictionary *)dict{
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_APNS_ChatReadPush" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
}

-(void)pushCreateChatRoom:(NSDictionary *)dict{
    @try{
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        
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
                        if(decodeUserImg!=nil&&![decodeUserImg isEqualToString:@""]) {
                            [roomImgArr addObject:decodeUserImg];
                        }
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
                
                //프로필 썸네일 로컬저장
                /*NSString *tmpPath = NSTemporaryDirectory();
                 UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                 NSData *imageData = UIImagePNGRepresentation(thumbImage);
                 NSString *fileName = [decodeUserImg lastPathComponent];
                 
                 NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                 [imageData writeToFile:thumbImgPath atomically:YES];*/
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
        
    } @catch(NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
//    NSString *imgPath = [MFUtil createChatRoomImg:dict :array :memberCnt :roomNo];
     NSLog(@"dict : %@ / array : %@ / memberCnt : %@", dict, array, memberCnt);
//    dict : { "REF_NO1" = 120819; } / array : ( "https://touch1.hhi.co.kr/snsService/snsUpload/profile/10/120819/thumb/20200410-102010004.png" ) / memberCnt : 2
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *sqlString;
    NSString *roomImgName = [[array valueForKey:@"description"] componentsJoinedByString:@","];;
    
    NSArray *roomUserKey = [dict allKeys];
    NSArray *roomUserVal = [dict allValues];
    
    NSString *resultKey = [[roomUserKey valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *resultVal = [[roomUserVal valueForKey:@"description"] componentsJoinedByString:@","];
    
    if([memberCnt isEqualToString:@"1"]){
        sqlString = [appDelegate.dbHelper insertRoomImages:roomNo roomImg:roomImgName refNo1:myUserNo];
        
    } else {
        sqlString = [appDelegate.dbHelper insertRoomImages:resultKey roomNo:roomNo roomImg:roomImgName resultVal:resultVal];
    }
    
    [appDelegate.dbHelper crudStatement:sqlString];
}

-(void)pushAddChatUser:(NSDictionary *)dict{
    @try{
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        NSArray *users = [dataSet objectForKey:@"USERS"];
        NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
        NSString *roomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomName = [NSString urlDecodeString:roomNm];
        
        //apns로 보낼때 decodeUserNm이 null
        NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
        NSString *decodeUserNm = [NSString urlDecodeString:userNm];
        
        //        NSLog(@"ADD_CHAT_USER userNm : %@", userNm);
        //        NSLog(@"ADD_CHAT_USER decodeRoomName : %@", decodeRoomName);
        //        NSLog(@"ADD_CHAT_USER decodeUserNm : %@", decodeUserNm);
        
        if([decodeRoomName rangeOfString:decodeUserNm].location != NSNotFound){
            decodeRoomName = [decodeRoomName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", decodeUserNm] withString:@""];
            //NSLog(@"ADD_CHAT_USER decodeRoomName2 : %@", decodeRoomName);
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
        
        NSString *queueName = [dict objectForKey:@"QUEUE_NAME"];
        
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
            
//            [self callDeletePush:roomNo type:@"CHAT"];
            [self callDeletePush:roomNo userInfo:queueName type:@"CHAT"];
            
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
        
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *userId = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
//        NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_NM"];
        NSString *phoneNo = [[dataSet objectAtIndex:0] objectForKey:@"PHONE_NO"];
        NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
//        NSString *profileImgThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_THUMB"]];
        NSString *deptNo = [[dataSet objectAtIndex:0] objectForKey:@"DEPT_NO"];
        NSString *profileBgImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
//        NSString *profileBgImgThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BACKGROUND_IMG_THUMB"]];
        
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

-(void)pushNewPost:(NSDictionary *)dict{
    
}

-(void)pushNewPostComment:(NSDictionary *)dict{
   
}

-(void)pushForceDeleteSNS:(NSDictionary *)dict{
    @try{
        //강제탈퇴 되었을 때 게시판목록, 게시판, 게시판정보, 게시판멤버정보 새로고침
        //로컬DB에서 SNS삭제
        NSString *queueName = [dict objectForKey:@"QUEUE_NAME"];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsNo = [dict objectForKey:@"SNS_NO"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        /*
        NSError *error;
        NSString *noticeMsg = NSLocalizedString(@"force_delete_sns_1", @"force_delete_sns_1");
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:noticeMsg arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments = @[attachment];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
         */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ForceDeleteSNS" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:queueName type:@"POST"];
        [self callDeletePush:snsNo userInfo:queueName type:@"COMMENT"];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushDeleteSNS:(NSDictionary *)dict{
    @try{
        NSString *queueName = [dict objectForKey:@"QUEUE_NAME"];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsNo = [dict objectForKey:@"SNS_NO"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        /*
        NSError *error;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:NSLocalizedString(@"delete_sns_2", @"delete_sns_2"), snsName] arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments = @[attachment];
        
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
         */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:queueName type:@"POST"];
        [self callDeletePush:snsNo userInfo:queueName type:@"COMMENT"];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushApproveSNS:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsKind =  [dict objectForKey:@"SNS_KIND"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
     
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        /*
        NSError *error;
        NSString *noticeMsg = NSLocalizedString(@"join_sns_toast1_2", @"join_sns_toast1_2");
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        
        if([snsKind isEqualToString:@"1"]) content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@\n%@", noticeMsg, NSLocalizedString(@"new_post_content", @"new_post_content")] arguments:nil];
        else if([snsKind isEqualToString:@"2"]) content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@\n%@", noticeMsg, NSLocalizedString(@"new_task_content", @"new_task_content")] arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments=@[attachment];
        
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
        */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)pushChangeSNSLeader:(NSDictionary *)dict{
    @try{
        //NSLog(@"dict : %@", dict);
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        //NSString *snsKind =  [[dataSet objectAtIndex:0] objectForKey:@"SNS_KIND"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        /*
        NSError *error;
        NSString *noticeMsg = NSLocalizedString(@"change_sns_leader_1", @"change_sns_leader_1");
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:noticeMsg arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments=@[attachment];
        
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
        */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
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
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        //NSString *snsKind =  [[dataSet objectAtIndex:0] objectForKey:@"SNS_KIND"];
//        NSLog(@"imgPath : %@", imgPath);
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];

        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);

        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }

        /*
        NSError *error;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:noticeMsg arguments:nil];
        content.sound = [UNNotificationSound defaultSound];

        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments=@[attachment];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
        */
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}
-(void)pushRejectSNS:(NSDictionary *)dict{
    @try{
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *rejectMsg =  [NSString urlDecodeString:[dict objectForKey:@"REJECT_MESSAGE"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast14_2", @"join_sns_toast14_2"), rejectMsg];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        //NSString *snsKind =  [[dataSet objectAtIndex:0] objectForKey:@"SNS_KIND"];
//        NSLog(@"imgPath : %@", imgPath);
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
//        NSLog(@"tmpUrl : %@", tmpUrl);
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        /*
        NSError *error;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:snsName arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:noticeMsg arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        UNNotificationAttachment *attachment;
        attachment=[UNNotificationAttachment attachmentWithIdentifier:fileName URL:tmpUrl options:nil error:&error];
        content.attachments=@[attachment];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"req" content:content trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
         */
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

#pragma mark -
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
    self.tempArr = [NSMutableArray array];
    [self readFromDatabase];
    
    int badgeCnt=0;
    for(int i=0; i<self.tempArr.count; i++){
        int notReadCnt = [[[self.tempArr objectAtIndex:i]objectForKey:@"NOT_READ_COUNT"] intValue];
        badgeCnt+=notReadCnt;
    }
    NSMutableDictionary *badgeDict = [NSMutableDictionary dictionary];
    [badgeDict setObject:[NSString stringWithFormat:@"%d", badgeCnt] forKey:@"CNT"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:badgeDict];
}

-(void)addChatListExecute{
    @try{
//        [Hi-SNS] -[PushReceivedHandler addChatListExecute](L:1089) Exception : *** -[__NSArrayM objectAtIndex:]: index 0 beyond bounds for empty array
        NSLog(@"DATA ARR : %@", self.dataArray);
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
        [dict2 setDictionary:[self.dataArray objectAtIndex:0]];
        
        NSArray *dataSet = [[self.dataArray objectAtIndex:0] objectForKey:@"DATASET"];
        
        NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
//        NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"];
//        NSString *decodeFileNm = [NSString urlDecodeString:fileName];
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:[self.dataArray objectAtIndex:0]];
            
        } else {
            contentStr = [[NSMutableString alloc]initWithString:content];
        }
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setValue:tmpNo forKey:@"TMP_NO"];
        [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
//        [tmpDic setValue:@"SENDING" forKey:@"TYPE"];
        [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            
            if([contentType isEqualToString:@"LONG_TEXT"]){
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];

                [appDelegate.dbHelper crudStatement:sqlString];
            }
            
            if(![contentType isEqualToString:@"SYS"]){
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
        } else {
            if([contentType isEqualToString:@"LONG_TEXT"]){
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
            
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }
        
        [self chatRoomListCount:roomNo :_myUserNo];
        
        if([roomType isEqualToString:@"0"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NoticeChat" object:nil userInfo:[self.dataArray objectAtIndex:0]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Chat" object:nil userInfo:[self.dataArray objectAtIndex:0]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ApnsChatList" object:nil];
        
        [self.dataArray removeObjectAtIndex:0];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void) addChatExecute:(NSDictionary *)dict{
    @try{
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
        [dict2 setDictionary:dict];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        
        NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
//        NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"];
//        NSString *decodeFileNm = [NSString urlDecodeString:fileName];
        NSString *date = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"];
        NSString *decodeDate = [NSString urlDecodeString:date];
        NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
        if([contentType isEqualToString:@"INVITE"]){
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:dict];
            
        } else {
            contentStr = [[NSMutableString alloc]initWithString:content];
            
            //상대방이보낸메시지
            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                NSString *sql = [appDelegate.dbHelper getRoomNoti:self.roomNo];
                self.roomNoti = [appDelegate.dbHelper selectString:sql];
            }
        }
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setValue:tmpNo forKey:@"TMP_NO"];
        [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
//        [tmpDic setValue:@"SENDING" forKey:@"TYPE"];
        [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            if([contentType isEqualToString:@"LONG_TEXT"]){
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
             
                [appDelegate.dbHelper crudStatement:sqlString];
            }
            
            self.tempArr = [NSMutableArray array];
            self.tempArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getChatInfo]];
            //기존 채팅방목록에 새채팅방번호가 있는지 비교
            self.array = [NSMutableArray array];
            for (int i=0; i<self.tempArr.count; i++) {
                NSDictionary *dictionary = [self.tempArr objectAtIndex:i];
                NSString *roomNoStr = [dictionary objectForKey:@"ROOM_NO"];
                
                if ([roomNoStr isEqualToString:[NSString stringWithFormat:@"%@", self.recvRoomNo]]) {
                    [self.array addObject:roomNoStr];
                }
            }
            
            if(![contentType isEqualToString:@"SYS"]){
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
        } else {
            if([contentType isEqualToString:@"LONG_TEXT"]){
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                //NSString *sqlString = [appDelegate.dbHelper insertChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
         
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }
        
        [self chatRoomListCount:roomNo :_myUserNo];
        
        if([roomType isEqualToString:@"0"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NoticeChat" object:nil userInfo:dict];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Chat" object:nil userInfo:dict];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ApnsChatList" object:nil userInfo:dict];
        
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)requestSynchronousDataWithURLString:(NSURL *)url :(NSString *)paramString{
    NSLog();
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",url];
    
//    if([urlStr isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
    if([urlStr rangeOfString:@"/api/exchanges/snsHost/mfps"].location != NSNotFound){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            [request setValue:@"Basic cmFiYml0bXE6ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
        }
    }
    
    if (paramString != nil) {
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:paramData];
    }
    //[self startTask:request];
    
    @try {
        if (paramString != nil) {
            NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:paramData];
        }
        
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        configuration.allowsCellularAccess = YES;
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
//        self.returnData = [[NSMutableData alloc] init];
//        [task resume];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundPush"];
        configuration.allowsCellularAccess = YES;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithStreamedRequest:request];
        self.returnData = [[NSMutableData alloc] init];
        [uploadTask resume];
    }
    
    @catch (NSException *exception) {
        NSLog(@"error : %@",exception);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotification" object:nil];
        
        
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errMsg = [[NSString alloc]initWithString:NSLocalizedString(@"MFURLSession_Error_Title", @"")];
    
    if(code >= 200 && code < 300) {
        completionHandler (NSURLSessionResponseAllow);
    } else {
        NSLog(@"error : %@", errMsg);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog();
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @try {
        if(!error){
            NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
            
//            if(![[NSString stringWithFormat:@"%@",self.url] isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
            if([[NSString stringWithFormat:@"%@",self.url] rangeOfString:@"/api/exchanges/snsHost/mfps"].location == NSNotFound){
                if([self.wsName isEqualToString:@"changePublicPushId"]||[self.wsName isEqualToString:@"getUserQueueInfo"]){
                    
                } else {
                    if([[MFSingleton sharedInstance] wsEncrypt]){
                        encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
                    }
                }
                NSLog(@"%@, encReturnDataString : %@", self.wsName, encReturnDataString);
                NSError *dicError;
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                self.returnDictionary = dataDic;
                [self syncReturnDataWithObject:nil];
            }
            
        } else {
            NSLog(@"error! : %@", error);
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog();
}

-(void)syncReturnDataWithObject:(NSString *)error{
    NSLog();
    
    if (error != nil) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@",error];
        NSLog(@"error : %@",errorMsg);
        
    }else{
        NSDictionary *dic = self.returnDictionary;
        NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
        NSLog(@"DATASET : %@", dataSet);
        
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
        
        [self addChatListExecute];
        
    }
    [SVProgressHUD dismiss];
}

/*
- (void)startTask:(NSMutableURLRequest *)request{
    @try {
        __block NSData *data = nil;
        NSLog(@"START TASK--------------");
        
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
            data = taskData;
            if (!data) {
                NSLog(@"task error : %@", error);
            }
            
            NSMutableData *returnData = [[NSMutableData alloc] init];
            [returnData appendData:data];
            NSString *encReturnDataString = [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"encReturnDataString : %@", encReturnDataString);
            
            if([[MFSingleton sharedInstance] wsEncrypt]){
                encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
            }
            
            NSError *dicError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
            self.returnDictionary = dataDic;
            [self syncReturnDataWithObject:nil];
            
//            dispatch_semaphore_signal(semaphore);
        }];
        
        [task resume];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotification" object:nil];
    }
}
*/

//apns일때는 리턴항목의 QUEUE_NAME으로 mfpsId를 대신하고, 유저넘버 상관없이 그냥 호출하면됨.
- (void)callDeletePush:(NSString *)num userInfo:(NSString *)queueName type:(NSString *)type{
    //내가 사용하는 다른 기기에서 동기화 시키기위해 호출
    @try {
        NSString *urlStr = @"";
        
        if([type isEqualToString:@"CHAT"]){
            urlStr = [NSString stringWithFormat:@"http://%@:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.CHAT.%@.%@",[[MFSingleton sharedInstance] rmq_host], queueName,[[MFSingleton sharedInstance] appType],[appDelegate.appPrefs objectForKey:@"COMP_NO"],num];
        } else {
            urlStr = [NSString stringWithFormat:@"http://%@:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.BOARD.%@.%@.%@",[[MFSingleton sharedInstance] rmq_host], queueName,[[MFSingleton sharedInstance] appType],type,[appDelegate.appPrefs objectForKey:@"COMP_NO"],num];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0f];
        [request setHTTPMethod:@"DELETE"];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            [request setValue:@"Basic cmFiYml0bXE6ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
        }
        
        __block NSData *data = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
            NSLog();
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
