//
//  NFIlterNum.h
//  nFilterNum KeyPad
//
//	Ver.5.3.6
//  Created by NSHC on 2013/07/29
//  Copyright (c) 2013 NSHC. ( http://www.nshc.net )
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "NFilterToolbar.h"
#import "NFilterToolbar2.h"
#import "NFilterCommon.h"
#import "NFNumInputView.h"

@protocol NFilterNumDelegate <NSObject>
@optional
- (void)onCustomizeButton:(UIButton *)button buttonIndex:(int)index reloadButton:(UIButton *)reloadButton deleteButton:(UIButton *)deleteButton;
- (void)onCustomizeEmptyButton:(UIButton *)button;
@end

@interface NFilterNum : UIViewController <NFilterToolbarDelegate> {
    IBOutlet UIView *vwInputDefalt;         // 기본 입력뷰
    
	IBOutlet UILabel *lblCursor;            // 커서
	IBOutlet UILabel *lblInputValue;        // 마지막 입력문자
    
    IBOutlet UILabel *lbltopTitle;          // 상단 타이틀
    IBOutlet UILabel *lbltopBarTitle;       // 탑바 타이틀
    IBOutlet UIImageView *imgTopBarLogo;    // 상단 로고
    
	IBOutlet UITextField *txtInSecurity;        // 입력문자 저장용
    
	IBOutlet UIButton *keypad1;             // 키패드
	IBOutlet UIButton *keypad2;             // 키패드
	IBOutlet UIButton *keypad3;             // 키패드
	IBOutlet UIButton *keypad4;             // 키패드
	IBOutlet UIButton *keypad5;             // 키패드
	IBOutlet UIButton *keypad6;             // 키패드
	IBOutlet UIButton *keypad7;             // 키패드
	IBOutlet UIButton *keypad8;             // 키패드
	IBOutlet UIButton *keypad9;             // 키패드
	IBOutlet UIButton *keypad0;             // 키패드
    
    
	IBOutlet UIButton *btnReload;           // 재배열 버튼
    IBOutlet UIButton *btnConfirm;                          // 확인 버튼
    IBOutlet UIButton *btnCancel;                           // 취소 버튼
    IBOutlet UIButton *btnToolbarConfirm;                   // 툴바 확인 버튼
    IBOutlet UIButton *btnToolbarPrev;                      // 툴바 이전 버튼
    IBOutlet UIButton *btnToolbarNext;                      // 툴바 다음 버튼
    IBOutlet UIButton *btnBackGroundClose;                  // 하프 모드 시에 백그라운드 클릭시 엔필터 닫힘
    
    __weak id _pTarget;                    // 타겟
    
    SEL _pMethodOnNext;             // 다음 셀렉터
    SEL _pMethodOnPrev;             // 이전 셀렉터
    SEL _pMethodOnPress;            // 버튼 누름 셀렉터
    SEL _pMethodOnConfirm;          // 확인 셀렉터
	SEL _pMethodOnCancel;           // 취소 셀렉터
    SEL _pMethodOnReArrange;        // 재배열
    SEL _pMethodOnDelete;           // 삭제
    SEL _pMethodOnClose;
	
	NSInteger lengthLimit;          // 텍스트 길이
	NSString *tagName;              // 태그 이름
    NSString *title;                // 타이틀
    NSString *barTitle;             // 바타이틀
    NSTimer *tmrCursor;             // 커서타이머
    
	BOOL isStopCursor;              // 커서멈춤
    BOOL isSuportLandscape;         // 가로모드 지원
	BOOL ignoreSuffle;              // 재배열 금지
	BOOL isDeepSecMode;             // 강한보안모드
	BOOL isHideLastValue;           // 마지막 입력값 숨김
    BOOL isNonPlainText;            // 평문없음
    BOOL isFullMode;                // 풀모드 옵션
    BOOL isSupportBackgroundEvent;   // 백그라운드이벤트 지원
    BOOL isNoSound;                 // 사운드
    BOOL isSuportRotation;          // 회전지원
    BOOL isInputBoxForIdentityNum;  // 주민등록번호 옵션
    BOOL isEngMode;                 // 영문모드
    BOOL isDummyData;               // 평문 사용 안함
    BOOL isInputSecurityId;         // 주민등록번호 옵션
    BOOL isBackGroundClose;         // 백그라운드 클릭시 종료
    BOOL isSupportFullEnc;          // 평문암호화
    BOOL isSupportLinkage;          // 연동모드
    BOOL isUseRSA;                  // RSA를 이용한 외부 연동 방식
    
    float barHeight;                // 바 높이
    
    CGFloat nfilterHeight;          //  nfilter 높이
    
