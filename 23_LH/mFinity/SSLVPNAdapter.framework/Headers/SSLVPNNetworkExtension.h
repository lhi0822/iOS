//
//  SSLVPNNetworkExtension.h
//  SSLVPN Adapter
//
//  Created by sjseong on 2018. 7. 31..
//

#import <NetworkExtension/NetworkExtension.h>
#import "SSLVPNAdapterEvent.h"
/**
 @brief SSLVPNNetworkExtensionDelegate API
 @details 터널링 관련된 응답처리 및 로그를 기록하기 위한 Delegate
 */
@protocol SSLVPNNetworkExtensionDelegate<NSObject>
@optional

/**
 @brief SSLVPN 터널링중 이벤트 메시지를 출력한다.
 @param event : 이벤트정보
 @param message : 메시지내용 \n
 @return void
 */
- (void)handleEvent:(SSLVPNAdapterEvent)event message:(nullable NSString *)message;
/**
 @brief SSLVPN 로그 메시지를 출력한다.
 @param logMessage : 로그메시지
 @return void
 */
- (void)handleLogMessage:(NSString *)logMessage;
/**
 @brief SSLVPN 에러 정보를 출력한다.
 @param error : 에러정보
 @return void
 */
- (void)handleError:(nonnull NSError *)error;
@end

/**
 @brief SSLVPNNetworkExtension API
 @details 터널링에 대한 상속처리
 */
@interface SSLVPNNetworkExtension : NEPacketTunnelProvider<SSLVPNNetworkExtensionDelegate>

/**
 @brief SSLVPN 터널링 시작 블럭 정의
 @param error : 에러정보
 @return void
 */
typedef void (^StartHandler)(NSError * _Nullable);
@property (nonatomic, strong) StartHandler startHandler;

/**
 @brief SSLVPN 터널링 중지 블럭 정의
 @return void
 */
typedef void (^StopHandler)(void);
@property (nonatomic, strong) StopHandler stopHandler;
@end
