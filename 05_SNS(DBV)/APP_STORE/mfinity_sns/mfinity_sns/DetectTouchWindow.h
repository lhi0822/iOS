//
//  DetectTouchWindow.h
//  mfinity_sns
//
//  Created by hilee on 2020/08/05.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
#import "AppDelegate.h"

@interface DetectTouchWindow : UIWindow {
    NSUInteger sessionTask;
}

@property (strong,nonatomic) NSTimer *idleTimer; //타이머 객체
@property (strong, nonatomic) UIWindow *window; //UIWindow 객체
@property (nonatomic,assign) int screenSaverTime; //화면보호기가 나타날 시간(터치가 없고난 뒤 몇 시간뒤?)
@property (nonatomic,assign) int sessionAlarm;
@property (nonatomic,assign) int sessionCount;

- (void)resetIdleTimer ;

@end

