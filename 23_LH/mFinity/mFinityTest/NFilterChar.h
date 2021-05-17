//
//  NFIlterChar.h
//  nFilterChar KeyPad
//
//	Ver.5.3.6
//  Created by NSHC on 2013/07/29
//  Copyright (c) 2013 NSHC. ( http://www.nshc.net )
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "nFilterTypes.h"
#import "NFilterToolbar.h"
#import "NFilterCommon.h"
#import "NFilterCharButton.h"
#import "NFilterToolbar2.h"

typedef NS_ENUM (NSInteger, NFilterFunctionKey)
{
    NFilterFunctionKeyShift,
    NFilterFunctionKeyDel,
    NFilterFunctionKeySpecial,
    NFilterFunctionKeyEng,
    NFilterFunctionKeyReplace
};

typedef NS_ENUM (NSInteger, NFilterKeyAlphaType)
{
    NFilterKeyALPHA_ALL,     //영문 전체
    NFilterKeyALPHA_LOWER,   //영문 소문자
    NFilterKeyALPHA_UPPER    //영문 대문자
};

@protocol NFilterCharDelegate <NSObject>
@optional
- (void)onCustomizeCharKeypadButton:(UIButton *)button;
@end


@interface NFilterChar : UIViewController <NFilterToolbarDelegate> {
	IBOutlet UILabel *lblCursor;                            // 커서
	IBOutlet UILabel *lblInputValue;                        // 입력문자
    
    IBOutlet UILabel *lblBigNum;                            // 풍선문자 (숫자)
    IBOutlet UILabel *lblBigChr;                            // 풍선문자 (문자)
    IBOutlet UILabel *lblBigRandom;                         // 풍선문자 랜덤
    IBOutlet UILabel *lbltopTitle;                          // 상단 타이틀
    IBOutlet UILabel *lbltopBarTitle;                       // 탑바 타이틀
    
	IBOutlet UITextField *txtInSecurity;                    // 입력문자 저장용
    IBOutlet UIView *vwInputDefalt;         // 기본 입력뷰
    
    IBOutlet UIImageView *imgTopBarTitle;
	IBOutlet UIImageView *imgBigNum;                        // 풍선문자이미지 (숫자)
	IBOutlet UIImageView *imgBigChr;                        // 풍선문자이미지 (문자)
	IBOutlet UIImageView *imgBigRadom;                      // 풍선문자이미지 (랜덤)
    
    IBOutlet UIButton *btnShiftkey;                         // shift 버튼
    IBOutlet UIButton *btnReplacekey;                       // 재배열 버튼
    IBOutlet UIButton *btnConfirm;                          // 확인 버튼
    IBOutlet UIButton *btnCancel;                           // 취소 버튼
    IBOutlet UIButton *btnDelete;                           // 삭제 버튼
    IBOutlet UIButton *btnSpace;                            // Space 버튼 
    
    __weak id _pTarget;                    // 타겟
    
    SEL _pMethodOnNext;             // 다음 셀렉터
    SEL _pMethodOnPrev;             // 이전 셀렉터
    SEL _pMethodOnPress;            // 버튼 누름 셀렉터
    SEL _pMethodOnConfirm;          // 확인 셀렉터
	SEL _pMethodOnCancel;           // 취소 셀렉터
    SEL _pMethodOnReArrange;        // 재배열
    SEL _pMethodOnClose;            // 닫기 
    
    NSString *tagName;              // 태그이름
    NSString *title;                // 타이틀
    NSString *barTitle;             // 바타이틀
	NSDictionary *dictKeys;         // 버튼라벨
	NSArray *arrKeys;
	NSInteger lengthLimit;          // 길이한정
    WKWebView *webview;
	NSTimer *tmrCursor;             // 커서 타이머
	UIButton *btnRadnomNum;         // 빈넘버
    
	NKeymodeType _keymodeTypeCurr;  // 키모드
    
	BOOL isStopCursor;              // 커서정지
	BOOL isDeepSecMode;             // 강한보안모드
	BOOL isSuportLandscape;         // 가로모드지원
	BOOL isHideLastValue;           // 마지막 문자 없앰
    BOOL isSuportRotation;          // 회전지원
    BOOL isSuportReplaceTable;      // 치환테이블
    BOOL isNonPlainText;            // 빈문자열
    BOOL isSuportCapslock;          // CapsLock 설정
    BOOL isReadyFixUppercase;       // 대문자 고정모드
    BOOL isFixUppercase;            // 대문자 고정모드
    BOOL isSuportBackgroundEvent;   // 백그라운드 이벤트
    BOOL isFullMode;                // 풀모드 옵션
    BOOL isToolbarHidden;           // 툴바
    BOOL isNoPadding;
    BOOL isNoSound;                 // 사운드
    BOOL isEngMode;                 // 영문모드
    BOOL isDummyData;               // 평문 사용 안함
    BOOL isBackGroundClose;         // 백그라운드 클릭시 종료
    BOOL isSupportFullEnc;          // 평문암호화
    BOOL isSupportLinkage;          // 연동모드
    BOOL isSupportRetinaHD;          // 6,6+ xib 지원
    
