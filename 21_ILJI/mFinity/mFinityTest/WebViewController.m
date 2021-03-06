//
//  WebViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewAdditions.h"
#import "MFinityAppDelegate.h"

#import "HDString.h"
#import "sqlite3.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "CustomSegmentedControl.h"
#import "CameraMenuViewController.h"
#import "SignPadViewController.h"
#import "PhotoViewController.h"
#import "FileUploadViewController.h"

#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import "UIDevice+IdentifierAddition.h"

#import <sys/utsname.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreMotion/CoreMotion.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#include <sys/param.h>
#include <sys/mount.h>

#import "FBEncryptorAES.h"

#import "SVProgressHUD.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFTableViewController.h"
#import "JTSImageViewController.h"


#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 320
//#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0)
#define IS_OS_8_OR_LATER NO
#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
#define TAB_BAR_HEIGHT 49


@interface WebViewController ()<MFNewWebViewDelegate>{
    int labelTag;
    int buttonTag;
    int labelSizePercent;
    int createTabCount;
    BOOL isLayout;
    WKWebView *newWebView;
    
    BOOL isFirst;
    
    NSString *uploadFormat;
    NSString *uploadSize;
}

@end

@implementation WebViewController
#pragma mark
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //모달팝업 완료버튼이 흰색으로 나오는 이슈가 있음
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UIToolbar.class]]setTintColor:[appDelegate myRGBfromHex:@"#007AFF"]]; //화살표만 바뀜
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[appDelegate myRGBfromHex:@"#007AFF"], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(executeFileUploadReturn:) name:@"executeFileUploadReturn" object:nil];
    
    createTabCount = 0;
    labelTag = 10001;
    buttonTag = 20001;
    labelSizePercent = 90;
    isLayout = NO;
    
    self.createdWKWebViews = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.webViews = [[NSMutableArray alloc]init];
    [self checkDownload];
    [self initUI];
    [self initNotification];
    
    [self initWKWebView];

}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"%s", __func__);
    [super viewWillAppear:animated];
    
    if(!isFirst){
        isFirst = YES;
        [self initWKWebView];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!isFirst){
        motionManager = [[CMMotionManager alloc]init];
        if (_isDMS) {
            NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
            documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
            documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
            
            self.dbDirectoryPath = documentPath;
        }else{
            self.dbDirectoryPath = [self makeDBFile];
        }
        
        if (!isViewing) {
            if (IS_OS_8_OR_LATER) {
                isViewing = YES;
            }
        }
        isFirst = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideImageViewer" object:nil];
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    if (appDelegate.inactivePushInfo != nil) {
//        [self throwPushNotification:appDelegate.inactivePushInfo];
//        appDelegate.inactivePushInfo = nil;
//    }
}

#pragma mark - Init Method
- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"HideImageViewer" object: nil];
}
- (void)checkDownload{
    if (_isDownload) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        UIViewController *vc = [[self.navigationController viewControllers]objectAtIndex:[arr count]-2];
        [arr removeObject:vc];
        self.navigationController.viewControllers = arr;
        _isDownload = NO;
    }
}
- (void)initUI{
    //Back Button
    flag = NO;
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badge = [appDelegate.badgeCount intValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badge]];
        }
    }
    
    //네비게이션 바 색상 변환
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UIImage *buttonImageRight = [UIImage imageNamed:@"navi_webback.png"];
    
    UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [rightButton setImage:buttonImageRight forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, buttonImageRight.size.width-12,buttonImageRight.size.height-12);
    
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItemRight = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = customBarItemRight;
    
    NSData *data = [appDelegate.menu_title dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([appDelegate.menu_title length] > 9 && [data length] > 18) {
        UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        if (appDelegate.isMainWebView) {
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }else{
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }
        _label.text = appDelegate.menu_title;
        _label.font = [UIFont boldSystemFontOfSize:18.0];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        
        self.navigationItem.titleView = _label;
        
    }else {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        if (appDelegate.isMainWebView) {
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }else{
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }
        label.text = appDelegate.menu_title;
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        
    }
    
    NSArray *controllers = [self.navigationController viewControllers];
    
    UIViewController *controller = [controllers objectAtIndex:0];
    NSString *tempString = [NSString stringWithFormat:@"%@", controller.class];
    if ([tempString isEqualToString:@"Notice_PushViewController"]) {
        appDelegate.preURL = appDelegate.target_url;
        appDelegate.preTitleName = self.navigationItem.title;
    } else if([tempString isEqualToString:@"ThirdViewController"]){
        appDelegate.preThirdTitle = self.navigationItem.title;
    } else if([tempString isEqualToString:@"FirstViewController"]){
        appDelegate.preMainTitle = self.navigationItem.title;
    }
}
- (void)setMfnpMethod:(WKUserContentController *)userController{
    [userController addScriptMessageHandler:self name:@"executeBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"executeBarcode"];
    [userController addScriptMessageHandler:self name:@"executeCamera"];
    [userController addScriptMessageHandler:self name:@"executeDatagate"];
    [userController addScriptMessageHandler:self name:@"executeExitRecognizeSpeech"];
    [userController addScriptMessageHandler:self name:@"executeExitWebBrowser"];
    [userController addScriptMessageHandler:self name:@"executeFileUpload"];
    [userController addScriptMessageHandler:self name:@"executeFlashLight"];
    [userController addScriptMessageHandler:self name:@"executeImageEditor"];
    [userController addScriptMessageHandler:self name:@"executeLogout"];
    [userController addScriptMessageHandler:self name:@"executeMediaRecorder"];
    [userController addScriptMessageHandler:self name:@"executeExitMediaRecorder"];
    [userController addScriptMessageHandler:self name:@"executeMenu"];
    [userController addScriptMessageHandler:self name:@"executeNonQuery"];
    [userController addScriptMessageHandler:self name:@"executeNotification"];
    [userController addScriptMessageHandler:self name:@"executeRecognizeSpeech"];
    [userController addScriptMessageHandler:self name:@"executeRetrieve"];
    [userController addScriptMessageHandler:self name:@"executePush"];
    [userController addScriptMessageHandler:self name:@"executeSignpad"];
    [userController addScriptMessageHandler:self name:@"executeSms"];
    [userController addScriptMessageHandler:self name:@"executeVideoPlayer"];
    [userController addScriptMessageHandler:self name:@"executeWebBack"];

    [userController addScriptMessageHandler:self name:@"getAccelerometer"];
    [userController addScriptMessageHandler:self name:@"getCheckSession"];
    [userController addScriptMessageHandler:self name:@"getConvertImageToBase64"];
    [userController addScriptMessageHandler:self name:@"getDeviceInfo"];
    [userController addScriptMessageHandler:self name:@"getDeviceSpec"];
    [userController addScriptMessageHandler:self name:@"getFileList"];
    [userController addScriptMessageHandler:self name:@"getFilePath"];
    [userController addScriptMessageHandler:self name:@"getGpsLocation"];
    [userController addScriptMessageHandler:self name:@"getGyroscope"];
    [userController addScriptMessageHandler:self name:@"getMagneticField"];
    [userController addScriptMessageHandler:self name:@"getMenuLocation"];
    [userController addScriptMessageHandler:self name:@"getNetworkStatus"];
    [userController addScriptMessageHandler:self name:@"getOrientation"];
    [userController addScriptMessageHandler:self name:@"getPreference"];
    [userController addScriptMessageHandler:self name:@"getProximity"];
    [userController addScriptMessageHandler:self name:@"getUserInfo"];
    [userController addScriptMessageHandler:self name:@"getWebHistory"];

    [userController addScriptMessageHandler:self name:@"setBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"setFileNames"];
    [userController addScriptMessageHandler:self name:@"setPreference"];
    [userController addScriptMessageHandler:self name:@"setWebHistoryClear"];
    
    [userController addScriptMessageHandler:self name:@"isRoaming"];
    
}
- (void) closeActiveWebView
{
    // Grab and remove the top web view, remove its reference from the windows array,
    // and nil itself and its delegate. Then we re-set the activeWindow to the
    // now-top web view and refresh the toolbar.
    UIWebView *webView = [self.webViews lastObject];
    [webView removeFromSuperview];
    [self.webViews removeLastObject];
    webView.delegate = nil;
    webView = nil;
    
    mywebView = [self.webViews lastObject];
    
}
- (UIWebView *) newWebView
{
    // Create a web view that fills the entire window, minus the toolbar height
    IMTWebView *webView = [[IMTWebView alloc] initWithFrame:CGRectMake(0, 0, (float)self.view.bounds.size.width, (float)self.view.bounds.size.height - 44)];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add to windows array and make active window
    [self.webViews addObject:webView];
    mywebView = webView;
    [webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    NSString *close = @"window.close=function(){ open('mfinity://windowClose'); };";
    [webView stringByEvaluatingJavaScriptFromString:close];
    return webView;
}
- (void)initUIWebView{
    NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
    mywebView.scalesPageToFit = YES;
    mywebView.mediaPlaybackRequiresUserAction = NO;
    mywebView.allowsInlineMediaPlayback = YES;
    //user-agent
    //NSString *secretAgent = [mywebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    if ([[page_url substringToIndex:6] isEqualToString:@"http:/"]||[[page_url substringToIndex:7] isEqualToString:@"https:/"]) {
        if (appDelegate.isOffLine) {
            
        }else{
            NSLog(@"appDelegate.target_method : %@",appDelegate.target_method);
            NSLog(@"appDelegate.target_param : %@",appDelegate.target_param);
            NSLog(@"appDelegate.target_url : %@",appDelegate.target_url);
            
            if(appDelegate.target_method==nil) appDelegate.target_method = @"POST";
            
            NSURL *nsurl=[NSURL URLWithString:page_url];
            NSMutableURLRequest *nsrequest = [NSMutableURLRequest requestWithURL:nsurl];
            [nsrequest setHTTPMethod:appDelegate.target_method];
            [nsrequest setHTTPBody:[appDelegate.target_param dataUsingEncoding:NSUTF8StringEncoding]];
            
            [mywebView loadRequest:nsrequest];
        }
        
    } else {
        NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *filemgr;
        NSArray *filelist;
        int countT;
        int i;
        
        filemgr =[NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:save error:NULL];
        countT = [filelist count];
        
        for(i = 0; i < countT; i++){
            NSLog(@"item : %@", [filelist objectAtIndex: i]);
        }
        
        NSData *htmlData = [NSData dataWithContentsOfFile:appDelegate.target_url];
        if (htmlData == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message91", @"") message:NSLocalizedString(@"message92", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alert show];
            
        }else{
            NSString *str = appDelegate.target_url;
            
            NSArray *arr = [NSArray arrayWithArray:[str pathComponents]];
            NSMutableString *tempString = [[NSMutableString alloc]initWithString:@""];
            for (int i=0; i<[arr count]-2; i++) {
                [tempString appendFormat:@"/"];
                [tempString appendFormat:@"%@",[arr objectAtIndex:i+1]];
            }
            [tempString appendFormat:@"/"];
            str = [str stringByAppendingFormat:@"?%@",appDelegate.paramString];
            str = [str stringByAppendingFormat:@"&devOs=I"];
            [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        }
    }
    [self.webViews addObject:mywebView];
}
- (void)initWKWebView{
    NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    [self setMfnpMethod:userController];
    webViewConfig.userContentController = userController;
    
    NSLog(@"page_url : %@", page_url);
    
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen]bounds].size.height;
    
    NSLog(@"screenWidth : %f / screenHeight : %f", screenWidth, screenHeight);
    //appDelegate.shouldSupportAllOrientation = NO;
    
    if (_isTabBar) {
        NSLog(@"is TabBar");
        self.navigationController.navigationBarHidden = NO; //TabBar ON일 경우 네비게이션 숨김해제.
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        CGRect rect = CGRectMake(mywebView.frame.origin.x
                                 , mywebView.frame.origin.y
                                 , screenWidth
                                 , screenHeight-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-TAB_BAR_HEIGHT);
        //        CGRect rect = CGRectMake(mywebView.frame.origin.x
        //                                 , mywebView.frame.origin.y
        //                                 , mywebView.frame.size.width
        //                                 , mywebView.frame.size.height-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-TAB_BAR_HEIGHT);
        _webView = [[WKWebView alloc] initWithFrame:rect configuration:webViewConfig];
        
    }else{
        NSLog(@"is not TabBar");
        if(_isNotice) self.navigationController.navigationBarHidden = NO;
        else self.navigationController.navigationBarHidden = YES; //TabBar OFF일 경우 네비게이션 숨김.

//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        CGRect rect = CGRectMake(mywebView.frame.origin.x
                                 , mywebView.frame.origin.y+[UIApplication sharedApplication].statusBarFrame.size.height
                                 , screenWidth
                                 , screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height);
        
        //        CGRect rect = CGRectMake(mywebView.frame.origin.x
        //                                 , mywebView.frame.origin.y+[UIApplication sharedApplication].statusBarFrame.size.height
        //                                 , mywebView.frame.size.width
        //                                 , mywebView.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height);
        _webView = [[WKWebView alloc] initWithFrame:rect configuration:webViewConfig];
    }
    
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.scrollEnabled = YES;
    _webView.scrollView.bounces = NO;
    
    if ([[page_url substringToIndex:6] isEqualToString:@"http:/"]||[[page_url substringToIndex:7] isEqualToString:@"https:/"]||[page_url hasPrefix:@"hdwebview://"]) {
        NSLog(@"[page_url substringToIndex:6] : %@", [page_url substringToIndex:6]);
        NSLog(@"[page_url substringToIndex:7] : %@", [page_url substringToIndex:7]);
        if (appDelegate.isOffLine) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message109", @"")];
        }else{
            NSLog(@"appDelegate.target_method : %@",appDelegate.target_method);
            NSLog(@"appDelegate.target_param : %@",appDelegate.target_param);
            if(appDelegate.target_method==nil) appDelegate.target_method = @"POST";
            
            NSURL *nsurl=[NSURL URLWithString:page_url];
            NSMutableURLRequest *nsrequest = [NSMutableURLRequest requestWithURL:nsurl];
            [nsrequest setHTTPMethod:appDelegate.target_method];
            [nsrequest setHTTPBody:[appDelegate.target_param dataUsingEncoding:NSUTF8StringEncoding]];
            //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
            [_webView loadRequest:nsrequest];
        }
        
    }else{
        NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSData *htmlData = [NSData dataWithContentsOfFile:appDelegate.target_url];
        if (htmlData == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message91", @"") message:NSLocalizedString(@"message92", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alert show];
            
        }else{
            NSString *htmlFilePath = appDelegate.target_url;
            htmlFilePath = [htmlFilePath stringByAppendingFormat:@"?%@",appDelegate.paramString];
            htmlFilePath = [htmlFilePath stringByAppendingFormat:@"&devOs=I"];
            htmlFilePath = [NSString stringWithFormat:@"file://%@",htmlFilePath];
            
            NSURL *fileURL=[NSURL URLWithString:htmlFilePath];
            [_webView loadFileURL:fileURL allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];
            
        }
        
    }
    [self.webViews addObject:_webView];
    [self.view addSubview:_webView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}


