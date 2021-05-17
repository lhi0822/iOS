//
//  RSLicenseUtil.h
//  RSLicenseSDK
//  Copyright © 2018년 RAONSECURE All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSLicense.h"
#import "RSErrorCode.h"

@interface RSLicenseChecker : NSObject <NSURLSessionDelegate> {
    RSLicense *mRSLicenseData;
    RSLicenseInfo *mRSLicenseInfo;
    RSLicenseSchema *mRSLicenseSchema;
    RSFeature *mRSFreature;
    NSString *mLicenseVersion;
    NSString *mExtension;
}


/**
 싱글턴객체 받아오기

 @return RSLicenseChecker object
 */
+ (RSLicenseChecker *) sharedInstance;


/**
 라이선스 체크 함수

 @param filePath 라이선스 파일이 저장된 경로
 @return errorCode (RSL_SUCCESS:성공...)
 */
- (int)checkLicenseFile:(NSString *)filePath;


/**
 더블체크 함수

 @return true:성공, false:실패
 */
- (BOOL)doubleCheckLicense;


/**
 라이선스 체크 online Activation Server 함수

 @param serverUrl Activation Server 도메인주소
 @param aSuccessEvent 성공이벤트 block
 @param aFailEvent 실패이벤트 block
 */
- (void)requestLicense:(NSString *)serverUrl withSuccessBlock:(void (^)(int resultCode))aSuccessEvent errorBlock:(void (^)(int resultCode))aFailEvent;


/**
 RSLicense 라이선스 객체 받아오기 함수

 @return RSLicense 객체 반환
 */
- (RSLicense *)getRaonLicense;


/**
 SDK 버전 확인 함수

 @return SDK 버전
 */
- (NSString *)getSdkVersion;


/**
 디버그 로그 설정 함수

 @param aFlag 로그 ON/OFF
 */
- (void)setFLAG:(BOOL)aFlag;
@end
