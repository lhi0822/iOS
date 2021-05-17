//
//  MFSingleton.h
//  mfinity_sns
//
//  Created by hilee on 09/03/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFSingleton : NSObject

@property (nonatomic, strong) NSString *legacyName;
@property (nonatomic, strong) NSString *mNewDBVersion;
@property (nonatomic, strong) NSString *aes256key;

@property (nonatomic, strong) NSString *mainUrl;
@property (nonatomic, strong) NSString *dvcType;
@property (nonatomic, strong) NSString *appType;
@property (nonatomic, strong) NSString *callScheme;
@property (nonatomic, strong) NSString *shareExtScheme;
@property (nonatomic, strong) NSString *notiExtScheme;

@property (nonatomic, strong) NSString *rmq_host;
@property int rmq_port;
@property (nonatomic, strong) NSString *rmq_user;
@property (nonatomic, strong) NSString *rmq_pwd;
@property (nonatomic, strong) NSString *rmq_virtualHost;
@property (nonatomic, strong) NSString *rmq_exFanout;
@property (nonatomic, strong) NSString *rmq_exTopic;
@property (nonatomic, strong) NSString *rmq_exDirect;
@property (nonatomic, strong) NSString *rmq_exDevInfo;

@property (nonatomic, strong) NSString *socketUrl1;
@property (nonatomic, strong) NSString *socketUrl2;

//어드민 사용자 번호
@property (nonatomic, strong) NSString *adminNo1;
@property (nonatomic, strong) NSString *adminNo2;

@property (nonatomic, strong) NSString *mainThemeColor;
@property (nonatomic, strong) NSString *chatBgColor;
@property (nonatomic, strong) NSString *chatSendBubbleColor;
@property (nonatomic, strong) NSString *chatRecvBubbleColor;
@property (nonatomic, strong) NSString *chatUnreadColor;

@property (nonatomic, strong) NSString *defaultBoard; //처음 로딩 시 일반게시판 선택
@property (nonatomic, strong) NSString *userListSort; //조직도 YES:부서기준, NO:사용자기준

//이미지 화질 설정 (NORMAL, HIGH)
@property (nonatomic, strong) NSString *imgQuality;
@property (nonatomic, strong) NSString *vdoQuality;
//파일 업로드 시 크기 제한
@property (nonatomic, strong) NSString *imgMaxSize;
@property (nonatomic, strong) NSString *vdoMaxSize;

@property BOOL dbEncrypt;       //로컬DB 암호화 여부
@property BOOL wsEncrypt;       //웹서비스 파라미터 암호화 여부
@property BOOL isMDM;           //MDM 사용여부
@property BOOL mediaAuthCheck;  //촬영 및 앨범 접근 권한 제한
@property BOOL useTask;         //프로젝트 게시판 사용 여부
@property BOOL autoLogin;       //자동로그인 사용 여부
@property int autoLoginDate;    //자동로그인 기간
@property int errorMaxCnt;      //에러 발생 시 재시도 허용 횟수
@property BOOL boardInfoIcon;   //팀룸목록에 아이콘 표시 여부
@property BOOL simplePwd;       //간편비밀번호 사용 여부

+ (instancetype)sharedInstance;

@end