#pragma mark - WKWebView Delegate Method
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"%s", __func__);
    createTabCount++;
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    
    if(!isLayout){
        //UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, screenWidth, screenHeight)];
   
        tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        //| UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;
        tmpView.tag=9009;
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.3f;
        //[self.view addSubview:tmpView];
        [self.navigationController.view addSubview:tmpView]; //네비게이션 바 덮음
        
        isLayout = YES;
    }
    
    CGFloat labelSize =(screenWidth/100)*90;
    //__block UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width-labelSize, 20, labelSize+10, 44)];
    __block UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width-labelSize, [UIApplication sharedApplication].statusBarFrame.size.height, labelSize+10, 44)];
    titleLabel.tag = labelTag++;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    //| UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    //| UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.layer.masksToBounds = YES;
    titleLabel.layer.cornerRadius = 5.f;
    titleLabel.backgroundColor = [UIColor colorWithRed:57/255.0 green:149/255.0 blue:251/255.0 alpha:1];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0f weight:6.0f];
    CGRect aboutRect = [titleLabel.text //높이를 구할 NSString
                        boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:titleLabel.font}
                        context:nil];
    CGFloat strikeWidth = aboutRect.size.width;
    NSLog(@"strikeWidth : %f",strikeWidth);
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    backButton.tag = buttonTag++;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    //| UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_closeContentLayer-4.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    [self setMfnpMethod:userController];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    
//    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
//    WKUserContentController *userController = [[WKUserContentController alloc]init];
//    [self setMfnpMethod:userController];
//    webViewConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    webViewConfig.userContentController = userController;
    
    
    //CGRect webViewRect = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+44, screenWidth, screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height);
    CGRect webViewRect = CGRectZero;
    if(_isTabBar){
        webViewRect = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+44, screenWidth, screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height-TAB_BAR_HEIGHT);
    } else {
        webViewRect = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+44, screenWidth, screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height);
    }
    