    NSString *OKTxt;
    NSString *CancelTxt;
    NSString *RepTxt;
    NSString *PrevTxt;
    NSString *NextTxt;
}

@property (nonatomic, retain) NSTimer* tmrCursor;           // 커서 타이머
@property (nonatomic, strong) NSString* tagName;
@property (nonatomic, assign) float barHeight;                // 바 높이
@property (nonatomic, strong) NSString *OKTxt;
@property (nonatomic, strong) NSString *CancelTxt;
@property (nonatomic, strong) NSString *RepTxt;
@property (nonatomic, strong) NSString *PrevTxt;
@property (nonatomic, strong) NSString *NextTxt;
@property (nonatomic, assign) BOOL useInitialVector;
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) float keyPadHeight;           // 키패드 높이
@property (nonatomic, assign) int bezelLengthOfKeyPad;      // 베젤 두께
@property (nonatomic, assign) int buttonMagin;
@property (nonatomic, strong) UIColor *keyPadBackground;
@property (nonatomic, assign) BOOL isSerialMode;            // 시리얼 모드 여부
@property (nonatomic, strong) NFilterToolbar *toolbar;
@property (nonatomic, strong) NFilterToolbar2 *toolbar2;
@property (nonatomic, strong) NFilterToolbar2 *toolbar2Serial;   
@property (nonatomic, strong) UIImage *emptyImage;
@property (nonatomic, strong) IBOutlet UIView *buttonView;
@property (nonatomic, strong) IBOutlet UIView *viwNumbPad;            // 숫자패드 뷰
@property (nonatomic, assign) id <NFilterNumDelegate> delegate;
@property (nonatomic, assign) BOOL supportViewRotatation;
@property (nonatomic, assign) NFilterMasking Masking;
@property (nonatomic, assign) NFilterAttachType attachType;
@property (nonatomic, assign) BOOL NoPadding;
@property (nonatomic, assign) BOOL allowCloseKeypadConfirmPressed;      // 확인 버튼 눌렀을 경우 keypad 닫을지 여부
@property (nonatomic, assign) BOOL enableChangeDelaysTouchesBeganGestureSettingInNFilter;   // 윈도우 터치지연 제스쳐 On/Off
@property (nonatomic, assign) NFilterAESMode AESMode;
@property (nonatomic, assign) BOOL useCustumEditViewLayout;
@property (nonatomic, assign) NFInputType custumEditViewLayoutType;
@property (nonatomic, assign) BOOL useVoiceOverViaSpreaker;
@property (nonatomic, assign) BOOL focusable; // 전면 모드 Textfield에 포커스 설정
@property (nonatomic, assign) int bottomMaginForIPhoneX;                // iPhoneX 반키패드 하단 마진 값 설정.
@property (nonatomic, assign) int maginForIPhoneX;                      // iPhoneX 반키패드 좌우 마진 값 설정.
@property (nonatomic, assign) BOOL transparentBottomForIPhoneX;         // iPhoneX 반키패드 하단 투명도 설정.
@property (nonatomic, assign) BOOL reactionless;                        // 키패드 입력시 클릭 무반응 사용 설정( Default : NO )
@property (nonatomic, assign) BOOL isUseResetInit;                      // 재배열 선택시 데이터 초기화 옵션 설정(랜덤 숫자 키패드는제공 안함)
@property (nonatomic, assign) NSString *closeButtonAccessibilityTxt;    // 반키패드 백그라운드 클릭시 백그라운드 버튼 대체 텍스트 설정
@property (nonatomic, assign) NSString *deleteBtnAccessibilityTxt;      // 시리얼키패드 삭제 버튼 대체 텍스트 설정
@property (nonatomic, assign) NSString *emptyBtnAccessibilityTxt;       // 시리얼키패드 Empty 버튼 대체 텍스트 설정
@property (nonatomic, assign) BOOL useUserLandscapeHeightInIPad;        // iPad 가로 모드 사용 여부.
@property (nonatomic, assign) CGFloat nFilterHeightForLandscape;        //  nfilter 높이 (iPad 가로 모드)
@property (nonatomic, assign) BOOL okCancelChange; 
@property (nonatomic, assign) BOOL hiddenReload;                        // 숫자 키패드 재배열 버튼 Hidden 설정
- (IBAction)pressCancel;                    // 취소
- (IBAction)pressConfirm;                   // 확인
- (IBAction)onBtnPrev:(id)sender;           // 이전
- (IBAction)onBtnNext:(id)sender;           // 다음
- (IBAction)pressButton:(id)sender;         // 버튼 누르기
- (IBAction)pressBack;                      // 백버튼
- (IBAction)pressKeypadReload;              // 재배열
- (IBAction)pressBackGround:(id)sender;     // 백그라운드 클릭

