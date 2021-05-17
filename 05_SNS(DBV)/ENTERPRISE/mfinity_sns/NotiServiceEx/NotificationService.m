//
//  NotificationService.m
//  NotiServiceEx
//
//  Created by hilee on 18/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotificationService.h"
#import "FBEncryptorAES.h"

#define NOTI_GRP_NAME @"group.hhi.sns.push"

@interface NotificationService () {
    NSString *thumbImagePath;
    NSString *originImagePath;
    NSMutableArray *dataArray;
    
    NSUserDefaults *notiDefaults;
    
}

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
//    self.contentHandler = contentHandler;
//    self.bestAttemptContent = [request.content mutableCopy];
//
//    NSDictionary *userInfo = request.content.userInfo;
//    NSLog(@"%s userInfo : %@", __func__, userInfo);
    
//    [self contentComplete];
    
//    [self pushDataHandler:userInfo completion:^(NSMutableDictionary *dict) {
//        if(dict!=nil){
//            NSString *title = [dict objectForKey:@"TITLE"];
//            NSString *body = [dict objectForKey:@"BODY"];
//            NSString *pushImg = [dict objectForKey:@"IMG_URL"];
//            NSString *mediaType = [dict objectForKey:@"MEDIA_TYPE"];
//
//            self.bestAttemptContent.title = title;
//            self.bestAttemptContent.body = body;
//
//            // load the attachment
//            [self loadAttachmentForUrlString:pushImg withType:mediaType completionHandler:^(UNNotificationAttachment *attachment) {
//                if (attachment) {
//                   self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
//                }
//                NSLog(@"dict ### : %@", dict);
//                if(dict!=nil) [self contentComplete]; //이거없으면 배너 안뜸!!! 프로필 푸시나 푸시 알림껐을경우 이거 실행 안하면 됨
//            }];
//        } else {
//            NSLog(@"아무것도 안띄우는 푸시");
//
//        }
//    }];


    /*
    dataArray = [NSMutableArray array];
    
    notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
    NSLog(@"ex) shareDefaults COMPNO: %@", [notiDefaults objectForKey:@"COMPNO"]);
    NSLog(@"ex) shareDefaults DBENCRYPT: %@", [notiDefaults objectForKey:@"DBENCRYPT"]);
    NSLog(@"ex) shareDefaults SETLOCALDB: %@", [notiDefaults objectForKey:[self setPreferencesKey:@"SETLOCALDB"]]);
    NSLog(@"ex) shareDefaults AES256KEY: %@", [notiDefaults objectForKey:@"AES256KEY"]);
    NSLog(@"ex) shareDefaults DBNAME: %@", [notiDefaults objectForKey:[self setPreferencesKey:@"DBNAME"]]);
    NSLog(@"ex) shareDefaults MAINURL: %@", [notiDefaults objectForKey:@"MAINURL"]);
    NSLog(@"ex) shareDefaults USERID: %@", [notiDefaults objectForKey:@"USERID"]);
    NSLog(@"ex) shareDefaults CUSERNO: %@", [notiDefaults objectForKey:[self setPreferencesKey:@"CUSERNO"]]);
    NSLog(@"ex) shareDefaults USERNM: %@", [notiDefaults objectForKey:[self setPreferencesKey:@"USERNM"]]);
    
    [notiDefaults setObject:@"NOTI_EXTENSION" forKey:@"TYPE"];
    [notiDefaults synchronize];
    
    _myUserNo = [notiDefaults objectForKey:[self setPreferencesKey:@"CUSERNO"]];
    
    NSDictionary *userInfo = request.content.userInfo;
    NSLog(@"%s userInfo : %@", __func__, userInfo);
        
    if (userInfo == nil) {
        [self contentComplete];
        return;
    }

    if(self.dbHelper==nil) self.dbHelper = [[MFDBHelper alloc] init:@"2" userId:nil];
    
    [self pushDataHandler:userInfo completion:^(NSMutableDictionary *dict) {
        if(dict!=nil){
            NSString *title = [dict objectForKey:@"TITLE"];
            NSString *body = [dict objectForKey:@"BODY"];
            NSString *pushImg = [dict objectForKey:@"IMG_URL"];
            NSString *mediaType = [dict objectForKey:@"MEDIA_TYPE"];
            
            self.bestAttemptContent.title = title;
            self.bestAttemptContent.body = body;
        
            // load the attachment
            [self loadAttachmentForUrlString:pushImg withType:mediaType completionHandler:^(UNNotificationAttachment *attachment) {
                if (attachment) {
                   self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
                }
                NSLog(@"dict ### : %@", dict);
                if(dict!=nil) [self contentComplete]; //이거없으면 배너 안뜸!!! 프로필 푸시나 푸시 알림껐을경우 이거 실행 안하면 됨
            }];
        } else {
            NSLog(@"아무것도 안띄우는 푸시");
            
        }
    }];
     */
    
}

- (void)contentComplete {
    NSLog(@"%s", __func__);
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    
    return [@"." stringByAppendingString:ext];
}