//    WKWebView *newWebView = [[WKWebView alloc] initWithFrame:webViewRect configuration:configuration];
    newWebView = [[WKWebView alloc] initWithFrame:webViewRect configuration:configuration];
    newWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    //| UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    newWebView.navigationDelegate = self;
    newWebView.UIDelegate = self;
    //newWebView.scrollView.bounces = NO;

    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.4];
    [applicationLoadViewIn setType:kCATransitionPush];
    [applicationLoadViewIn setSubtype:kCATransitionFromRight];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[newWebView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    //[self.view addSubview:newWebView];    // 눈에 보여지도록
    [self.navigationController.view addSubview:newWebView]; //네비게이션 바 덮음
    
     [self.createdWKWebViews addObject:newWebView];
    
    //self.webView = newWebView;
    NSLog(@"newWebView : %@",newWebView.title);

    [newWebView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error)
     {
         //result == title
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
         titleLabel.text = [NSString stringWithFormat:@"\t%@",result];
         CATransition *applicationLoadViewIn =[CATransition animation];
         [applicationLoadViewIn setDuration:0.4];
         [applicationLoadViewIn setType:kCATransitionPush];
         [applicationLoadViewIn setSubtype:kCATransitionFromRight];
         [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
         [[titleLabel layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
         [[backButton layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
         //[self.view addSubview:titleLabel];
         //[self.view addSubview:backButton];
         [self.navigationController.view addSubview:titleLabel]; //네비게이션 바 덮음
         [self.navigationController.view addSubview:backButton]; //네비게이션 바 덮음
     }];
    
    return newWebView;
}


-(IBAction)backButton:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    
    NSLog(@"createTabCount : %d", createTabCount);
    if(createTabCount>0){
        if (createTabCount==1) {
            //UIView *tmpView = [self.view viewWithTag:9009];
            UIView *tmpView = [self.navigationController.view viewWithTag:9009]; //네비게이션 바 덮음
            [tmpView removeFromSuperview];
            tmpView = nil;
            isLayout = NO;
        }
        createTabCount--;
    }
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:.5];
    //[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:YES]; //네비게이션 바 덮음
    WKWebView *wkView = [self.createdWKWebViews lastObject];
    [wkView removeFromSuperview];
    [self.createdWKWebViews removeLastObject];
    wkView = nil;
    
    [UIView commitAnimations];
    if (self.createdWKWebViews.count>0) {
        self.webView = [self.createdWKWebViews lastObject];
    }
    
    //UIButton *backButton = (UIButton *)[self.view viewWithTag:--buttonTag];
    UIButton *backButton = (UIButton *)[self.navigationController.view viewWithTag:--buttonTag]; //네비게이션 바 덮음
    [backButton removeFromSuperview];
    backButton = nil;
    
    UILabel *label = (UILabel *)[self.navigationController.view viewWithTag:--labelTag]; //네비게이션 바 덮음
    //UILabel *label = (UILabel *)[self.view viewWithTag:--labelTag];
    [label removeFromSuperview];
    label = nil;
}
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"createTabCount : %d", createTabCount);
    
    if(createTabCount > 0){
        if (createTabCount==1) {
            //UIView *tmpView = [self.view viewWithTag:9009];
            UIView *tmpView = [self.navigationController.view viewWithTag:9009]; //네비게이션 바 덮음
            [tmpView removeFromSuperview];
            tmpView = nil;
            isLayout = NO;
        }
        
        createTabCount--;
        
        WKWebView *wkView = [self.createdWKWebViews lastObject];
        [wkView removeFromSuperview];
        [self.createdWKWebViews removeLastObject];
        wkView = nil;
        
        if (self.createdWKWebViews.count>0) {
            self.webView = [self.createdWKWebViews lastObject];
        }
        
        UIButton *backButton = (UIButton *)[self.navigationController.view viewWithTag:--buttonTag]; //네비게이션 바 덮음
        //UIButton *backButton = (UIButton *)[self.view viewWithTag:--buttonTag];
        [backButton removeFromSuperview];
        backButton = nil;
        
        UILabel *label = (UILabel *)[self.navigationController.view viewWithTag:--labelTag]; //네비게이션 바 덮음
        //UILabel *label = (UILabel *)[self.view viewWithTag:--labelTag];
        [label removeFromSuperview];
        label = nil;
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message : %@",message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NULL
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"keyPath : %@",keyPath);
    NSLog(@"object : %@",object);
    NSLog(@"self.webView : %@",self.webView);
    if ([keyPath isEqualToString:@"estimatedProgress"] /*&& object == self.webView*/) {
        NSLog(@"estimatedProgress : %f", self.webView.estimatedProgress);
        [self.progressView setProgress:self.webView.estimatedProgress];
        
        if(self.webView.estimatedProgress >= 1.0f) {
            [self.progressView setHidden:YES];
        }
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark
#pragma mark WKWebView Set MFNP
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    
    NSString *mfnpName = message.name;
    NSString *mfnpParam = message.body;
    NSDictionary *dic;
    @try{
        dic = [self getParameters:mfnpParam];
    }
    @catch(NSException *e){
        if (![mfnpName isEqualToString:@"exeWindowClose"]) {
            NSLog(@"[mfnp parameter exception] : %@",e);
        }
    }
    
    if ([mfnpName isEqualToString:@"executeBackKeyEvent"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];

    }
    else if ([mfnpName isEqualToString:@"executeBarcode"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeBarcode:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeCamera"]) {
        NSLog(@"camera dic : %@", dic);
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        uploadFormat=@"jpeg";
        uploadSize=@"816";
        
        if(dic.count==3){
            uploadFormat = [dic objectForKey:@"format"];
            
        } else if(dic.count==4){
            uploadSize = [dic objectForKey:@"size"];
            uploadFormat = [dic objectForKey:@"format"];
        }
        
        [self executeCamera:callBackFunc :userSpecific :uploadFormat :uploadSize];
    }
    else if ([mfnpName isEqualToString:@"executeDatagate"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
        NSString *sprocName = [dic objectForKey:@"sprocName"];
        NSString *args = [dic objectForKey:@"args"];
        [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
    }
    else if ([mfnpName isEqualToString:@"executeExitWebBrowser"]) {
        [self executeExitWebBrowser];
    }
    else if ([mfnpName isEqualToString:@"executeFileUpload"]) {
        //NSLog(@"dict : %@", dic);
        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:@"cdSuccessFileUpload" forKey:@"callbackFunc"];
//        [dic setObject:@"getFileUploadResult" forKey:@"userSpecific"];
//
//        NSString *testStr = @"[{\"file_src\":\"storage/emulated/0/Download/YESCO/test/image1.jpeg\",\"upload_url\":\"uploadurl\",\"flag\":\"false\"},{\"file_src\":\"storage/emulated/0/Download/YESCO/test/image2.jpeg\",\"upload_url\":\"uploadurl2\",\"flag\":\"false\"}]";
//        [dic setObject:testStr forKey:@"data"];
        
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        
        if(dic.count>3){
            NSString *fileList = [dic objectForKey:@"fileList"];
            NSError *jsonError;
            NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
            //        NSString *upLoadPath = @"http://svr001.ezsmart.co.kr:1598/samples/";
            //        NSString *upLoadPath = @"http://192.168.0.8:9000/hhi_sns/upload";
            
            NSString *flag;
            if([dic objectForKey:@"flag"]!=nil){
                flag = [dic objectForKey:@"flag"];
            } else {
                flag = @"false";
            }
            [self executeFileUpload:callBackFunc :userSpecific :json :upLoadPath :[flag boolValue]];
            
        } else {
            NSString *jsonString = [dic objectForKey:@"fileList"];
            //file_src, upload_url, flag
            NSError *error;
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
            [self executeFileUpload:callBackFunc :userSpecific :json];
        }
    }
    else if ([mfnpName isEqualToString:@"executeFlashLight"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeFlashLight:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeImageEditor"]) {
        NSLog(@"mfnpName executeImageEditor dic : %@", dic);
        
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *imagePath = [dic objectForKey:@"imagePath"];
        [self executeImageEditor:callBackFunc :userSpecific :imagePath];
    }
    
    else if ([mfnpName isEqualToString:@"executeLogout"]) {
        [self executeLogout];
    }
    else if ([mfnpName isEqualToString:@"executeMenu"]) {
        NSString *menuNo = [dic objectForKey:@"menuNo"];
        [self executeMenu:menuNo];
    }
    else if ([mfnpName isEqualToString:@"executeMediaRecorder"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeMediaRecorder:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeExitMediaRecorder"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeExitMediaRecorder:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeNonQuery"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeNotification"]) {
        NSString *useVibrator = [dic objectForKey:@"vibrator"];
        NSString *useBeep = [dic objectForKey:@"beep"];
        NSString *time = [dic objectForKey:@"time"];
        [self executeNotification:useVibrator :useBeep :time];
    }
    
    else if ([mfnpName isEqualToString:@"executePush"]) {
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *userList = [dic objectForKey:@"userList"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executePush:callBackFunc :userSpecific :userList :msg];
    }
    else if ([mfnpName isEqualToString:@"executeRecognizeSpeech"]) {
        if (IS_OS_9_OR_LATER) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message167", @"iOS10 버전 이상에서 지원하는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }else{
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *succession = [dic objectForKey:@"succession"];
            if (succession!=nil) {
                [self executeRecognizeSpeech:callBackFunc :userSpecific :succession];
            }else{
                [self executeRecognizeSpeech:callBackFunc :userSpecific];
            }
        }
    }
    else if ([mfnpName isEqualToString:@"executeExitRecognizeSpeech"]) {
        if (IS_OS_9_OR_LATER) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message167", @"iOS10 버전 이상에서 지원하는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }else{
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeExitRecognizeSpeech:callBackFunc :userSpecific];
        }
    }
    else if ([mfnpName isEqualToString:@"executeRetrieve"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"selectStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeSignpad"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeSignpad:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeSms"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *userList = [dic objectForKey:@"userList"];
        [self executeSms:callBackFunc :userSpecific :msg :userList];
    }
    else if([mfnpName isEqualToString:@"executeVideoPlayer"]){
        NSString *streamingUrl = [dic objectForKey:@"streamingUrl"];
        [self executeVideoPlayer:streamingUrl];
        
    }else if([mfnpName isEqualToString:@"executeWebBack"]){
        [self rightBtnClick];
    }
    
    else if ([mfnpName isEqualToString:@"getAccelerometer"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getAccelerometer:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getCheckSession"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getCheckSession:callBackFunc :userSpecific];
    }
    else if([mfnpName isEqualToString:@"getConvertImageToBase64"]){
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *imagePath = [dic objectForKey:@"imagePath"];
        [self getConvertImageToBase64:callBackFunc :imagePath];
    }
    else if ([mfnpName isEqualToString:@"getDeviceInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        
        [self getDeviceSpec:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getDeviceSpec"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *specName = [dic objectForKey:@"specName"];
        if (specName!=nil) {
            [self getDeviceSpec:callBackFunc :userSpecific :specName];
        }else{
            [self getDeviceSpec:callBackFunc :userSpecific];
        }
    }
    else if ([mfnpName isEqualToString:@"getFileList"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *directoryPath = [dic objectForKey:@"directoryPath"];
        [self getFileList:callBackFunc :userSpecific :directoryPath];
    }
    else if ([mfnpName isEqualToString:@"getFilePath"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getFilePath:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getGpsLocation"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getGpsLocation:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getGyroscope"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getGyroscope:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getMagneticField"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getMagneticField:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getNetworkStatus"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getNetworkStatus:callBackFunc :userSpecific];
    }
    else if([mfnpName isEqualToString:@"getOrientation"]){
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getOrientation:callBackFunc :userSpecific];
        
    }
    else if ([mfnpName isEqualToString:@"getMenuLocation"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getMenuLocation:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getPreference"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *keyList = [dic objectForKey:@"keyList"];
        [self getPreferences:callBackFunc :userSpecific :keyList];
    }
    else if ([mfnpName isEqualToString:@"getProximity"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getProximity:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getUserInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getUserInfo:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getWebHistory"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getWebHistory:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"setBackKeyEvent"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *backkeyMode = [dic objectForKey:@"backkeyMode"];
        [self setBackKeyEvent:callBackFunc :userSpecific :backkeyMode];
    }
    else if ([mfnpName isEqualToString:@"setFileNames"]) {
        NSString *fileList = [dic objectForKey:@"fileList"];
        [self setFileNames:fileList];
    }
    else if ([mfnpName isEqualToString:@"setPreference"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *data = [dic objectForKey:@"data"];
        [self setPreferences:callBackFunc :userSpecific :data];
    }
    else if ([mfnpName isEqualToString:@"setWebHistoryClear"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self setWebHistoryClear:callBackFunc :userSpecific];
    }
    
    else if ([mfnpName isEqualToString:@"isRoaming"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self isRoaming:callBackFunc :userSpecific];
    }

}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s : %@",__FUNCTION__,webView.URL);
    
    for (int i=0; i<self.createdWKWebViews.count; i++) {
        WKWebView *tmp = self.createdWKWebViews[0];
        if ([webView.URL.absoluteString isEqualToString:tmp.URL.absoluteString]) {
            //[self.view addSubview:webView];
            [self.navigationController.view addSubview:webView]; //네비게이션 바 덮음
        }
    }
    
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
    [self.progressView setHidden:YES];
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation : %@",error);
    [self.progressView setHidden:YES];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    if (@available(iOS 11.0, *)) {  //available on iOS 11+
//        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
//        [cookieStore getAllCookies:^(NSArray* cookies) {
//            if (cookies.count > 0) {
//                for (NSHTTPCookie *cookie in cookies) {
//                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//                }
//
//                decisionHandler(WKNavigationResponsePolicyAllow);
//            }
//        }];
//    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;

        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];

        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }

        decisionHandler(WKNavigationResponsePolicyAllow);
//    }
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation : %@",webView);
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    @try{
        __block UILabel *label = (UILabel *)[self.navigationController.view viewWithTag:labelTag-1]; //네비게이션 바 덮음
        if([label.text isEqualToString:@""] || [[label.text urlEncodeUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"%09"]){
            [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error)
             {
                //result == title
                //NSLog(@"result !! : %@", result);
                NSString *text = [result componentsSeparatedByString:@"|"][0];
                text = [NSString stringWithFormat:@"\t%@",text];
                text = [self splitString:label :text];
                label.text = text;
                
            }];
        }
        
    } @catch(NSException *e){
        NSLog(@"%s Exception : %@", __func__, e);
    }
    
    [self.webViews addObject:webView];
    [self.progressView setHidden:YES];
}

-(NSString *)splitString:(UILabel *)label :(NSString *)text{
    int maxWidth;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    NSLog(@"screenwidth : %f",screenWidth);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        maxWidth = 700;
    }else{
        if (screenWidth>320) {
            maxWidth = 300;
        }else{
            maxWidth = 275;
        }
    }
    
    CGRect aboutRect = [text //높이를 구할 NSString
                        boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:label.font}
                        context:nil];
    CGFloat strikeWidth = aboutRect.size.width;
    NSString *editText = @"";
    if (strikeWidth>maxWidth) {
        NSArray *arr = [text componentsSeparatedByString:@" "];
        
        for (int i=0; i<=arr.count-2; i++) {
            NSString *tmp = arr[i];
            
            editText = [editText stringByAppendingString:tmp];
            if (i!=arr.count-2) {
                editText = [editText stringByAppendingString:@" "];
            }
            
        }
        
    }else{
        editText = text;
    }
    
    aboutRect = [editText //높이를 구할 NSString
                 boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                 options:NSStringDrawingUsesLineFragmentOrigin
                 attributes:@{NSFontAttributeName:label.font}
                 context:nil];
    strikeWidth = aboutRect.size.width;
    
    if (strikeWidth>maxWidth) {
        editText = [self splitString:label :editText];
    }
    return editText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark UIWebView Delegate Method
-(void) webView:(IMTWebView *)_tmp_webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources {
    [self.progressView setProgress:((float)resourceNumber) / ((float)totalResources)];
    if (resourceNumber == totalResources) {
        _tmp_webView.resourceCount = 0;
        _tmp_webView.resourceCompletedCount = 0;
    }
}
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"error : %@",error);
    self.progressView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    if (error.code == 102) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"message159", @"지원하지 않는 포멧입니다.") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
        
    }else if(error.code == -999){
        return;
    }/*else{
      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"오류" message:@"일시적인 네트워크 오류가 발생했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
      [alertView show];
      [alertView release];
      }*/
    
}

#pragma mark
#pragma mark UIWebView Set MFNP
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
   // NSLog(@"[request URL] : %@",[request URL]);
    //NSLog(@"request url : %@",[[request URL] absoluteURL]);
    
    if (UIWebViewNavigationTypeLinkClicked == navigationType || UIWebViewNavigationTypeOther == navigationType) {
        ////NSLog(@"a tag url : %@",[[request URL] absoluteURL]);
        if ([[[request URL] scheme]isEqualToString:@"ezmovetab"]) {
            self.tabBarController.selectedIndex = [[[request URL] host] intValue]-1;
            return NO;
        }else if([[[request URL] scheme]isEqualToString:@"dbcall"]){
            NSString *_paramString = [[request URL] absoluteString];
            NSArray *paramArray = [_paramString componentsSeparatedByString:@"!@"];
            
            
            NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
            documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
            documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
            
            documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
            NSLog(@"appDelegate.user_id : %@",appDelegate.user_id);
            NSString *dbPath = [[paramArray objectAtIndex:4] stringByAppendingPathExtension:@"db"];
            dbPath = [dbPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            documentPath = [documentPath stringByAppendingPathComponent:dbPath];
            
            /*
             NSBundle *bundle = [NSBundle mainBundle];
             NSString *documentPath = [bundle pathForResource:[paramArray objectAtIndex:4] ofType:@"db"];
             */
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSLog(@"documentPath : %@",documentPath);
            
            if ([fileManager isReadableFileAtPath:documentPath]) {
                [self oldDbConnection:[paramArray objectAtIndex:1] :[paramArray objectAtIndex:2] :[paramArray objectAtIndex:3] :documentPath];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
                [self dismissModalViewControllerAnimated:YES];
            }
            return NO;
            
        }else if([[[request URL] scheme]isEqualToString:@"mfnp"]||[[[request URL] scheme]isEqualToString:@"mfinity"]){
            NSString *host = [[request URL] host];
            NSLog(@"host : %@", host);
            NSURL *url = [request URL];
            NSArray *params = [[url query] componentsSeparatedByString:@"&"];
            
            if ([host isEqualToString:@"camera"]) {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
                appDelegate.mediaControl = @"camera";
                vc.isWebApp = YES;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if([host isEqualToString:@"movetab"]){
                self.tabBarController.selectedIndex = [[[request URL] host] intValue]-1;
                
            }else if([host isEqualToString:@"dbcall"]){
                NSArray *tmpArr = [[params objectAtIndex:0] componentsSeparatedByString:@"="];
                NSString *_paramString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
                NSLog(@"paramString : %@",_paramString);
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[_paramString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                
                NSLog(@"jsonDic : %@",jsonDic);
                
                NSBundle *bundle = [NSBundle mainBundle];
                
                NSString *path = [bundle pathForResource:[jsonDic objectForKey:@"db_name"] ofType:@"db"];
                NSLog(@"path : %@",path);
                [self dbConnection:[jsonDic objectForKey:@"gubn"] :[jsonDic objectForKey:@"crud"] :[jsonDic objectForKey:@"query"] :path];
                //[self dbConnection:[dic objectForKey:@"gubn"] :[dic objectForKey:@"crud"] :[dic objectForKey:@"sql"] :path :@"CBResultSql"];
                
            }else if([host isEqualToString:@"gps"]){
                [self getGpsLocation:@"CBLocation" :nil];
                
            }else if([host isEqualToString:@"addressbook"]){
                NSDictionary *dic = [appDelegate contracts];
                NSString *dicString = [NSString stringWithFormat:@"%@",dic];
                NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"signpad"]){
                SignPadViewController *vc = [[SignPadViewController alloc]init];
                UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                //[self.navigationController pushViewController:vc animated:YES];
                [self presentViewController:nvc animated:YES completion:nil];
                
            }else if([host isEqualToString:@"photosave"]){
                PhotoViewController *vc = [[PhotoViewController alloc] init];
                vc.imagePath = _imgFileName;
                vc.isWebApp = YES;
                [vc rightBtnClick];
                //[self.navigationController pushViewController:vc animated:YES];
                
            }else if([host isEqualToString:@"barcode"]){
                [self barCodeReaderOpen];
                
            }else if([host isEqualToString:@"blobstring"]){
                NSLog(@"[url query] : %@",[url query]);
                NSString *query = [url query];
                NSString *jsCommand = [NSString stringWithFormat:@"receive_blob('%@');",query];
                
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"filePath"]){
                //photo 폴더 경로 넘겨주면 됨
                NSString *photoPath =[self getPhotoFilePath];
                photoPath = [photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"saveFile"]){
                //
                
            }else if([host isEqualToString:@"executeBackKeyEvent"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                /*
                 NSDictionary *dic = [self getParameters:[url query]];
                 NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                 NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                 [self executeBackKeyEvent:callBackFunc :userSpecific];
                 */
                
            }else if([host isEqualToString:@"executeBarcode"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeBarcode:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeCamera"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
//                [self executeCamera:callBackFunc :userSpecific];
                
                NSLog(@"camera dic2 : %@", dic);
                uploadFormat=@"jpeg";
                uploadSize=@"816";
                
                if(dic.count==3){
                    uploadFormat = [dic objectForKey:@"format"];
                    
                } else if(dic.count==4){
                    uploadSize = [dic objectForKey:@"size"];
                    uploadFormat = [dic objectForKey:@"format"];
                }
                
                [self executeCamera:callBackFunc :userSpecific :uploadFormat :uploadSize];
                
            }else if([host isEqualToString:@"executeDatagate"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
                NSString *sprocName = [dic objectForKey:@"sprocName"];
                NSString *args = [dic objectForKey:@"args"];
                [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
                
            }else if([host isEqualToString:@"executeExitWebBrowser"]){
                [self executeExitWebBrowser];
                
            }else if([host isEqualToString:@"executeFileUpload"]){
                NSDictionary *dic = [self getParameters:[url query]];
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                
                if(dic.count>3){
                    NSString *fileList = [dic objectForKey:@"fileList"];
                    NSError *jsonError;
                    NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                    NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
                    //        NSString *upLoadPath = @"http://svr001.ezsmart.co.kr:1598/samples/";
                    //        NSString *upLoadPath = @"http://192.168.0.8:9000/hhi_sns/upload";
                    
                    NSString *flag;
                    if([dic objectForKey:@"flag"]!=nil){
                        flag = [dic objectForKey:@"flag"];
                    } else {
                        flag = @"false";
                    }
                    [self executeFileUpload:callBackFunc :userSpecific :json :upLoadPath :[flag boolValue]];
                    
                } else {
                    NSString *jsonString = [dic objectForKey:@"fileList"];
                    //file_src, upload_url, flag
                    NSError *error;
                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
                    [self executeFileUpload:callBackFunc :userSpecific :json];
                    
                }
                
            }else if([host isEqualToString:@"executeFlashLight"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeFlashLight:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeImageEditor"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"host executeImageEditor dic : %@", dic);
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *imagePath = [dic objectForKey:@"imagePath"];
                [self executeImageEditor:callBackFunc :userSpecific :imagePath];
                
            }else if([host isEqualToString:@"executeLogout"]){
                [self executeLogout];
                
            }else if([host isEqualToString:@"executeMenu"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *menuNo = [dic objectForKey:@"menuNo"];
                [self executeMenu:menuNo];
                
            }else if([host isEqualToString:@"executeMediaRecorder"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeMediaRecorder:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeExitMediaRecorder"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeExitMediaRecorder:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeNonQuery"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *dbName = [dic objectForKey:@"dbName"];
                NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeNotification"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"dic : %@",dic);
                NSString *useVibrator = [dic objectForKey:@"vibrator"];
                NSString *useBeep = [dic objectForKey:@"beep"];
                NSString *time = [dic objectForKey:@"time"];
                [self executeNotification:useVibrator :useBeep :time];
                
            }else if([host isEqualToString:@"executePush"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *msg = [dic objectForKey:@"msg"];
                NSString *userList = [dic objectForKey:@"userList"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executePush:callBackFunc :userSpecific :userList :msg];
                
            }else if([host isEqualToString:@"executeRecognizeSpeech"]){
                if (IS_OS_9_OR_LATER) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message167", @"iOS10 버전 이상에서 지원하는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    NSDictionary *dic = [self getParameters:[url query]];
                    NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                    NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                    NSString *succession = [dic objectForKey:@"succession"];
                    
                    if(succession!=nil) [self executeRecognizeSpeech:callBackFunc :userSpecific :succession];
                    else [self executeRecognizeSpeech:callBackFunc :userSpecific];
                }
                
            }else if ([host isEqualToString:@"executeExitRecognizeSpeech"]) {
                if (IS_OS_9_OR_LATER) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message167", @"iOS10 버전 이상에서 지원하는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    NSDictionary *dic = [self getParameters:[url query]];
                    NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                    NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                    [self executeExitRecognizeSpeech:callBackFunc :userSpecific];
                }
            }else if([host isEqualToString:@"executeRetrieve"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *dbName = [dic objectForKey:@"dbName"];
                NSString *selectStmt = [dic objectForKey:@"selectStmt"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeSignpad"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeSignpad:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeSms"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *msg = [dic objectForKey:@"msg"];
                NSString *userList = [dic objectForKey:@"userList"];
                [self executeSms:callBackFunc :userSpecific :msg :userList];
             
            }else if([host isEqualToString:@"executeVideoPlayer"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *streamingUrl = [dic objectForKey:@"streamingUrl"];
                [self executeVideoPlayer:streamingUrl];
                
            }else if([host isEqualToString:@"executeWebBack"]){
                [self rightBtnClick];
                
            }else if([host isEqualToString:@"getAccelerometer"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getAccelerometer:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getCheckSession"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getCheckSession:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getConvertImageToBase64"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *imagePath = [dic objectForKey:@"imagePath"];
                [self getConvertImageToBase64:callBackFunc :imagePath];
                
            }else if([host isEqualToString:@"getDeviceInfo"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getDeviceSpec:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getDeviceSpec"]){
                NSDictionary *dic = [self getParameters:[url query]];
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *specName = [dic objectForKey:@"specName"];
                if (specName!=nil) {
                    [self getDeviceSpec:callBackFunc :userSpecific :specName];
                }else{
                    [self getDeviceSpec:callBackFunc :userSpecific];
                }
                
            }else if([host isEqualToString:@"getFileList"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *directoryPath = [dic objectForKey:@"directoryPath"];
                [self getFileList:callBackFunc :userSpecific :directoryPath];
                
            }else if([host isEqualToString:@"getFilePath"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getFilePath:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getGpsLocation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getGpsLocation:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getGyroscope"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getGyroscope:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getMagneticField"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getMagneticField:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getMenuLocation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getMenuLocation:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getNetworkStatus"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getNetworkStatus:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getOrientation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"dic : %@",dic);
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getOrientation:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getPreference"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *keyList = [dic objectForKey:@"keyList"];
                [self getPreferences:callBackFunc :userSpecific :keyList];
                
            }else if([host isEqualToString:@"getProximity"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getProximity:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getUserInfo"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getUserInfo:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getWebHistory"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getWebHistory:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"setBackKeyEvent"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"setBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else if([host isEqualToString:@"setFileNames"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *fileList = [dic objectForKey:@"fileList"];
                [self setFileNames:fileList];
                
            }else if([host isEqualToString:@"setPreference"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *data = [dic objectForKey:@"data"];
                [self setPreferences:callBackFunc :userSpecific :data];
                
            }else if([host isEqualToString:@"setWebHistoryClear"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self setWebHistoryClear:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"isRoaming"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self isRoaming:callBackFunc :userSpecific];
                
            }
            return NO;
        }
        else {
            return YES;
        }
    }
    
    
    return YES;
    
}
-(void) webViewDidStartLoad:(UIWebView *)webView {
    
    //[mywebView addSubview:myIndicator];
    //[myIndicator startAnimating];
    /*
     activityAlert = [[[ActivityAlertView alloc] initWithTitle:nil
     message:@"페이지를 로딩중입니다"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:nil ] autorelease];
     
     [activityAlert show];
     */
    if (!flag) {
        self.progressView.hidden = NO;
        self.progressView.progress = 0.0f;
        flag = YES;
    }
    
}
-(void) webViewDidFinishLoad:(UIWebView *)webView {
    self.progressView.hidden = YES;
    [mywebView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    if([webView isLoading]){
        //NSLog(@"loading");
    }
    [self.locationManager stopUpdatingLocation];
    
    if ([_type isEqualToString:@"A3"]) {
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%f', '%f');",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude];
        [self evaluateJavaScript:jsCommand];
        
    }
    //NSLog(@"webView : %@",[webView request]);
    [webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    NSString *close = @"window.close=function(){ open('mfinity://windowClose'); };";
    close = [close stringByAppendingString:@"window.self.close=function(){ open('mfinity://windowClose'); };"];
    [webView stringByEvaluatingJavaScriptFromString:close];
    
//    if (appDelegate.inactivePushInfo != nil) {
//        [self throwPushNotification:appDelegate.inactivePushInfo];
//        appDelegate.inactivePushInfo = nil;
//    }
    
}
#pragma mark
#pragma mark Action Event Handler
- (void)errorButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked2:(UploadListViewController *)aSecondDetailViewController :(NSMutableArray *)returnArr{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    @try {
        if(returnArr!=nil){
            NSError *_error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnArr options:0 error:&_error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString URLEncode];
            
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
            NSLog(@"jsCommand : %@", jsCommand);
            
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        }
        
        if(self.isSync){
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:txtPath error:nil];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"SUCCEED" forKey:@"RESULT"];
            NSString *decString = [self getJsonStringByDictionary:dic];
            
            NSLog(@"upload result : %@",decString);
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                   _callbackFunc,
                                   _userSpecific,
                                   [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   ];
            
            [self evaluateJavaScript:jsCommand];
            self.isSync = NO;
        }else{
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
            imageInfo.imageURL = [NSURL URLWithString:appDelegate.target_url];
            
            //    imageInfo.referenceRect = self.bigImageButton.frame;
            //    imageInfo.referenceView = self.bigImageButton.superview;
            
            // Setup view controller
            JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                                      initWithImageInfo:imageInfo
                                                      mode:JTSImageViewControllerMode_Image
                                                      backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
            
            // Present the view controller.
            [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
        }
        
    } @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%s", __func__] message:[NSString stringWithFormat:@"%@", exception] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)cancelButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    NSLog(@"cancelButtonClicked");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isDMS = _isDMS;
    vc.isTabBar = _isTabBar;
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
    vc.navigationItem.backBarButtonItem=left;
    if (!_isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }else{
        vc.hidesBottomBarWhenPushed = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
-(void)getExecuteMenuInfo:(NSString *)menuNo pushNo:(NSString *)pushNo devNo:(NSString *)devNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    NSString *_paramString = [NSString stringWithFormat:@"menuNo=%@&cuserNo=%@&pushNo=%@&devNo=%@&encType=AES256",menuNo,appDelegate.user_no,pushNo,devNo];
    NSData *paramData = [_paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: paramData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn!=nil) {
        [SVProgressHUD show];
        receiveData = [[NSMutableData alloc]init];
    }
    [conn start];
}

-(void)throwPushNotification:(NSDictionary *)dictionary{
    NSLog(@"throwPushNotification dictionary : %@",dictionary);
    NSDictionary *aps = [dictionary objectForKey:@"aps"];
    
    NSDictionary *alertDict = [aps objectForKey:@"alert"];
    NSString *title = @"";
    NSString *body = @"";
    @try{
        if([alertDict objectForKey:@"title"]!=nil){
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if([title isEqualToString:@""]) title = appName;
            else title = [alertDict valueForKey:@"title"];
        }
        
        if([alertDict objectForKey:@"body"]!=nil){
            body = [alertDict valueForKey:@"body"];
        }
    } @catch(NSException *e){
        //푸시 라이브러리 변경전
        body = [aps objectForKey:@"alert"];
    }
    
    @try{
        NSString *_data = [dictionary objectForKey:@"data"];
        NSString *message = body;
        NSString *badge = [aps objectForKey:@"badge"];
        NSError *jsonError;
        NSData *plainData = [_data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:plainData options:NSJSONReadingMutableLeaves error:&jsonError];
        NSString *type = [data objectForKey:@"MSG_TYPE"];
        NSString *pushNo = [data objectForKey:@"PUSH_NO"];
        NSString *etc1 = [data objectForKey:@"ETC1"];
        NSString *etc2 = [data objectForKey:@"ETC2"];
        NSString *etc3 = [data objectForKey:@"ETC3"];
        NSString *etc4 = [data objectForKey:@"ETC4"];
        
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        [returnDic setObject:message forKey:@"MESSAGE"];
        [returnDic setObject:badge==nil?@"":badge forKey:@"BADGE"];
        [returnDic setObject:type==nil?@"":type forKey:@"TYPE"];
        [returnDic setObject:pushNo==nil?@"":pushNo forKey:@"PUSH_NO"];
        [returnDic setObject:etc1==nil?@"":etc1 forKey:@"ETC1"];
        [returnDic setObject:etc2==nil?@"":etc2 forKey:@"ETC2"];
        [returnDic setObject:etc3==nil?@"":etc3 forKey:@"ETC3"];
        [returnDic setObject:etc4==nil?@"":etc4 forKey:@"ETC4"];
        
        NSString *pushNotification = [self getJsonStringByDictionary:returnDic];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *callbackFunc = [prefs objectForKey:@"RECEIVE_PUSH_FUNC_NAME"];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callbackFunc,[pushNotification stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self evaluateJavaScript:jsCommand];
        
    }  @catch(NSException *e){
        NSLog(@"throwPushNotification e : %@", e);
    }
}

-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
//    NSString *alert = [aps objectForKey:@"alert"];
    
    NSDictionary *alertDict = [aps objectForKey:@"alert"];
    NSString *title = @"";
    NSString *body = @"";
    @try{
        if([alertDict objectForKey:@"title"]!=nil){
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if([title isEqualToString:@""]) title = appName;
            else title = [alertDict valueForKey:@"title"];
        }
        
        if([alertDict objectForKey:@"body"]!=nil){
            body = [alertDict valueForKey:@"body"];
        }
    } @catch(NSException *e){
        //푸시 라이브러리 변경전
        body = [aps objectForKey:@"alert"];
    }
    
    NSString *type = [userInfo objectForKey:@"type"];
    
    if ([type isEqualToString:@"E"]) {
        NSString *menuNo = [userInfo objectForKey:@"menuNo"];
        NSString *pushNo = [userInfo objectForKey:@"pushNo"];
        NSString *devNo = [userInfo objectForKey:@"devNo"];
        [self getExecuteMenuInfo:menuNo pushNo:pushNo devNo:devNo];
        
    }else{
        @try {
            NSString *jsCommand = [NSString stringWithFormat:@"CBPushMessage('%@');",body];
            [self evaluateJavaScript:jsCommand];
        } @catch (NSException *exception) {
            NSLog(@"msg exception : %@",exception);
        }
    } 
}
- (void)menuHandler{
    
    if ([menuKind isEqualToString:@"M"]) { //SubMenu
        MFTableViewController *subMenuList = [[MFTableViewController alloc]init];
        subMenuList.urlString = @"ezMainMenu2";
        [self.navigationController pushViewController:subMenuList animated:YES];
    
    } else if ([menuKind isEqualToString:@"P"]) { //실행메뉴일때
        if ([menuType isEqualToString:@"B1"]) {
            //바코드를 사용하는 메뉴일때
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Barcode" message:NSLocalizedString(@"message88", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                [self barCodeReaderOpen];
            }
            
        } else if ([menuType isEqualToString:@"B0"]) {
            
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Camera" message:NSLocalizedString(@"message89", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc] init];
                appDelegate.uploadURL = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                //NSLog(@"camera : paramString : %@",appDelegate.uploadURL);
                appDelegate.mediaControl = @"camera";
                //PictureController호출
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            
        } else if([menuType isEqualToString:@"B2"]){
            //Movie
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Video" message:NSLocalizedString(@"message89", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }else {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc] init];
                //appDelegate.menu_title = target_url;
                appDelegate.uploadURL = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                appDelegate.mediaControl = @"video";
                //PictureController호출
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else if ([menuType isEqualToString:@"C0"]) {
            
            NSString *url = appDelegate.target_url;
            if([url rangeOfString:@"://"].location==NSNotFound){
                url = [url stringByAppendingString:@"://"];
            }
            
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            NSString *current = [pref objectForKey:appDelegate.menu_no];
            current = [current stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *versionFromServer = currentAppVersion;
            versionFromServer = [versionFromServer stringByReplacingOccurrencesOfString:@"." withString:@""];
            url = [url stringByAppendingFormat:@"?%@",paramString];
            if (current.length==3) current = [current stringByAppendingString:@"00"];
            if (versionFromServer.length==3) versionFromServer = [versionFromServer stringByAppendingString:@"00"];
            
            NSLog(@"nativeAppURL : %@",nativeAppURL);
            @try {
                if ([nativeAppURL isEqualToString:@"#"]) {
                    BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                    if (!isInstall) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                        [alertView show];
                    }
                }else{
                    if ([pref objectForKey:appDelegate.menu_no]==nil) {
                        [pref setValue:currentAppVersion forKey:appDelegate.menu_no];
                        [pref synchronize];
                        NSURL *browser = [NSURL URLWithString:nativeAppURL];
                        [[UIApplication sharedApplication] openURL:browser];
                    }else if ([current intValue]!=[versionFromServer intValue]) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message94", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
                        [alertView show];
                    }else if([current intValue]==[versionFromServer intValue]){
                        BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                        if (!isInstall) {
                            NSURL *browser = [NSURL URLWithString:nativeAppURL];
                            [[UIApplication sharedApplication] openURL:browser];
                            
                        }
                    }
                }
                
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }
            
        } else if ([menuType isEqualToString:@"A1"]){
            appDelegate.isMainWebView = NO;
            NSString *passUrl = [NSString stringWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            NSURL *browser = [NSURL URLWithString:passUrl];
            [[UIApplication sharedApplication] openURL:browser];
            
        } else if([menuType isEqualToString:@"A2"]||[menuType isEqualToString:@"D0"]){
            appDelegate.isMainWebView = NO;
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *webAppFolder = [documentFolder stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,appDelegate.menu_no];
            NSString *htmlFilePath = [webAppFolder stringByAppendingFormat:@"/%@",appDelegate.target_url];
            if (![paramString isEqualToString:@""]) {
                appDelegate.paramString = paramString;
            }
            
            appDelegate.target_url = htmlFilePath;
            
            NSData *data = [NSData dataWithContentsOfFile:htmlFilePath];
            
            NSPropertyListFormat format;
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
            NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
            NSLog(@"dic : %@",dic);
            if (appDelegate.isOffLine) {
                if ([dic objectForKey:appDelegate.menu_no]!=nil && ![[dic objectForKey:appDelegate.menu_no] isEqualToString:currentAppVersion]) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message113", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                    
                }else if([dic objectForKey:appDelegate.menu_no]==nil){
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message114", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else {
                if (data==nil ||
                    [dic objectForKey:appDelegate.menu_no]==nil ||
                    ![[dic objectForKey:appDelegate.menu_no] isEqualToString:currentAppVersion]) {
                    
                    NSString *lastPath = [nativeAppURL lastPathComponent];
                    NSString *useDownloadURL = nativeAppURL;
                    NSString *temp=@"";
                    lastPath = [lastPath urlEncodeUsingEncoding:NSUTF8StringEncoding];
                    NSArray *pathArray = [useDownloadURL pathComponents];
                    for (int i=0; i<[pathArray count]-1; i++) {
                        temp = [temp stringByAppendingFormat:@"%@",[pathArray objectAtIndex:i]];
                        if ([temp isEqualToString:@"http:"]) {
                            temp = [temp stringByAppendingString:@"//"];
                        }else{
                            temp = [temp stringByAppendingString:@"/"];
                        }
                    }
                    NSMutableArray *_downloadUrlArray = [NSMutableArray array];
                    NSMutableArray *_menuTitles = [NSMutableArray array];
                    NSString *naviteAppDownLoadUrl = [temp stringByAppendingString:lastPath];
                    [_downloadUrlArray addObject:naviteAppDownLoadUrl];
                    [_menuTitles addObject:appDelegate.menu_title];
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]init];
                    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *compFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
                    NSString *commonFolder = [compFolder stringByAppendingPathComponent:@"webapp"];
                    commonFolder = [commonFolder stringByAppendingPathComponent:@"common"];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    if ([prefs objectForKey:@"COMMON_DOWNLOAD"]!=nil) {
                        BOOL isCommon = [fileManager isReadableFileAtPath:commonFolder];
                        if (!isCommon){
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            [_downloadUrlArray addObject:[prefs objectForKey:@"COMMON_DOWNLOAD"]];
                            [_menuTitles addObject:@"COMMON"];
                        }
                    }
                    
                    DownloadListViewController *vc = [[DownloadListViewController alloc]init];
                    
                    vc.downloadNoArray = [NSMutableArray arrayWithArray:@[nativeAppMenuNo]];
                    vc.downloadVerArray = [NSMutableArray arrayWithArray:@[currentAppVersion]];
                    
                    vc.downloadUrlArray = _downloadUrlArray;
                    vc.downloadMenuTitleList = _menuTitles;
                    vc.delegate = self;
                    //vc.view.frame = CGRectMake(0, 0, 320, 100);
                    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                    nvc.navigationBarHidden=NO;
                    int increaseRow = 0;
                    for (int i=1; i<[_downloadUrlArray count]; i++) {
                        increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
                    }
                    if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
                    
                    nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
                    [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
                   
                }else{
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            
        } else if ([menuType isEqualToString:@"A0"]||[menuType isEqualToString:@"A4"]){
            //Mobile web 메뉴일때
            NSString *page_url;
            if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            appDelegate.target_url = page_url;
            appDelegate.isMainWebView = NO;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
            
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if ([menuType isEqualToString:@"A3"]){
            NSString *page_url;
            appDelegate.isMainWebView = NO;
            
            if ([paramString isEqualToString:@""])
                page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else
                page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            
            appDelegate.target_url = page_url;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.type = @"A3";
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
}
-(void) addMenuHist:(NSString *)menu_no {

    if (!appDelegate.isOffLine) {
        if ([appDelegate.demo isEqualToString:@"DEMO"]) {
            [self menuHandler];
        }else{
            [SVProgressHUD show];
            NSString *menuHitURL;
            NSString *paramStr;
            if (appDelegate.isAES256) {
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addMenuHist",appDelegate.main_url];
                paramStr = [[NSString alloc]initWithFormat:@"cuser_no=%@&menu_no=%@&encType=AES256",appDelegate.user_no,menu_no];
            }else{
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addMenuHist",appDelegate.main_url];
                paramStr = [[NSString alloc]initWithFormat:@"cuser_no=%@&menu_no=%@",appDelegate.user_no,menu_no];
                
            }
            NSLog(@"menuHitURL : %@",menuHitURL);
            NSLog(@"menuHitParam : %@",paramStr);
            
            NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSURL *rankUrl = [NSURL URLWithString:menuHitURL];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody: postData];
            
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (urlCon) {
                histData = [[NSMutableData alloc]init];
            }
            [urlCon start];
        }
    }else{
        [self menuHandler];
    }
    
}

-(void)rightBtnClick {
    NSLog(@"%s", __func__);

    if (_backMode) {
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",_backDefineFunc,_backUserSpecific];
        [self evaluateJavaScript:jsCommand];
    }else{
//        if (IS_OS_8_OR_LATER) {
            if ([_webView canGoBack]) {
                [_webView goBack];
            }else{
                if (![self.webView isEqual:[self.webViews objectAtIndex:0]]) {
                    NSLog(@"before webview count : %lu",(unsigned long)[self.webViews count]);
                    WKWebView *webview = [self.webViews lastObject];
                    [webview removeFromSuperview];
                    [self.webViews removeLastObject];
                    NSLog(@"after webview count : %lu",(unsigned long)[self.webViews count]);
                    self.webView = [self.webViews lastObject];
                }
            }
    }
}

#pragma mark
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message91", @"")]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        [_webView reload];
        //[mywebView reload];
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message201", @"")]){
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }
        
    }
    
}
#pragma mark
#pragma mark WebViewController Utils
- (void)evaluateJavaScript:(NSString *)jsCommand{
    NSLog(@"jsCommand : %@",jsCommand);
    
    NSLog(@"self.webView : %@", self.webView);
    NSLog(@"newWebView : %@", newWebView);
    
    if(newWebView!=nil){
        [newWebView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
         {
             //result == title
             NSLog(@"%s result : %@",__FUNCTION__,result);
             NSLog(@"%s error : %@",__FUNCTION__,error);
             
             NSLog(@"newWebView customUserAgent : %@",newWebView.customUserAgent);
         }];
        
    } else {
        [self.webView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
         {
             //result == title
             NSLog(@"%s result : %@",__FUNCTION__,result);
             NSLog(@"%s error : %@",__FUNCTION__,error);
             
             NSLog(@"self.webView customUserAgent : %@",self.webView.customUserAgent);
         }];
    }
}

- (void) playbackDidFinish:(NSNotification *)noti {
    MPMoviePlayerController *player = [noti object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self dismissMoviePlayerViewControllerAnimated];
    
}

- (NSString *)makeDBFile{
    NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"Application Support"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"dbvalley"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"sqlite_db"];
    NSString *userPath = [libraryPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    NSString *dbFilePath = [userPath stringByAppendingPathComponent:@"mFinity.db"];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mFinity.sqlite" ofType:nil];
    NSError *error;
    
    if (![manager isReadableFileAtPath:userPath]) {
        [manager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![manager isReadableFileAtPath:dbFilePath]) {
        [manager copyItemAtPath:filePath toPath:dbFilePath error:&error];
    }
    
    return libraryPath;
}
-(void)myLocation:(id)sender {
    if ([_type isEqualToString:@"A3"]) {
        [self.locationManager startUpdatingLocation];
        NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%@', '%@');",[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
    }
}


-(NSDictionary *)getParameters:(NSString *)query{
    NSArray *params = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[params count]; i++) {
        NSArray *tmpArr = [[params objectAtIndex:i] componentsSeparatedByString:@"="];
        NSString *keyString = [NSString urlDecodeString:[tmpArr objectAtIndex:0]];
        NSString *valueString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
        [returnDic setObject:valueString forKey:keyString];
    }
    
    return returnDic;
}

-(NSString *)getPhotoFilePath{
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *photoFolder = @"photo";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@/",photoFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        NSLog(@"directory success");
    }else{
        NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
}
- (void)signSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc{
    NSLog(@"fileName : %@",fileName);
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) {
        NSLog(@"exist file");
    }else{
        NSLog(@"not exist file");
    }
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"jsCommand : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
- (void)signSave:(NSString *)fileName{
    NSLog(@"fileName : %@",fileName);
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"CBSignPad('%@','%@');",[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[fileName lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
- (void)photoSave:(NSString *)fileName{
    _imgFileName = fileName;
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"photoSave('%@','%@');",[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[fileName lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
- (void)photoSave:(NSString *)fileName :(NSString *)userSpectific :(NSString *)callbackFunc{
    NSLog(@"photoSave");
    _imgFileName = fileName;
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSData *data = [NSData dataWithContentsOfFile:txtPath];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"str : %@",str);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"PhotoSave jsCommand : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
//이게 호출됨
-(void)dbConnection:(NSString *)page :(NSString *)crud :(NSString *)sql :(NSString *)dbName :(NSString *)cbName{
    
    sqlite3 *database;
    /*
     NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     documentPath = [documentPath stringByAppendingPathComponent:@"app_oracle.sync"];
     documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
     documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
     NSString *dbPath = [dbName stringByAppendingPathExtension:@"db"];
     documentPath = [documentPath stringByAppendingPathComponent:dbPath];
     */
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                        NSLog(@"value null");
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                    
                    
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (rowCount==0) {
                returnStr = @"null";
            }
            
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        NSLog(@"returnStr : %@",returnStr);
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
}
-(void)oldDbConnection:(NSString *)gubn :(NSString *)crud :(NSString *)sql :(NSString *)dbName{
    sqlite3 *database;
    NSLog(@"dbname : %@",dbName);
    NSLog(@"gubn : %@",gubn);
    NSLog(@"sql : %@",sql);
    NSLog(@"crud : %@",crud);
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    //NSLog(@"sqlite3_open([documentPath UTF8String], &database : %d",sqlite3_open([dbName UTF8String], &database));
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    
                    NSString *valueString = nil;
                    //NSData *valueData = nil;
                    
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                    
                    //NSLog(@"valueData : %@",valueData);
                    
                    
                    
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            NSLog(@"returnStr : %@",returnStr);
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
        //NSLog(@"not db open");
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
    
}
-(void)dbConnection:(NSString *)gubn :(NSString *)crud :(NSString *)sql :(NSString *)dbName{
    sqlite3 *database;
    NSLog(@"dbname : %@",dbName);
    NSLog(@"gubn : %@",gubn);
    NSLog(@"sql : %@",sql);
    NSLog(@"crud : %@",crud);
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    //NSLog(@"sqlite3_open([documentPath UTF8String], &database : %d",sqlite3_open([dbName UTF8String], &database));
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            NSLog(@"returnStr : %@",returnStr);
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
        //NSLog(@"not db open");
    }
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
}

#pragma mark
#pragma mark MFNP EXECUTE
-(void) executeBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific{
    _backDefineFunc = callBackFunc;
    _backUserSpecific = userSpecific;
}
-(void)executeBarcode:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    [self barCodeReaderOpen];
}
-(void)executeCamera:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)format :(NSString *)size{
    NSLog(@"%s", __func__);
    
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    isCamera = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSLog(@"picker : %@",picker);
        [self presentViewController:picker animated:YES completion:NULL];
    }else{
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
}
-(void)executeDataGate:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)dbConfigKey :(NSString *)sprocName :(NSString *)args{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    [_callBackDic setValue:[dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"dbConfigKey"];
    [_callBackDic setValue:[sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"sprocName"];
    [_callBackDic setValue:[args urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"args"];
    
    NSString *_dbConfigKey =[FBEncryptorAES encryptBase64String:dbConfigKey
                                                      keyString:appDelegate.AES256Key
                                                  separateLines:NO];
    NSString *_sprocName =[FBEncryptorAES encryptBase64String:sprocName
                                                    keyString:appDelegate.AES256Key
                                                separateLines:NO];
    NSString *_args =[FBEncryptorAES encryptBase64String:args
                                               keyString:appDelegate.AES256Key
                                           separateLines:NO];
    NSString *_compNo =[FBEncryptorAES encryptBase64String:appDelegate.comp_no
                                                 keyString:appDelegate.AES256Key
                                             separateLines:NO];
    NSLog(@"dbConfigKey : %@",dbConfigKey);
    NSLog(@"sprocName : %@",sprocName);
    NSLog(@"args : %@",args);
    NSLog(@"appDelegate.comp_no : %@",appDelegate.comp_no);
    //NSString *mainString = [appDelegate.main_url stringByReplacingOccurrencesOfString:@"dataservice41" withString:@""];
    //NSString *mainString = @"http://192.168.0.54:1598/";
    NSString *urlString = [NSString stringWithFormat:@"%@/DataGate3",appDelegate.main_url];
    NSString *param = [[NSString alloc]initWithFormat:@"jsonPCallback=?&dbConfigKey=%@&sprocName=%@&args=%@&jsonPCallback?&compNo=%@&encType=AES256",[_dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding],[_sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding],[_args urlEncodeUsingEncoding:NSUTF8StringEncoding],[_compNo urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"paramString : %@",param);
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (urlConnection) {
        receiveData = [NSMutableData data];
        [urlConnection start];
    }
    
}
-(void) executeExitWebBrowser{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)executeFileUploadReturn:(NSNotification *)notification {
    NSLog(@"executeFileUploadReturn userinfo : %@", notification.userInfo);
    NSArray *returnArr = [notification.userInfo objectForKey:@"RETURN"];
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if(returnArr!=nil){
        NSError *_error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnArr options:0 error:&_error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding]; //[jsonString URLEncode];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
        NSLog(@"jsCommand : %@", jsCommand);
        
        [self evaluateJavaScript:jsCommand];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"executeFileUploadReturn" object:nil];
    }
}
-(void)executeFileUpload:(NSString *)callBackFunc :(NSString *)userSpecific :(NSArray *)dataArr{
    self.callbackFunc = callBackFunc;
    self.userSpecific = userSpecific;
    
    NSLog(@"dataArr : %@", dataArr);
    //NSLog(@"dataArr 0 : %@", [dataArr objectAtIndex:0]);
    
    @try{
        BOOL flag = false;
        
        NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
        NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[dataArr count]; i++) {
            [uploadFilePathArray addObject:[[dataArr objectAtIndex:i] objectForKey:@"file_src"]];
            [uploadUrlArray addObject:[[dataArr objectAtIndex:i] objectForKey:@"upload_url"]];
            flag = [[[dataArr objectAtIndex:i] objectForKey:@"flag"] boolValue];
        }
        
        [self fileUploads:uploadFilePathArray :uploadUrlArray :flag];
    
    } @catch(NSException *exception){
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
-(void)executeFileUpload:(NSString *)callBackFunc :(NSString *)userSpecific :(NSDictionary *)fileList :(NSString *)upLoadPath :(BOOL)flag{
    NSLog(@"callBackFunc : %@", callBackFunc);
    NSLog(@"userSpecific : %@", userSpecific);
    NSLog(@"fileList : %@", fileList);
    NSLog(@"upLoadPath : %@", upLoadPath);
    NSLog(@"flag : %d", flag);
    
    self.callbackFunc = callBackFunc;
    self.userSpecific = userSpecific;
    
    @try {
        NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
        NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
        for (int i=0; i<[fileList count]; i++) {
            [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
            [uploadUrlArray addObject:upLoadPath];
        }
        NSLog(@"uploadFilePathArray : %@", uploadFilePathArray);
        NSLog(@"uploadUrlArray : %@", uploadUrlArray);
        
        [self fileUploads:uploadFilePathArray :uploadUrlArray :flag];
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

-(void)fileUploads:(NSMutableArray *)uploadFilePathArray :(NSMutableArray *)uploadUrlArray :(BOOL)flag{
    @try {
        UploadListViewController *vc = [[UploadListViewController alloc]init];
        vc.uploadFilePathArray = uploadFilePathArray;
        vc.uploadUrlArray = uploadUrlArray;
        vc.deleteFlag = flag;
        vc.delegate = self;
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        nvc.navigationBarHidden=NO;
        int increaseRow = 0;
        for (int i=1; i<[uploadFilePathArray count]; i++) {
            increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
        }
        if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
        
        nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
        [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);

    }
}
-(void)executeImageEditor:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)imagePath{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    
    UIImage *image = nil;
    
    if ([imagePath hasPrefix:@"http://"]||[imagePath hasPrefix:@"https://"]) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
    } else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    if(image.size.width>image.size.height){
        image = [self setResizeImage:image :816 :YES];
    } else {
        image = [self setResizeImage:image :816 :NO];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ImageDrawViewController *vc = (ImageDrawViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImageDrawViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.getBgImg = image;
    vc.bgImgPath = imagePath;
    vc.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}
-(void)returnEditImage:(NSString *)imgPath{
    self.userSpecific = [self.userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding];
    imgPath = [imgPath urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",self.callbackFunc,self.userSpecific,imgPath];
    NSLog(@"jsCommand : %@", jsCommand);
    //[mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)executeFlashLight:(NSString *)callbackFunc :(NSString *)userSpecific{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSString *jsCommand;
    
    if(!isFlash){
        isFlash = true;
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
        jsCommand = [NSString stringWithFormat:@"%@('%@','ON');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        isFlash = false;
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        jsCommand = [NSString stringWithFormat:@"%@('%@','OFF');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeLogout{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [conn start];
}
-(void)executeMediaRecorder:(NSString *)callbackFunc :(NSString *)userSpecific{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    NSString *filename = appDelegate.user_no;
    filename = [filename stringByAppendingString:@"("];
    
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@")"];
    filename = [filename stringByAppendingFormat:@".m4a"];
    
    NSString *voiceFilePath = [self getVoiceFilePath];
    NSArray *pathComponents = [NSArray arrayWithObjects: voiceFilePath, filename, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSLog(@"outputFileURL : %@", outputFileURL);
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    
    [self.recorder prepareToRecord];
    [session setActive:YES error:nil];
    [self.recorder record];
    
    NSDictionary *resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"true",@"status", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",callbackFunc,userSpecific,jsonString];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(NSString *)getVoiceFilePath{
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *photoFolder = @"voice";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@/",photoFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        NSLog(@"directory success");
    }else{
        NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
}
-(void)executeExitMediaRecorder:(NSString *)callbackFunc :(NSString *)userSpecific{
    [self.recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    //play
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    [self.player setDelegate:self];
    [self.player play];
    
    NSDictionary *resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false", @"status", [NSString stringWithFormat:@"%@", self.recorder.url], @"Path", nil];
    //NSLog(@"resultDic : %@", resultDic);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",callbackFunc,userSpecific,jsonString];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}
-(void)executeMenu:(NSString *)menuNo{
    [self getExecuteMenuInfo:menuNo pushNo:@"" devNo:@""];
}
-(void)executeNonQuery:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    //self.dbDirectoryPath;
    
    documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    NSLog(@"appDelegate.user_id : %@",appDelegate.user_id);
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"documentPath : %@",documentPath);
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    sqlite3 *database;
    
    NSString *returnStr = @"";
    if (sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = [NSString urlDecodeString:selectStmt];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                NSLog(@"Error updating table: %s", sqlite3_errmsg(database));
                
                NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
                returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
                returnStr = [returnStr stringByAppendingString:@"\"}"];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
                
            }else{
                returnStr = @"{\"RESULT\":\"SUCCEED\"}";
            }
            
            if(sqlite3_finalize(compiledStatement) != SQLITE_OK){
                NSLog(@"SQL Error : %s",sqlite3_errmsg(database));
                NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
                returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
                returnStr = [returnStr stringByAppendingString:@"\"}"];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            }
            
            
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
            returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
            returnStr = [returnStr stringByAppendingString:@"\"}"];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeNonQuery : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
}
-(void)executeNotification:(NSString *)useVibrator :(NSString *)useBeep :(NSString *)timer{
    count=0;
    endCount=[timer intValue];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:useVibrator,@"useVibrator",useBeep,@"useBeep", nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(handleTimer:)
                                   userInfo:userInfo
                                    repeats:YES];
    
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    
    if (count==endCount) {
        count=0;
        
        if ([[timer.userInfo objectForKey:@"useVibrator"] isEqualToString:@"true"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        if ([[timer.userInfo objectForKey:@"useBeep"] isEqualToString:@"true"]) {
            AudioServicesPlaySystemSound(1106);
            //AudioServicesPlayAlertSound(1057);
        }
        [timer invalidate];
    }
}
-(void)executePush:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)userList :(NSString *)message{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSString *urlString = [NSString stringWithFormat:@"%@/sendPushService",appDelegate.main_url];
    //NSString *urlString = @"http://192.168.0.54:1598/dataservice41/sendPushService";
    NSLog(@"urlString : %@",urlString);
    NSLog(@"message : %@",message);
    NSLog(@"userList : %@",dic);
    
    NSString *_paramString = [NSString stringWithFormat:@"encType=AES256&mode=C&msg=%@&userList=%@",message,dic];
    
    NSData *paramData = [_paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: paramData];
    [request setTimeoutInterval:10.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (conn) {
        receiveData = [NSMutableData data];
    }
}
-(void) executeRecognizeSpeech:(NSString *)callbackFunc :(NSString *)userSpecific{
    [self startRecording:callbackFunc :userSpecific :nil];
}

-(void)executeRecognizeSpeech:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)succession{
    [self startRecording:callbackFunc :userSpecific :succession];
}

-(void)executeExitRecognizeSpeech:(NSString *)callbackFunc :(NSString *)userSpecific{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    
    [audio stop];
    [inputNode removeTapOnBus:0];
    
    request = nil;
    task = nil;
    NSDictionary *resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false", @"status", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc, userSpecific, jsonString];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeRetrieve:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSString *returnStr = @"";
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    sqlite3 *database;
    if (sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = selectStmt;
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            returnStr = @"{\"RESULT\":\"SUCCEED\",";
            
            //NSMutableDictionary *row = [[NSMutableDictionary alloc]init];
            
            int rowCount = 0;
            returnStr = [returnStr stringByAppendingFormat:@"\"DATASET\":{"];
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                NSString *LKey = [NSString stringWithFormat:@"ROW%d",i++];
                
                returnStr = [returnStr stringByAppendingFormat:@"\"%@\":{",LKey];
                //NSMutableDictionary *dataSet = [[NSMutableDictionary alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                        
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"\"%@\":\"%@\",",keyString,valueString];
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                returnStr = [returnStr stringByAppendingFormat:@"},"];
            }
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            if(rowCount==0){
                returnStr = [returnStr stringByAppendingFormat:@"\"\"}"];
            }else{
                returnStr = [returnStr stringByAppendingFormat:@"}}"];
            }
            
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
            returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
            returnStr = [returnStr stringByAppendingString:@"\"}"];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    NSLog(@"returnStr : %@",returnStr);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeRetrive : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeSignpad:(NSString *)callBackFunc :(NSString *)userSpecific{
    SignPadViewController *vc = [[SignPadViewController alloc]init];
    vc.userSpecific = userSpecific;
    vc.callbackFunc = callBackFunc;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    //[self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:nvc animated:YES completion:nil];
}
-(void) executeSms:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)msg :(NSString *)userList{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSError *error;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding: NSUTF8StringEncoding] options:kNilOptions error:&error];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSString *user in [dataDic allValues]) {
        NSString *inValue = [user stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [array addObject:inValue];
    }
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = msg;
        controller.recipients = array;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        //[self presentModalViewController:controller animated:YES];
    }
}
-(void) executeVideoPlayer:(NSString *)streamingUrl{ //20181031 호출부분 추가해야함
    NSLog(@"streamingUrl : %@",streamingUrl);
    NSURL *movieURL = [NSURL URLWithString:streamingUrl];
    MPMoviePlayerViewController *playView = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
    MPMoviePlayerController *moviePlayer = [playView moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:playView];
}

#pragma mark
#pragma mark MFNP GET
-(void)getAccelerometer:(NSString *)callBackFunc :(NSString *)userSpecific{
    // Create a CMMotionManager
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogUserAccelerationData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopAccelerometer) withObject:self afterDelay:1.0];
}

-(void)stopAccelerometer{
    [_myDataLogger stopLoggingMotionDataAndSave];
    
    NSArray *accelorInfo = [_myDataLogger.userAccelerationString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:3] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void) getCheckSession:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSString *sessionURL = [NSString stringWithFormat:@"%@/CheckSession",appDelegate.main_url];
    NSURL *url = [NSURL URLWithString:sessionURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (conn) {
        receiveData = [NSMutableData data];
    }
}
-(void)getConvertImageToBase64:(NSString *)callBackFunc :(NSString *)imagePath {
    /*
     Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
     ByteArrayOutputStream outStream = new ByteArrayOutputStream();
     bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream);
     byte[] image = outStream.toByteArray();
     String fileImageBase64 = Base64.encodeToString(image, 0);
     
     JSONObject json = new JSONObject();
     File file = new File(imagePath);
     json.put("title",file.getName().toString());
     json.put("value", fileImageBase64);
     
     String result = "javascript:"+callbackFunc+"('"+json+"')";
     Message msg = mfnpHandler.obtainMessage();
     msg.what = 6;
     msg.obj = result;
     mfnpHandler.sendMessage(msg);
     */
    
    //NSString *_imagePath = [self getPhotoFilePath];
    //_imagePath = [_imagePath stringByAppendingFormat:@"/%@",];
    //_imagePath = [_imagePath stringByAppendingPathExtension:imagePath];
    
    NSLog(@"callBackFunc : %@", callBackFunc);
    NSLog(@"imagePath : %@", imagePath);
    
    NSRange range = [imagePath rangeOfString:@"." options:NSBackwardsSearch];
    NSString *fileExt = [[imagePath substringFromIndex:range.location+1] lowercaseString];
    
    NSString *dataType = [NSString stringWithFormat:@"data:image/%@;base64,", fileExt];
    if([fileExt isEqualToString:@"png"]){
        dataType = @"data:image/png;base64,";
    } else {
        dataType = @"data:image/jpeg;base64,";
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:[imagePath lastPathComponent] forKey:@"title"];
    [returnDic setObject:[dataType stringByAppendingString:base64] forKey:@"value"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
  
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callBackFunc,jsonString];
    NSLog(@"jsCommand : %@", jsCommand);

    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)specName{
    NSDictionary *deviceSpec = [self getDeviceSpec];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[deviceSpec objectForKey:specName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *spec = [self getJsonStringByDictionary:[self getDeviceSpec]];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[spec stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(NSDictionary *)getDeviceSpec{
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = @"iOS";
    NSString *osVersion = myDevice.systemVersion;
    // 통신사
    //CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    //CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    // Get carrier name
    //NSString *carrierName = [carrier carrierName];
    
    NSString *production = @"Apple";
    //해상도
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    if ([self retinaDisplayCapable]) {
        screenHeight = screenHeight*2;
        screenWidth = screenWidth*2;
    }
    NSString *width = [NSString stringWithFormat:@"%f",screenWidth];
    width = [width stringByDeletingPathExtension];
    NSString *height = [NSString stringWithFormat:@"%f",screenHeight];
    height = [height stringByDeletingPathExtension];
    NSString *resolution = [width stringByAppendingString:@"*"];
    resolution = [resolution stringByAppendingString:height];
    
    //가속도 센서
    NSString *isAccelerometer = @"";
    if ([self accelerometerAvailable]) {
        isAccelerometer = @"YES";
    }else{
        isAccelerometer = @"NO";
    }
    //g센서
    
    NSString *isGyroscope = @"";
    if ([self gyroscopeAvailable]) {
        isGyroscope = @"YES";
    }else{
        isGyroscope = @"NO";
    }
    
    //자기장센서
    NSString *isMagnetometer = @"";
    if ([self compassAvailable]) {
        isMagnetometer = @"YES";
    }else{
        isMagnetometer = @"NO";
    }
    
    //방향센서
    NSString *isDirection = @"";
    if ([self accelerometerAvailable]) {
        isDirection = @"YES";
    }else{
        isDirection = @"NO";
    }
    
    //근접센서
    NSString *isProximity = @"";
    UIDevice *device = [UIDevice currentDevice];
    if(device.proximityMonitoringEnabled){
        isProximity = @"YES";
    }else{
        isProximity = @"NO";
    }
    
    //gps
    NSString *isGPS = @"";
    if ([self gpsAvailable]) {
        isGPS = @"YES";
    }else{
        isGPS = @"NO";
    }
    //camera
    //NSString *isCamera = [self isValue:@"still-camera"];
    NSString *_isCamera = @"";
    if ([self linearCameraAvailable]) {
        _isCamera = @"YES";
    }else{
        _isCamera = @"NO";
    }
    //front_camera
    //NSString *isFrontCamera = [self isValue:@"front-facing-camera"];
    NSString *isFrontCamera = @"";
    if ([self frontCameraAvailable]) {
        isFrontCamera = @"YES";
    }else{
        isFrontCamera = @"NO";
    }
    
    //cpu core
    NSString *coreCount = [NSString stringWithFormat:@"%d",[self countCores]];
    
    NSString *appType = @"Phone";
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *modelName = [[UIDevice currentDevice] modelName];
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:modelName  forKey:@"modelName"];
    [returnDic setObject:coreCount  forKey:@"cpuCore"];
    [returnDic setObject:production forKey:@"manufacturer"];
    [returnDic setObject:resolution forKey:@"resolution"];
    
    [returnDic setObject:isAccelerometer forKey:@"accelerometer"];
    [returnDic setObject:isGyroscope forKey:@"gyroscope"];
    [returnDic setObject:isMagnetometer forKey:@"magnet"];
    [returnDic setObject:isDirection forKey:@"orientation"];
    [returnDic setObject:isGPS forKey:@"gps"];
    [returnDic setObject:_isCamera forKey:@"stillcam"];
    [returnDic setObject:isFrontCamera forKey:@"frontcam"];
    
    [returnDic setObject:osName forKey:@"osType"];
    [returnDic setObject:osVersion forKey:@"osVersion"];
    [returnDic setObject:appType forKey:@"appType"];
    [returnDic setObject:appVersion forKey:@"appVersion"];
    
    return returnDic;
}
-(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
-(void)getFilePath:(NSString *)callBackFunc :(NSString *)userSpecific {
    NSString *photoPath = [self getPhotoFilePath];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (void)getFileList:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)_directoryPath{
    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directoryPath error:nil];
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc]init];
    for(int i=0; i<list.count; i++){
        NSMutableDictionary *rowDic = [[NSMutableDictionary alloc]init];
        NSString *filename = [list objectAtIndex:i];
        NSString *filepath = [_directoryPath stringByAppendingPathComponent:filename];
        [rowDic setObject:filename forKey:@"filename"];
        [rowDic setObject:filepath forKey:@"filepath"];
        NSString *keyName = [NSString stringWithFormat:@"ROW%d",i];
        [contentDic setObject:rowDic forKey:keyName];
    }
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:contentDic forKey:@"DATASET"];
    [returnDic setObject:@"SUCCEED" forKey:@"RESULT"];
    NSLog(@"returnDic : %@",returnDic);
    NSString *returnString = [self getJsonStringByDictionary:returnDic];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnString urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}


-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific {
    // Location Manager 생성
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    /*
     if([CLLocationManager locationServicesEnabled]){
     
     NSLog(@"Location Services Enabled");
     }*/
    /*
     if (self.locationManager.location.coordinate.latitude==0 && self.locationManager.location.coordinate.longitude==0) {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
     }*/
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    NSString *jsCommand;
    if (userSpecific == nil) {
        jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.locationManager stopUpdatingLocation];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

-(void)getGyroscope:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    if( motionManager.gyroAvailable )
    {
        motionManager.gyroUpdateInterval = 1.0 / 10.0;
        [motionManager startGyroUpdatesToQueue:queue withHandler:
         ^(CMGyroData* gyroData, NSError* error )
         {
             if( error )
             {
                 [motionManager stopGyroUpdates];
                 NSLog(@"%@",[NSString stringWithFormat:@"Gyroscope encountered error: %@", error]);
             }
             else
             {
                 sensorString = [NSString stringWithFormat:
                                 @"%f,%f,%f",
                                 gyroData.rotationRate.x,
                                 gyroData.rotationRate.y,
                                 gyroData.rotationRate.z];
             }
             
         }];
        [self performSelector:@selector(stopGyroscope) withObject:self afterDelay:1.0];
        
    }
    else
    {
        NSLog(@"This device has no gyroscope");
    }
    
}
-(void)stopGyroscope{
    [motionManager stopGyroUpdates];
    NSArray *accelorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
}
-(void)getMagneticField:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    if(motionManager.gyroAvailable)
    {
        motionManager.gyroUpdateInterval = 1.0 / 10.0;
        [motionManager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
            CMMagneticField field = magnetometerData.magneticField;
            sensorString = [NSString stringWithFormat:
                            @"%f,%f,%f",
                            field.x,
                            field.y,
                            field.z];
            
        }];
        [self performSelector:@selector(stopMagneticField) withObject:self afterDelay:1.0];
        
    }
    else
    {
        NSLog(@"This device has no gyroscope");
    }
    
}
-(void)getMenuLocation:(NSString *)callbackFunc :(NSString *)userSpecific{
    NSString *result = mywebView.request.URL.absoluteString;
    
    NSRange range = [result rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *menuLoc = [result substringToIndex:range.location];
    
    NSDictionary *resultDic = [[NSDictionary alloc]initWithObjectsAndKeys: menuLoc, @"MENU_PATH", nil];
    NSLog(@"resultDic : %@", resultDic);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc, userSpecific, jsonString];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)stopMagneticField{
    [motionManager stopMagnetometerUpdates];
    NSArray *sensorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getOrientation:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogRotationRateData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopRotationRate) withObject:self afterDelay:1.0];
}
-(void)stopRotationRate{
    [_myDataLogger stopLoggingMotionDataAndSave];
    NSArray *accelorInfo = [_myDataLogger.rotationRateString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[accelorInfo objectAtIndex:0] URLEncode],[[accelorInfo objectAtIndex:1] URLEncode],[[accelorInfo objectAtIndex:2] URLEncode]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getNetworkStatus:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *result = [MFinityAppDelegate deviceNetworkingType];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (void)getPreferences:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)keyList{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    //NSLog(@"keyList : %@", keyList);
    
    NSString *result;
    if (keyList == nil || [keyList isEqualToString:@"undefined"]) {
        result = [NSString stringWithFormat:@"%@",[appDelegate getJsonStringByDictionary: [self getConfigProperties]]];
        
    }else{
        NSArray *keyArr = [NSArray array];
        NSLog(@"keyList : %@", keyList);
        
        if([keyList rangeOfString:@"["].location != NSNotFound && [keyList rangeOfString:@"]"].location != NSNotFound){
            keyList = [keyList stringByReplacingOccurrencesOfString:@"[" withString:@""];
            keyList = [keyList stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            if([keyList rangeOfString:@","].location != NSNotFound){
                keyArr = [keyList componentsSeparatedByString:@","];
            } else {
                keyArr = @[keyList];
            }
        }
        
        //NSArray *keys = [NSJSONSerialization JSONObjectWithData:[keyList dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        result = [NSString stringWithFormat:@"%@",[appDelegate getJsonStringByDictionary: [self getConfigPropertiesWithKeys:keyArr]]];
    }
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",callbackFunc,userSpecific,result];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (NSDictionary *)getConfigProperties{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingPathComponent:@"Config.plist"];
    
    NSPropertyListFormat format;
    NSError *error;
    NSDictionary *currentConfig = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    
    return currentConfig;
}
- (NSDictionary *)getConfigPropertiesWithKeys:(NSArray *)keys{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingPathComponent:@"Config.plist"];
    
    NSPropertyListFormat format;
    NSError *error;
    NSDictionary *currentConfig = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    //NSLog(@"currentConfig : %@", currentConfig);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for(int i=0; i<keys.count; i++){
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [currentConfig objectForKey:key];
        @try {
            [dic setObject:value forKey:key];
        } @catch (NSException *exception) {
            [dic setObject:@"" forKey:key];
        }
    }
    return dic;
}
-(void)getProximity:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    UIDevice *device = [UIDevice currentDevice];
    //device.proximityMonitoringEnabled = YES;
    NSLog(@"device.proximityMonitoringEnabled : %@",device.proximityMonitoringEnabled?@"YES":@"NO");
    if (device.proximityMonitoringEnabled == YES){
        NSLog(@"proximityMonitoringEnabled");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:@"UIDeviceProximityStateDidChangeNotification" object:device];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Proximity" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}
- (void) proximityChanged:(NSNotification *)notification {
    UIDevice *device = [notification object];
    NSLog(@"In proximity: %i", device.proximityState);
}
-(void)getUserInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    /*
     String callbackFunc = singleton.getUrlDecode(m_callbackFunc);
     String userSpecific = singleton.getUrlDecode(m_userSpecific);
     JSONObject userJson = new JSONObject();
     userJson.put("UserId", singleton.UserId);
     TelephonyManager telManager = (TelephonyManager)getActivity().getSystemService(Context.TELEPHONY_SERVICE);
     if (telManager.getLine1Number() != null && !telManager.getLine1Number().equals("")) userJson.put("PhoneNum", telManager.getLine1Number());
     else userJson.put("PhoneNum", "NONE");
     Locale language = getResources().getConfiguration().locale;
     userJson.put("DeviceLanguage", language.getLanguage());
     webbrowser_webview.loadUrl("javascript:"+callbackFunc+"('"+userSpecific+"','"+userJson+"')");
     */
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:appDelegate.user_id forKey:@"UserId"];
    [returnDic setObject:@"NONE" forKey:@"PhoneNum"];
    [returnDic setObject:language forKey:@"DeviceLanguage"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSString *jsCommand = [NSString stringWithFormat:@"callbackUserInfo2('%@');",jsonString];
    //NSString *jsCommand = @"callbackUserInfo2('jhpark');";
    NSLog(@"jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
}
-(void) getWebHistory:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSLog(@"webHistroies : %@", self.webHistories);
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for(int i=0; i<self.webHistories.count; i++){
        [returnDic setObject:[self.webHistories objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

#pragma mark
#pragma mark MFNP SET
-(void) setBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)backKeyMode{
    if ([backKeyMode isEqualToString:@"0"]) {
        _backMode = NO;
    }else if([backKeyMode isEqualToString:@"1"]){
        _backMode = YES;
    }
    NSString *tmp = @"true";
    tmp = [tmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],tmp];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)setFileNames:(NSString *)fileList{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
    if (readFile!=nil) {
        
    }else{
        
    }
    
}
- (void)setPreferences:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)data{
    _callbackFunc = callbackFunc;
    _userSpecific = userSpecific;
    
    @try {
        NSError *dicError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
        //NSLog(@"dataDic : %@", dataDic);
        for (int i=0; i<[dataDic allKeys].count; i++) {
            NSString *key = [[dataDic allKeys] objectAtIndex:i];
            id value = [dataDic objectForKey:key];
            [self setConfigProperties:key :value];
        }
        //NSLog(@"dicError : %@",dicError);
        NSDictionary *resultDic;
        if (dicError!=nil) {
            resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false",@"RESULT", nil];
        }else{
            resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"true",@"RESULT", nil];
        }
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",callbackFunc,userSpecific,jsonString];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
    } @catch (NSException *exception) {
        NSLog(@"exception : %@",exception.reason);
        NSDictionary *resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:@"false",@"RESULT", nil,exception.reason,@"MSG", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@')",callbackFunc,userSpecific,jsonString];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
}
- (void)setConfigProperties:(NSString *)key :(id)value{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingPathComponent:@"Config.plist"];
    NSMutableDictionary *dic;
    NSError *dicError;
    NSPropertyListFormat format;
    NSError *error;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm isReadableFileAtPath:filePath]){
        NSMutableDictionary *config = [NSMutableDictionary dictionary];
        [config writeToFile:filePath atomically:YES];
    }
    
    NSDictionary *currentConfig = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (currentConfig==nil) {
        dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:value,key,nil];
    }else{
        dic = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&dicError];
        [dic setObject:value forKey:key];
    }
    [dic writeToFile:filePath atomically:YES];
    
}
-(void) setWebHistoryClear:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    //[returnDic setObject:[self.webHistories objectAtIndex:0] forKey:[NSString stringWithFormat:@"%d",0]];
    
    @try{
        for(int i=1; i<self.webHistories.count; i++){
            [self.webHistories removeObjectAtIndex:i];
        }
        [returnDic setObject:@"true" forKey:@"RESULT"];
    }@catch(NSException *e){
        [returnDic setObject:@"false" forKey:@"RESULT"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

#pragma mark
#pragma mark MFNP IS
- (void)isRoaming:(NSString *)callBackFunc :(NSString *)userSpecific{
    
    NSString *yesStr = @"YES";
    NSString *noStr = @"NO";
    
    NSString *jsCommand;
    
    if ([self isRoaming]) {
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[yesStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[noStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (BOOL)isRoaming
{
    static NSString *carrierPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.carrier.plist";
    static NSString *operatorPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.operator.plist";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *carrierPListPath = [fm destinationOfSymbolicLinkAtPath:carrierPListSymLinkPath error:&error];
    NSLog(@"carrierPListPath : %@",carrierPListPath);
    NSString *operatorPListPath = [fm destinationOfSymbolicLinkAtPath:operatorPListSymLinkPath error:&error];
    NSLog(@"operatorPListPath : %@",operatorPListPath);
    return (![operatorPListPath isEqualToString:carrierPListPath]);
}


#pragma mark
#pragma mark URLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"error : %@",error);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alert show];
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    if (statusCode ==200) {
        [receiveData setLength:0];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        NSString *urlStr = connection.currentRequest.URL.absoluteString;
        NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
        NSString *methodName = [methodArr objectAtIndex:0];
        if([methodName isEqualToString:@"upload"]){
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"FAILED" forKey:@"RESULT"];
            [dic setObject:[NSString stringWithFormat:@"Status Code : %ld",(long)statusCode] forKey:@"ERR_MSG"];
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                   _callbackFunc,
                                   _userSpecific,
                                   [[NSString stringWithFormat:@"%@",dic] urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   ];
            
            [self evaluateJavaScript:jsCommand];
        }
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    if ([methodName isEqualToString:@"addMenuHist"]) {
        [histData appendData:data];
    }else{
        [receiveData appendData:data];
    }
    
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    NSLog(@"methodName : %@",methodName);
    if([methodName isEqualToString:@"upload"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString = encString;
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if ([dic objectForKey:@"ERR_MSG"]!=nil) {
            NSLog(@"upload result : %@",decString);
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                   _callbackFunc,
                                   _userSpecific,
                                   [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   ];
            
            [self evaluateJavaScript:jsCommand];
        }else{
            
            NSArray *paths = [appDelegate.main_url pathComponents];
            
            if (appDelegate.uploadURL == nil || [appDelegate.uploadURL isEqualToString:@""]) {
                appDelegate.uploadURL = [NSString stringWithFormat:@"%@//%@/samples/PhotoSave",[paths objectAtIndex:0],[paths objectAtIndex:1]];
            }
            
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
            NSMutableArray *readArray;
            NSMutableArray *uploadArray = [[NSMutableArray alloc]init];
            NSFileHandle *readFile;
            readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
            if (readFile==nil) {
                NSLog(@"not found filePhotoFiles.");
            }else{
                NSData *data = [readFile readDataToEndOfFile];
                NSString *readStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                readArray = [NSMutableArray arrayWithArray:[readStr componentsSeparatedByString:@"\n"]];
                [readArray removeLastObject];
            }
            for(int i=0; i<readArray.count; i++){
                [uploadArray addObject:appDelegate.uploadURL];
            }
            NSLog(@"uploadArray : %@",uploadArray);
            NSLog(@"readArray : %@",readArray);
            
            if(readArray!=nil){
                self.isSync = YES;
                [self fileUploads:readArray :uploadArray :NO];
            }else{
                NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                       _callbackFunc,
                                       _userSpecific,
                                       [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                       ];
                
                [self evaluateJavaScript:jsCommand];
            }
            
            
        }
        
    }else if ([methodName isEqualToString:@"DataGate3"]) {
        
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if ([dic objectForKey:@"ERROR"]!=nil) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"DataGate Error" message:[dic objectForKey:@"ERROR"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
            [alertView show];
            
        }
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               decString];
        
        [self evaluateJavaScript:jsCommand];
        
    }else if([methodName isEqualToString:@"sendPushService"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               [dic objectForKey:@"V1"]];
        
        NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
    }else if([methodName isEqualToString:@"CheckSession"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        /*
         if (appDelegate.isAES256) {
         encString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
         }
         else{
         encString = encString;
         }*/
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[encString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               [dic objectForKey:@"V0"]];
        
        NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
        
    }else if([methodName isEqualToString:@"addMenuHist"]) {
        NSDictionary *dic;
        NSError *error;
        @try {
            // if AES256
            NSString *encString =[[NSString alloc]initWithData:histData encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            }
            else{
                decString = encString;
            }
            NSLog(@"WebViewController encString : %@",encString);
            NSLog(@"WebViewController decString : %@",decString);
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            NSLog(@"WebViewController addMenuHist dic : %@",dic);
            // if nomal
            //dic = [NSJSONSerialization JSONObjectWithData:receiveData options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        [SVProgressHUD dismiss];
        if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
            [self menuHandler];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    } else if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSLog(@"WebViewController GetExecuteMenuInfo dic : %@",dic);
        if ([[dic objectForKey:@"V0"] isEqualToString:@"True"]) {
            NSString *menu_no = [dic objectForKey:@"V3"];
            
            NSString *target_url = [dic objectForKey:@"V6"];
            
            NSString *param_String = [dic objectForKey:@"V6_1"];
            
            NSData *param_data = [param_String dataUsingEncoding:NSUTF8StringEncoding];
            menuKind = @"P";
            
            appDelegate.menu_title = [dic objectForKey:@"V9"];
            
            menuType = [dic objectForKey:@"V10"];
            
            NSString *versionFromServer = [dic objectForKey:@"V12"];
            
            nativeAppURL = [dic objectForKey:@"V13"];
            
            _isDMS = [[dic objectForKey:@"V16"] isEqualToString:@"Y"];
            _isTabBar = [[dic objectForKey:@"V17"] isEqualToString:@"Y"];
            
            paramString = @"";
            appDelegate.menu_no = menu_no;
            nativeAppMenuNo = menu_no;
            currentAppVersion = versionFromServer;
            appDelegate.target_url = target_url;
            
            NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:param_data options:kNilOptions error:&error];
            @try {
                for(int i=1; i<=[paramDic count]; i++){
                    NSDictionary *subParamDic = [paramDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                    paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_KEY"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
                    paramString = [paramString stringByAppendingFormat:@"="];
                    paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_VAL"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
                    paramString = [paramString stringByAppendingFormat:@"&"];
                }
                if ([[paramString substringFromIndex:paramString.length-1] isEqualToString:@"&"]) {
                    paramString = [paramString substringToIndex:paramString.length-1];
                }
                
            }
            @catch (NSException *exception) {
                //NSLog(@"exception : %@",[exception name]);
            }
            if (IS_OS_8_OR_LATER) {
                if (_isDMS) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message163", @"iOS8 버전 이상은 지원하지 않습니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    [self addMenuHist:appDelegate.menu_no];
                }
            }else{
                [self addMenuHist:appDelegate.menu_no];
            }
        }else{
            
        }
        
        [SVProgressHUD dismiss];
        
    }else{
        
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:receiveData], nil, nil, nil);
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"사진이 앨범에 저장되었습니다." delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [alertView show];
        
        
    }
    receiveData = nil;
}

#pragma mark
#pragma mark Barcode Call
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[errMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void) barCodeReaderOpen{
    MFBarcodeScannerViewController *vc = [[MFBarcodeScannerViewController alloc]init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if (isCamera) {
        //카메라뷰일때
        UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // 현재시간 알아오기
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        NSString *filename = appDelegate.user_no;
        filename = [filename stringByAppendingString:@"("];
        
        filename = [filename stringByAppendingString:currentTime];
        filename = [filename stringByAppendingString:@")"];
        if (sendImage!=nil) {
            [self savePicture:sendImage :filename];
        }
        [reader dismissViewControllerAnimated:YES completion:nil];
        isCamera = NO;
        
    }else{
        //바코드뷰일때
        //        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        //        ZBarSymbol *symbol = nil;
        //
        //        for (symbol in results) {
        //            break;
        //        }
        //        NSString *serial = symbol.data;
        //        NSLog(@"serial : %@",symbol.data);
        //        [_reader dismissViewControllerAnimated:YES completion:nil];
        //        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[serial stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //        [self evaluateJavaScript:jsCommand];
    }
}
- (UIImage*)setResizeImage:(UIImage *)image :(float)imgSize :(BOOL)isLandscape {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    if(isLandscape) {
        scaleFactor = imgSize / oldWidth; //가로고정
    } else {
        scaleFactor = imgSize / oldHeight; //높이고정
    }
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
-(void) savePicture:(UIImage *)sendImage :(NSString*)file{
    NSLog(@"%s",__func__);
    NSString *saveFolder = [self getPhotoFilePath];
    
    UIImage *image = sendImage;
    //디폴트사이즈설정------------------------------------------------
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    int fixSize = [uploadSize intValue]; //1024;
    if(oldWidth>=oldHeight){
        if(oldWidth>fixSize){
            scaleFactor = fixSize / oldWidth;
        }
    } else {
        if(oldHeight>fixSize){
            scaleFactor = fixSize / oldHeight;
        }
    }
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize fixedNewSize = CGSizeMake(newWidth, newHeight);
    NSLog(@"fixedNewSize : %f*%f", fixedNewSize.width, fixedNewSize.height);
    
    //디폴트사이즈설정------------------------------------------------
    CGRect rect = CGRectMake(0, 0, fixedNewSize.width, fixedNewSize.height);
    [image drawInRect:rect];
    
    NSData *imageData = nil;
    if ([uploadFormat isEqualToString:[@"png" lowercaseString]]) {
        imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    } else {
        imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.1)];
    }
    
    NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:[NSString stringWithFormat:@".%@", uploadFormat]]];
    NSString *filePath3 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".thum"]];
    //NSLog(@"thum file path : %@",filePath3);
    [imageData writeToFile:filePath2 atomically:YES];
    
    UIImage *thumImage = [self resizedImage:image inRect:CGRectMake(0, 0, 60, 60)];
    NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    [thumData writeToFile:filePath3 atomically:YES];
    
    if (_userSpecific ==nil) {
        [self photoSave:filePath2];
    }else{
        [self photoSave:filePath2 :_userSpecific :_callbackFunc];
    }
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}

#pragma mark
#pragma mark Recognize Speech Call
- (void)startRecording :(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)succession{
    NSLog(@"succession : %@", succession);
    NSError * error;
    
    NSString *langCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *contCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    SFSpeechRecognizer *speech = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:[NSString stringWithFormat:@"%@-%@", langCode, contCode]]];
    [speech setDelegate:self];
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus authStatus) {
        switch (authStatus) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"SFSpeechRecognizerAuthorizationStatusDenied");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"SFSpeechRecognizerAuthorizationStatusRestricted");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                break;
                
            default:
                NSLog(@"Default");
                break;
        }
    }];
    
    audio = [[AVAudioEngine alloc] init];
    if(audio.isRunning){
        [audio stop];
        [request endAudio];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
        [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation  error:&error];
        
        request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        inputNode = [audio inputNode];
        
        if (request == nil) {
            NSLog(@"Unable to created a SFSpeechAudioBufferRecognitionRequest object");
        }
        
        if (inputNode == nil) {
            NSLog(@"Unable to created a inputNode object");
        }
        
        NSMutableArray *textArr = [NSMutableArray array];
        
        request.shouldReportPartialResults = true;
        task = [speech recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            BOOL isFinal = false;
            //NSLog(@"isFinal : %d", isFinal);
            if(result != nil) {
                NSLog(@"text : %@", result.bestTranscription.formattedString);
                [textArr addObject:result.bestTranscription.formattedString];
                isFinal = result.isFinal;
                
                NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc, userSpecific, result.bestTranscription.formattedString];
                [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
                
                if(succession==nil||[succession isEqualToString:@"false"]){
                    [audio stop];
                    [inputNode removeTapOnBus:0];
                    
                    request = nil;
                    task = nil;
                }
            }
        }];
        
        [inputNode installTapOnBus:0 bufferSize:1024 format:[inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when){
            [request appendAudioPCMBuffer:buffer];
        }];
        
        [audio prepare];
        [audio startAndReturnError:&error];
    }
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    NSLog(@"%s", __func__);
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)result {
    NSString * translatedString = [[[result bestTranscription] formattedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"translatedString : %@", translatedString);
    
    if ([result isFinal]) {
        [audio stop];
        [inputNode removeTapOnBus:0];
        task = nil;
        request = nil;
    }
}

#pragma mark
#pragma mark Location Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status==2) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message201", @"위치 접근 허용") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"취소") otherButtonTitles:NSLocalizedString(@"message51", @"확인"), nil];
        [alertView show];
        
    }
    NSLog(@"status : %d",status);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"Location Updateing Failed! : %@",error);
} // 위치 정보 가져오는 것 실패 때


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation     // CLLocation *)newLocation 여기에 위도경도가 변수에 들어가 있다.
{
    double latitude;  //더블형
    double longitude;
    
    latitude = newLocation.coordinate.latitude; //위도정보
    longitude =newLocation.coordinate.longitude;//경도 정보
    
    NSString *lbl_laText = [NSString stringWithFormat:@"위도는 : %g",latitude];
    NSString *lbl_loText = [NSString stringWithFormat:@"경도는 : %g",longitude];
    
    
    NSLog(@"%@",lbl_loText);
    NSLog(@"%@",lbl_laText);
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    //NSLog(@"didFinishDeferredUpdatesWithError");
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"didExitRegion");
}

