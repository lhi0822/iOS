//
//  DetectTouchWindow.m
//  mfinity_sns
//
//  Created by hilee on 2020/08/05.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "DetectTouchWindow.h"
#import "MFUtil.h"

@implementation DetectTouchWindow

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event]; // 타이머 재설정 횟수를 줄이기 위해 시작 터치 또는 종료 터치에서만 타이머를 재설정.
    NSSet *allTouches = [event allTouches]; // 눌렀을때 1, 누르고 손가락을 땔때 resetIdleTimer 를 호출한다.
//    NSLog(@"sendEvent : %lu" , (unsigned long)[allTouches count]);
    if ([allTouches count] > 0) {
        //allTouches 수는 1로만 계산되므로 anyObject가 여기에서 작동합니다.
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan || phase == UITouchPhaseEnded)
            [self resetIdleTimer];
    }
}


//터치가 되면 호출되는 함수 - 터치 중
- (void)resetIdleTimer {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([appDelegate.sessionFlag isEqualToString:@"Y"]){
        if(sessionTask){
//            NSLog(@"세션테스크가 있다");
//            [[UIApplication sharedApplication] endBackgroundTask:sessionTask];
//            sessionTask = UIBackgroundTaskInvalid;
        }
        
//        NSLog(@"idleTimer : %@", _idleTimer);
        if (_idleTimer) {
//            NSLog(@"DetectTouchWindow - 터치가 감지되는 중...");
            [_idleTimer invalidate]; //타이머 제거 = 타이머 초기화
        }
        
        //시간(분) = 1000 * 60 해야함!!!!
        _screenSaverTime = [appDelegate.sessionTerm intValue] * 1000 * 60;
        _sessionAlarm = [appDelegate.sessionAlrm intValue] * 1000 * 60;
//        NSLog(@"_screenSaverTime : %d / _sessionAlarm : %d", _screenSaverTime, _sessionAlarm);
        
        _sessionCount = 0;
        
        
//        UIDevice* device = [UIDevice currentDevice];
//        BOOL backgroundSupported = NO;
//        if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
//            backgroundSupported = device.multitaskingSupported;
//        }
//        // background 작업을 지원하면
//        if(backgroundSupported){
//            // System 에 background 작업이 필요함을 알림. 작업의 id 반환
//            sessionTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//                NSLog(@"Backgrouund task ran out of time and was terminated");
//                [[UIApplication sharedApplication] endBackgroundTask:sessionTask];
//                sessionTask = UIBackgroundTaskInvalid;
//            }];
//        }

        //일정 시간뒤 화면보호기 창 띄우기 - 터치가 되면 계속 일정 시간으로 초기화 됨.
        _idleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:YES];
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *current = [dateFormatter stringFromDate:now];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:current forKey:@"CURR_SESSION_TIME"];
        [prefs synchronize];
    }
}

- (void)idleTimerExceeded {
//    NSLog(@"DetectTouchWindow - 화면 보호기 창을 띄웁니다.");

    _sessionCount++;
//    NSLog(@"_sessionCount : %d / _screenSaverTime : %d", _sessionCount, _screenSaverTime);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *sessionStr = [prefs objectForKey:@"CURR_SESSION_TIME"];
    double currSessionTime = [sessionStr doubleValue];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currStr = [dateFormatter stringFromDate:now];
    double currTime = [currStr doubleValue];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//        NSLog(@"%f - %f = %d", currTime, currSessionTime, (int)(currTime-currSessionTime));
        int count = (int)(currTime-currSessionTime);
        if(count>=_screenSaverTime){
            [prefs setObject:@"0" forKey:@"CURR_SESSION_TIME"];
            [prefs synchronize];
            
            //위의 클래스들이 아닐때 화면보호기 띄우기
            [_idleTimer invalidate];
            
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"session_disconnect_msg2", @"session_disconnect_msg2"), appName]  message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                exit(0);
                                                             }];
            [alert addAction:okButton];
            [[MFUtil topViewController] presentViewController:alert animated:YES completion:nil];
            
        } else if(count==_screenSaverTime-_sessionAlarm){
//            NSLog(@"장시간 미사용으로 1분뒤 종료됩니다.");
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

                UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"session_disconnect_msg1", @"session_disconnect_msg1"), appName, appDelegate.sessionAlrm] message:nil preferredStyle:UIAlertControllerStyleAlert];
                [[MFUtil topViewController] presentViewController:alert animated:YES completion:nil];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }
        
//        if (_sessionCount==_screenSaverTime-_sessionAlarm) {
//            NSLog(@"장시간 미사용으로 1분뒤 종료됩니다.");
//            dispatch_async(dispatch_get_main_queue(), ^{
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//
//            UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"장시간 %@ 미사용으로 %@분뒤 종료됩니다.", @"장시간 %@ 미사용으로 %@분뒤 종료됩니다."), appName, appDelegate.sessionAlrm] message:nil preferredStyle:UIAlertControllerStyleAlert];
//            [[MFUtil topViewController] presentViewController:alert animated:YES completion:nil];
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            });
//            });
//
//        } else if(_sessionCount==_screenSaverTime){
//            NSLog(@"장시간 미사용으로 종료되었습니다.");
//
//            // background 작업의 종료를 알린다.
//            [[UIApplication sharedApplication] endBackgroundTask:sessionTask];
//            sessionTask = UIBackgroundTaskInvalid;
//
//            //사진촬영 중일때, 녹음중일때 제외하고 화면보호기 띄우기 - !
//            //현재 띄워진 class 의 이름 - 특정 클래스 걸러내기
//            NSString *currentSelectedCViewController = NSStringFromClass([[UIViewController currentViewController] class]);
//            NSLog(@"currentSelectedCViewController : %@", currentSelectedCViewController);
//            if([currentSelectedCViewController isEqualToString:@"CAMImagePickerCameraViewController"]){
//                [self resetIdleTimer]; //화면 보호기 시간 계속 초기화(터치중임)
//
//            }else{
//                //위의 클래스들이 아닐때 화면보호기 띄우기
//                [_idleTimer invalidate];
//
//                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"장시간 %@ 미사용으로 종료되었습니다.", @"장시간 %@ 미사용으로 종료되었습니다."), appName]  message:nil preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                                 handler:^(UIAlertAction * action) {
//                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
//                    exit(0);
//                                                                 }];
//                [alert addAction:okButton];
//                [[MFUtil topViewController] presentViewController:alert animated:YES completion:nil];
//            }
//        }
        
    }
}

@end