// show for trans
+ (NFilterNum*)numPadShared;                //싱글톤
- (void)showKeypad:(UIInterfaceOrientation)tointerfaceOrientation parentViewController:(UIViewController*)pParentViewController;
- (void)showKeypad:(UIInterfaceOrientation)tointerfaceOrientation parentView:(UIView*)pParentView;
- (void)showKeyPatronux:(UIInterfaceOrientation)tointerfaceOrientation parentView:(UIView*)pParentView;
- (void)showKeyPopup:(UIInterfaceOrientation)tointerfaceOrientation parentView:(UIView*)pParentView;



- (void)clearField;                                         // 필드클리어
- (void)closeKeypad;

// 이하 고객지원 옵션
- (void)setSupportBackgroundEvent:(BOOL)pYesOrNo;           // 백그라운드 이벤트 설정
- (void)setDeepSecMode:(BOOL)pYesOrNo;                      // 강한 보한 모드 설정
- (void)setSupportRotation:(BOOL)pYesOrNo;                  // 회전 설정
- (void)setIgnoreSuffle:(BOOL)pIgnoreSuffle;                // 셔플안함 설정
- (void)setServerPublickey:(NSString *)pServerPublickey;    // 서버공개키 설정
- (void)setServerPublickeyURL:(NSString *)pXmlURL;          // 서버공개키 설정(xml)
- (void)setRSAPublicKey:(NSString *)pRSAPublickKey;         // RSA 공개키 설정
- (void)setIsUseRSA:(BOOL)pYesOrNo;                         // RSA를 이용한 외부 연동 방식
- (void)setFullMode:(BOOL)pYesOrNo;                         // 풀모드 설정
- (void)setTitleText:(NSString *)ptitle;                    // 타이틀 텍스트 설정
- (void)setTopBarText:(NSString *)bBarTitle;                // 탑바 텍스트 설정
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength webView:(WKWebView *)pWebView;            // 태그이름,길이 설정
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength;
- (void)setNonPlainText:(BOOL)pYesOrNo;                     // 평문없앰 설정
- (void)setNoSound:(BOOL)pYesOrNo;                          // 사운드 없앰
- (void)setSupportIdentityNum:(BOOL)pYesOrNo;
- (void)setSupportIdentityId:(BOOL)pYesOrNo;                // 주민등록번호
- (void)setEngMode:(BOOL)pYesOrNo;                          // 영문모드
- (void)setDummyText:(BOOL)pYesOrNo;                        // 평문 사용 안함
- (void)setSupportBackGroundClose:(BOOL)pYesOrNO;           // 백그라운드 클릭시 종료
- (void)setSupportFullEnc:(BOOL)pYesOrNO;                 // 평문 암호화
- (void)setVerticalFrame:(NSInteger)pYFrame;                // View의 Y축을 조절
- (void)setSupportLinkage:(BOOL)pYesOrNO;                   // 연동모드
- (void)setCoworKerCode:(NSString *)pCoworKerCode;          // CoworKerCode 설정
- (void)setBtnTextWithRepText:(NSString *)pRepText
                       okText:(NSString *)pOkText
                   cancelText:(NSString *)pCancelText
                     prevText:(NSString *)pPrevText
                     nextText:(NSString *)pNextText;

- (void)setUseSpeakerInVoiceOver:(BOOL)use __attribute__((deprecated("Replaced by setUseVoiceOverViaSpreaker:")));

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
             methodOnPrev:(SEL)pMethodOnPrev
             methodOnNext:(SEL)pMethodOnNext
            methodOnPress:(SEL)pMethodOnPress;

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
            methodOnPress:(SEL)pMethodOnPress;

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
		   methodOnCancel:(SEL)pMethodOnCancel;

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
           methodOnCancel:(SEL)pMethodOnCancel
            methodOnPress:(SEL)pMethodOnPress;

- (void)setCallbackMethod:(id)pTarget
          methodOnConfirm:(SEL)pMethodOnConfirm
             methodOnPrev:(SEL)pMethodOnPrev
             methodOnNext:(SEL)pMethodOnNext
            methodOnPress:(SEL)pMethodOnPress
        methodOnReArrange:(SEL)pMethodOnReArrange;

- (void)setCallbackMethod:(id)pTarget
           methodOnDelete:(SEL)pMethodOnDelete;

- (void)setCloseCallbackMethod:(id)pTarget
                 methodOnClose:(SEL)pMethodOnClose;

- (NSString *)getNFilterVer;

@end
