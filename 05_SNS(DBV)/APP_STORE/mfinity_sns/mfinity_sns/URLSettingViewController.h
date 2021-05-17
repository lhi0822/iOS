//
//  URLSettingViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 10. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"
#import "AppDelegate.h"

@interface URLSettingViewController : UIViewController <MFURLSessionDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIAlertViewDelegate, NSURLConnectionDataDelegate> {
    BOOL isHideKeyboard;
}

@property (strong, nonatomic) IBOutlet UIImageView *bgImgView;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UIButton *textButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UITextField *compTextField;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, retain)NSString *gwUrl;

@property (nonatomic, strong) UIBarButtonItem *_button;
@property (nonatomic, strong) UIToolbar *_toolBar;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, retain) NSDictionary *returnDic;
@property (nonatomic, strong) NSDictionary *compDic;
@property (nonatomic, strong)NSString *compNm;
@property (nonatomic, retain) NSString *compCode;

@end
