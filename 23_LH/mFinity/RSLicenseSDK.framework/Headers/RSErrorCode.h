//
//  RSLicenseUtil.h
//  RSLicenseSDK
//  Copyright © 2018년 RAONSECURE All rights reserved.
//

#import <Foundation/Foundation.h>


// 성공
#define RSL_SUCCESS                                     0

// 초기화
#define RSL_ERR_LICENSEFILE_NOT_EXIST                   -1          //라이센스 파일이 지정된 경로에 없음
#define RSL_ERR_LICENSEFILE_READ_FAILED                 -2

// 포멧
#define RSL_ERR_PARSEJSON                               -100        //JSON 파싱 실패
#define RSL_ERR_PARSEJSON_MANDATORY_ITEM_NOT_EXIST      -101        //필수항목 데이터가 없음
#define RSL_ERR_PARSEJSON_MANDATORY_SITENM_NOT_EXIST    -102        //필수항목 데이터없음 - 사이트명
#define RSL_ERR_PARSEJSON_MANDATORY_SITECD_NOT_EXIST    -103        //필수항목 데이터없음 - 사이트코드
#define RSL_ERR_PARSEJSON_MANDATORY_PRODNM_NOT_EXIST    -104        //필수항목 데이터없음 - 제품명
#define RSL_ERR_PARSEJSON_MANDATORY_LCSTYPE_NOT_EXIST   -105        //필수항목 데이터없음 - 라이선스 타입
#define RSL_ERR_PARSEJSON_MANDATORY_LCSCD_NOT_EXIST     -106        //필수항목 데이터없음 - 라이선스 코드
#define RSL_ERR_PARSEJSON_MANDATORY_EXPDT_NOT_EXIST     -107        //필수항목 데이터없음 - 만료일
#define RSL_ERR_PARSEJSON_MANDATORY_ISSUER_NOT_EXIST    -108        //필수항목 데이터없음 - 발급자
#define RSL_ERR_PARSEJSON_MANDATORY_ISSUEDDT_NOT_EXIST  -109        //필수항목 데이터없음 - 발급일

// 키 검증
#define RSL_ERR_VERIFY                                  -200
#define RSL_ERR_VERIFY_TOO_SHORT                        -201
#define RSL_ERR_VERIFY_INVALID_FORMAT                   -202        //라이선스 타입, 해시, 라이선스 데이터 파싱 실패
#define RSL_ERR_VERIFY_INVALID_INPUT                    -203        //입력이 null이거나 유효하지 않은 값
#define RSL_ERR_VERIFY_INTEGRITY_CHECK_FAIL             -204        //무결성 체크 실패

// 유효성 체크
#define RSL_ERR_CHK_VALIDITY                            -300
#define RSL_ERR_CHK_VALIDITY_INVALID_MAC                -301        //허용되지 않은 mac
#define RSL_ERR_CHK_VALIDITY_INVALID_IP                 -302        //허용되지 않은 ip
#define RSL_ERR_CHK_VALIDITY_INVALID_DOMAIN             -303        //허용되지 않은 domain
#define RSL_ERR_CHK_VALIDITY_INVALID_CPU_CORE_COUNT     -304        //허용되지 않은 cpu core count
#define RSL_ERR_CHK_VALIDITY_INVALID_WAS_INSTANCE_COUNT -305        //허용되지 않은 was instance count
#define RSL_ERR_CHK_VALIDITY_INVALID_HOST_ID            -306        //허용되지 않은 hostid
#define RSL_ERR_CHK_VALIDITY_INVALID_BROWSER            -307        //허용되지 않은 browser
#define RSL_ERR_CHK_VALIDITY_LICENSE_EXPIRED            -308        //유효기간 경과
#define RSL_ERR_CHK_VALIDITY_INVALID_APP_ID             -309        //허용되지 않은 app_id
#define RSL_ERR_CHK_VALIDITY_INVALID_OS                 -310        //허용되지 않은 os

#define RSL_ERR_CHK_VALIDITY_INVALID_FORMAT             -351
#define RSL_ERR_CHK_VALIDITY_GET_MACADDR_FAIL           -352
#define RSL_ERR_CHK_VALIDITY_GET_IPADDR_FAIL            -353
#define RSL_ERR_CHK_VALIDITY_GET_OS_FAIL                -354
#define RSL_ERR_CHK_VALIDITY_GET_CPUCORECNT_FAIL        -355

#define  RSL_ERR_CHK_VALIDITY_CONV_TO_INT_FAIL          -371        //int반환하는 getter가 원래 값이 null혹은 길이가 0인 경우,숫자로 변환 불가한 경우
#define  RSL_ERR_CHK_VALIDITY_INVALID_FEATURE_NAME      -372        //feature명 입력받는 인터페이스를 사용하는 함수들에서 feature명으로 feature를 가져오지 못한경우

// 온라인 액티베이션
#define RSL_ERR_ONACT                                   -500
#define RSL_ERR_ONACT_NOT_TRUSTED_SVR                   -501
#define RSL_ERR_ONACT_CONN_FAIL                         -502
#define RSL_ERR_ONACT_TIMEOUT                           -503


@interface RSErrorCode : NSObject

+(NSString *) getErrorMessage:(int) errorCode;

@end
