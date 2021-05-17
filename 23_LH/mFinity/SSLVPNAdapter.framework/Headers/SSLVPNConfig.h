//
//  SSLVPNConfig.h
//  SSLVPN Adapter
//
//  Created by sjseong on 2018. 8. 10..
//

#import <Foundation/Foundation.h>
/**
 @brief SSLVPNConfig API
 @details SSLVPN 연결관련 및 전체적인 설정 함수집합
 */
@interface SSLVPNConfig : NSObject
/**
 @brief SSLVPN 서버주소 설정
 @details SSLVPN 서버주소 설정 \n
 @param host
 @return void
 */
+ (void)setApiHost:(NSString *)host;
/**
 @brief SSLVPN 서버 포트설정
 @details SSLVPN 서버 포트설정 \n
 @param port
 @return void
 */
+ (void)setApiPort:(int)port;
/**
 @brief SSLVPN DNS 주소 설정
 @details SSLVPN DNS 주소를 추가등록한다. \n
 @param address
 @return void
 */
+ (void)addDNSAddress:(NSString *)address;
/**
 @brief SSLVPN PacketTunnelExtension identifier 설정
 @details SSLVPN PacketTunnelExtension identifier 설정\n
 @param identifier
 @return void
 */
+ (void)setPacketTunnelBundleIdentifier:(NSString*)identifier;
/**
 @brief SSLVPN CA 인증서위치 설정
 @details SSLVPN CA 인증서위치 설정\n
 @param path
 @return void
 */
+ (void)setRootCAPath:(NSString*)path;
/**
 @brief SSLVPN API 호출 타임아웃설정
 @details SSLVPN API 호출 타임아웃설정\n
 @param timeout
 @return void
 */
+ (void)setNetworkTimeout:(float)timeout;
/**
 @brief SSLVPN API 호출 재시도 카운트설정
 @details SSLVPN API 호출 재시도 카운트설정\n
 @param count
 @return void
 */
+ (void)setRetryCount:(int)count;
/**
 @brief 앱이 종료되면 터널도 자동 종료
 @details 앱이 종료되면 터널도 자동 종료할지 여부\n
 @param enable
 @return void
 */
+ (void)setAutoStop:(BOOL)enable;
/**
 @brief ID/PW 인증 시 OTP 인증도 자동으로 처리한다(자체적으로 OTP 발생시켜 사용)
 @details ID,PW를 인자로한 auth함수를 호출하면 자체적으로 발생시킨 OTP로 OTP인증을 함께 처리한다.\n
 ID, PW, OTP를 인자로한 auth함수를 호출하면 기존처럼 사용자가 지정한 OTP로 로그인한다.\n
 @param enable
 @return void
 */
+ (void)setUsingBundleOTP:(BOOL)enable;
/**
 @brief SSLVPN 설정된 서버주소
 @details SSLVPN 설정된 서버주소\n
 @return NSString
 */
+ (NSString *)getApiHost;
/**
 @brief SSLVPN 설정된 서버포트
 @details SSLVPN 설정된 서버포트\n
 @return int
 */
+ (int)getApiPort;
/**
 @brief SSLVPN 라이브러리 버전
 @details SSLVPN 라이브러리 버전\n
 @return NSString
 */
+ (NSString *)getApiVersion;
/**
 @brief SSLVPN 설정된 API 호출 재시도 카운트
 @details SSLVPN 설정된 API 호출 재시도 카운트\n
 @return int
 */
+ (int)getRetryCount;
/**
 @brief SSLVPN 설정된 API 호출 타임아웃
 @details SSLVPN 설정된 API 호출 타임아웃\n
 @return int
 */
+ (float)getNetworkTimeout;
/**
 @brief 앱이 종료되면 터널도 자동 종료
 @details 앱이 종료되면 터널도 자동 종료할지 여부\n
 @return BOOL
 */
+ (BOOL)getAutoStop;
/**
 @brief ID/PW 인증 시 OTP 인증도 자동으로 처리한다(자체적으로 OTP 발생시켜 사용)
 @details ID,PW를 인자로한 auth함수를 호출하면 자체적으로 발생시킨 OTP로 OTP인증을 함께 처리한다.\n
 ID, PW, OTP를 인자로한 auth함수를 호출하면 기존처럼 사용자가 지정한 OTP로 로그인한다.\n
 @param enable
 @return void
 */
+ (BOOL)getUsingBundleOTP;

+ (NSString *)getPacketTunnelBundleIdentifier;
+ (NSString *)getDeviceVersion;
+ (NSString *)getHwInfo;
+ (NSString *)getUUID;
+ (NSString *)getRootCAPath;

@end