- (void)loadAttachmentForUrlString:(NSString *)urlString withType:(NSString *)type completionHandler:(void(^)(UNNotificationAttachment *))completionHandler  {
    NSLog(@"%s", __func__);
    
    if(urlString!=nil&&![urlString isEqualToString:@""]){
        __block UNNotificationAttachment *attachment = nil;
            NSURL *attachmentURL = [NSURL URLWithString:urlString];
        //    NSString *fileExt = [self fileExtensionForMediaType:type];

            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[session downloadTaskWithURL:attachmentURL
                        completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                            if (error != nil) {
                                NSLog(@"%@", error.localizedDescription);
                            } else {
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:type]];
                                [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];

                                NSError *attachmentError = nil;
                                attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                                if (attachmentError) {
                                    NSLog(@"%@", attachmentError.localizedDescription);
                                }
                            }
                            completionHandler(attachment);
                        }] resume];
    } else {
        completionHandler(nil);
    }
}

//- (void)serviceExtensionTimeWillExpire {
//    NSLog(@"%s", __func__);
//    self.contentHandler(self.bestAttemptContent);
//}

-(void)pushDataHandler:(NSDictionary *)userInfo completion:(void(^)(NSMutableDictionary *result))completion{
    notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
    
    NSString *message = [userInfo objectForKey:@"MESSAGE"];
    NSLog(@"MESSAGE : %@", message);
    
    //{"MESSAGE":"-","RESULT":"SUCCESS","QUEUE_NAME":"USER.SNS.ENT.P.10.BP15214.F43097F2-1063-4115-A4DD-B3E8DE11D4C3","READ_USER_NO":"120819","ROOM_NO":"1","TYPE":"UPDATE_CHAT_UNREAD_COUNT","DATASET":[{"CHAT_NO_LIST":"8761%2C8762","UNREAD_COUNT":0}]}
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *pushType = [dict objectForKey:@"TYPE"];
    if([pushType isEqualToString:@"ADD_CHAT"]){
        [self pushAddChat:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"UPDATE_CHAT_UNREAD_COUNT"]){
        [self pushUpdateChatUnreadCount:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"CREATE_CHAT_ROOM"]){
        [self pushCreateChatRoom:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"ADD_CHAT_USER"]){
        [self pushAddChatUser:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"DELETE_CHAT_USER"]){
        [self pushDeleteChatUser:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"CHANGE_USER_PROFILE"]){
        [self pushChangeUserProfile:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"CHANGE_CHAT_ROOM_NAME"]){
        [self pushChangeChatRoomName:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"NEW_POST"]){
        [self pushNewPost:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"NEW_POST_COMMENT"]){
        [self pushNewPostComm:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
    
    } else if([pushType isEqualToString:@"NEW_TASK"]){
        
    } else if([pushType isEqualToString:@"EDIT_TASK"]){

    } else if([pushType isEqualToString:@"FORCE_DELETE_SNS"]){
        //게시판 강제탈퇴
        [self pushForceDeleteSNS:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"DELETE_SNS"]){
        //게시판 삭제
        [self pushDeleteSNS:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"APPROVE_SNS"]){
        //게시판 가입 승인
        [self pushApproveSNS:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
    
    } else if([pushType isEqualToString:@"CHANGE_SNS_LEADER"]){
        //게시판 리더 변경
        [self pushChangeSNSLeader:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"APPROVE_REQUEST_SNS"]){
        //게시판 가입 요청
        [self pushApproveReqSNS:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"REJECT_SNS"]){
        //게시판 가입 거절
        [self pushRejectSNS:dict completion:^(NSMutableDictionary *result) {
            completion(result);
        }];
        
    } else if([pushType isEqualToString:@"SYSTEM_MSG"]){
        
    }
}

#pragma mark - Chat Push
-(void)pushAddChat:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *content =[NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
        NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"];
        NSString *decodeFileNm = [NSString urlDecodeString:fileName];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
//        NSString *myUserNo = [notiDefaults objectForKey:[self setPreferencesKey:@"CUSERNO"]];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
        
        [returnDic setObject:userName forKey:@"TITLE"];
        [returnDic setObject:content forKey:@"BODY"];
        [returnDic setObject:@"" forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
        /*
        NSString *sqlString = [self.dbHelper getRoomNoti:roomNo];
        NSString *roomNoti = [self.dbHelper selectString:sqlString];
        if(roomNoti==nil) roomNoti = @"1";
        
        self.recvRoomNo = roomNo;
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        NSString *folder = @"";
        if([contentType isEqualToString:@"IMG"]) folder = @"Image";
        else if([contentType isEqualToString:@"VIDEO"]) folder = @"Video";
        else if([contentType isEqualToString:@"FILE"]) folder = @"File";
        
        NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/", roomNo, folder, currentTime];
        NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/thumb/", roomNo, folder, currentTime];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
        if (issue) {
            
        }else{
            [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NotiExtensionUtil *exUtil = [[NotiExtensionUtil alloc]init];
        if([contentType isEqualToString:@"IMG"]){
            UIImage *originImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            NSData *originImageData = UIImageJPEGRepresentation(originImage, 0.1);
            
            originImagePath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",decodeFileNm]];
            [originImageData writeToFile:originImagePath atomically:YES];
            
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeFileThumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            
            //큰이미지 사이즈조절
            if(thumbImage.size.height > thumbImage.size.width*2){
                UIImage *image2 = [exUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : thumbImage];
                thumbImage = [exUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
                thumbImage = [exUtil getScaledLowImage:thumbImage scaledToMaxWidth:180.0f];
            }
            
            NSData *thumbImageData = UIImagePNGRepresentation(thumbImage);
            thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
            
        } else if([contentType isEqualToString:@"VIDEO"]){
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeFileThumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            
            //큰이미지 사이즈조절
            if(thumbImage.size.height > thumbImage.size.width*2){
                UIImage *image2 = [exUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : thumbImage];
                thumbImage = [exUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
                thumbImage = [exUtil getScaledLowImage:thumbImage scaledToMaxWidth:180.0f];
            }
            
            NSData *thumbImageData = UIImagePNGRepresentation(thumbImage);
            thumbImagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbFileNm]];
            [thumbImageData writeToFile:thumbImagePath atomically:YES];
        }
        
        [self readFromDatabase];
        
        if(![contentType isEqualToString:@"SYS"]){
            NSString *sqlString = [self.dbHelper getRoomNoti:roomNo];
            NSString *roomNoti = [self.dbHelper selectString:sqlString];
            if(roomNoti==nil) roomNoti = @"1";
            
            if([roomNoti isEqualToString:@"1"]){
                NSString *contentMsg=@"";
                if([contentType isEqualToString:@"IMG"]){
                    contentMsg = NSLocalizedString(@"chat_receive_image", @"chat_receive_image");
                    
                } else if([contentType isEqualToString:@"VIDEO"]){
                    contentMsg = NSLocalizedString(@"chat_receive_video", @"chat_receive_video");

                } else if([contentType isEqualToString:@"TEXT"]){
                    if([[notiDefaults objectForKey:[self setPreferencesKey:@"NOTINEWCHAT"]] isEqualToString:@"0"]){
                        contentMsg = NSLocalizedString(@"new_chat_no_prev", @"new_chat_no_prev");
                    } else {
                        contentMsg = content;
                    }
                    
                } else if([contentType isEqualToString:@"FILE"]){
                    contentMsg = NSLocalizedString(@"chat_receive_file", @"chat_receive_file");

                } else if([contentType isEqualToString:@"INVITE"]){
                    contentMsg = NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite");
                }
                
                [returnDic setObject:userName forKey:@"TITLE"];
                [returnDic setObject:content forKey:@"BODY"];
                [returnDic setObject:@"" forKey:@"IMG_URL"];
                [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
            }
        }
        
        NSLog(@"ARR !!! : %@", self.array);
        if(self.array.count == 0){
            [dataArray insertObject:dict atIndex:0];
            
            NSString *urlString = [notiDefaults objectForKey:@"MAINURL"];
            NSString *userID = [notiDefaults objectForKey:@"USERID"];
            NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&roomNo=%@", userID, userNo, roomNo];
            paramString = [self webServiceParamEncrypt:paramString];
            
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getRoomInfo"]];
            
            [self requestSynchronousDataWithURLString:url :paramString];
            
        } else {
            [self addChatExecute:dict];
        }
        */
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushUpdateChatUnreadCount:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *roomNo = [dict objectForKey:@"ROOM_NO"];
        
        for(int i=0; i<dataSet.count; i++){
            NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO_LIST"]];
            NSNumber *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];

            NSString *sqlString = [self.dbHelper updateChatUnReadCount:unreadCnt roomNo:roomNo chatNoList:chatNoList];
            [self.dbHelper crudStatement:sqlString];
        }
        
        completion(nil);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushCreateChatRoom:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        
        self.recvRoomNo = [dataSet objectForKey:@"ROOM_NO"];
        self.recvRoomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomNm = [NSString urlDecodeString:self.recvRoomNm];
        NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = decodeRoomNm;
        else resultRoomNm = [self createChatRoomName:decodeRoomNm];
        
        NSArray *users = [dataSet objectForKey:@"USERS"];
        [self readFromDatabase];
        
        //채팅방목록에 채팅방번호가 없으면 새채팅방 생성
        if(self.array.count == 0){
            
            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
            NSMutableArray *roomImgArr = [NSMutableArray array];
            NSMutableArray *myRoomImgArr = [NSMutableArray array];
            int roomImgCount = 1;
            
            NSString *sqlString1 = [self.dbHelper insertChatRooms:self.recvRoomNo roomName:resultRoomNm roomType:roomType];
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
                
                NSString *sqlString2 = [self.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                NSString *sqlString3 = [self.dbHelper insertChatUsers:self.recvRoomNo userNo:userNo];
                
                [self.dbHelper crudStatement:sqlString2];
                [self.dbHelper crudStatement:sqlString3];
            }
            
            [self.dbHelper crudStatement:sqlString1];
            
            if(roomUsers.count>0){
                [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
            } else {
                [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
            }
        }
        
        //채팅방에 사이드바 새로고침을 위한것
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddAndDelUser" object:nil userInfo:dict];
        
        self.recvRoomNo = nil;
        self.recvRoomNm = nil;
        
        
        completion(nil);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushAddChatUser:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSDictionary *dataSet = [dict objectForKey:@"DATASET"];
        NSArray *users = [dataSet objectForKey:@"USERS"];
        NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
        NSString *roomNm = [dataSet objectForKey:@"ROOM_NM"];
        NSString *decodeRoomName = [NSString urlDecodeString:roomNm];
        
        //apns로 보낼때 decodeUserNm이 null
        NSString *userNm = [notiDefaults objectForKey:[self setPreferencesKey:@"USERNM"]];
        NSString *decodeUserNm = [NSString urlDecodeString:userNm];
        
        if([decodeRoomName rangeOfString:decodeUserNm].location != NSNotFound){
            decodeRoomName = [decodeRoomName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", decodeUserNm] withString:@""];
            //NSLog(@"ADD_CHAT_USER decodeRoomName2 : %@", decodeRoomName);
        }
        
        NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
        NSMutableArray *roomImgArr = [NSMutableArray array];
        NSMutableArray *myRoomImgArr = [NSMutableArray array];
        int roomImgCount = 1;
        
        NSString *sqlString1 = [self.dbHelper updateRoomName:decodeRoomName roomNo:roomNo];
        
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
            
            NSString *sqlString2 = [self.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
            NSString *sqlString3 = [self.dbHelper insertChatUsers:roomNo userNo:userNo];
            
            [self.dbHelper crudStatement:sqlString2];
            [self.dbHelper crudStatement:sqlString3];
        }
        
        [self.dbHelper crudStatement:sqlString1];
        
        if(roomUsers.count>0){
            [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
        } else {
            [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeRoomName" object:nil userInfo:dict];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        //채팅/채팅목록 willAppear화면에서 해당 푸시를 받으면(룸넘버 동일 추가) 노티 실행하는 어떤게 있어야하나..?
        
        completion(nil);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

-(void)pushDeleteChatUser:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
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
        else resultRoomNm = [self createChatRoomName:decodeRoomNm];
        
        NSString *userNo = [users objectForKey:@"USER_NO"];
        
        NSString *sqlString1 = [self.dbHelper updateRoomName:resultRoomNm roomNo:[dataSet objectForKey:@"ROOM_NO"]];
        [self.dbHelper crudStatement:sqlString1];
         
        NSString *sqlString2 = [self.dbHelper deleteChatUsers:[dataSet objectForKey:@"ROOM_NO"] userNo:userNo];
        [self.dbHelper crudStatement:sqlString2];
         
        if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", self.myUserNo]]){
            NSString *sqlString3 = [self.dbHelper deleteMissedChat:roomNo];
            [self.dbHelper crudStatement:sqlString3];
            NSString *sqlString4 = [self.dbHelper deleteChats:roomNo];
            [self.dbHelper crudStatement:sqlString4];
            NSString *sqlString5 = [self.dbHelper deleteChatUsers:roomNo];
            [self.dbHelper crudStatement:sqlString5];
            NSString *sqlString6 = [self.dbHelper deleteChatRooms:roomNo];
            [self.dbHelper crudStatement:sqlString6];

//             채팅방에서 나가기했을때 보고있는 채팅방을 닫기위해
//             NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
//             if([currentClass isEqualToString:@"LGSideMenuController"]){
//                 [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatExit" object:nil];
//             }
             
            //내가 나갔을때만 호출
//            [self callDeletePush:roomNo type:@"CHAT"];
            [self callDeletePush:roomNo userInfo:queueName type:@"CHAT"];
            
         } else {
             //사용자 나간 후 채팅방 유저 조회
             NSMutableArray *selectArr = [self.dbHelper selectMutableArray:[self.dbHelper getUserNoAndUserImg:[dataSet objectForKey:@"ROOM_NO"]]];
             NSLog(@"앱종료) 사용자 나간 후 채팅방 유저 조회 : %@", selectArr);
             
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
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeRoomName" object:nil userInfo:dict];
         }
//         [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        
        completion(nil);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushChangeUserProfile:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
                
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *userId = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
        NSString *phoneNo = [[dataSet objectAtIndex:0] objectForKey:@"PHONE_NO"];
        NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
        NSString *deptNo = [[dataSet objectAtIndex:0] objectForKey:@"DEPT_NO"];
        NSString *profileBgImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
        
        NSString *deptName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DEPT_NM"]];
        NSString *levelName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NM"]];
        NSString *dutyName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DUTY_NM"]];
        NSString *jobGrpName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"JOB_GRP_NM"]];
        NSString *exCompNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY"]];
        NSString *exCompName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"]];
        NSString *levelNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NO"]];
        NSString *dutyNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DUTY_NO"]];
        NSString *userType = [[dataSet objectAtIndex:0] objectForKey:@"SNS_USER_TYPE"];
        
        NSString *sqlString = [self.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:profileImg userMsg:profileMsg phoneNo:phoneNo deptNo:deptNo userBgImg:profileBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
        
        [self.dbHelper crudStatement:sqlString];
        
        //chat_users에 사용자 있는 방번호 조회
        NSMutableArray *selectRoomArr = [self.dbHelper selectMutableArray:[self.dbHelper getRoomNo:userNo]];
        NSUInteger roomArrCnt = selectRoomArr.count;
        for(int i=0; i<(int)roomArrCnt; i++){
            //room_images에서 사용자있는 방 삭제
            NSString *roomNo = [[selectRoomArr objectAtIndex:i] objectForKey:@"ROOM_NO"];
            NSString *deleteRoomImg = [self.dbHelper deleteRoomImage:roomNo];
            [self.dbHelper crudStatement:deleteRoomImg];
            
            //다시 데이터 삽입
            NSMutableArray *selectUserArr = [self.dbHelper selectMutableArray:[self.dbHelper getUserNoAndUserImg:roomNo]];
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
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeProfilePush" object:nil userInfo:dict];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        
        completion(nil);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushChangeChatRoomName:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *roomNo = [dict objectForKey:@"ROOM_NO"];
        NSString *changeRoomNm = [NSString urlDecodeString:[dict objectForKey:@"ROOM_NM"]];
        
        NSString *sqlString = [self.dbHelper updateCustomRoomName:changeRoomNm roomNo:roomNo];
        [self.dbHelper crudStatement:sqlString];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeCustomRoomName" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
        
        completion(nil);
        
    } @catch(NSException *exception){
        NSLog(@"%s Exception : %@", __func__, exception);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeCustomRoomName" object:nil userInfo:@{@"RESULT":@"FAIL"}];
    }
}
#pragma mark - Chat Push Handler
- (void)readFromDatabase {
    NSString *sqlString = [self.dbHelper getRoomList];
    
    self.tempArr = [NSMutableArray array];
    self.tempArr = [self.dbHelper selectMutableArray:sqlString];
    
    NSLog(@"temp : %@", self.tempArr);
    
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
    
    NSLog(@"%s, noti_ChangeChatBadge 호출", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:badgeDict];
}


-(void)addChatListExecute {
    @try{
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
        [dict2 setDictionary:[dataArray objectAtIndex:0]];
        
        NSArray *dataSet = [[dataArray objectAtIndex:0] objectForKey:@"DATASET"];
        
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
        
        NSString *roomType = [self.dbHelper selectString:[self.dbHelper getRoomType:roomNo]];
        NSLog(@"addChatListExecute roomtype ~~ : %@", roomType);
        
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
        [tmpDic setValue:@"SENDING" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                [self.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];

                [self.dbHelper crudStatement:sqlString];
            }
            
            if(![contentType isEqualToString:@"SYS"]){
                NSString *sqlString2 = [self.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [self.dbHelper crudStatement:sqlString2];
            }
        } else {
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                
                [self.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
            
                [self.dbHelper crudStatement:sqlString];
            }
        }
        
        [self chatRoomListCount:roomNo :_myUserNo];
        
//        if([roomType isEqualToString:@"0"]){
//            NSLog(@"%s, noti_NoticeChat 호출? : %@", __func__);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NoticeChat" object:nil userInfo:[dataArray objectAtIndex:0]];
//        } else {
//            NSLog(@"%s, noti_Chat 호출? : %@", __func__);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Chat" object:nil userInfo:[dataArray objectAtIndex:0]];
//        }
//        NSLog(@"%s, noti_ApnsChatList 호출? : %@", __func__);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ApnsChatList" object:nil];
        
        [dataArray removeObjectAtIndex:0];
        
        
    } @catch(NSException *exception){
        NSLog(@"%s exception : %@", __func__, exception);
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
        NSString *date = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"];
        NSString *decodeDate = [NSString urlDecodeString:date];
        NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];
        NSString *decodeFileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *thumbFileNm = [decodeFileThumb lastPathComponent];
        
        if([contentType isEqualToString:@"INVITE"]){
            content = [NSString urlDecodeString:content];
        }
        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
       
        NSString *roomType = [self.dbHelper selectString:[self.dbHelper getRoomType:roomNo]];
        NSLog(@"roomtype !! : %@", roomType);
        
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
            
        } else {
            contentStr = [[NSMutableString alloc]initWithString:content];
            
            //상대방이보낸메시지
            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                NSString *sql = [self.dbHelper getRoomNoti:roomNo];
                self.roomNoti = [self.dbHelper selectString:sql];
            }
        }
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setValue:tmpNo forKey:@"TMP_NO"];
        [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
        [tmpDic setValue:@"SENDING" forKey:@"TYPE"];
        [tmpDic setValue:originImagePath forKey:@"LOCAL_CONTENT"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //남이 보낸 메시지 (시스템메시지도 포함)
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:contentStr];
                
                [self.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"0" unReadCnt:unRead contentPrev:@""];
             
                [self.dbHelper crudStatement:sqlString];
            }
            
            self.tempArr = [NSMutableArray array];
            self.tempArr = [self.dbHelper selectMutableArray:[self.dbHelper getChatInfo]];
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
                NSString *sqlString2 = [self.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                [self.dbHelper crudStatement:sqlString2];
            }
        } else {
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:contentStr];
                [self.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [self.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:contentStr localContent:@"" chatDate:decodeDate fileName:thumbFileNm aditInfo:jsonString isRead:@"1" unReadCnt:unRead contentPrev:@""];
                [self.dbHelper crudStatement:sqlString];
            }
        }
        
        [self chatRoomListCount:roomNo :_myUserNo];

    } @catch(NSException *exception){
        NSLog(@"%s exception : %@", __func__, exception);
    }
}