    float btnRect;                  // 가로모드 버튼 공백
    float barHeight;                // 바 높이
        
    NSString *OKTxt;
    NSString *CancelTxt;
    NSString *ENTxt;
    NSString *RepTxt;
    NSString *PrevTxt;
    NSString *NextTxt;
}

@property (nonatomic, retain) NSTimer* tmrCursor;
@property (nonatomic, retain) NSMutableString* stringKeyboardType;
@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) NSString *OKTxt;
@property (nonatomic, strong) NSString *CancelTxt;
@property (nonatomic, strong) NSString *ENTxt;
@property (nonatomic, strong) NSString *RepTxt;
@property (nonatomic, strong) NSString *PrevTxt;
@property (nonatomic, strong) NSString *NextTxt;
@property (nonatomic, assign) BOOL useInitialVector;
@property (nonatomic, strong) NFilterToolbar *toolbar;
@property (nonatomic, strong) NFilterToolbar2 *toolbar2;
@property (nonatomic, assign) CGFloat nFilterHeight;                      //  nfilter 높이
@property (nonatomic, assign) CGFloat nFilterHeightForLandscape;          //  nfilter 높이 (iPad 가로 모드)
@property (nonatomic, assign) BOOL okCancelChange; 
@property (nonatomic, strong) UIFont* fontBigChar;          // 문자 키패드 영어 라벨 폰트
@property (nonatomic, strong) UIFont* fontSmallChar;        // 문자 키패드 한글 라벨 폰트
@property (nonatomic, assign) BOOL supportViewRotatation;
@property (nonatomic, strong) UIColor *keyPadBackground;

@property (nonatomic, assign) NFilterMasking Masking;
@property (nonatomic, assign) NFilterAttachType attachType;
@property (nonatomic, assign) id <NFilterCharDelegate> delegate;
@property (nonatomic, assign) BOOL showHanguleText;
@property (nonatomic, assign) BOOL showKeypadBubble;
@property (nonatomic, assign) BOOL allowCloseKeypadConfirmPressed;      // 확인 버튼 눌렀을 경우 keypad 닫을지 여부
@property (nonatomic, strong) IBOutlet UIView *buttonView;
@property (nonatomic, assign) NFilterAESMode AESMode;
@property (nonatomic, assign) BOOL useUserLandscapeHeightInIPad;        // iPad 가로 모드 사용 여부.
@property (nonatomic, assign) int topMaginForIPhoneX;
@property (nonatomic, assign) int bottomMaginForIPhoneX;                // iPhoneX 반키패드 하단 마진 값 설정.
@property (nonatomic, assign) int maginForIPhoneX;                      // iPhoneX 반키패드 좌우 마진 값 설정.
@property (nonatomic, assign) BOOL transparentBottomForIPhoneX;         // iPhoneX 반키패드 하단 투명도 설정.
@property (nonatomic, assign) BOOL useUserKeyPadMode;
@property (nonatomic, assign) NKeymodeType userKeyPadModeType;
@property (nonatomic, assign) BOOL useVoiceOverViaSpreaker;
@property (nonatomic, assign) NSString *closeButtonAccessibilityTxt;    // 반키패드 백그라운드 클릭시 백그라운드 버튼 대체 텍스트 설정


- (IBAction)pressCancel;                                    // 취소버튼
- (IBAction)pressConfirm;                                   // 확인버튼
- (IBAction)touchDownKepad:(id)sender;                      // 키패드누름상태
- (IBAction)pressButton:(id)sender;                         // 키패드 누름
- (IBAction)pressKeypadReload;                              // 재배열버튼
- (IBAction)pressBack;                      // 백버튼

+ (NFilterChar*)charPadShared;
- (void)setRotateToInterfaceOrientation:(UIInterfaceOrientation)tointerfaceOrientation;                                  // 회전지원
- (void)showKeypad:(UIInterfaceOrientation)tointerfaceOrientation parentViewController:(UIViewController*)pParentViewController;
- (void)showKeypadPatronux:(UIInterfaceOrientation)tointerfaceOrientation parentView:(UIView *)parentView code:(NSString *)code;
- (void)clearField;                                          // 키패드 클리어
- (void)closeKeypad;

