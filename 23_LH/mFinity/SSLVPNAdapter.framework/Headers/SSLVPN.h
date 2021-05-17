//
//  SSLVPN.h
//  SSLVPN Adapter iOS
//
//  Created by sjseong on 2018. 7. 31..
//

#import <Foundation/Foundation.h>
#import "SGTypeHeader.h"
#import <NetworkExtension/NetworkExtension.h>

/**
@class SSLVPN
@brief SSLVPN Web API 처리
@details SSLVPN Web API 처리 \n
 SSLVPN 접속정보에 대한 웹 API 통신에 대한 클래스 입니다.
*/
@interface SSLVPN : NSObject

/**
 @brief 최신 버전 정보를 확인한다.
 @details 어플리케이션이 최신 버전인지 확인하고, 다운로드 URL과 자동 업데이트 알림 여부를 제공한다. \n
 @param currentVersion : 현재 버전\n
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - isLatestVersion : 최신 버전 여부 \n
 param - downloadURL : 최신 버전 ipa 다운로드 페이지 \n
 param - isAutoUpdate : 업데이트 알림 여부\n
 @return void
 */
+ (void)checkVersionWithCompleteBlock:(void (^)(NSError * _Nullable error, NSString* latestVersion, NSString* downloadURL, BOOL isAutoUpdate))complete;

/**
 @brief 서버정보(로그인 타입, 인증타입)를 확인한다.
 @details 서버정보 상세정보를 확인한다. \n
 로그인타입\n
 - AUTH_LOCAL_DB : 로컬DB \n
 - AUTH_INTERNAL_OTP : 내부OTP \n
 - AUTH_LOCAL_DB_AND_INTERNAL_OTP: 로컬DB와 내부OTP \n\n
 인증타입\n
 - LOGIN_PASS : 패스워드인증 \n
 - LOGIN_CERT : 인증서 인증 \n
 - LOGIN_PASS_OR_CERT : 패스워드 혹은 인증서 인증\n
 - LOGIN_PASS_AND_CERT : 패스워드와 인증서 인증\n
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - authType: 인증 타입 \n
 param - loginType: 로그인 타입 \n
 @return void
 */
+ (void)checkServerWithCompleteBlock:(void (^)(NSError * _Nullable error, INNER_AUTH_RTYPE authType, LOGIN_RTYPE loginType))complete;

/**
@brief 동일한 터널이 이미 사용 중인지 검사
@details 아이폰 내에서 같은 터널이 이미 사용 중인지 검사한다.\n
@param userId : 사용자 ID
@return Boolean : 터널링 사용 여부
*/
+ (Boolean)checkTunnelExistWithUserID:(NSString*)userID;

/**
 @brief OTP 포함된 로그인하기
 @details VPN 웹 서버에 로그인정보를 인증합니다. (OTP 포함된 인증) \n
 - 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param otp : OTP Number
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - isMultiSSLPolicy : 다중정책 여부\n
 param - address : 단일 정책 주소 \n
 param - port : 단일 정책 포트\n
 param - token : 단일 정책 토큰\n
 param - policyList : 다중정책 정보\n
 @return void
 */
+ (void)authWithUserId:(NSString *)userId
           withUserPwd:(NSString *)userPwd
               withOTP:(NSString *)otp
     withCompleteBlock:(void (^)(NSError * _Nullable error, BOOL isMultiSSLPolicy,NSString *address ,NSString *port, NSString *token, NSArray * policyList))complete;

/**
 @brief OTP 포함되지 않은 로그인을 로그인하기
 @details VPN 웹 서버에 로그인정보를 인증합니다. (OTP 포함되지 않은 인증) \n
 - 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - isMultiSSLPolicy : 다중정책 여부\n
 param - address : 단일 정책 주소 \n
 param - port : 단일 정책 포트\n
 param - token : 단일 정책 토큰\n
 param - policyList : 다중정책 정보\n
 @return void
 */
+ (void)authWithUserId:(NSString *)userId
           withUserPwd:(NSString *)userPwd
     withCompleteBlock:(void (^)(NSError * _Nullable error, BOOL isMultiSSLPolicy,NSString *address ,NSString *port, NSString *token, NSArray * policyList))complete;

