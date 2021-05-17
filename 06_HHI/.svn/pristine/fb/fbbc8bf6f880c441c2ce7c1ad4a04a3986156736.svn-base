//
//  WebViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMTWebView.h"

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
#import "MFBarcodeScannerViewController.h"

#import "PullRefreshTableView.h"

@interface WebViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate,UIApplicationDelegate,IMTWebViewProgressDelegate,UIActionSheetDelegate,NSURLConnectionDataDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,MFBarcodeScannerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DownloadListDelegate,UploadListDelegate>{
    NSString *menuKind;
    NSString *menuType;
    NSString *nativeAppURL;
    
    NSString *paramString;
    NSString *nativeAppMenuNo;
    NSString *currentAppVersion;
    
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
    
	//IBOutlet UIActivityIndicatorView		*myIndicator;
	ActivityAlertView		*activityAlert;
	bool flag;
    CLLocationManager *locationManager;
    NSString *sensorString;
    CMMotionManager *motionManager;
    
    
    NSString *dbDirectoryPath;

    BOOL isCamera;
    UIImagePickerController *picker;
    
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    
    NSString                                *refreshTime;
    BOOL                                    isRefresh;
    BOOL                                    isDragging;
    
    UILabel                                 *lbRefreshTime2;
    UIImageView                             *ivRefreshArrow2;
    UIActivityIndicatorView                 *spRefresh2;
    
    NSString                                *refreshTime2;
    BOOL                                    isRefresh2;
    BOOL                                    isDragging2;

}
@property (nonatomic, assign)BOOL backMode;
@property (nonatomic, retain) NSString *backDefineFunc;
@property (nonatomic, retain) NSString *backUserSpecific;

@property (nonatomic, strong)NSMutableDictionary *callBackDic;
@property (nonatomic, retain)NSString *callbackFunc;
@property (nonatomic, retain)NSString *userSpecific;

@property (nonatomic, assign)BOOL isDMS;
@property (nonatomic, assign)BOOL isTabBar;

@property (nonatomic, assign)BOOL isMain;
@property (nonatomic, assign)BOOL isDownload;
@property (strong, nonatomic)NSString *type;
@property (nonatomic, retain)NSString *selectedImageURL;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain)NSString *compName;
@property (nonatomic, retain)NSString *urlString;
-(void)dbConnection:(NSString *)page :(NSString *)crud :(NSString *)sql :(NSString *)dbName;
-(void)myLocation:(id)sender;
-(void)photoSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc;
-(void)signSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc;
-(void)photoSave:(NSString *)fileName;
-(void)signSave:(NSString *)fileName;
@end
@interface UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame;
@end
