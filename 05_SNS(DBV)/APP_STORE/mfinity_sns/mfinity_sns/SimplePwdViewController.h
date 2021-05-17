//
//  SimplePwdViewController.h
//  mfinity_sns
//
//  Created by hilee on 2020/07/01.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"

#import "SimplePwdInputViewController.h"

@interface SimplePwdViewController : UIViewController <MFURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIView *useContainer;
@property (weak, nonatomic) IBOutlet UILabel *pwdTitleLbl;
@property (weak, nonatomic) IBOutlet UISwitch *pwdSwitch;
@property (weak, nonatomic) IBOutlet UILabel *remarkLbl;
@property (weak, nonatomic) IBOutlet UIView *setContainer;
@property (weak, nonatomic) IBOutlet UILabel *pwdSetTitle;
@property (strong, nonatomic) IBOutlet UIButton *pwdSetBtn;

@end

