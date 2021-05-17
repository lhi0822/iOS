//
//  PopupViewController.h
//  mFinity_KDGas
//
//  Created by hilee on 2020/12/03.
//  Copyright © 2020 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MFinityAppDelegate.h"

@interface PopupViewController : UIViewController <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)WKWebView *wkWebView;
@property (nonatomic, strong)NSMutableArray *webViews;
@property (nonatomic, strong)NSMutableArray *createdWKWebViews;
@property (weak, nonatomic) IBOutlet UIView *webViewFrame;
@property (weak, nonatomic) IBOutlet UIView *container;

@property (nonatomic, strong)NSDictionary *popupDic;

@property (nonatomic, strong) NSString *noticeNo;

@end