-(void)syncReturnDataWithObject:(NSString *)error{
    NSLog(@"%s",__func__);
    
    if (error != nil) {
#ifdef DEBUG
        NSString *errorMsg = [NSString stringWithFormat:@"%@",error];
        NSLog(@"error : %@",errorMsg);
#endif
        
    }else{
        NSDictionary *dic = self.returnDictionary;
        NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
        
        NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
        NSString *roomNm = [NSString urlDecodeString:[dataSet objectForKey:@"ROOM_NM"]];
        NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = roomNm;
        else resultRoomNm = [self createChatRoomName:roomNm];
        NSLog(@"resultRoomNm ## : %@", resultRoomNm);
        
        NSArray *users = [dataSet objectForKey:@"USERS"];
        NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
        NSMutableArray *roomImgArr = [NSMutableArray array];
        NSMutableArray *myRoomImgArr = [NSMutableArray array];
        int roomImgCount = 1;
        
        NSString *sqlString1 = [self.dbHelper insertChatRooms:roomNo roomName:resultRoomNm roomType:roomType];
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
            
            NSString *sqlString2 = [self.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
            NSString *sqlString3 = [self.dbHelper insertChatUsers:roomNo userNo:userNo];
            
            [self.dbHelper crudStatement:sqlString2];
            [self.dbHelper crudStatement:sqlString3];
        }
        [self.dbHelper crudStatement:sqlString1];
        
        if(roomUsers.count>0){
            [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
        } else {
            [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)users.count] :self.recvRoomNo];
        }
        
        [self addChatListExecute];
        
    }
}

