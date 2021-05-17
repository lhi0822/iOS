//
//  MFNewWebViewController.h
//  mFinity
//
//  Created by hilee on 2018. 10. 30..
//  Copyright © 2018년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "UIViewController+MJPopupViewController.h"

@protocol MFNewWebViewDelegate;

@interface MFNewWebViewController : UIViewController<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>{
    IBOutlet UIView *webViewFrame;
    BOOL flag;
}
@property (assign, nonatomic) id <MFNewWebViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong)NSURLRequest *startRequest;
@property (nonatomic,strong)WKWebViewConfiguration *configuration;
@property (nonatomic, strong)WKWebView *webView;
@end

@protocol MFNewWebViewDelegate <NSObject>
@optional
- (void)closeButtonClick:(MFNewWebViewController *)secondDetailViewController;

@end
