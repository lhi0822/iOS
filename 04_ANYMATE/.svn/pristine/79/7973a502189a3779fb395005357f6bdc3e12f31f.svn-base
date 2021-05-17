//
//  FileViewerController.h
//  Anymate
//
//  Created by hilee on 19/11/2019.
//  Copyright © 2019 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

@interface FileViewerController : UIViewController<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    NSMutableData *receiveData;
}

@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet WKWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) NSURL *fileUrl;
@property (retain, nonatomic) NSString *fileName;

@end

