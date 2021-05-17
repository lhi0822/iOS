//
//  SSVPNProfile.h
//  SSLVPN Adapter
//
//  Created by sjseong on 2018. 8. 10..
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
/**
 @class SSLVPNProfile
 @brief iOS VPN프로파일 API
 @details iOS에서 VPN프로파일에 대해 생성 및 수정,삭제,실행,중지,상태체크에 대한 프로파일
 */
@interface SSLVPNProfile : NSObject

/**
 @brief VPN 터널링을 시작한다.
 @details 생성된 프로파일 이름에 VPN통신을 재개한다.
 @param profileName : 프로파일이름
 @param vpnStatusBlock : 접속 상태 체크 블럭 \n
 param - status : 접속 상태 \n
 @param complete : 처리 결과 블럭 \n
 param - error : 에러정보 \n
 @return void
 */
+ (void) startVPNTunnelwithProfileName:(NSString *)profileName
                     withVPNStatuBlock:(void (^)(NEVPNStatus status))vpnStatusBlock
                     withCompleteBlock:(void (^)(NSError * _Nullable error))complete;
/**
 @brief VPN 터널링을 중지한다.
 @details 생성된 프로파일 이름에 VPN통신을 중지한다.
 @param profileName : 프로파일이름
 @param complete : 처리 결과 블럭 void (^)(NSError * _Nullable error)\n
 param - error : 에러정보 \n
 @return void
 */
+ (void) stopVPNTunnelwithProfileName:(NSString *)profileName
                    withCompleteBlock:(void (^)(NSError * _Nullable error))complete;

/**
 @brief VPN 터널링상태를 체크한다.
 @details 생성된 프로파일 이름에 VPN통신 상태를 체크한다.
 @param profileName : 프로파일이름
 @param complete : 처리 결과 블럭 \n
 param - status : VPN 터널링 상태 \n
 param - error : 에러정보 \n
 @return void
 */
+ (void) checkStatusVPNProfileWithProfileName:(NSString *)profileName
                            withCompleteBlock:(void (^)(NEVPNStatus status, NSError * _Nullable error))complete;

/**
 @brief VPN프로파일을 생성 및 수정한다.
 @details 프로파일 이름과 VPN정보로 VPN프로파일을 생성및 수정한다.
 @param address : 서버주소
 @param vpnData : VPN서버정보 데이터스트림
 @param profileName : 프로파일이름
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 @return void
 */
+ (void) requestUserProfileVPNTunnelWithServerAddress:(NSString *)address
                                             withData:(NSData *)vpnData
                                      withProfileName:(NSString *)profileName
                                    withCompleteBlock:(void (^)(NSError * _Nullable error))complete;
/**
 @brief VPN프로파일이 존재하는지 확인한다.
 @details 프로파일이 있는지 확인한다.
 @param profileName : 프로파일이름
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 param - isExist : 프로파일존재여부 \n
 param - manager : 프로파일관리정보 \n
 @return void
 */
+ (void) loadVPNProfileWithProfileName:(NSString *)profileName
                     withCompleteBlock:(void (^)(NSError * _Nullable error,bool isExist, NEVPNManager *manager))complete;

/**
 @brief VPN프로파일을 삭제한다.
 @details 프로파일을 삭제한다.
 @param profileName : 프로파일이름
 @param complete : 처리 결과 블럭\n
 param - error : 에러정보 \n
 @return void
 */
+ (void) removeProfileVPNTunnelWithProfileName:(NSString *)profileName
                             withCompleteBlock:(void (^)(NSError * _Nullable error))complete;
@end
