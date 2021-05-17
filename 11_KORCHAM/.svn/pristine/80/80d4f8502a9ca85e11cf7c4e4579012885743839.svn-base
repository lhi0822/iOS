//
//  MFNewWebViewController.h
//  korchampass
//
//  Created by Jun HyungPark on 2017. 1. 16..
//  Copyright © 2017년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MFWebViewController.h"
#import "UIViewController+MJPopupViewController.h"
@protocol MFNewWebViewDelegate;

@interface MFNewWebViewController : UIViewController<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>{
    IBOutlet UIView *webViewFrame;
    BOOL flag;
}
@property (assign, nonatomic) id <MFNewWebViewDelegate>delegate;
@property (nonatomic, strong)IBOutlet UIProgressView *progressView;
@property (nonatomic,strong)NSURLRequest *startRequest;
@property (nonatomic,strong)WKWebViewConfiguration *configuration;
@property (nonatomic, strong)WKWebView *webView;
@end

@protocol MFNewWebViewDelegate <NSObject>
@optional
- (void)closeButtonClick:(MFNewWebViewController *)secondDetailViewController;

@end
