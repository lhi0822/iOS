//
//  MFSingleton.m
//  mfinity_sns
//
//  Created by hilee on 09/03/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "MFSingleton.h"

/*
//현대중공업------------------------------------------------------------
#define LCY_NAME @"HHI"
//#define DB_VER @"15" //1.5.4(200327)
#define DB_VER @"16" //1.5.8(200826)
#define AES256KEY @"E3Z2S1M5A9R8T1F3E2E4L31504081532"

//운영
#define MAIN_URL @"https://touch1.hhi.co.kr/snsService/"
#define APP_TYPE @"ENT"
#define P_SCHEME @"hhi.mobile.ios.mfinity"
#define T_SCHEME @"hhi.mobile.ios.mfinityhd"
#define SHARE_EXT_SCHEME @"group.hhi.sns.share"
#define NOTI_EXT_SCHEME @"group.hhi.sns.push"

//개발
//#define MAIN_URL @"http://dev.hhi.co.kr:49175/snsService/"
//#define APP_TYPE @"DEV"
//#define P_SCHEME @"hhi.mobile.ios.mfinity.dev"
//#define T_SCHEME @"hhi.mobile.ios.mfinityhd.dev"

#define RMQ_HOST @"mfps2.hhi.co.kr"
#define RMQ_PORT 5672
#define RMQ_USER @"snsService"
#define RMQ_PWD @"feel1001"
#define RMQ_VIRTUAL_HOST @"snsHost"
#define RMQ_EX_FANOUT @"mfps.fanout"
#define RMQ_EX_TOPIC @"mfps.topic"
#define RMQ_EX_DIRECT @"mfps.direct"
#define RMQ_EX_DEV_INFO @"mfps.device.info"
//authorization : Basic YWRtaW46ZmVlbDEwMDE=

#define SOCKET_URL1 @"ws://211.193.193.220:49175/snsListener/wsListener";
#define SOCKET_URL2 @"ws://211.193.193.221:49175/snsListener/wsListener";

#define ADMIN_NO1 @"0"
#define ADMIN_NO2 @"2"
#define MAIN_COLOR @"0093D5"
#define CHAT_BG_COLOR @"ABC0D0" //채팅방 배경색상
#define CHAT_SEND_BUBBLE_COLOR @"FDE232" //채팅 말풍선 색상
#define CHAT_RECV_BUBBLE_COLOR @"FFFFFF" //채팅 말풍선 색상
#define CHAT_UNREAD_COLOR @"FDE232" //채팅 읽음 카운트 색상

#define DEFAULT_BOARD @"NORMAL" //NORMAL, TASK
#define USER_LIST_SORT @"USER"  //DEPT, USER

#define IMG_QUAL @"HIGH"
#define VDO_QUAL @"NORMAL"
#define IMG_MAX_SIZE @""
#define VDO_MAX_SIZE @""

#define DB_ENCRYPT YES          //로컬DB 암호화 사용 여부
#define WS_ENCRYPT YES          //웹서비스 파라미터 암호화 사용 여부
#define IS_MDM NO               //MDM 사용여부
#define MEDIA_AUTH_CHECK YES     //촬영 및 앨범 접근 권한 제한
#define USE_TASK NO             //프로젝트 게시판 사용 여부
#define AUTO_LOGIN YES          //자동로그인 사용 여부
#define AUTO_LOGIN_DATE 30      //자동로그인 기간
#define ERROR_MAX_CNT 2         //에러 발생 시 재시도 허용 횟수
#define BOARD_INFO_ICON NO      //팀룸목록에 아이콘 표시 여부
#define SIMPLE_PWD YES          //간편비밀번호 사용 여부
//--------------------------------------------------------------------
*/

