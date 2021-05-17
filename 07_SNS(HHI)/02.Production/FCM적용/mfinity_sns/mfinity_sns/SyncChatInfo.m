//
//  SyncChatInfo.m
//  mfinity_sns
//
//  Created by hilee on 2020/08/18.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "SyncChatInfo.h"

@implementation SyncChatInfo{
    AppDelegate *appDelegate;
    
    int pRoomSize;
    NSString *stRoomSeq;
    
    int pChatSize;
    NSString *stChatSeq;
    
    NSString *myUserNo;
    
    NSURLSession *session;
    NSMutableArray *currRoomArr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
//        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:appName];
//        configuration.allowsCellularAccess = YES;
//        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        UIDevice* device = [UIDevice currentDevice];
        BOOL backgroundSupported = NO;
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
            backgroundSupported = device.multitaskingSupported;
        }
        // background 작업을 지원하면
        if(backgroundSupported){
            // System 에 background 작업이 필요함을 알림. 작업의 id 반환
            taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                 NSLog(@"Backgrouund task ran out of time and was terminated");
                 [[UIApplication sharedApplication] endBackgroundTask:taskId];
                taskId = UIBackgroundTaskInvalid;
            }];
        }
    }
    return self;
}

-(void)syncChatRoom{
    stRoomSeq = @"1";
    pRoomSize = 30;
    
    //기존 채팅방번호가 있는지 비교 (이건 웹서비스 호출할때마다 조회하지말고 SyncChatRoom 호출할 때 한번만 호출하자)
    currRoomArr = [appDelegate.dbHelper selectArray:[appDelegate.dbHelper getChatRoomNo]];
//    NSLog(@"currRoomArr : %@", currRoomArr);
    myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSLog(@"install date : %@", [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]);
    NSLog(@"back time : %@", [appDelegate.appPrefs objectForKey:@"BACKGROUND_TIME"]);
    
    [self callWebService:@"getRoomList" WithParameter:[NSString stringWithFormat:@"usrNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, stRoomSeq, pRoomSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]]];
}

-(void)syncChat:(NSString *)roomNo{
    stChatSeq = @"1";
    pChatSize = 30;
    
//    __block NSData *data = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *paramStr = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]];
    paramStr = [MFUtil webServiceParamEncrypt:paramStr];

    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getChatList"]];
    self.wsName = [url.absoluteURL lastPathComponent];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:@"POST"];

    NSData *paramData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramData];

//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"getChat"];
//    configuration.allowsCellularAccess = YES;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session2 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task = [session2 dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
        if (!taskData) {
            NSLog(@"error : %@", error);
        } else {
            NSString *encReturnDataString = [[NSString alloc]initWithData:taskData encoding:NSUTF8StringEncoding];

            if([[MFSingleton sharedInstance] wsEncrypt]){
                encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
            }
//            NSLog(@"[%@] taskDATA : %@", self.wsName, encReturnDataString);

            if(encReturnDataString != nil){
                NSError *dicError;
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                self.returnDictionary = dataDic;
                
                [self returnDataWithObject:self.returnDictionary];
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

//    [self callWebService:@"getChatList" WithParameter:[NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]]];
}

- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSLog(@"[%@] paramString : %@", serviceName,paramString);
    self.paramString = paramString;
    paramString = [MFUtil webServiceParamEncrypt:paramString];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
//    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//    session.delegate = self;
//    [session start];
    
    self.wsName = [url.absoluteURL lastPathComponent];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:@"POST"];

    NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramData];

