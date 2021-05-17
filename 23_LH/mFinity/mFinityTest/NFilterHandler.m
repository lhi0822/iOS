//
//  NFilterHandler.m
//  mFinity
//
//  Created by hilee on 2021/05/11.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import "NFilterHandler.h"

@implementation NFilterHandler

- (instancetype)init{
    self = [super init];
    NSLog(@"%s", __func__);
    
    _isCustomKeypad = YES; //NO;
    _isSupportLandscape = NO;
    _isCloseKeypad = YES;
    
    
    return self;
}

- (void)showCharKeyForFullMode
{
    if (self.numPad != nil) {
        [self.numPad.view removeFromSuperview];
        self.numPad = nil;
    }
    
    if (self.charPad != nil) {
        [self.charPad.view removeFromSuperview];
        self.charPad = nil;
    }
    
    self.charPad = [[NFilterChar alloc] initWithNibName:@"NFilterChar" bundle:nil];
    self.charPad.useInitialVector = YES;
    [self.charPad setServerPublickey:@"MDIwGhMABBYCBEsAMWHtqFKFE9xK+8OWdHVjeXSQBBTlmbbw1STxAJoZXHDu2Uyj8drXTg=="];   // 더미용 공개키입니다 자사의 공개키로 바꿔주세요
    
    [self.charPad setCallbackMethod:self
                               methodOnConfirm:@selector(onConfirmNFilter:encText:dummyText:tagName:)
                                  methodOnPrev:@selector(onPrevNFilter:encText:dummyText:tagName:)
                                  methodOnNext:@selector(onNextNFilter:encText:dummyText:tagName:)
                                 methodOnPress:@selector(onPressNFilter:encText:dummyText:tagName:)
                             methodOnReArrange:@selector(onReArrangeNFilter)
     ];
    
    [self.charPad setLengthWithTagName:@"encdata2" length:16];
    [self.charPad setFullMode:YES];
    [self.charPad setTopBarText:@"nFilter 문자키"];
    [self.charPad setTitleText:@"문자를 입력하세요."];
    [self.charPad setNoPadding:NO];
    [self.charPad setSupportBackgroundEvent:YES];
    [self.charPad setSupportViewRotatation:_isSupportLandscape];
    [self.charPad setMasking:NFilterMaskingDefault];
    [self.charPad setAttachType:NFilterAttachViewController];
    [self.charPad setShowHanguleText:NO];
    [self.charPad setNFilterHeight:250];
    [self.charPad setSupportBackGroundClose:NO];
    [self.charPad setDeepSecMode:NO];
    [self.charPad setUseVoiceOverViaSpreaker:YES];
    [self.charPad setAllowCloseKeypadConfirmPressed:_isCloseKeypad];
    
    // 아이패드인 경우
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self.charPad setShowKeypadBubble:NO];
    }

    if (_isCustomKeypad == YES)
        self.charPad.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.charPad setVerticalFrame:0];
    } else {
        [self.charPad setVerticalFrame:20];
    }
    [self.charPad showKeypad:[UIApplication sharedApplication].statusBarOrientation parentViewController:self];
}

- (void)showCharKeyForViewMode
{
    NSLog(@"%s", __func__);

    if (self.numPad != nil) {
        [self.numPad.view removeFromSuperview];
        self.numPad = nil;
    }
    
    if (self.charPad != nil) {
        [self.charPad.view removeFromSuperview];
        self.charPad = nil;
    }
    
    self.charPad = [[NFilterChar alloc] initWithNibName:@"NFilterChar" bundle:nil];
    self.charPad.useInitialVector = YES;
    [self.charPad setServerPublickey:@"MDIwGhMABBYCBEsAMWHtqFKFE9xK+8OWdHVjeXSQBBTlmbbw1STxAJoZXHDu2Uyj8drXTg=="];   // 더미용 공개키입니다 자사의 공개키로 바꿔주세요
    [self.charPad setCallbackMethod:self
                    methodOnConfirm:@selector(onConfirmNFilter:encText:dummyText:tagName:)
                       methodOnPrev:@selector(onPrevNFilter:encText:dummyText:tagName:)
                       methodOnNext:@selector(onNextNFilter:encText:dummyText:tagName:)
                      methodOnPress:@selector(onPressNFilter:encText:dummyText:tagName:)
                  methodOnReArrange:@selector(onReArrangeNFilter)
     ];
    [self.charPad setCloseCallbackMethod:self methodOnClose:@selector(onCloseNFilter:encText:dummyText:tagName:)];
    
    [self.charPad setLengthWithTagName:@"encdata2" length:64];
    [self.charPad setFullMode:NO];
    [self.charPad setNoPadding:NO];
    [self.charPad setSupportBackgroundEvent:NO];
    [self.charPad setSupportBackGroundClose:YES];
    [self.charPad setSupportViewRotatation:_isSupportLandscape];
    [self.charPad setMasking:NFilterMaskingDefault];
    [self.charPad setAttachType:NFilterAttachViewController];
    [self.charPad setShowHanguleText:YES];
    [self.charPad setNFilterHeight:250];
    [self.charPad setDeepSecMode:NO];
    [self.charPad setUseVoiceOverViaSpreaker:YES];
    [self.charPad setAllowCloseKeypadConfirmPressed:_isCloseKeypad];
    [self.charPad setBottomMaginForIPhoneX:40];
    [self.charPad setMaginForIPhoneX:40];
    [self.charPad setTransparentBottomForIPhoneX:YES];
    [self.charPad setSupportLinkage:NO];
    
    // 아이패드인 경우
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.charPad setShowKeypadBubble:NO];
    }
    
    if (_isCustomKeypad == YES) self.charPad.delegate = self;
    

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.charPad setVerticalFrame:0];
    } else {
        [self.charPad setVerticalFrame:20];
    }

    if (_isCustomKeypadToolbar) {
        self.charPad.toolbar2 = [self createNFilterToolbarForCustom];
        self.charPad.toolbar2.delegate = self;
    } else {
        self.charPad.toolbar2 = [self createNFilterToolbarForChar];
        self.charPad.toolbar2.delegate = self;
    }
    
    UIViewController *vc = [[UIApplication sharedApplication].keyWindow rootViewController];
