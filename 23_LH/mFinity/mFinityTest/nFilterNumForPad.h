//
//  NFIlterNum.h
//  nFilterNum KeyPad
//
//  Created by NSHC on 2013/07/29
//  Copyright (c) 2013 NSHC. ( http://www.nshc.net )
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "NFilterCommon.h"

@interface nFilterNumForPad : UIViewController {
    IBOutlet UIView *viwToolbar;            // 툴바 뷰
    IBOutlet UIView *viwFullMode;           // 풀모드 상단
    IBOutlet UILabel *lblCursor;            // 커서
    
    IBOutlet UILabel *lblInputValue;        // 마지막 입력문자
    IBOutlet UITextField *txtInSecurity;    // 입력문자 저장용
    
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
    
    IBOutlet UIButton *btnReplacekey;                       // 재배열 버튼
    IBOutlet UIButton *btnConfirm;                          // 확인 버튼
    IBOutlet UIButton *btnCancel;                           // 취소 버튼
    IBOutlet UIButton *btnToolbarPrev;                      // 툴바 이전 버튼
    IBOutlet UIButton *btnToolbarNext;                      // 툴바 다음 버튼
    
    id _pTarget;                    // 타겟
    
    SEL _pMethodOnNext;             // 다음 셀렉터
    SEL _pMethodOnPrev;             // 이전 셀렉터
    SEL _pMethodOnPress;            // 버튼 누름 셀렉터
    SEL _pMethodOnConfirm;          // 확인 셀렉터
    SEL _pMethodOnCancel;           // 취소 셀렉터
    
    NSInteger lengthLimit;          // 텍스트 길이
    NSString *tagName;              // 태그 이름
    NSTimer *tmrCursor;             // 커서타이머
    NSTimer *tmrMasking;            // LastInputValue 마스킹 타이머
    UIButton *btnRadnomNum;         // 랜덤버튼
    NSArray *arrGapByEcc;
    
    BOOL isStopCursor;              // 커서멈춤
    BOOL isSuportLandscape;         // 가로모드 지원
    BOOL isLandscapeMode;           // 회전지원
    BOOL ignoreSuffle;              // 재배열 금지
    BOOL isDeepSecMode;             // 강한보안모드
    BOOL isHideLastValue;           // 마지막 입력값 숨김
    BOOL isNonPlainText;            // 평문없음
    BOOL isFullMode;                // 풀모드 옵션
    BOOL isSuportBackgroundEvent;   // 백그라운드이벤트 지원
    BOOL isToolbarHidden;           // 툴바
    BOOL isNoSound;                 // 사운드
    BOOL isSuportRotation;          // 회전지원
    BOOL isEngMode;                 // 영문모드
    BOOL isDummyData;               // 평문 사용 안함
    BOOL isSupportFullEnc;          // 평문암호화
    BOOL isSupportLinkage;          // 연동모드
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSString *OKTxt;
    NSString *CancelTxt;
    NSString *RepTxt;
    NSString *PrevTxt;
    NSString *NextTxt;
}

@property (nonatomic, retain) NSTimer* tmrCursor;           // 커서 타이머
@property (nonatomic, retain) NSTimer* tmrMasking;
@property (nonatomic, strong) NSString* tagName;
@property (nonatomic, strong) NSString *OKTxt;
@property (nonatomic, strong) NSString *CancelTxt;
@property (nonatomic, strong) NSString *RepTxt;
@property (nonatomic, strong) NSString *PrevTxt;
@property (nonatomic, strong) NSString *NextTxt;

@property (nonatomic, strong) IBOutlet UIView *keypadView;
@property (nonatomic, assign) BOOL isSerialMode;            // 시리얼 모드 여부
@property (nonatomic, assign) BOOL NoPadding;
@property (nonatomic, assign) NFilterAESMode AESMode;

- (IBAction)pressCancel;                    // 취소
- (IBAction)pressConfirm;                   // 확인
- (IBAction)onBtnPrev:(id)sender;           // 이전
- (IBAction)onBtnNext:(id)sender;           // 다음
- (IBAction)pressButton:(id)sender;         // 버튼 누르기
- (IBAction)pressBack;                      // 백버튼
- (IBAction)pressKeypadReload;              // 재배열

// show for trans
+ (nFilterNumForPad*)nFilterNumForiPad;                        //싱글톤
- (void)setRotateToInterfaceOrientation:(UIInterfaceOrientation)tointerfaceOrientation parentView:(UIView*)pParentView;  // 회전지원
- (void)clearField;                                         // 필드클리어
- (void)closeNFilter;                                       // nFilter 닫기

// 이하 고객지원 옵션
- (void)setSupportBackgroundEvent:(BOOL)pYesOrNo;           // 백그라운드 이벤트 설정
- (void)setDeepSecMode:(BOOL)pYesOrNo;                      // 강한 보한 모드 설정
- (void)setSupportLandscape:(BOOL)pYesOrNo;                 // 가로모드 설정
- (void)setIgnoreSuffle:(BOOL)pIgnoreSuffle;                // 셔플안함 설정
- (void)setServerPublickey:(NSString *)pServerPublickey;    // 공개키 설정
- (void)setServerPublickeyURL:(NSString *)pXmlURL;          // 서버공개키 설정(xml)
- (void)setFullMode:(BOOL)pYesOrNo;                         // 풀모드 설정
- (void)setToolBar:(BOOL)pYesOrNo;                          // 툴바 설정
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength webView:(WKWebView *)pWebView __attribute__((deprecated)); // 태그이름 길이 설정
- (void)setLengthWithTagName:(NSString *)pTagName length:(NSInteger)pLength;
- (void)setNonPlainText:(BOOL)pYesOrNo;                     // 평문없앰 설정
- (void)setNoSound:(BOOL)pYesOrNo;                          // 사운드 없앰
- (void)setEngMode:(BOOL)pYesOrNo;                          // 영문모드
- (void)setDummyText:(BOOL)pYesOrNo;                        // 평문 사용 안함
- (void)setSupportFullEnc:(BOOL)pYesOrNO;                   // 평문 암호화
- (void)setSupportLinkage:(BOOL)pYesOrNO;                   // 연동모드
- (void)setVerticalFrame:(NSInteger)pYFrame;                // View의 Y축을 조절
- (NSString *)getNFilterVer;
- (void)setBtnTextWithRepText:(NSString *)pRepText
                       okText:(NSString *)pOkText
                   cancelText:(NSString *)pCancelText
                     prevText:(NSString *)pPrevText
                     nextText:(NSString *)pNextText;

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

@end