/*
//디비밸리---------------------------------------------------------------
#define LCY_NAME @"ANYMATE"
#define DB_VER @"5"
#define AES256KEY @"E3Z2S1M5A9R8T1F3E2E4L31504081532"
 
#define MAIN_URL @"https://roms.dbvalley.com/snsService"
//#define MAIN_URL @"http://192.168.0.150:8080/snsService" //김과장님 로컬
#define APP_TYPE @"ENT"
#define P_SCHEME @"com.dbvalley.mfinity.sns"
#define T_SCHEME @""
#define SHARE_EXT_SCHEME @"group.sns.share"
#define NOTI_EXT_SCHEME @""

#define RMQ_HOST @"roms.dbvalley.com"
#define RMQ_PORT 5672
#define RMQ_USER @"snsService"
#define RMQ_PWD @"feel1001"
#define RMQ_VIRTUAL_HOST @"snsHost"
#define RMQ_EX_FANOUT @"mfps.fanout"
#define RMQ_EX_TOPIC @"mfps.topic"
#define RMQ_EX_DIRECT @"mfps.direct"
#define RMQ_EX_DEV_INFO @"mfps.device.info"
//authorization : Basic cmFiYml0bXE6ZmVlbDEwMDE=
 
#define SOCKET_URL1 @"wss://roms.dbvalley.com/snsListener/wsListener";
#define SOCKET_URL2 @"wss://roms.dbvalley.com/snsListener/wsListener";
 
#define ADMIN_NO1 @"0"
#define ADMIN_NO2 @"2"
#define MAIN_COLOR @"1B4C98"
#define CHAT_BG_COLOR @"ABC0D0" //채팅방 배경색상
#define CHAT_SEND_BUBBLE_COLOR @"FDE232" //채팅 말풍선 색상
#define CHAT_RECV_BUBBLE_COLOR @"FFFFFF" //채팅 말풍선 색상
#define CHAT_UNREAD_COLOR @"FDE232" //채팅 읽음 카운트 색상
 
#define DEFAULT_BOARD @"NORMAL" //NORMAL, TASK
#define USER_LIST_SORT @"USER"  //DEPT, USER
 
#define IMG_QUAL @"HIGH"
#define VDO_QUAL @"NORMAL"
#define IMG_MAX_SIZE @""
#define VDO_MAX_SIZE @""

#define DB_ENCRYPT YES           //로컬DB 암호화 사용 여부
#define WS_ENCRYPT YES          //웹서비스 파라미터 암호화 사용 여부
#define IS_MDM NO               //MDM 사용여부
#define MEDIA_AUTH_CHECK NO     //촬영 및 앨범 접근 권한 제한
#define USE_TASK NO            //프로젝트 게시판 사용 여부
#define AUTO_LOGIN YES           //자동로그인 사용 여부
#define AUTO_LOGIN_DATE 30      //자동로그인 기간
#define ERROR_MAX_CNT 2         //에러 발생 시 재시도 허용 횟수
#define BOARD_INFO_ICON YES     //팀룸목록에 아이콘 표시 여부
#define SIMPLE_PWD YES           //간편비밀번호 사용 여부
//--------------------------------------------------------------------
*/

//앱스토어---------------------------------------------------------------
#define LCY_NAME @"ANYMATE"
//#define DB_VER @"5"
#define DB_VER @"16" //1.6.1(210504)
#define AES256KEY @"E3Z2S1M5A9R8T1F3E2E4L31504081532"
 
#define MAIN_URL @"https://roms.dbvalley.com/snsService"
//#define MAIN_URL @"http://192.168.0.150:8080/snsService" //김과장님 로컬
#define APP_TYPE @"ENT"
#define P_SCHEME @"com.dbvalley.sns-consumer"
#define T_SCHEME @""
#define SHARE_EXT_SCHEME @"group.dbvalley.sns.ShareEx"
#define NOTI_EXT_SCHEME @""

#define RMQ_HOST @"roms.dbvalley.com"
#define RMQ_PORT 5672
#define RMQ_USER @"snsService"
#define RMQ_PWD @"feel1001"
#define RMQ_VIRTUAL_HOST @"snsHost"
#define RMQ_EX_FANOUT @"mfps.fanout"
#define RMQ_EX_TOPIC @"mfps.topic"
#define RMQ_EX_DIRECT @"mfps.direct"
#define RMQ_EX_DEV_INFO @"mfps.device.info"
//authorization : Basic cmFiYml0bXE6ZmVlbDEwMDE=
 
#define SOCKET_URL1 @"wss://roms.dbvalley.com/snsListener/wsListener";
#define SOCKET_URL2 @"wss://roms.dbvalley.com/snsListener/wsListener";
 
