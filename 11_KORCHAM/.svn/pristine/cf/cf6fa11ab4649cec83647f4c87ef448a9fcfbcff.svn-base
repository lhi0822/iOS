//
//  APDApiManager.h
//  ExafeAppDefenceLibrary
//
//  Created by extrus on 2016. 10. 10..
//  Copyright © 2016년 extrus. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface APDApiManager : NSObject{

}

/*
 앱위변조 모듈 초기화
 - licCode :: 라이선스 코드
 - setURL :: 앱위변조 검증(E2E) 서버
*/
-(BOOL) initAPD: (NSString *) licCode  :(NSString *) setURL;

/*
 앱위변조 검증 수행
 - adID :: 앱위변조 검증 ID
 - adPWD :: 앱위변조 검증 PWD
 + 기기 고유정보 로그인시 값이 없어도 무방.
 
 - setLoginType :: 로그인 타입 지정
    1: 기기 고유정보 (Default)
    2: ID/PW기반 로그인
*/
-(NSString *)startAppDefence : (NSString *)adID :(NSString *)adPWD :(NSString *)setLoginType ;

@end