#pragma mark
#pragma mark Device Spec
- (int) countCores
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount ) ;
    
    return hostInfo.max_cpus ;
}
- (BOOL) gpsAvailable{
    return [CLLocationManager locationServicesEnabled];
}

- (BOOL) accelerometerAvailable{
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    BOOL accelerometer = motionManager.accelerometerAvailable;
    return accelerometer;
}

- (BOOL) gyroscopeAvailable
{
#ifdef __IPHONE_4_0
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    BOOL gyroAvailable = motionManager.gyroAvailable;
    return gyroAvailable;
#else
    return NO;
#endif
    
}

- (BOOL) compassAvailable
{
    BOOL compassAvailable = NO;
    
#ifdef __IPHONE_3_0
    compassAvailable = [CLLocationManager headingAvailable];
#else
    CLLocationManager *cl = [[CLLocationManager alloc] init];
    compassAvailable = cl.headingAvailable;
    [cl release];
#endif
    
    return compassAvailable;
    
}

- (BOOL) retinaDisplayCapable
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    
    if(scale == 2.0f) return YES;
    else return NO;
}
- (BOOL) frontCameraAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
#else
    return NO;
#endif
    
    
}
- (BOOL) linearCameraAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
#else
    return NO;
#endif
    
    
}

- (BOOL) cameraFlashAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
#else
    return NO;
