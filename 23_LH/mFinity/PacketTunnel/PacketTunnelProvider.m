//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by hilee on 2021/03/25.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import "PacketTunnelProvider.h"

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    // Add code here to start the process of connecting the tunnel.
    [super startTunnelWithOptions:options completionHandler:completionHandler];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    // Add code here to start the process of stopping the tunnel.
    [super stopTunnelWithReason:reason completionHandler:completionHandler];
    completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
    // Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    // Add code here to get ready to sleep.
    [super sleepWithCompletionHandler:completionHandler];
    completionHandler();
}

- (void)wake {
    // Add code here to wake up.
    [super wake];
}

//VPN프로토콜 디버그 및 상태확인
-(void)handleLogMessage:(NSString *)logMessage{
    //VPN프로토콜 통신로그
    NSLog(@"VPN logMessage : %@", logMessage);
}

-(void)handleError:(NSError *)error{
    //VPN프로토콜 에러
    NSLog(@"VPN error : %@", error);
}

-(void)handleEvent:(SSLVPNAdapterEvent)event message:(NSString *)message{
    //VPN프로토콜 상태
    NSLog(@"VPN message : %@", message);
}

@end
