//
//  ChatConnectSocket.m
//  mfinity_sns
//
//  Created by hilee on 14/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//


#import "ChatConnectSocket.h"
#import "AppDelegate.h"

@interface ChatConnectSocket(){
    AppDelegate *appDelegate;
    NSString *myUserNo;
    
    BOOL socketFail;
    int alreadyFail;
}
@end

@implementation ChatConnectSocket

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        socketFail = NO;
        alreadyFail = 0;
    }
    return self;
}

- (void)connectSocket{
    @try{
        NSLog(@"Connect Socket...");

        int usrNo = [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]] intValue];
       
        socket.delegate = nil;
        socket = nil;
        
        NSString *socketUrl;
        int lastNum = usrNo % 2;
        if (lastNum == 0) socketUrl = [[MFSingleton sharedInstance] socketUrl1];
        else socketUrl = [[MFSingleton sharedInstance] socketUrl2];
       
        NSMutableURLRequest *pushServerRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:socketUrl]];
        NSString *userId = [appDelegate.appPrefs objectForKey:@"USERID"];
        NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
        NSString *userpass = [NSString stringWithFormat:@"%@_%@", userId, userNm];
        NSData *plainData = [userpass dataUsingEncoding:NSUTF8StringEncoding];
        userpass = [plainData base64EncodedStringWithOptions:kNilOptions];
        [pushServerRequest setValue:[NSString stringWithFormat:@"Basic %@", userpass] forHTTPHeaderField:@"Authorization"];
       
        SRWebSocket *newWebSocket  = [[SRWebSocket alloc] initWithURLRequest:pushServerRequest protocols:nil];
        newWebSocket.delegate = self;
        [newWebSocket open];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    NSLog();
    @try{
        socket = newWebSocket;
        socketFail = NO;
        
        alreadyFail=0;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"error : %@", error);

    @try{
        if(webSocket!=nil) [webSocket close];
        socketFail = YES;
        
        if(error.code == 50){
           NSLog(@"Network is down !");
        }

        alreadyFail++;
        if(alreadyFail==1){
           NSLog(@"소켓연결 실패! 반대 서버에 연결");
           //소켓연결 실패 시 반대 서버에 붙어야함
           int usrNo = [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]] intValue];
           NSString *socketUrl;
           int lastNum = usrNo % 2;
           if (lastNum == 0) socketUrl = [[MFSingleton sharedInstance] socketUrl2];
           else socketUrl = [[MFSingleton sharedInstance] socketUrl1];
           
           SRWebSocket *newWebSocket  = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketUrl]];
           newWebSocket.delegate = self;
           [newWebSocket open];
        }
      
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog();
    @try{
        if(socket!=nil) [webSocket close];
        socket = nil;
        socketFail = YES;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//   NSLog(@"Socket Receive : %@", message);
}