/**
 @brief 쉬운 로그인(OTP가 포함하지 않음)
 @details VPN 웹 서버에 로그인 인증부터 터널링까지 일괄 수행합니다. \n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param sharing: 앱간 VPN 관리 권한 공유(false시 각 앱마다 로그인할 때 이전 VPN은 끊어지므로 무조건 새로운 세션을 만듦)
 @param profileName : 프로파일이름
 @param vpnStatusBlock : 접속 상태 체크 블럭 \n
 param - status : 접속 상태 \n
 @param complete : 처리 결과 블럭 \n
 param - error : 에러정보 \n 
 @return void
 */
+ (void)easyAuthWithUserId:(NSString *)userId
      withUserPwd:(NSString *)userPwd
      withSharing:(Boolean)sharing
      withProfileName:(NSString *)profileName
      withVPNStatuBlock:(void (^)(NEVPNStatus status))vpnStatusBlock
      withCompleteBlock:(void (^)(NSError * _Nullable error))complete;

/**
 @brief 쉬운 로그인(OTP가 포함)
 @details VPN 웹 서버에 로그인 인증부터 터널링까지 일괄 수행합니다. \n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param otp : OTP Number
 @param sharing: 앱간 VPN 관리 권한 공유(false시 각 앱마다 로그인할 때 이전 VPN은 끊어지므로 무조건 새로운 세션을 만듦)
 @param profileName : 프로파일이름
 @param vpnStatusBlock : 접속 상태 체크 블럭 \n
 param - status : 접속 상태 \n
 @param complete : 처리 결과 블럭 void (^)(NSError * _Nullable error)\n
 param - error : 에러정보 \n
 @return void
 */
+ (void)easyAuthWithUserId:(NSString *)userId
      withUserPwd:(NSString *)userPwd
      withOTP:(NSString *)otp
      withSharing:(Boolean)sharing
      withProfileName:(NSString *)profileName
      withVPNStatuBlock:(void (^)(NEVPNStatus status))vpnStatusBlock
      withCompleteBlock:(void (^)(NSError * _Nullable error))complete;

/**
 @brief 패스워드 변경하기
 @details VPN 웹 서버에 비밀번호변경을 요청합니다. \n
 - 패스워드 만료에 대해 변경을 요청합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param newPwd : 사용자 새암호
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - isSuccess : 변경 성공여부 \n
 @return void
 */
+ (void)changePasswordWithUserId:(NSString *)userId
                     withUserPwd:(NSString *)userPwd
                      withNewPwd:(NSString *)newPwd
               withCompleteBlock:(void (^)(NSError * _Nullable error, BOOL isSuccess))complete;

/**
 @brief OTP 포함된 다중정책 선택하기
 @details SSL 정책값이 다중일때 해당 정책값을 통해 정책IP, 정책Port ,정책 token을 받아오는 함수 \n
 - 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param otp : OTP Number
 @param token : 선태한 로그인 정책 토큰
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - address : 로그인 토큰에 대한 정책 IP\n
 param - port : 로그인 토큰에 대한 정책 Port\n
 param - token : 로그인 토큰에 대한 정책 토큰\n
 @return void
 */
+ (void)selectSSLPolicyWithUserId:(NSString *)userId
                      withUserPwd:(NSString *)userPwd
                          withOTP:(NSString *)otp
                        withToken:(NSString *)token
                withCompleteBlock:(void (^)(NSError * _Nullable error,NSString *address ,NSString *port, NSString *token))complete;
/**
@brief OTP 포함되지 않은 다중정책 선택하기
@details SSL 정책값이 다중일때 해당 정책값을 통해 정책IP, 정책Port ,정책 token을 받아오는 함수 \n
- 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
@param userId : 사용자 ID
@param userPwd : 사용자 암호
@param token : 선태한 로그인 정책 토큰
@param complete : 처리 결과 블럭\n
param - error : 에러정보 \n
param - address : 로그인 토큰에 대한 정책 IP\n
param - port : 로그인 토큰에 대한 정책 Port\n
param - token : 로그인 토큰에 대한 정책 토큰\n
@return void
*/
+ (void)selectSSLPolicyWithUserId:(NSString *)userId
                      withUserPwd:(NSString *)userPwd
                        withToken:(NSString *)token
                withCompleteBlock:(void (^)(NSError * _Nullable error,NSString *address ,NSString *port, NSString *token))complete;