#endif
}

#pragma mark
#pragma mark SMS
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = NSLocalizedString(@"cancel", @"");
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = NSLocalizedString(@"fail", @"");
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            resultString = NSLocalizedString(@"success", @"");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Send SMS %@",resultString] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }];
    
}
#pragma mark
#pragma mark WebView Download
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:mywebView];
        
        // convert point from view to HTML coordinate system
        // 뷰의 포인트 위치를 HTML 좌표계로 변경한다.
        CGSize viewSize = [mywebView frame].size;
        CGSize windowSize = [mywebView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [mywebView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        [self openContextualMenuAt:pt];
    }
}
- (void)openContextualMenuAt:(CGPoint)pt{
    // Load the JavaScript code from the Resources and inject it into the web page
    NSBundle *bundle = [NSBundle mainBundle];
    //NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Anymate" ofType:@"bundle"]];
    
    NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
    //NSLog(@"js path : %@",path);
    
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"pt : %f, %f",pt.x,pt.y);
    //NSLog(@"jsCode : %@",jsCode);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [mywebView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsHREF = [mywebView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsSRC = [mywebView stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    //NSLog(@"tags : %@",tags);
    //NSLog(@"href : %@",tagsHREF);
    //NSLog(@"src : %@",tagsSRC);
    
    if (!_actionActionSheet) {
        _actionActionSheet = nil;
    }
    _actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    selectedLinkURL = @"";
    self.selectedImageURL = @"";
    
    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        self.selectedImageURL = tagsSRC;
        
        if (_actionActionSheet.title == nil) {
            //_actionActionSheet.title = tagsSRC;
        }
        
        [_actionActionSheet addButtonWithTitle:@"Save Image"];
        //[_actionActionSheet addButtonWithTitle:@"Copy Image"];
    }
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        selectedLinkURL = tagsHREF;
        
        //_actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:@"Open Link"];
        //[_actionActionSheet addButtonWithTitle:@"Copy Link"];
    }
    
    if (_actionActionSheet.numberOfButtons > 0) {
        [_actionActionSheet addButtonWithTitle:@"Cancel"];
        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
        
        
        [_actionActionSheet showInView:mywebView];
    }
    
}
#pragma mark
@end
@implementation UIWebView (WebUI)

@end