#define ADMIN_NO1 @"0"
#define ADMIN_NO2 @"2"
#define MAIN_COLOR @"1B4C98"
#define CHAT_BG_COLOR @"ABC0D0" //채팅방 배경색상
#define CHAT_SEND_BUBBLE_COLOR @"FDE232" //채팅 말풍선 색상
#define CHAT_RECV_BUBBLE_COLOR @"FFFFFF" //채팅 말풍선 색상
#define CHAT_UNREAD_COLOR @"FDE232" //채팅 읽음 카운트 색상
 
#define DEFAULT_BOARD @"NORMAL" //NORMAL, TASK
#define USER_LIST_SORT @"USER"  //DEPT, USER
 
#define IMG_QUAL @"HIGH"
#define VDO_QUAL @"NORMAL"
#define IMG_MAX_SIZE @""
#define VDO_MAX_SIZE @""

#define DB_ENCRYPT YES           //로컬DB 암호화 사용 여부
#define WS_ENCRYPT YES          //웹서비스 파라미터 암호화 사용 여부
#define IS_MDM NO               //MDM 사용여부
#define MEDIA_AUTH_CHECK NO     //촬영 및 앨범 접근 권한 제한
#define USE_TASK NO            //프로젝트 게시판 사용 여부
#define AUTO_LOGIN YES           //자동로그인 사용 여부
#define AUTO_LOGIN_DATE 30      //자동로그인 기간
#define ERROR_MAX_CNT 2         //에러 발생 시 재시도 허용 횟수
#define BOARD_INFO_ICON YES     //팀룸목록에 아이콘 표시 여부
#define SIMPLE_PWD YES           //간편비밀번호 사용 여부
//--------------------------------------------------------------------


@implementation MFSingleton

+ (instancetype)sharedInstance {
    static MFSingleton *shared = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MFSingleton alloc] init];
    });

    return shared;
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"");
        
        self.legacyName = LCY_NAME;
        self.mNewDBVersion = DB_VER;
        self.mainUrl = MAIN_URL;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.dvcType = @"T";
            self.callScheme = T_SCHEME;
        } else {
            self.dvcType = @"P";
            self.callScheme = P_SCHEME;
        }
        self.shareExtScheme = SHARE_EXT_SCHEME;
        self.notiExtScheme = NOTI_EXT_SCHEME;
        
        self.aes256key = AES256KEY;
        self.appType = APP_TYPE;
        
        self.rmq_host = RMQ_HOST;
        self.rmq_port = RMQ_PORT;
        self.rmq_user = RMQ_USER;
        self.rmq_pwd = RMQ_PWD;
        self.rmq_virtualHost = RMQ_VIRTUAL_HOST;
        self.rmq_exFanout = RMQ_EX_FANOUT;
        self.rmq_exTopic = RMQ_EX_TOPIC;
        self.rmq_exDirect = RMQ_EX_DIRECT;
        self.rmq_exDevInfo = RMQ_EX_DEV_INFO;
        
        self.socketUrl1 = SOCKET_URL1;
        self.socketUrl2 = SOCKET_URL2;
        self.mainThemeColor = MAIN_COLOR;
        self.chatBgColor = CHAT_BG_COLOR;
        self.chatSendBubbleColor = CHAT_SEND_BUBBLE_COLOR;
        self.chatRecvBubbleColor = CHAT_RECV_BUBBLE_COLOR;
        self.chatUnreadColor = CHAT_UNREAD_COLOR;
        
        self.adminNo1 = ADMIN_NO1;
        self.adminNo2 = ADMIN_NO2;
        self.imgQuality = IMG_QUAL;
        self.vdoQuality = VDO_QUAL;
        self.defaultBoard = DEFAULT_BOARD;
        self.userListSort = USER_LIST_SORT;
        
        self.dbEncrypt = DB_ENCRYPT;
        self.wsEncrypt = WS_ENCRYPT;
        self.isMDM = IS_MDM;
        self.mediaAuthCheck = MEDIA_AUTH_CHECK;
        self.useTask = USE_TASK;
        self.autoLogin = AUTO_LOGIN;
        self.autoLoginDate = AUTO_LOGIN_DATE;
        self.errorMaxCnt = ERROR_MAX_CNT;
        self.boardInfoIcon = BOARD_INFO_ICON;
        self.simplePwd = SIMPLE_PWD;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.mNewDBVersion forKey:@"DB_VER"];
        [userDefaults synchronize];
        
    }
    return self;
}

@end