/**
 @brief OTP 포함된 다중정책 선택하기
 @details SSL 정책값이 다중일때 해당 정책값을 통해 정책IP, 정책Port ,정책 token을 받아오는 함수 \n
 - 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param otp : OTP Number
 @param token : 선태한 로그인 정책 토큰
 @param completeQueue : 동기화 처리를 위한 Queue
 @param completeGroup : 동기화 처리를 위한 QueueGroup
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - address : 로그인 토큰에 대한 정책 IP\n
 param - port : 로그인 토큰에 대한 정책 Port\n
 param - token : 로그인 토큰에 대한 정책 토큰\n
 @return void
 */
+ (void)selectSSLPolicyWithUserId:(NSString *)userId
                      withUserPwd:(NSString *)userPwd
                          withOTP:(NSString *)otp
                        withToken:(NSString *)token
                withCompleteQueue:(dispatch_queue_t)completeQueue
                withCompleteGroup:(dispatch_group_t)completeGroup
                withCompleteBlock:(void (^)(NSError * _Nullable error,NSString *address ,NSString *port, NSString *token))complete;
/**
 @brief OTP 포함되지 않은 다중정책 선택하기
 @details SSL 정책값이 다중일때 해당 정책값을 통해 정책IP, 정책Port ,정책 token을 받아오는 함수 \n
 - 정책에 다중여부에 따라 해당값은 다음과 같은 결과 값을 가지고 다중정책일 경우에는 다중정책선택에 대한 로직이 추가가 필요합니다.\n
 @param userId : 사용자 ID
 @param userPwd : 사용자 암호
 @param token : 선태한 로그인 정책 토큰
 @param completeQueue : 동기화 처리를 위한 Queue
 @param completeGroup : 동기화 처리를 위한 QueueGroup
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - address : 로그인 토큰에 대한 정책 IP\n
 param - port : 로그인 토큰에 대한 정책 Port\n
 param - token : 로그인 토큰에 대한 정책 토큰\n
 @return void
 */
+ (void)selectSSLPolicyWithUserId:(NSString *)userId
                      withUserPwd:(NSString *)userPwd
                        withToken:(NSString *)token
                withCompleteQueue:(dispatch_queue_t)completeQueue
                withCompleteGroup:(dispatch_group_t)completeGroup
                withCompleteBlock:(void (^)(NSError * _Nullable error,NSString *address ,NSString *port, NSString *token))complete;

/**
 @brief 정책정보 다운로드하기
 @details 정책ID에 따른 VPN접속정보를 다운로드 하는 함수 \n
 @warning 1.0.5버전 이후 삭제예정된 함수
 @param address : 다중정책 혹은 단일정책으로 받은 IP
 @param port : 다중정책 혹은 단일정책으로 받은 포트
 @param token : 다중정책 혹은 단일정책으로 받은 토큰값
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - hostName : 서버이름\n
 param - address : 서버주소\n
 param - vpnData : VPN접속에 대한 정보 스트림데이터\n
 @return void
 */
+ (void)policyInfoDownloadWithServerAddress:(NSString *)address
                                   withPort:(NSString *)port
                                  withToken:(NSString *)token
                          withCompleteBlock:(void (^)(NSError * _Nullable error, NSString *hostName, NSString *address, NSData *vpnData))complete __deprecated_msg("not supported sslvpn 1.0.5 and policyUpdateWithServerAddress instead.");

/**
 @brief 정책정보 다운로드하기
 @details 정책ID에 따른 VPN접속정보를 다운로드 하는 함수 \n
 @param address : 다중정책 혹은 단일정책으로 받은 IP
 @param port : 다중정책 혹은 단일정책으로 받은 포트
 @param token : 다중정책 혹은 단일정책으로 받은 토큰값
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - hostName : 서버이름\n
 param - address : 서버주소\n
 param - vpnData : VPN접속에 대한 정보 스트림데이터\n
 param - vpnInfoDict : VPN접속에 대한 정보에 Dictionary모음\n
 param - isUpdated : 이전 로그인처리 이후 변경사항 유무 처리\n
 @return void
 */
