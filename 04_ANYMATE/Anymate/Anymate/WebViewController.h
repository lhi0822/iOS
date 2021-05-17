//
//  ViewController.h
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 14..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIPopover+iPhone.h"
#import <WebKit/WebKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

//#import "IMTWebView.h"
        
@interface WebViewController : UIViewController<UIApplicationDelegate, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIPopoverControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>{
//    IBOutlet WKWebView *webView;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UINavigationBar *naviBar;

    NSString *_compName;
    NSString *_urlString;
    UIActionSheet *_actionActionSheet;
    NSString *selectedLinkURL;
   
    NSMutableData *receiveData;
}
@property (retain, nonatomic) IBOutlet UIView *webViewFrame;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIWebView *uiWebView;

@property (nonatomic, retain) NSURL *failedURL;
@property (nonatomic, retain) UIDocumentInteractionController *doic;
@property (nonatomic, retain)NSString *selectedImageURL;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain)NSString *compName;
@property (nonatomic, retain)NSString *urlString;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, retain)NSString *isBadge;

@property (nonatomic, strong)NSMutableArray *createdWKWebViews;


-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;
-(IBAction)refresh:(id)sender;
-(IBAction)setting:(id)sender;
-(void)moveToPage;
@end

@interface UINavigationController (Autorotation2)
-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
@end
