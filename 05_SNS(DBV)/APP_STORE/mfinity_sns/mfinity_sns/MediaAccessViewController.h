//
//  MediaAccessViewController.h
//  mfinity_sns
//
//  Created by hilee on 2020/06/18.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"
#import "AppDelegate.h"
#import "MFUtil.h"

@interface MediaAccessViewController : UIViewController <MFURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UIView *accessView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *valueLbl;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@property (weak, nonatomic) IBOutlet UILabel *remarkLbl;
@property (weak, nonatomic) IBOutlet UIView *remarkView;
@property (weak, nonatomic) IBOutlet UITextView *remarkTxtView;

@property (weak, nonatomic) IBOutlet UILabel *noticeLbl;

@property (weak, nonatomic) IBOutlet UIButton *accessBtn;

@property (weak, nonatomic) NSString *authVal;
@property (weak, nonatomic) NSArray *dataArr;
@property (weak, nonatomic) NSString *exCompNm;

@end