+ (void)policyUpdateWithServerAddress:(NSString *)address
                             withPort:(NSString *)port
                            withToken:(NSString *)token
                    withCompleteBlock:(void (^)(NSError * _Nullable error, NSString *hostName, NSString *address, NSData *vpnData, NSDictionary *vpnInfoDict,BOOL isUpdated))complete;

/**
 @brief 정책정보 다운로드하기
 @details 정책ID에 따른 VPN접속정보를 다운로드 하는 함수 \n
 @param address : 다중정책 혹은 단일정책으로 받은 IP
 @param port : 다중정책 혹은 단일정책으로 받은 포트
 @param token : 다중정책 혹은 단일정책으로 받은 토큰값
 @param success : 성공 처리 블럭\n
 param - hostName : 서버이름\n
 param - address : 서버주소\n
 param - vpnData : VPN접속에 대한 정보 스트림데이터\n
 param - vpnInfoDict : VPN접속에 대한 정보에 Dictionary모음\n
 param - isUpdated : 이전 로그인처리 이후 변경사항 유무 처리\n
 @param failure : 실패 처리 블럭\n
 param - error : 에러정보 \n
 @return void
 */
+ (void)policyUpdateWithServerAddress:(NSString *)address
                             withPort:(NSString *)port
                            withToken:(NSString *)token
                    withCompleteSuccessBlock:(void (^)(NSString *hostName, NSString *address, NSData *vpnData, NSDictionary *vpnInfoDict,BOOL isUpdated))success
                    withCompleteFailBlock:(void (^)(NSError * _Nullable error)) failure;

/**
 @brief 정책정보 다운로드하기
 @details 정책ID에 따른 VPN접속정보를 다운로드 하는 함수 \n
 @param address : 다중정책 혹은 단일정책으로 받은 IP
 @param port : 다중정책 혹은 단일정책으로 받은 포트
 @param token : 다중정책 혹은 단일정책으로 받은 토큰값
 @param convert : VPN접속에 대한 정보 임의변경 블럭\n
 param - vpnInfoDict : 설정된 VPN접속에 대한 정보에 Dictionary모음\n
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - hostName : 서버이름\n
 param - address : 서버주소\n
 param - vpnData : 설정된 VPN접속에 대한 정보 스트림데이터\n
 param - vpnInfoDict : 설정된 VPN접속에 대한 정보에 Dictionary모음\n
 @return void
 */
+ (void)policyUpdateWithServerAddress:(NSString *)address
                             withPort:(NSString *)port
                            withToken:(NSString *)token
                withConvertToOvpnData:(NSData *(^)(NSDictionary *vpnInfoDict))convert
                    withCompleteBlock:(void (^)(NSError * _Nullable error, NSString *hostName, NSString *address, NSData *vpnData))complete;

/**
 @brief 정책정보 다운로드하기
 @details 정책ID에 따른 VPN접속정보를 다운로드 하는 함수 \n
 @param address : 다중정책 혹은 단일정책으로 받은 IP
 @param port : 다중정책 혹은 단일정책으로 받은 포트
 @param token : 다중정책 혹은 단일정책으로 받은 토큰값
 @param convert : VPN접속에 대한 정보 임의변경 블럭\n
 param - vpnInfoDict : 설정된 VPN접속에 대한 정보에 Dictionary모음\n
 @param success : 성공 처리 블럭\n
 param - hostName : 서버이름\n
 param - address : 서버주소\n
 param - vpnData : VPN접속에 대한 정보 스트림데이터\n
 @param failure : 실패 처리 블럭\n
 param - error : 에러정보 \n
 @return void
 */
+ (void)policyUpdateWithServerAddress:(NSString *)address
                             withPort:(NSString *)port
                            withToken:(NSString *)token
                withConvertToOvpnData:(NSData *(^)(NSDictionary *vpnInfoDict))convert
             withCompleteSuccessBlock:(void (^)(NSString *hostName, NSString *address, NSData *vpnData))success
                withCompleteFailBlock:(void (^)(NSError * _Nullable error))failure;

@end