//    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:appName];
//    configuration.allowsCellularAccess = YES;
////    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//
////    NSLog(@"sesssiosn : %@", session);
////    if(session!=nil){
////        session = nil;
//////        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
////    }
//    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithStreamedRequest:request];
//    self.returnData = [[NSMutableData alloc] init];
//    [uploadTask resume];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session2 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session2 dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
        if (!taskData) {
            NSLog(@"error : %@", error);
        } else {
            NSString *encReturnDataString = [[NSString alloc]initWithData:taskData encoding:NSUTF8StringEncoding];
            
            if([[MFSingleton sharedInstance] wsEncrypt]){
                encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
            }
            //            NSLog(@"[%@] taskDATA : %@", self.wsName, encReturnDataString);
            
            if(encReturnDataString != nil){
                NSError *dicError;
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                self.returnDictionary = dataDic;
                
                [self returnDataWithObject:self.returnDictionary];
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errMsg = [[NSString alloc]initWithString:NSLocalizedString(@"MFURLSession_Error_Title", @"")];
    NSLog(@"ERROR : [%ld] %@", code, errMsg);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @try{
        if(!error){
            NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];

            if([[MFSingleton sharedInstance] wsEncrypt]){
                encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
            }
            NSLog(@"[%@] returnDataString : %@", self.wsName, encReturnDataString);

            if(encReturnDataString != nil){
                NSError *dicError;
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                self.returnDictionary = dataDic;
                
                [self returnDataWithObject:self.returnDictionary];
            }
            

        } else {
            NSLog(@"error : %@",error);
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - NSURLSession Delegate

- (void)returnDataWithObject:(NSDictionary *)dict{
    if([_wsName isEqualToString:@"getRoomList"]){
        NSLog(@"getRoomList : %@", dict);
        @try{
            NSArray *dataSet = [dict objectForKey:@"DATASET"];
            
            NSString *lastDate = [NSString urlDecodeString:[[dataSet firstObject] objectForKey:@"LAST_CHAT_DATE"]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.0";
            NSDate *date1 = [formatter dateFromString:lastDate];
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"yyyyMMddHHmmss"];
            NSString *date2 = [formatter2 stringFromDate:date1];
            NSString *backTime = [appDelegate.appPrefs objectForKey:@"BACKGROUND_TIME"];
            NSLog(@"backTime : %f / lastChatDate : %f", [backTime doubleValue], [date2 doubleValue]);
            
            if([backTime doubleValue] > [date2 doubleValue]){
                NSLog(@"백그라운드 내려가기 전 모두 호출했기 때문에 더 이상 웹서비스 호출안함");

            } else {
                NSUInteger count = dataSet.count;
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=count; i++){
                    seq = [NSString stringWithFormat:@"%d", [stRoomSeq intValue]+i];
                }
                stRoomSeq = seq;
                
                if(count==0){
                    
                } else if(count>0){
                    if(count<pRoomSize){
                        
                    } else {
                        //리턴결과가 pRoomSize와 같거나 크면 다음페이지 호출
//                        NSLog(@"stRoomSeq : %@", stRoomSeq);
                        [self callWebService:@"getRoomList" WithParameter:[NSString stringWithFormat:@"usrNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, stRoomSeq, pRoomSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]]];
                    }
                    
                    for(int i=0; i<dataSet.count; i++){
                        NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                        NSString *roomNm = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_NM"]];
                        NSString *roomTy = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_TYPE"];
                        //                    NSString *seq = [[dataSet objectAtIndex:i] objectForKey:@"SEQ"];
                        
                        NSString *lastChatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_DATE"]];
                        NSString *lastChatNo = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_NO"];
                        NSString *lastChatUserNo = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_USER_NO"];
                        NSString *lastContent = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"LAST_CONTENT"]];
                        NSString *lastContentTy = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CONTENT_TY"];
                        NSString *lastUnreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"LAST_UNREAD_COUNT"];
                        NSString *memberCnt = [[dataSet objectAtIndex:i] objectForKey:@"MEMBER_COUNT"];
                        
//                        NSLog(@"lastContent11 : %@", lastContent);
                        
                        NSString *isRead;
                        if([[NSString stringWithFormat:@"%@", lastUnreadCnt] isEqualToString:@"0"]) isRead = @"1";
                        else isRead = @"0";
                        
                        NSString *aditInfo = @"";
                        if([[NSString stringWithFormat:@"%@", lastChatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                            [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                            
                            NSError *error;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                            aditInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        }
                        
                        NSDate *date1 = [formatter dateFromString:lastChatDate];
                        NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                        [formatter3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString *date2 = [formatter3 stringFromDate:date1];
                        
                        NSMutableDictionary *chatDict = [NSMutableDictionary dictionary];
                        [chatDict setObject:date2 forKey:@"LAST_DATE"];
                        [chatDict setObject:roomNo forKey:@"ROOM_NO"];
                        [chatDict setObject:roomNm forKey:@"ROOM_NM"];
                        [chatDict setObject:lastUnreadCnt forKey:@"NOT_READ_COUNT"];
                        [chatDict setObject:roomTy forKey:@"ROOM_TYPE"];
                        [chatDict setObject:lastContentTy forKey:@"CONTENT_TY"];
                        
                        NSError *error;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[lastContent dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                        NSString *content;
                        
                        if ([lastContentTy isEqualToString:@"INVITE"]) {
//                            content = [NSString urlDecodeString:content];
                            NSDictionary *contentDic = [dict objectForKey:@"VALUE"];
//                            NSLog(@"contentDic : %@", contentDic);
                            
                            NSData* contentData = [NSJSONSerialization dataWithJSONObject:contentDic options:kNilOptions error:nil];
                            content = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                            
                        } else {
                            content = [dict objectForKey:@"VALUE"];
                            
                        }
                        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        [chatDict setObject:content forKey:@"CONTENT"];
                        
                        //CHAT_ROOM_INFO (ROOM_NO, ROOM_TPYE, LAST_CHAT_NO, EXIT_FLAG)
                        NSMutableArray *chatInfoArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getChatRoomInfo:roomNo]];
                        if(chatInfoArr.count>0 && [[[chatInfoArr objectAtIndex:0] objectForKey:@"EXIT_FLAG"] isEqualToString:@"Y"]){
                            NSLog(@"1:1이고 나가기 했을 경우 채팅목록에 없어야 함.");
                            //1:1이고 나가기 했을 경우 채팅목록에 없어야 함.
                            //로컬에 저장된 마지막 채팅번호가 웹서비스로 가져온 마지막 번호보다 작으면 표시해야함.
                            //그리고 디비에 엑시트플래그 N으로 변경
                            NSString *dbLastChatNo = [[chatInfoArr objectAtIndex:0] objectForKey:@"LAST_CHAT_NO"];
                            if([lastChatNo intValue] < [dbLastChatNo intValue]){
                                NSString *insertChatRoomInfo = [appDelegate.dbHelper insertChatRoomInfo:roomNo roomType:roomTy lastChatNo:[NSString stringWithFormat:@"%@", lastChatNo] exitFlag:@"N"];
                                [appDelegate.dbHelper crudStatement:insertChatRoomInfo];
                                
                                NSError *error;
                                NSArray *roomImgArr = [NSJSONSerialization JSONObjectWithData:[[NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_IMGS"]] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                NSMutableArray *roomImg = [[NSMutableArray alloc] init];
                                NSMutableDictionary *roomUserDict = [[NSMutableDictionary alloc] init];
                                
                                for(int j=0; j<roomImgArr.count; j++){
                                    NSString *userNo = [[roomImgArr objectAtIndex:j] objectForKey:@"CUSER_NO"];
                                    NSString *userImg = [NSString urlDecodeString:[[roomImgArr objectAtIndex:j] objectForKey:@"USER_IMG"]];
                                    
                                    if(![userImg isEqualToString:@""] && ![userImg isEqualToString:@"*"] && userImg!=nil){
                                        [roomUserDict setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d", j+1]];
                                        [roomImg addObject:userImg];
                                    }
                                }
                                [self insertChatRoomAndChat:currRoomArr roomUserDict:roomUserDict roomImg:roomImg roomNo:roomNo roomNm:roomNm roomTy:roomTy lastChatDate:lastChatDate lastChatNo:lastChatNo lastChatUserNo:lastChatUserNo content:content lastContentTy:lastContentTy lastUnreadCnt:lastUnreadCnt memberCnt:memberCnt isRead:isRead aditInfo:aditInfo];
                                
                                [self syncChat:roomNo];
                                //                            stChatSeq = @"1";
                                //                            pChatSize = 30;
                                //
                                //                            NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
                                //                            NSString *paramStr = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]];
                                //                            paramStr = [MFUtil webServiceParamEncrypt:paramStr];
                                //
                                //                            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getChatList"]];
                                //                            self.wsName = [url.absoluteURL lastPathComponent];
                                //
                                //                            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
                                //                            [request setHTTPMethod:@"POST"];
                                //
                                //                            NSData *paramData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
                                //                            [request setHTTPBody:paramData];
                                //
                                //                            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"getChat"];
                                //                            configuration.allowsCellularAccess = YES;
                                //                            NSURLSession *session2 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                                //
                                //                            NSURLSessionDataTask *task = [session2 dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
                                //                                if (!taskData) {
                                //                                    NSLog(@"error ㅠㅠ : %@", error);
                                //                                } else {
                                //                                    NSLog(@"데이터있냐!!! ");
                                //                                }
                                //                            }];
                                //                            [task resume];
                                
                            } else {
                                //마지막 채팅번호가 작거나 같으면 표시 안하면됨.
                            }
                            
                        } else{
                            NSError *error;
                            NSArray *roomImgArr = [NSJSONSerialization JSONObjectWithData:[[NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_IMGS"]] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                            NSMutableArray *roomImg = [[NSMutableArray alloc] init];
                            NSMutableDictionary *roomUserDict = [[NSMutableDictionary alloc] init];
                            
                            for(int j=0; j<roomImgArr.count; j++){
                                NSString *userNo = [[roomImgArr objectAtIndex:j] objectForKey:@"CUSER_NO"];
                                NSString *userImg = [NSString urlDecodeString:[[roomImgArr objectAtIndex:j] objectForKey:@"USER_IMG"]];
                                
                                if(![userImg isEqualToString:@""] && ![userImg isEqualToString:@"*"] && userImg!=nil){
                                    [roomUserDict setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d", j+1]];
                                    [roomImg addObject:userImg];
                                }
                            }
                            
                            [self insertChatRoomAndChat:currRoomArr roomUserDict:roomUserDict roomImg:roomImg roomNo:roomNo roomNm:roomNm roomTy:roomTy lastChatDate:lastChatDate lastChatNo:lastChatNo lastChatUserNo:lastChatUserNo content:content lastContentTy:lastContentTy lastUnreadCnt:lastUnreadCnt memberCnt:memberCnt isRead:isRead aditInfo:aditInfo];
                            
                            [self syncChat:roomNo];
                            
                            //                        stChatSeq = @"1";
                            //                        pChatSize = 30;
                            //
                            //                        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
                            //                        NSString *paramStr = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]];
                            //                        paramStr = [MFUtil webServiceParamEncrypt:paramStr];
                            //
                            //                        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getChatList"]];
                            //                        self.wsName = [url.absoluteURL lastPathComponent];
                            //
                            //                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
                            //                        [request setHTTPMethod:@"POST"];
                            //
                            //                        NSData *paramData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
                            //                        [request setHTTPBody:paramData];
                            //
                            //                        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"getChat"];
                            //                        configuration.allowsCellularAccess = YES;
                            //                        NSURLSession *session2 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                            //
                            //                        NSURLSessionDataTask *task = [session2 dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
                            //                            if (!taskData) {
                            //                                NSLog(@"error ㅜㅜ : %@", error);
                            //                            } else {
                            //                                NSLog(@"데이터있냐!!! ");
                            //                            }
                            //                        }];
                            //                        [task resume];
                        }
                    }
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
        NSLog(@"DONE BACKGROUND TASK TO GETROOMLIST.");
        // background 작업의 종료를 알린다.
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
        taskId = UIBackgroundTaskInvalid;
        
        
    } else if([_wsName isEqualToString:@"getChatList"]){
        NSLog(@"getChatList : %@", dict);
        
        @try{
            NSArray *dataSet = [dict objectForKey:@"DATASET"];
            
            //            NSUInteger count = dataSet.count;
            NSString *seq = [[NSString alloc]init];
            NSString *chatRoomNo;
            for(int i=0; i<dataSet.count; i++){
                seq = [NSString stringWithFormat:@"%d", [stChatSeq intValue]+i+1];
                chatRoomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                
                NSMutableArray *chatInfoArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getChatRoomInfo:chatRoomNo]];
//                NSLog(@"chatinfoArr: %@", chatInfoArr);
                
                if(chatInfoArr.count>0 && [[[chatInfoArr objectAtIndex:0] objectForKey:@"EXIT_FLAG"] isEqualToString:@"Y"]){
                    //1:1인데 나가기 한 방
                    NSString *dbLastChatNo = [[chatInfoArr objectAtIndex:0] objectForKey:@"LAST_CHAT_NO"];
                    
                    NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_DATE"]];
                    NSString *chatNo = [[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO"];
                    
                    if([chatNo intValue] > [dbLastChatNo intValue]){
                        //나가기했지만 새로운 채팅이 생겼을 경우 채팅 추가
                        
                        NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CONTENT"]];
                        NSString *contentTy = [[dataSet objectAtIndex:i] objectForKey:@"CONTENT_TY"];
                        NSString *cuserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                        NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                        NSString *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
                        
                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                        [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                        
                        if ([contentTy isEqualToString:@"INVITE"]) {
                            content = [NSString urlDecodeString:content];
                            
                        } else if([contentTy isEqualToString:@"SYS"]){
                            NSDictionary *aditInfo = [[dataSet objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                            NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
                            
                            if([sysMsgType isEqualToString:@"ADD_USER"]){
                                NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
                                NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                                if([addSysMsg rangeOfString:@","].location != NSNotFound){
                                    addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                                }
                                content = [[NSMutableString alloc]initWithString:addSysMsg];
                                
                            } else if([sysMsgType isEqualToString:@"DELETE_USER"]){
                                NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                                content = [[NSMutableString alloc]initWithString:deleteSysMsg];
                            }
                        }
                        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        if([contentTy isEqualToString:@"LONG_TEXT"]){
                            NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:@"" localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:content];
                            [appDelegate.dbHelper crudStatement:sqlString];
                            
                        } else {
                            NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:content localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:@""];
                            [appDelegate.dbHelper crudStatement:sqlString];
                        }
                        
                    } else {
                        //나갔던 방이므로 이전데이터는 불러올 필요 없음
                    }
                    
                } else {
                    NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_DATE"]];
                    NSString *chatNo = [[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO"];
                    NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CONTENT"]];
                    NSString *contentTy = [[dataSet objectAtIndex:i] objectForKey:@"CONTENT_TY"];
                    NSString *cuserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                    NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                    NSString *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
                    
                    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                    [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                    
                    if ([contentTy isEqualToString:@"INVITE"]) {
                        content = [NSString urlDecodeString:content];
                        
                    } else if([contentTy isEqualToString:@"SYS"]){
                        NSDictionary *aditInfo = [[dataSet objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                        NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
                        
                        if([sysMsgType isEqualToString:@"ADD_USER"]){
                            NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
                            NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                            if([addSysMsg rangeOfString:@","].location != NSNotFound){
                                addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                            }
                            content = [[NSMutableString alloc]initWithString:addSysMsg];
                            
                        } else if([sysMsgType isEqualToString:@"DELETE_USER"]){
                            NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                            content = [[NSMutableString alloc]initWithString:deleteSysMsg];
                        }
                    }
                    content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    
                    NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, chatNo];
                    NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                    if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]){
                        NSLog(@"채팅이 없을때만 인서트");
                        if([contentTy isEqualToString:@"LONG_TEXT"]){
                            NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:@"" localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:content];
                            [appDelegate.dbHelper crudStatement:sqlString];
                            
                        } else {
                            NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:content localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:@""];
                            [appDelegate.dbHelper crudStatement:sqlString];
                        }
                    }
                }
            }
            stChatSeq = seq;
            
//            if(count==0){
//
//            } else if(count>0){
//                if(count<pChatSize){
//
//                } else {
//                    //리턴결과가 pChatSize와 같거나 크면 다음페이지 호출
//                    NSLog(@"stChatSeq : %@", stChatSeq);
//                }
//            }
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
        NSLog(@"DONE BACKGROUND TASK TO GETCHATLIST.");
        // background 작업의 종료를 알린다.
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
        taskId = UIBackgroundTaskInvalid;
        
    }
}

-(void)insertChatRoomAndChat:(NSMutableArray *)currRoomArr roomUserDict:(NSMutableDictionary *)roomUserDict roomImg:(NSMutableArray *)roomImg roomNo:(NSString *)roomNo roomNm:(NSString *)roomNm roomTy:(NSString *)roomTy lastChatDate:(NSString *)lastChatDate lastChatNo:(NSString *)lastChatNo lastChatUserNo:(NSString *)lastChatUserNo content:(NSString *)content lastContentTy:(NSString *)lastContentTy lastUnreadCnt:(NSString *)lastUnreadCnt memberCnt:(NSString *)memberCnt isRead:(NSString *)isRead aditInfo:(NSString *)aditInfo{
    @try{
        if(currRoomArr.count > 0){
            if([currRoomArr containsObject:[NSString stringWithFormat:@"%@", roomNo]]){
                NSLog(@"기존에 있는 방이면 채팅내용만 업데이트");
                
                NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]){
                    NSLog(@"채팅이 없는 경우 인서트");
                    NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                    [appDelegate.dbHelper crudStatement:sqlString2];
                }
                
            } else {
                NSLog(@"방 생성 후 채팅 업데이트 : %@", roomNo);
                
                roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
                NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
                [appDelegate.dbHelper crudStatement:sqlString1];
                
                NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]){
                    NSLog(@"채팅이 없는 경우 인서트");
                    NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                    [appDelegate.dbHelper crudStatement:sqlString2];
                }
                
                //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:myUserNo];
                [appDelegate.dbHelper crudStatement:sqlString3];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                    [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
                });
            }
            
        } else {
            NSLog(@"채팅방 없는 경우");
            roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
            
            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
            [appDelegate.dbHelper crudStatement:sqlString1];
            
            NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
            NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
            if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]){
                NSLog(@"채팅이 없는 경우 인서트");
                NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
            
            //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
            NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:myUserNo];
            [appDelegate.dbHelper crudStatement:sqlString3];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
            });
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    @try{
        UIImage *roomImg = [[UIImage alloc] init];
        ChatRoomImgDivision *divide = [[ChatRoomImgDivision alloc]init];
        [divide roomImgSetting:array :memberCnt];
        roomImg = divide.returnImg;
        NSLog(@"Room Img : %@", roomImg);
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
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
        NSLog(@"Room Img Path : %@", imgPath);
        
        NSString *sqlString;
        NSString *roomImgName = [imgPath lastPathComponent];
        
        NSArray *roomUserKey = [dict allKeys];
        NSArray *roomUserVal = [dict allValues];
        
        NSString *resultKey = [[roomUserKey valueForKey:@"description"] componentsJoinedByString:@","];
        NSString *resultVal = [[roomUserVal valueForKey:@"description"] componentsJoinedByString:@","];
        
        //    if([memberCnt isEqualToString:@"1"]){ //200820 기존
        if([[NSString stringWithFormat:@"%@", memberCnt] isEqualToString:@"1"]){
            sqlString = [appDelegate.dbHelper insertRoomImages:roomNo roomImg:roomImgName refNo1:myUserNo];
            
        } else {
            sqlString = [appDelegate.dbHelper insertRoomImages:resultKey roomNo:roomNo roomImg:roomImgName resultVal:resultVal];
        }
        
        [appDelegate.dbHelper crudStatement:sqlString];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

/*
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];


    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSLog(@"에러1!!! : %@", error);
    } else {
        NSDictionary *dic = session.returnDictionary;
        NSLog(@"dsddddddddd : %@", dic);
        NSArray *dataSetArr = [dic objectForKey:@"DATASET"];
        for(int i=0; i<dataSetArr.count; i++){
            NSDictionary *dataSet = [dataSetArr objectAtIndex:i];
            NSString *userNo = [dataSet objectForKey:@"NODE_NO"];
            NSString *userId = [NSString urlDecodeString:[dataSet objectForKey:@"CUSER_ID"]];
            NSString *userName = [NSString urlDecodeString:[dataSet objectForKey:@"USER_NM"]];
            NSString *userImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_IMG"]];
            NSString *userMsg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_MSG"]];
            NSString *phoneNo = [NSString urlDecodeString:[dataSet objectForKey:@"PHONE_NO"]];
            NSString *deptNo = [dataSet objectForKey:@"DEPT_NO"];
            NSString *userBgImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_BG_IMG"]];
            
            NSString *deptName = [NSString urlDecodeString:[dataSet objectForKey:@"DEPT_NM"]];
            NSString *levelNo = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NO"]];
            NSString *levelName = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NM"]];
            NSString *dutyNo = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NO"]];
            NSString *dutyName = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NM"]];
            NSString *jobGrpName = [NSString urlDecodeString:[dataSet objectForKey:@"JOB_GRP_NM"]];
            NSString *exCompNo = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY"]];
            NSString *exCompName = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY_NM"]];
            NSString *userType = [dataSet objectForKey:@"SNS_USER_TYPE"];
            
            NSArray *paramArr = [session.decParamStr componentsSeparatedByString:@"&"];
            for (NSString *str in paramArr) {
                NSString * key = [[str componentsSeparatedByString:@"="] objectAtIndex:0];
                NSString * value = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
                
                if ([[key lowercaseString] isEqualToString:@"roomno"]) {
                    NSLog(@"roomNo value : %@", value);
                    
                    //목록에 없는 새 채팅방일 경우 CHAT_USERS에 추가
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:userImg userMsg:userMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                    [appDelegate.dbHelper crudStatement:sqlString];
                    
                    NSString *sqlString2 = [appDelegate.dbHelper insertChatUsers:value userNo:userNo];
                    [appDelegate.dbHelper crudStatement:sqlString2];
                    
                    //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                    NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:value userNo:myUserNo];
                    [appDelegate.dbHelper crudStatement:sqlString3];
                }
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
}
*/

@end