//    UIViewController *vc = [[UIApplication sharedApplication].delegate.window rootViewController];
    [self.charPad showKeypad:[UIApplication sharedApplication].statusBarOrientation parentViewController:vc];
    
//    [self.charPad showKeypad:[UIApplication sharedApplication].statusBarOrientation parentViewController:self];

    //    [self.delegate returnKeyPad:self.charPad];
}

#pragma mark -
#pragma mark NFilter toolbar callback 함수

- (void) NFilterToolbarButtonClick:(NFilterButtonType)buttonType withButton :(UIButton *)button
{
    if (self.numPad != nil)
    {
        if (buttonType == NFilterButtonTypeReplace)
            [self.numPad pressKeypadReload];
        else if (buttonType == NFilterButtonTypeOK)
            [self.numPad pressConfirm];
        else if (buttonType == NFilterButtonTypeDelete)
            [self.numPad pressBack];
        else if (buttonType == NFilterButtonTypeNext)
            NSLog(@"이전 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypePrev)
            NSLog(@"다음 작업 처리를 하세요.");
    }
    else if (self.charPad != nil)
    {
        if (buttonType == NFilterButtonTypeNext)
            NSLog(@"이전 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypeOK)
            [self.charPad pressConfirm];
        else if (buttonType == NFilterButtonTypePrev)
            NSLog(@"다음 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypeReplace)
             [self.charPad pressKeypadReload];
        else if (buttonType == NFilterButtonTypeDelete)
            [self.charPad pressBack];
        
    }
}

#pragma mark -
#pragma mark NFilter 키패드 callback 함수
- (void)onReArrangeNFilter
{
    
}

/*--------------------------------------------------------------------------------------
 엔필터 '이전' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onPrevNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName {
    NSLog(@"이전버튼 눌림");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
}

/*--------------------------------------------------------------------------------------
 엔필터 '다음' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onNextNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"다음버튼 눌림");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
}

/*--------------------------------------------------------------------------------------
 엔필터 '키' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onPressNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 키눌림");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
}

/*--------------------------------------------------------------------------------------
 엔필터 '확인' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onConfirmNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 닫힘");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);

    // allowCloseKeypadConfirmPressed 속성이 NO여서 키패드가 안닫힐때 내려가게하고 싶으면 아래와 같이 closeKeypad를 호출하면 키패드가 내려갑니다.
    [self.charPad closeKeypad];
}

/*--------------------------------------------------------------------------------------
 엔필터 '취소' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onCancelNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 닫힘 : onCancelNFilter");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
}


/*--------------------------------------------------------------------------------------
 엔필터 '취소' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onCancel {
    NSLog(@"엔필터 닫힘");
}

/*--------------------------------------------------------------------------------------
 엔필터 'Background Close'동작할때 발생하는 콜백 함수
 ---------------------------------------------------------------------------------------*/
- (void)onCloseNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 닫힘 : onCloseNFilter");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
}


- (NFilterToolbar2 *)createNFilterToolbarForChar
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    NFilterToolbar2 *toolbar = [[NFilterToolbar2 alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 44)];
//    NFilterToolbar2 *toolbar = [[NFilterToolbar2 alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 44)];
    toolbar.backgroundColor = UIColorFromRGB(0xebebeb);
    
    // 이전
    NFilterButton2 *toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, 80, 42)];
    UIButton *btn = toolbarButton.button;
    [btn setTitle:@"이전" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[SampleUtils imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    toolbarButton.nFilterbuttonType = NFilterButtonTypePrev;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(4, 4, 0, 4);
    toolbarButton.dock = NFDockTypeLeft;
    
    [toolbar addToolbarButton:toolbarButton];
    
    // 다음
    toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, 80, 42)];
    btn = toolbarButton.button;
    [btn setTitle:@"다음" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[SampleUtils imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    toolbarButton.nFilterbuttonType = NFilterButtonTypeNext;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(4, 4, 0, 4);
    toolbarButton.dock = NFDockTypeLeft;
    
    [toolbar addToolbarButton:toolbarButton];
    
    // 확인
    toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, 80, 42)];
    btn = toolbarButton.button;
    [btn setTitle:@"확인" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[SampleUtils imageFromColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    toolbarButton.nFilterbuttonType = NFilterButtonTypeOK;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(4, 4, 4, 4);
    toolbarButton.dock = NFDockTypeRight;
    
    [toolbar addToolbarButton:toolbarButton];
    
    toolbar.align = NFilterToolbarAlignTop;
    return toolbar;
}

- (NFilterToolbar2 *)createNFilterToolbarForCustom
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    NFilterToolbar2 *toolbar = [[NFilterToolbar2 alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 56)];
//    NFilterToolbar2 *toolbar = [[NFilterToolbar2 alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 56)];
    toolbar.backgroundColor = UIColorFromRGB(0xE4EFF7);
    
    // 버튼 색상 적용 (재배열 bg = F2F7FB   재배열 pressed bg = C7CED3, 확인 bg = 1857A6   확인 pressed bg = 114694)
    UIImage *image = [SampleUtils imageFromColor:UIColorFromRGB(0xF2F7FB)];
    UIImage *image_bg = [SampleUtils imageFromColor:UIColorFromRGB(0xC7CED3)];
    UIImage *imageEnter = [SampleUtils imageFromColor:UIColorFromRGB(0x1857A6)];
    UIImage *imageEnter_Enter  = [SampleUtils imageFromColor:UIColorFromRGB(0x114694)];
    
    // 버튼 넓이 적용
//    int width = (self.view.frame.size.width - 12 - 3 - 3 - 12 )/3; // (단말 width - 각각 마진값 ) /3
    int width = (screenWidth - 12 - 3 - 3 - 12 )/3; // (단말 width - 각각 마진값 ) /3
    
    // 재배열
    NFilterButton2 *toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, width, 42)];
    UIButton *btn = toolbarButton.button;
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:UIColorFromRGB(0x333333)forState:UIControlStateNormal];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:image_bg forState:UIControlStateHighlighted];
    //nFilterbuttonType3 에서만 해당 옵션 설정되며, nFilterbuttonType3 호출 전에 설정해야 됨.
    toolbarButton.nFilterButtonTextLanguage = NFilterButtonTextEn;
    toolbarButton.nFilterbuttonType3 = NFilterButtonTypeReplace;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(12, 4, 0, 4);
    toolbarButton.dock = NFDockTypeLeft;
    
    [toolbar addToolbarButton:toolbarButton];
    
    // 삭제
    toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, width, 42)];
    btn = toolbarButton.button;
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:UIColorFromRGB(0x333333)forState:UIControlStateNormal];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:image_bg forState:UIControlStateHighlighted];
    //nFilterbuttonType3 에서만 해당 옵션 설정되며, nFilterbuttonType3 호출 전에 설정해야 됨.
    toolbarButton.nFilterButtonTextLanguage = NFilterButtonTextEn;
    toolbarButton.nFilterbuttonType3 = NFilterButtonTypeDelete;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(3, 4, 0, 4);
    toolbarButton.dock = NFDockTypeLeft;
    
    [toolbar addToolbarButton:toolbarButton];
    
    // 확인
    toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, width, 42)];
    btn = toolbarButton.button;
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:imageEnter forState:UIControlStateNormal];
    [btn setBackgroundImage:imageEnter_Enter forState:UIControlStateHighlighted];
    //nFilterbuttonType3 에서만 해당 옵션 설정되며, nFilterbuttonType3 호출 전에 설정해야 됨.
    toolbarButton.nFilterButtonTextLanguage = NFilterButtonTextEn;
    toolbarButton.nFilterbuttonType3 = NFilterButtonTypeOK;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(3, 4, 12, 4);
    toolbarButton.dock = NFDockTypeLeft;
    
    [toolbar addToolbarButton:toolbarButton];
    
    toolbar.align = NFilterToolbarAlignBottom;
    return toolbar;
}


@end