-(void)socketCheck:(NSString *)type roomNo:(NSString *)chatRoomNo message:(NSString *)msg dictionary:(NSDictionary *)dict{
    //채팅방 입장 시 웹소켓연결->채팅전송시 웹소켓 연결 되있는지 안되있는지 확인->소켓연결 되있으면 소켓전송, 안되어있으면 소켓연결 후 소켓전송
    
    @try{
        if(socket==nil) {
           [self connectSocket];
           
           if(socketFail) {
              //소켓연결 실패 시 바로 sendSocket 호출하여 http연결
              NSLog(@"소켓연결 실패 시 바로 sendSocket 호출하여 http연결");
               [self sendSocket:type roomNo:chatRoomNo message:msg dictionary:dict];
              
           } else {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 //소켓연결 성공 시 약간의 텀이 있으므로 0.3초 뒤에 sendSocket 호출
                 NSLog(@"소켓연결 성공 시 약간의 텀이 있으므로 0.3초 뒤에 sendSocket 호출");
                  [self sendSocket:type roomNo:chatRoomNo message:msg dictionary:dict];
              });
           }
        } else {
            [self sendSocket:type roomNo:chatRoomNo message:msg dictionary:dict];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)sendSocket:(NSString *)type roomNo:(NSString *)chatRoomNo message:(NSString *)msg dictionary:(NSDictionary *)dict{
    NSMutableDictionary *socketDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    @try{
        if([type isEqualToString:@"SAVE_CHAT"]){
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            
            if(dict==nil){
                msg = [MFUtil replaceEncodeToChar:msg];
                
                NSUInteger textByte = [msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                if(textByte>1000) [contentDic setObject:@"LONG_TEXT" forKey:@"TYPE"];
                else [contentDic setObject:@"TEXT" forKey:@"TYPE"];
                [contentDic setObject:msg forKey:@"VALUE"];
                
            } else {
                [contentDic setObject:@"INVITE" forKey:@"TYPE"];
                [contentDic setObject:dict forKey:@"VALUE"];
            }
            
            NSData *contentData = [NSJSONSerialization dataWithJSONObject:contentDic options:0 error:nil];
            NSString *contentJson = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
            
            NSData *editJsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:kNilOptions error:nil];
            NSString *editJsonStr = [[NSString alloc] initWithData:editJsonData encoding:NSUTF8StringEncoding];
            
            NSString *userNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@", myUserNo]];
            NSString *roomNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@", chatRoomNo]];
            NSString *content = [MFUtil paramEncryptAndEncode:contentJson];
            NSString *aditInfo = [MFUtil paramEncryptAndEncode:editJsonStr];
            
            [paramDict setObject:userNo forKey:@"usrNo"];
            [paramDict setObject:roomNo forKey:@"roomNo"];
            [paramDict setObject:content forKey:@"content"];
            [paramDict setObject:aditInfo forKey:@"aditInfo"];
            
            [socketDict setObject:@"saveChat" forKey:@"request"];
            
        } else if([type isEqualToString:@"CHAT_READ_STATUS"]){
            NSNumber *firstChat;
            NSNumber *lastChat;
            
            /*
             1,2 같은계정 다른기기, 3 다른계정 다른기기
             1,2 둘다 앱 실행되있을 경우(포그라운드)
             1에서 채팅보내고 3에서 읽으면 2에서도 읽음 처리됨
             2가 백그라운드/종료일 경우
             1에서 채팅보내고 3에서 읽으면 2에서도 읽음 처리안됨
             
             1에서 보낸 채팅 2에서 is_read=1로 디비 저장인데
             그 이후 남이 보낸 채팅을 로컬에서 가져와서 is_read가 1이면 그 전에 채팅 번호까지 읽음처리로 보내면..?
             
             select max(chat_no) from chats where room_no = %@ and user_no != %@ and is_read = 1
             -> 남이 보낸 마지막 채팅(읽은것)
             
             SELECT IFNULL(MIN(CHAT_NO),'-1') FIRST_CHAT, IFNULL(MAX(CHAT_NO),'-1') LAST_CHAT FROM CHATS WHERE CONTENT_TY != 'SYS' AND IS_READ = 0 AND ROOM_NO = %@ AND USER_NO != %@
             */
            
            if(dict==nil){
                NSString *sqlString = [appDelegate.dbHelper getUnreadChatNoRange:chatRoomNo myUserNo:myUserNo];
//                NSString *sqlString = [appDelegate.dbHelper getMyUnreadChatNoRange:chatRoomNo myUserNo:myUserNo];
                
                NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString];
                
                firstChat = [[selectArr objectAtIndex:0] objectForKey:@"FIRST_CHAT"];
                lastChat = [[selectArr objectAtIndex:0] objectForKey:@"LAST_CHAT"];
                
            } else {
                firstChat = [dict objectForKey:@"FIRST_CHAT"];
                lastChat = [dict objectForKey:@"LAST_CHAT"];
            }
            NSLog(@"firstChat : %@ / lastChat : %@", firstChat, lastChat);
            
            if(![[NSString stringWithFormat:@"%@", firstChat] isEqualToString:@"-1"] && ![[NSString stringWithFormat:@"%@", lastChat] isEqualToString:@"-1"]){
                NSString *userNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@", myUserNo]];
                NSString *roomNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@", chatRoomNo]];
                NSString *firstStr = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",firstChat]];
                NSString *lastStr = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",lastChat]];
                
                [paramDict setObject:userNo forKey:@"usrNo"];
                [paramDict setObject:roomNo forKey:@"roomNo"];
                [paramDict setObject:firstStr forKey:@"firstChatNo"];
                [paramDict setObject:lastStr forKey:@"lastChatNo"];
            }
            
            if(paramDict.count<=0){
                appDelegate.currChatRoomNo = chatRoomNo;
                
                NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:chatRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
            
            [socketDict setObject:@"saveChatReadStatus" forKey:@"request"];
        }
        
        [socketDict setObject:paramDict forKey:@"request_value"];
    
        if(paramDict.count>0){
            NSData *socketData = [NSJSONSerialization dataWithJSONObject:socketDict options:0 error:nil];
            NSString *socketJson = [[NSString alloc] initWithData:socketData encoding:NSUTF8StringEncoding];
            
            //메시지 소켓전송 성공이면 끝. 실패면 웹서비스 전송
            @try {
                NSError *error;
                if([socket sendString:socketJson error:&error]){
                    NSLog(@"SOCKET SEND...");
                    if([type isEqualToString:@"SAVE_CHAT"]){
                        
                    } else if([type isEqualToString:@"CHAT_READ_STATUS"]){
                        appDelegate.currChatRoomNo = chatRoomNo;
                        
                        NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:chatRoomNo];
                        [appDelegate.dbHelper crudStatement:sqlString2];
                    }
                    
                } else {
                    NSLog(@"HTTP SEND...");
                    
                    //소켓 재연결/확인
                    [self connectSocket];
                    if([socket sendString:socketJson error:&error]){
                        if([type isEqualToString:@"SAVE_CHAT"]){
                            
                        } else if([type isEqualToString:@"CHAT_READ_STATUS"]){
                            appDelegate.currChatRoomNo = chatRoomNo;
                            
                            NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:chatRoomNo];
                            [appDelegate.dbHelper crudStatement:sqlString2];
                        }
                        
                    } else {
                        if([type isEqualToString:@"SAVE_CHAT"]){
                            if(dict==nil) [self.delegate callSaveChat:msg];
                            else [self.delegate callSaveInviteChat:dict];
                            
                        } else if([type isEqualToString:@"CHAT_READ_STATUS"]){
                            [self.delegate callChatReadStatus];
                        }
                    }
                }
            } @catch (NSException *exception) {
                NSLog(@"Socket Error !");
                [socket close];
                socket = nil;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)socketClose{
    @try{
        [socket close];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

@end
