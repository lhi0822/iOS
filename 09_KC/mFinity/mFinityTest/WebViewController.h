//
//  WebViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMTWebView.h"
#import <Photos/Photos.h>

#import "DataLogger.h"
#import "ActivityAlertView.h"
#import "MFinityAppDelegate.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

#import "DownloadListViewController.h"
#import "UploadListViewController.h"
#import <WebKit/WebKit.h>
#import "MFBarcodeScannerViewController.h"

#import "UploadProcessViewController.h"

@interface WebViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate,UIApplicationDelegate,IMTWebViewProgressDelegate,UIActionSheetDelegate,NSURLConnectionDataDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DownloadListDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UploadListDelegate,MFBarcodeScannerDelegate, UploadProcessViewDelegate, UIDocumentInteractionControllerDelegate, NSURLSessionDelegate>{
    NSString *menuKind;
    NSString *menuType;
    NSString *nativeAppURL;
    
    NSString *paramString;
    NSString *nativeAppMenuNo;
    NSString *currentAppVersion;
    
    WKWebView *_webView;
    IBOutlet IMTWebView *mywebView;
    IBOutlet UIBarButtonItem *setButton;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UINavigationBar *naviBar;
    DataLogger *_myDataLogger;
    
    MFinityAppDelegate *appDelegate;
    NSString *_compName;
    NSString *_urlString;
    UIActionSheet *_actionActionSheet;
    NSString *selectedLinkURL;
    NSString *_imgFileName;
    NSString *_signFileName;
    NSMutableData *receiveData;
    NSMutableData *histData;
    
    int count;
    int endCount;
    ActivityAlertView		*activityAlert;
    bool flag;
    
    NSString *sensorString;
    CMMotionManager *motionManager;
   
    BOOL isCamera;
    BOOL isViewing;
}
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, assign)BOOL backMode;
@property (nonatomic, retain) NSString *backDefineFunc;
@property (nonatomic, retain) NSString *backUserSpecific;

@property (nonatomic, strong)NSMutableDictionary *callBackDic;
@property (nonatomic, retain)NSString *callbackFunc;
@property (nonatomic, retain)NSString *userSpecific;

@property (nonatomic, assign)BOOL isDMS;
@property (nonatomic, assign)BOOL isTabBar;
@property (nonatomic, assign)BOOL isSync;
@property (nonatomic, assign)BOOL isMain;
@property (nonatomic, assign)BOOL isDownload;
@property (strong, nonatomic)NSString *type;
@property (nonatomic, retain)NSString *selectedImageURL;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain)NSString *compName;
@property (nonatomic, retain)NSString *urlString;

@property (nonatomic, strong)NSMutableArray *webViews;

@property (nonatomic, strong)NSString *dbDirectoryPath;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) UIImagePickerController *picker;

@property (nonatomic, retain) NSURL* lastLoadedURL;
@property (nonatomic, retain) NSMutableArray* historyArr;

@property (nonatomic, retain) UIDocumentInteractionController *doic;

-(void)dbConnection:(NSString *)page :(NSString *)crud :(NSString *)sql :(NSString *)dbName;
-(void)myLocation:(id)sender;
-(void)photoSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc;
-(void)signSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc;
-(void)photoSave:(NSString *)fileName;
-(void)signSave:(NSString *)fileName;
@end
@interface UIWebView (WebUI)

//-(void) webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;

@end