// 이하 고객지원옵션
- (void)setSupportBackgroundEvent:(BOOL)pYesOrNo;           // 백그라운드 이벤트
- (void)setSupportCapslock:(BOOL)pYesOrNO;                  // Caps Lock 지원모드
- (void)setSupportReplaceTable:(BOOL)pYesOrNO;              // 랜덤넘버
- (void)setHideLastValue:(BOOL)pYesOrNo;                    // 마지막 문자 숨김
- (void)setDeepSecMode:(BOOL)pYesOrNo;                      // 강한보안모드
- (void)setSupportRotation:(BOOL)pYesOrNo;                  // 회전 설정
- (void)setServerPublickey:(NSString *)pServerPublickey;    // 서버공개키설정
- (void)setServerPublickeyURL:(NSString *)pXmlURL;          // 서버공개키 설정(xml)
- (void)setRSAPublicKey:(NSString *)pRSAPublickKey;         // RSA 공개키 설정
- (void)setIsUseRSA:(BOOL)pYesOrNo;                         // RSA를 이용한 외부 연동 방식
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength webView:(WKWebView *)pWebView __attribute__((deprecated("Replaced by setLengthWithTagName:length:"))); // 태그이름 길이 설정
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength;
- (void)setFullMode:(BOOL)pYesOrNo;                         // 풀모드 설정
- (void)setTitleText:(NSString *)ptitle;                    // 타이틀 텍스트 설정
- (void)setTopBarText:(NSString *)bBarTitle;                // 탑바 텍스트 설정
- (void)setNonPlainText:(BOOL)pYesOrNo;                     // 평문없앰
- (void)setNoPadding:(BOOL)pYesOrNo;                        // 패딩없음
- (void)setNoSound:(BOOL)pYesOrNo;                          // 사운드 없앰
- (void)setEngMode:(BOOL)pYesOrNo;                          // 영문모드
- (void)setDummyText:(BOOL)pYesOrNo;                        // 평문 사용 안함
- (void)setSupportBackGroundClose:(BOOL)pYesOrNO;           // 백그라운드 클릭시 종료
- (void)setSupportFullEnc:(BOOL)pYesOrNO;                 // 평문 암호화
- (void)setVerticalFrame:(NSInteger)pYFrame;                // View의 Y축을 조절
- (void)setSupportLinkage:(BOOL)pYesOrNO;                 // 연동모드
- (void)setCoworKerCode:(NSString *)pCoworKerCode;          // CoworKerCode 설정
- (void)setBtnTextWithEngText:(NSString *)pEnText
                      repText:(NSString *)pRepText
                       okText:(NSString *)pOkText
                   cancelText:(NSString *)pCancelText
                     prevText:(NSString *)pPrevText
                     nextText:(NSString *)pNextText;

- (void)setUseSpeakerInVoiceOver:(BOOL)use __attribute__((deprecated("Replaced by setUseVoiceOverViaSpreaker:")));

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
             methodOnPrev:(SEL)pMethodOnPrev
             methodOnNext:(SEL)pMethodOnNext
            methodOnPress:(SEL)pMethodOnPress
        methodOnReArrange:(SEL)pMethodOnReArrange;

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
             methodOnPrev:(SEL)pMethodOnPrev
             methodOnNext:(SEL)pMethodOnNext
            methodOnPress:(SEL)pMethodOnPress;              // 콜백 메소드 설정

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
            methodOnPress:(SEL)pMethodOnPress;              // 콜백 메소드 설정

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
		   methodOnCancel:(SEL)pMethodOnCancel;             // 콜백 메소드 설정

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
           methodOnCancel:(SEL)pMethodOnCancel
            methodOnPress:(SEL)pMethodOnPress;

- (void)setCloseCallbackMethod:(id)pTarget
                 methodOnClose:(SEL)pMethodOnClose;

- (NSString *)getNFilterVer;
- (NKeymodeType)getCurrentKeymode;

- (void)setKeyPadMode:(NKeymodeType)mode;

- (void)performPressKey:(NSString *)key;
- (void)performPressFunctionKey:(NFilterFunctionKey)functionKey;

@property (nonatomic, strong) IBOutlet UIView *viwFullMode;                             // 풀모드 상단
@property (nonatomic, strong) IBOutlet UIView *viwCharPad;                              // 키패드뷰
@property (nonatomic, strong) UIColor *toolTipTextColor;
@property (nonatomic, assign) int keyGap;
@property (nonatomic, assign) BOOL hideRow5;
@property (nonatomic, assign) BOOL enableChangeDelaysTouchesBeganGestureSettingInNFilter;                   // 윈도우 터치지연 제스쳐 On/Off
@property (nonatomic, assign) BOOL isUseResetInit;                                      // 재배열 버튼 사용지 문자열 초기화 설정( Default : YES )
@property (nonatomic, assign) BOOL reactionless;                                        // 키패드 입력시 클릭 무반응 사용 설정( Default : NO )
@property (nonatomic, strong) NSString *SpaceTxt;
@property (nonatomic, strong) UIColor *charBtnTextColor;                                // (iOS 13 대응) 문자 키패드 버튼 텍스트 색상 설정.

//Do Not Use
@property (nonatomic, assign) BOOL focusable; // 전면 모드 Textfield에 포커스 설정

@end