- (void)requestSynchronousDataWithURLString:(NSURL *)url :(NSString *)paramString{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0f];
    [request setHTTPMethod:@"POST"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",url];
    if([urlStr isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
    }
    
    if (paramString != nil) {
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:paramData];
    }
    [self startTask:request];
}

- (void)startTask:(NSMutableURLRequest *)request{
    @try {
        __block NSData *data = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error){
            data = taskData;
            if (!data) {
                NSLog(@"%@", error);
            }
            
            NSMutableData *returnData = [[NSMutableData alloc] init];
            [returnData appendData:data];
            NSString *encReturnDataString = [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
        
            if([notiDefaults objectForKey:@"WSENCRYPT"]){
                NSUserDefaults *notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
                encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[notiDefaults objectForKey:@"AES256KEY"]];
            }
            
            NSError *dicError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
            self.returnDictionary = dataDic;
            [self syncReturnDataWithObject:nil];
            
            dispatch_semaphore_signal(semaphore);
        }];
        
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotification" object:nil];
    }
}

#pragma mark - SNS Push
-(void)pushNewPost:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NO"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
        NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];

        NSString *myUserNo = [notiDefaults objectForKey:[self setPreferencesKey:@"CUSERNO"]];

        NSString *postNoti =  [self.dbHelper selectString:[self.dbHelper getPostNoti:snsNo]];
        if([postNoti isEqualToString:@"1"]||postNoti==nil){
            if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                NSString *noticeMsg = @"";
                
                if([[notiDefaults objectForKey:[self setPreferencesKey:@"NOTINEWPOST"]] isEqualToString:@"0"]){
                    noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1", @"new_post1"), writerNm];
                } else {
                    noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1_3", @"new_post1_3"), writerNm, summary]; //내용표시해야함
                }
                
                [returnDic setObject:snsName forKey:@"TITLE"];
                [returnDic setObject:noticeMsg forKey:@"BODY"];
                [returnDic setObject:@"" forKey:@"IMG_URL"];
                [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
            }
        }
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushNewPostComm:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        
        NSString *snsName =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
        NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
        NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
        NSNumber *cWriterNo = [[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NO"];
        NSString *cWriterNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NM"]];
        NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];
        
        NSString *isTag = [NSString stringWithFormat:@"%@",[[dataSet objectAtIndex:0] objectForKey:@"IS_TAG"]];
        NSString *jsonTag = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TARGET_LIST"]];
        NSData *jsonData = [jsonTag dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        NSString *myName = [jsonDict objectForKey:[notiDefaults objectForKey:@"USERID"]];
        NSString *myUserNo = [notiDefaults objectForKey:[self setPreferencesKey:@"CUSERNO"]];

        NSString *noticeMsg = @"";
        NSString *commNoti = [self.dbHelper selectString:[self.dbHelper getCommentNoti:snsNo]];
        
        if([commNoti isEqualToString:@"1"]||commNoti==nil){
            AVAudioSession * session = [AVAudioSession sharedInstance];
            [session setCategory: AVAudioSessionCategoryPlayback error: nil];

            if(![[NSString stringWithFormat:@"%@", cWriterNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                if([isTag isEqualToString:@"0"]){
                    if([[notiDefaults objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1", @"new_post_comment1"), cWriterNm, writerNm];
                    } else {
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1_3", @"new_post_comment1_3"), cWriterNm, summary]; //내용표시해야함
                    }

                } else {
                    NSString *noticeMsg = @"";
                    if([[notiDefaults objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2", @"new_post_comment2"), cWriterNm, myName];
                    } else {
                        noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2_3", @"new_post_comment2_3"), cWriterNm, myName, summary]; //내용표시해야함
                    }
                }
            }
            
            [returnDic setObject:snsName forKey:@"TITLE"];
            [returnDic setObject:noticeMsg forKey:@"BODY"];
            [returnDic setObject:@"" forKey:@"IMG_URL"];
            [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        }
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushForceDeleteSNS:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        //강제탈퇴 되었을 때 게시판목록, 게시판, 게시판정보, 게시판멤버정보 새로고침
        //로컬DB에서 SNS삭제
        
        NSString *queueName = [dict objectForKey:@"QUEUE_NAME"];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsNo = [dict objectForKey:@"SNS_NO"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        NSString *noticeMsg = NSLocalizedString(@"force_delete_sns_1", @"force_delete_sns_1");
        [returnDic setObject:snsName forKey:@"TITLE"];
        [returnDic setObject:noticeMsg forKey:@"BODY"];
        [returnDic setObject:@"" forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:queueName type:@"POST"];
        [self callDeletePush:snsNo userInfo:queueName type:@"COMMENT"];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushDeleteSNS:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *queueName = [dict objectForKey:@"QUEUE_NAME"];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsNo = [dict objectForKey:@"SNS_NO"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        
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
        
        [returnDic setObject:snsName forKey:@"TITLE"];
        [returnDic setObject:[NSString stringWithFormat:NSLocalizedString(@"delete_sns_2", @"delete_sns_2"), snsName] forKey:@"BODY"];
        [returnDic setObject:tmpUrl forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
//        [self callDeletePush:snsNo type:@"POST"];
//        [self callDeletePush:snsNo type:@"COMMENT"];
        [self callDeletePush:snsNo userInfo:queueName type:@"POST"];
        [self callDeletePush:snsNo userInfo:queueName type:@"COMMENT"];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushApproveSNS:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        NSString *snsKind =  [dict objectForKey:@"SNS_KIND"];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
     
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        NSString *noticeMsg = NSLocalizedString(@"join_sns_toast1_2", @"join_sns_toast1_2");
        
        [returnDic setObject:snsName forKey:@"TITLE"];
        if([snsKind isEqualToString:@"1"]) [returnDic setObject:[NSString stringWithFormat:@"%@\n%@", noticeMsg, NSLocalizedString(@"new_post_content", @"new_post_content")] forKey:@"BODY"];
        else if([snsKind isEqualToString:@"2"]) [returnDic setObject:[NSString stringWithFormat:@"%@\n%@", noticeMsg, NSLocalizedString(@"new_task_content", @"new_task_content")] forKey:@"BODY"];
        [returnDic setObject:tmpUrl forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushChangeSNSLeader:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        NSString *noticeMsg = NSLocalizedString(@"change_sns_leader_1", @"change_sns_leader_1");
        [returnDic setObject:snsName forKey:@"TITLE"];
        [returnDic setObject:noticeMsg forKey:@"BODY"];
        [returnDic setObject:tmpUrl forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:dict];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushNewTask:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushEditTask:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushApproveReqSNS:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *reqUserName =  [NSString urlDecodeString:[dict objectForKey:@"REQUEST_USER_NM"]];
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast13", @"join_sns_toast13"), reqUserName];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];

        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];

        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];

        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        [returnDic setObject:snsName forKey:@"TITLE"];
        [returnDic setObject:noticeMsg forKey:@"BODY"];
        [returnDic setObject:tmpUrl forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
       
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)pushRejectSNS:(NSDictionary *)dict completion:(void(^)(NSMutableDictionary *result))completion{
    @try{
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        NSString *snsName =  [NSString urlDecodeString:[dict objectForKey:@"SNS_NM"]];
        NSString *rejectMsg =  [NSString urlDecodeString:[dict objectForKey:@"REJECT_MESSAGE"]];
        
        NSString *noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"join_sns_toast14_2", @"join_sns_toast14_2"), rejectMsg];
        NSString *imgPath =  [NSString urlDecodeString:[dict objectForKey:@"COVER_IMG"]];
        
        //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
        NSString *fileName = [imgPath lastPathComponent];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/Cover/%@",documentFolder,fileName];
        NSURL *tmpUrl = [[NSURL alloc] initFileURLWithPath:savePath];
        
        if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savePath];
            if(!fileExists){
                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                [imageData writeToFile:savePath atomically:YES];
            }
        }
        
        [returnDic setObject:snsName forKey:@"TITLE"];
        [returnDic setObject:noticeMsg forKey:@"BODY"];
        [returnDic setObject:tmpUrl forKey:@"IMG_URL"];
        [returnDic setObject:@"" forKey:@"MEDIA_TYPE"];
        
        completion(returnDic);
        
    } @catch(NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

#pragma mark - SNS Push Handler
//apns일때는 리턴항목의 QUEUE_NAME으로 mfpsId를 대신하고, 유저넘버 상관없이 그냥 호출하면됨.
- (void)callDeletePush:(NSString *)num userInfo:(NSString *)queueName type:(NSString *)type{
    //내가 사용하는 다른 기기에서 동기화 시키기위해 호출
    @try {
        NSString *urlStr = @"";
        
        if([type isEqualToString:@"CHAT"]){
            urlStr = [NSString stringWithFormat:@"http://mfps2.hhi.co.kr:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.CHAT.%@.%@",queueName,[notiDefaults objectForKey:@"DVCTY"],[notiDefaults objectForKey:@"COMPNO"],num];
        } else {
            urlStr = [NSString stringWithFormat:@"http://mfps2.hhi.co.kr:15672/api/bindings/snsHost/e/mfps.topic/q/%@/%@.BOARD.%@.%@.%@",queueName,[notiDefaults objectForKey:@"DVCTY"],type,[notiDefaults objectForKey:@"COMPNO"],num];
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
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
#ifdef DEBUG
    NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",connection.currentRequest.URL.absoluteString,error];
    NSLog(@"error : %@",errorMsg);
#endif
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *returnString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *result = [dic objectForKey:@"RESULT"];
    if ([result isEqualToString:@"SUCCESS"]) {
        
    }else{
#ifdef DEBUG
        NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",connection.currentRequest.URL.absoluteString,error];
        NSLog(@"error : %@",errorMsg);
#endif
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error {
#ifdef DEBUG
    NSLog(@"%s error : %@",__func__, error);
#endif
}

#pragma mark - Util
- (NSString *)setPreferencesKey:(NSString *)keyName{
    NSString *userId = [notiDefaults objectForKey:@"USERID"];
    NSString *resultKey = [NSString stringWithFormat:@"%@_%@",userId,keyName];
    return resultKey;
}

-(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSLog(@"%s", __func__);
    
    NSUserDefaults *notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
    NSLog(@"ex) shareDefaults COMPNO2: %@", [notiDefaults objectForKey:@"COMPNO"]);
    
    UIImage *roomImg = [[UIImage alloc] init];
    NotiExtensionUtil *divide = [[NotiExtensionUtil alloc]init];
    [divide roomImgSetting:array :memberCnt];
    roomImg = divide.returnImg;
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"]];
    
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/Chat/%@", roomNo];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        
    }else{
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(roomImg);
    NSString *fileName = @"";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    fileName = [NSString stringWithFormat:@"%@(%@).png",roomNo,currentTime];
    
    NSString *imgPath = [saveFolder stringByAppendingPathComponent:fileName];
    [imageData writeToFile:imgPath atomically:YES];
    
    NSString *sqlString;
    NSString *roomImgName = [imgPath lastPathComponent];
    
    NSArray *roomUserKey = [dict allKeys];
    NSArray *roomUserVal = [dict allValues];
    
    NSString *resultKey = [[roomUserKey valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *resultVal = [[roomUserVal valueForKey:@"description"] componentsJoinedByString:@","];
    
    if([memberCnt isEqualToString:@"1"]){
        sqlString = [self.dbHelper insertRoomImages:roomNo roomImg:roomImgName refNo1:_myUserNo];
        
    } else {
        sqlString = [self.dbHelper insertRoomImages:resultKey roomNo:roomNo roomImg:roomImgName resultVal:resultVal];
    }
    
    [self.dbHelper crudStatement:sqlString];
    
    return imgPath;
}

- (NSString *)webServiceParamEncrypt :(NSString*)paramStr{
    NSArray *paramArr= [paramStr componentsSeparatedByString: @"&"];
    NSString *resultStr = @"";
    
    for(int i=0;i<paramArr.count;i++){
        NSString *paramStr = [paramArr objectAtIndex:i];
        
        NSString *paramKey;
        NSString *paramVal;
        NSString *encodedKey;
        NSString *encodedVal;
        
        NSRange subRange;
        subRange = [paramStr rangeOfString : @"="];
        if (subRange.location == NSNotFound){
            //NSLog(@"String not found");
        } else {
            paramKey = [paramStr substringToIndex:subRange.location];
            paramVal = [paramStr substringFromIndex:subRange.location+1];
            
            if([notiDefaults objectForKey:@"WSENCRYPT"]){
                NSUserDefaults *notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
                paramVal = [FBEncryptorAES encryptBase64String:[paramStr substringFromIndex:subRange.location+1] keyString:[notiDefaults objectForKey:@"AES256KEY"] separateLines:NO];
                encodedVal = [paramVal urlEncodeUsingEncoding:NSUTF8StringEncoding];
                
                if(i==0){
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@", paramKey, encodedVal]];
                } else {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", paramKey, encodedVal]];
                }
            } else {
                encodedKey = [paramKey urlEncodeUsingEncoding:NSUTF8StringEncoding];
                encodedVal = [paramVal urlEncodeUsingEncoding:NSUTF8StringEncoding];

                if(i==0){
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@", paramKey, encodedVal]];
                } else {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", paramKey, encodedVal]];
                }
            }
        }
    }
    
    //NSLog(@"resultStr : %@", resultStr);
    return resultStr;
}

-(NSString *)createChatRoomName:(NSString *)roomName{
    NSUserDefaults *notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
    
    NSArray *roomNmArr = [NSArray array];
    if([roomName rangeOfString:@","].location != NSNotFound){
        roomNmArr = [roomName componentsSeparatedByString:@","];
    }
    
    NSString *resultRoomNm = @"";
    NSMutableArray *resultRoomArr = [NSMutableArray array];
    BOOL isMyName = NO;
    NSString *myName = [NSString urlDecodeString:[notiDefaults objectForKey:[self setPreferencesKey:@"USERNM"]]];
    
    if(roomNmArr.count>0){
        for(int i=0; i<roomNmArr.count; i++){
            NSString *arrUserNm = [roomNmArr objectAtIndex:i];
            if(!isMyName&&[arrUserNm isEqualToString:myName]){
                isMyName = YES;
                
            } else{
                [resultRoomArr addObject:arrUserNm];
            }
        }
        resultRoomNm = [[resultRoomArr valueForKey:@"description"] componentsJoinedByString:@","];
    }
    return resultRoomNm;
}

@end

@implementation NSString (URLEncoding)

- (NSString *)AES256EncryptWithKeyString:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES256DecryptWithKeyString:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES256DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

@end
