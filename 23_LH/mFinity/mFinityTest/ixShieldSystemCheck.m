//
//  ixShieldSystemCheck.m
//  mFinity
//
//  Created by hilee on 2021/03/31.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import "ixShieldSystemCheck.h"

@implementation ixShieldSystemCheck

- (void)dealloc {
    NSLog( @"ixShieldSystemCheck - dealloc" );
}

- (id)init {
    self = [super init];
    if (self) {
        //개발시에 사용하는 옵션으로 상용 배포시에 필히 삭제하여야 한다.
        ix_set_debug();
        [self systemCheck];
    }
    return self;
}

#pragma mark 1. 시스템 체크 진행
-(void)systemCheck{
    NSLog(@"%s",__func__);
    UIViewController *viewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ( viewController.presentedViewController ) {
        viewController = viewController.presentedViewController;
    }
    
    // 시스템 검사 API의 경우 Objective-C를 타켓으로 하는 Hooking Tool 에 의한 메소드 우회를 방지하기 위해 아래의 사항을 권장합니다.
    // 1. 별도의 Objectivce-C 메소드로 재구현하지 않고 C API 그대로 사용
    // 2. 호출 시점은 비즈니스 로직상 반드시 수행되야하는 위치에서 호출
    //  ( 예, 어플리케이션 실행 초기 서버와의 데이터 통신을 하는 메소드 )
    struct ix_detected_pattern *patternInfo;
    int ret = ix_sysCheckStart(&patternInfo);

//    "ixShield_error_title" = "보안 알림";
//    "ixShield_error_msg" = "에러가 발생했습니다.\n관리자에게 문의 바랍니다.\n(Error Code : %d)";
//    "ixShield_alert_msg" = "시스템 변조 및 악성 파일을 탐지하였습니다.\n보안정책에 의거하여 앱을 종료해주시기 바랍니다.";
    
    if (ret != 1) {
        // System Check Error
        // 보안정책 위반 상황이 아니라 시스템 체크 에러 상황입니다.
        // 즉 에러코드의 상황으로 각 기능 검사가 정상적으로 수행되지 않은 경우이니 그에 맞는 문구로 개별 표현해 주시기 바랍니다.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:[NSString stringWithFormat:NSLocalizedString(@"ixShield_error_msg", @"ixShield_error_msg"), ret] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                                
                                                         }];
        [alert addAction:okButton];
        
        
        [viewController presentViewController:alert animated:YES completion:nil];

    }else {
        NSString *jbCode = [NSString stringWithUTF8String:patternInfo->pattern_type_id];

        if ([jbCode isEqualToString:@"0000"]) {
            NSLog(@"[ixShield(AV)] System OK");
            //다음 진행하면됨
            [self integrityCheck];
        }
        
        else if ([[jbCode substringToIndex:1] isEqualToString:@"H"]) {
            // Hooking Tool이 탐지될 경우 jbCode가 H로 시작합니다.
            // Hooking Tool에 대한 탐지 시 어플리케이션 종료를 권고합니다.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:NSLocalizedString(@"ixShield_alert_msg", @"ixShield_alert_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                //다음 진행하거나 앱 종료
                                                             }];
            [alert addAction:okButton];
            [viewController presentViewController:alert animated:YES completion:nil];
            
        } else {
            // Error code Check and App Exit.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:NSLocalizedString(@"ixShield_alert_msg", @"ixShield_alert_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                //다음 진행하거나 앱 종료
                                                             }];
            [alert addAction:okButton];
            [viewController presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"[ixShield(AV)] %@", [NSString stringWithFormat:@"Jail break %@",[NSString stringWithUTF8String:patternInfo->pattern_type_id]]);
        }
    }
}

#pragma mark 2. 무결성 검사 진행 (위변조)
-(void)integrityCheck{
    UIViewController *viewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ( viewController.presentedViewController ) {
        viewController = viewController.presentedViewController;
    }
    
    struct ix_init_info initInfo; // 초기값 및 옵션 셋팅
    struct ix_verify_info verifyInfo; //결과 값
    
    initInfo.integrity_type = IX_INTEGRITY_LOCAL;
    int ret = ix_integrityCheck(&initInfo, &verifyInfo);
    
    NSString *verifyResult = [NSString stringWithCString:verifyInfo.verify_result encoding:NSUTF8StringEncoding];
    NSString *verifyData = [NSString stringWithCString:verifyInfo.verify_data encoding:NSUTF8StringEncoding];
    
    NSLog(@"verifyResult : %@", verifyResult);
    NSLog(@"verifyData : %@", verifyData);
    
    if (ret != 1) // 무결성 검사가 실패한 경우
    {
        // Integrity Check Error
        // 보안정책 위반 사항이 아니라 무결성 검사 에러 상황입니다.
        // 즉 에러코드의 상황으로 각 기능 검사가 정상적으로 수행되지 않은 경우이니 그에 맞는 문구로 개별 표현해 주시기 바랍니다.
        
        // 무결성 검사가 실패한 경우에 검사가 실패한 사유를 verfiyData로 확인 가능합니다.
        // 하기의 UIAlertView는 샘플 어플리케이션에서 결과를 표현하기 위한 예시로 정책에 맞는 구현을 하시면 됩니다.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:[NSString stringWithFormat:NSLocalizedString(@"ixShield_error_msg", @"ixShield_error_msg"), ret] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                                
                                                         }];
        [alert addAction:okButton];
        
        
        [viewController presentViewController:alert animated:YES completion:nil];
        
    }
    else {
        // 무결성 검사가 성공한 경우 무결성 훼손 여부를 확인해야 합니다.
        if([verifyResult isEqualToString:@VERIFY_SUCC]) {
            // 무결성이 훼손되지 않은 경우에 대한 처리(verifyResult : "VERIFY_SUCC")
            // 하기의 UIAlertView는 샘플 어플리케이션에서 결과를 표현하기 위한 예시로 정책에 맞는 구현을 하시면 됩니다.
            
            //다음으로 이동
        }
        else
        {
            // 무결성이 훼손된 경우에 대한 처리(verifyResult : "VERIFY_FAIL")
            // 하기의 UIAlertView는 샘플 어플리케이션에서 결과를 표현하기 위한 예시로 정책에 맞는 구현을 하시면 됩니다.
            // 주의 : verfiyResult 값이 "VERIFY_SIM"인 경우 시뮬레이터에서 테스트하여 발생한 것으로 실제 단말에 테스트가 필요합니다.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:[NSString stringWithFormat:NSLocalizedString(@"ixShield_error_msg", @"ixShield_error_msg"), ret] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    
                                                             }];
            [alert addAction:okButton];
            
            
            [viewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

-(void)antiDebugCheck{
    int ret = ix_runAntiDebugger();
    //0 : 탐지 안됨 (iX_FALSE)
    //1 : 탐지 됨 (iX_TRUE)
    if (ret != 1) {
        if(ret == 0) {
            NSLog(@"[ixShield(AV)] Not Used Debugger!");
        }
        else {
            NSLog(@"[ixShield(AV)] %@", [NSString stringWithFormat:@"error code : %d", ret]);
        }
    }
    else {
        NSLog(@"[ixShield(AV)] Detected Debugger!");
    }
}
@end
