//
//  ChatConnectSocket.h
//  mfinity_sns
//
//  Created by hilee on 14/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRWebSocket.h"

@protocol ChatConnectSocketDelegate;

@interface ChatConnectSocket : NSObject <SRWebSocketDelegate> {
    SRWebSocket *socket;
}

@property (nonatomic,strong) NSMutableDictionary *editInfoDic;

-(void)connectSocket;
-(void)socketCheck:(NSString *)type roomNo:(NSString *)chatRoomNo message:(NSString *)msg dictionary:(NSDictionary *)dict;
-(void)socketClose;

@property (weak, nonatomic) id <ChatConnectSocketDelegate> delegate;

@end


@protocol ChatConnectSocketDelegate <NSObject>
@optional
- (void)callSaveChat:(NSString *)message;
- (void)callSaveInviteChat:(NSDictionary *)dict;
- (void)callChatReadStatus;

@end
