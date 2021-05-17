//
//  WKWebViewController.m
//  mFinity_HHI
//
//  Created by hilee on 2020/04/10.
//  Copyright © 2020 Jun hyeong Park. All rights reserved.
//

#import "WKWebViewController.h"

#import "WebViewAdditions.h"
#import "MFinityAppDelegate.h"

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
#import <MediaPlayer/MediaPlayer.h>

#import "FBEncryptorAES.h"

#import "SVProgressHUD.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFTableViewController.h"
#import "HISImageViewer.h"
#import "JTSImageViewController.h"

#import "ImageViewerController.h"

#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 320
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define REFRESH_TABLEVIEW_DEFAULT_ROW               44.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               44.f

#define REFRESH_TITLE_TABLE_PULL                    @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_RELEASE                 @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_LOAD                    @"Refreshing ..."

#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"

@interface WKWebViewController () {
    HISImageViewer *imageViewer;
    CGFloat tabHeight;
    
    int labelSizePercent;
    int createTabCount;
}

@end

@implementation WKWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    //모달팝업 완료버튼이 흰색으로 나오는 이슈가 있음(200414)
//    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UIToolbar.class]]setTintColor:[UIColor lightGrayColor]]; //화살표만 바뀜
//    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    self.createdWKWebViews = [NSMutableArray array];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    CGFloat viewHeight = [[UIScreen mainScreen]bounds].size.height;
    
    if(appDelegate.isWebviewTab) _isTabBar = YES;
    tabHeight = 0;
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        appDelegate.scrollView.hidden = YES;
        
        if(_isTabBar){
            self.tabBarController.tabBar.hidden = NO;
        } else {
            self.tabBarController.tabBar.hidden = YES;
        }
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        appDelegate.scrollView.hidden = YES;
        
        if(_isTabBar){
            self.tabBarController.tabBar.hidden = NO;
            
        } else {
            self.tabBarController.tabBar.hidden = YES;
        }
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if(_isTabBar) {
            tabHeight = appDelegate.scrollView.frame.size.height;
            appDelegate.scrollView.hidden = NO;
        } else {
            tabHeight = 0;
            appDelegate.scrollView.hidden = YES;
        }
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [_webViewFrame setFrame:CGRectMake(_webViewFrame.frame.origin.x, _webViewFrame.frame.origin.y, _webViewFrame.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            if([appDelegate isIphoneX]){
                [_webViewFrame setFrame:CGRectMake(_webViewFrame.frame.origin.x, tabHeight, _webViewFrame.frame.size.width, self.tabBarController.tabBar.frame.origin.y-tabHeight)];
            } else {
                [_webViewFrame setFrame:CGRectMake(_webViewFrame.frame.origin.x, tabHeight, _webViewFrame.frame.size.width, viewHeight-(appDelegate.scrollView.frame.origin.y+tabHeight))];
            }
        }
    }
    
    NSString *currentClass = NSStringFromClass([self.parentViewController class]);
    if([currentClass isEqualToString:@"UIMoreNavigationController"]){
        self.navigationItem.hidesBackButton = YES;
    }
    
    [self initWKWebView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.scrollView.delegate = self;
    
    createTabCount = 0;
    
    //쿠키허용
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"HideImageViewer" object: nil];
    
    
//    UIImage *buttonImageRight = [UIImage imageNamed:@"navi_webback.png"];
//
//    UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
//    [rightButton setImage:buttonImageRight forState:UIControlStateNormal];
//    rightButton.frame = CGRectMake(0, 0, buttonImageRight.size.width-12,buttonImageRight.size.height-12);
//
//    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *customBarItemRight = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem = customBarItemRight;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        imageViewer = [[HISImageViewer alloc] initWithNibName:@"HISImageViewer" bundle:nil];
    } else {
        imageViewer = [[HISImageViewer alloc] initWithNibName:@"HISImageViewer_IPad" bundle:nil];
    }
    
    // Do any additional setup after loading the view from its nib.
    
    if (_isDownload) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        UIViewController *vc = [[self.navigationController viewControllers]objectAtIndex:[arr count]-2];
        [arr removeObject:vc];
        self.navigationController.viewControllers = arr;
        _isDownload = NO;
    }
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([_type isEqualToString:@"A3"]) {
        
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate =self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [locationManager startUpdatingLocation];
        
    }
    
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
    
    NSLog(@"ver : %@", ver);
    
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }

    self.navigationController.navigationBar.topItem.title = @"";
    
    if(appDelegate.isInitPwd){
        UIImage *buttonImageLeft = [UIImage imageNamed:@"prev_bt_03.png"];
        
        UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [leftButton setImage:buttonImageLeft forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, buttonImageLeft.size.width,buttonImageLeft.size.height);
        
        [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItemLeft = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = customBarItemLeft;
    }
    
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
    NSLog(@"tempStr : %@", tempString);
    
    //2018.06 UI개선
    //if ([tempString isEqualToString:@"Notice_PushViewController"]) {
    if ([tempString isEqualToString:@"NotiPushViewController"]) {
        appDelegate.preURL = appDelegate.target_url;
        appDelegate.preTitleName = self.navigationItem.title;
    } else if([tempString isEqualToString:@"ThirdViewController"]){
        appDelegate.preThirdTitle = self.navigationItem.title;
    } else if([tempString isEqualToString:@"FirstViewController"]){
        appDelegate.preMainTitle = self.navigationItem.title;
    }
    
     [self performSelector:@selector(_initializeRefreshViewOnTableViewTop)];
}

-(void)viewDidAppear:(BOOL)animated{
    motionManager = [[CMMotionManager alloc]init];
    if (_isDMS) {
        NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
        documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
        documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
        
        dbDirectoryPath = documentPath;
    }else{
        dbDirectoryPath = [self makeDBFile];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initWKWebView{
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    [self setMfnpMethod:userController];
    
    WKProcessPool *wkProcessPool = [[WKProcessPool alloc] init];
    WKPreferences *wkPreferences = [[WKPreferences alloc] init];
    
    //웹뷰 텍스트 선택 금지
    NSString *script = @"document.documentElement.style.webkitUserSelect='none'; document.body.style.webkitTouchCallout='none';";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userController addUserScript:userScript];
    
    wkPreferences.javaScriptEnabled = YES;
    wkPreferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    webViewConfig.processPool = wkProcessPool;
    webViewConfig.preferences = wkPreferences;
    
    //로컬에 저장된 메뉴 로드하기위해 사용
    [webViewConfig.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
    [webViewConfig setValue:@"TRUE" forKey:@"allowUniversalAccessFromFileURLs"];

    webViewConfig.userContentController = userController;
    
    WKWebsiteDataStore *ds = [WKWebsiteDataStore nonPersistentDataStore];
    //로그인 시 저장한 세션쿠키 웹뷰에 적용
    
    if (@available(iOS 11.0, *)) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies) {
            [ds.httpCookieStore setCookie:cookie completionHandler:nil];
        }
        webViewConfig.websiteDataStore = ds;
    }
            
    CGRect webViewRect = CGRectMake(self.webViewFrame.frame.origin.x, self.webViewFrame.frame.origin.y, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height);
    self.webView = [[WKWebView alloc] initWithFrame:webViewRect configuration:webViewConfig];

    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;

    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
        
        if (appDelegate.isOffLine) {
            
        }else{
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:page_url]]];
        }
        
    }else{
        NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *filemgr;
        NSArray *filelist;
        int countT;
        int i;
        
        filemgr =[NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:save error:NULL];
        countT = [filelist count];
        
        for(i = 0; i < countT; i++)
        {
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
//            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            
            NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [NSString stringWithFormat:@"file://%@",str];
            NSLog(@"filePath : %@",filePath);
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
                [self.webView loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];

            }else{
                [self.webView loadHTMLString:filePath baseURL:[NSURL fileURLWithPath:documentsDir]];
            }
        }
    }
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webViewFrame addSubview:self.webView];
    
    
    //워터마크 테스트중
//    NSString *str = [NSString stringWithFormat:@"BP15214\n2020-05-13"];
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height)];
//    [lbl setText:str];
//    [lbl setFont:[UIFont systemFontOfSize:30]];
//    [lbl setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
//    [lbl setNumberOfLines:0];
//
//    CGRect rect = [lbl bounds];
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context1 = UIGraphicsGetCurrentContext();
//    [lbl.layer renderInContext:context1];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height)];
//    imgView.image = img;
//    [self.webViewFrame addSubview:imgView];
    
}

#pragma mark - WKWebViewDelegate Method
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

//    WKUserContentController *userController = [[WKUserContentController alloc] init];
//    // 화면에 보여지기 위해 addSubView 를 하므로 window.close() 시에 remove view 를 하도록 아래 소스를 document 시작시점에 inject 한다.
//
//    NSString *script = @"window.close=function(){ open('mfinity://windowClose'); };";
//
//    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//    [userController addUserScript:userScript];
//    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    configuration.userContentController = userController;
//
//    WKWebView *newWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:configuration];
//    newWebView.navigationDelegate = self;
//    newWebView.UIDelegate = self;
//    [self.createdWKWebViews addObject:newWebView]; // 포함된 viewcontroller 가 dealloc 되기 전까지 참조를 유지 => 한번 생성된 window 를 다시 띄우는 경우 다시 create 를 타지 않기 때문에 remove view 를 해버리면 newWebView 가 dealloc 되므로
//
//    [self.view addSubview:newWebView];    // 눈에 보여지도록
//
//    return newWebView;
    
    createTabCount++;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, _webViewFrame.frame.size.height)];
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
    [self.view addSubview:tmpView];
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    [self setMfnpMethod:userController];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    
    CGRect webViewRect = CGRectMake(_webViewFrame.frame.origin.x, 0, screenWidth, _webViewFrame.frame.size.height);
    WKWebView *newWebView = [[WKWebView alloc] initWithFrame:webViewRect configuration:configuration];
    newWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    newWebView.navigationDelegate = self;
    newWebView.UIDelegate = self;
    
    [self.createdWKWebViews addObject:newWebView];
    
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.4];
    [applicationLoadViewIn setType:kCATransitionPush];
    [applicationLoadViewIn setSubtype:kCATransitionFromRight];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[newWebView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [self.view addSubview:newWebView];    // 눈에 보여지도록

    return newWebView;
}
-(IBAction)backButton:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if(createTabCount>0){
        if (createTabCount==1) {
            UIView *tmpView = [self.view viewWithTag:9009];
            [tmpView removeFromSuperview];
            tmpView = nil;
        }
        createTabCount--;
    }
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:.5];
    //[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    WKWebView *wkView = [self.createdWKWebViews lastObject];
    [wkView removeFromSuperview];
    [self.createdWKWebViews removeLastObject];
    wkView = nil;
    
    [UIView commitAnimations];
    if (self.createdWKWebViews.count>0) {
        self.webView = [self.createdWKWebViews lastObject];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"keyPath : %@",keyPath);
//    NSLog(@"object : %@",object);
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
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

- (void)setMfnpMethod:(WKUserContentController *)userController{
    NSLog(@"%s",__FUNCTION__);
    [userController addScriptMessageHandler:self name:@"camera"];
    [userController addScriptMessageHandler:self name:@"movetab"];
    [userController addScriptMessageHandler:self name:@"dbcall"];
    [userController addScriptMessageHandler:self name:@"gps"];
    [userController addScriptMessageHandler:self name:@"addressbook"];
    [userController addScriptMessageHandler:self name:@"signpad"];
    [userController addScriptMessageHandler:self name:@"photosave"];
    [userController addScriptMessageHandler:self name:@"barcode"];
    [userController addScriptMessageHandler:self name:@"blobstring"];
    [userController addScriptMessageHandler:self name:@"filePath"];
    [userController addScriptMessageHandler:self name:@"saveFile"];
    
    [userController addScriptMessageHandler:self name:@"executePush"];
    [userController addScriptMessageHandler:self name:@"executeRetrieve"];
    [userController addScriptMessageHandler:self name:@"executeNonQuery"];
    [userController addScriptMessageHandler:self name:@"executeCamera"];
    [userController addScriptMessageHandler:self name:@"executeSignpad"];
    [userController addScriptMessageHandler:self name:@"executeBarcode"];
    [userController addScriptMessageHandler:self name:@"executeFileUpload"];
    [userController addScriptMessageHandler:self name:@"getGpsLocation"];
    [userController addScriptMessageHandler:self name:@"getFilePath"];
    [userController addScriptMessageHandler:self name:@"setFileNames"];
    [userController addScriptMessageHandler:self name:@"getNetworkStatus"];
    [userController addScriptMessageHandler:self name:@"getDeviceSpec"];
    [userController addScriptMessageHandler:self name:@"executeNotification"];
    [userController addScriptMessageHandler:self name:@"getAccelerometer"];
    [userController addScriptMessageHandler:self name:@"getGyroscope"];
    [userController addScriptMessageHandler:self name:@"getMagneticField"];
    [userController addScriptMessageHandler:self name:@"getOrientation"];
    [userController addScriptMessageHandler:self name:@"getProximity"];
    [userController addScriptMessageHandler:self name:@"getFileList"];
    [userController addScriptMessageHandler:self name:@"executeDatagate"];
    [userController addScriptMessageHandler:self name:@"isRoaming"];
    [userController addScriptMessageHandler:self name:@"executeBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"executeSms"];
    [userController addScriptMessageHandler:self name:@"executeRecognizeSpeech"];
    [userController addScriptMessageHandler:self name:@"executeExitWebBrowser"];
    [userController addScriptMessageHandler:self name:@"getCheckSession"];
    [userController addScriptMessageHandler:self name:@"setBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"getUserInfo"];
    [userController addScriptMessageHandler:self name:@"getmFinityOtherInfo"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStart"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStop"];
    [userController addScriptMessageHandler:self name:@"getConvertImageToBase64"];
    [userController addScriptMessageHandler:self name:@"executeMenu"];
    [userController addScriptMessageHandler:self name:@"executeVideoPlayer"];
    [userController addScriptMessageHandler:self name:@"executeImageViewer"];
    
    [userController addScriptMessageHandler:self name:@"windowClose"];
}
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    
    NSString *mfnpName = [NSString stringWithString:message.name];
    NSString *mfnpParam = [NSString stringWithString:message.body];
    NSDictionary *dic ;
    if (![mfnpParam isEqualToString:@""]) {
        dic = [self getParameters:mfnpParam];
    }
    if([mfnpName isEqualToString:@"windowClose"]){
        NSLog(@"%s windowClose",__FUNCTION__);
        NSLog(@"self.createWKWebViews : %@",self.createdWKWebViews);
        NSLog(@"=======================================================");
        
        if(createTabCount>0){
            if (createTabCount==1) {
                UIView *tmpView = [self.view viewWithTag:9009];
                [tmpView removeFromSuperview];
                tmpView = nil;
            }
            createTabCount--;
        }
        WKWebView *wkView = [self.createdWKWebViews lastObject];
        [wkView removeFromSuperview];
        [self.createdWKWebViews removeLastObject];
        wkView = nil;
        
        if (self.createdWKWebViews.count>0) {
            self.webView = [self.createdWKWebViews lastObject];
        }
        
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@')",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self evaluateJavaScript:jsCommand];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    NSLog(@"%s error : %@",__FUNCTION__,error);
    NSLog(@"%s error : %@",__FUNCTION__,[error userInfo]);
    NSLog(@"%s error : %@",__FUNCTION__,[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]);
    
    
    
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s error : %@",__FUNCTION__,error);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message : %@",message);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TouchOne"
                                                                                message:message
                                                                         preferredStyle:UIAlertControllerStyleAlert];
   [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action) {
                                                         completionHandler();
                                                     }]];
   [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TouchOne" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0f;
    
    for (int i=0; i<self.createdWKWebViews.count; i++) {
        WKWebView *tmp = self.createdWKWebViews[0];
        if ([webView.URL.absoluteString isEqualToString:tmp.URL.absoluteString]) {
            //NSLog(@"webView.URL same");
            [self.view addSubview:webView];
        }
    }
    
    NSURL *url = webView.URL;
    NSString *urlString = [url absoluteString];
    NSLog(@"[request URL] : %@",urlString);
    
    /*
    if ([[url scheme]isEqualToString:@"ezmovetab"]) {
        self.tabBarController.selectedIndex = [[url host] intValue]-1;
        
    }else if([[url scheme]isEqualToString:@"toiphoneapp"]){
        if (imageViewer == nil) {
            NSLog(@"imageViewer is nil");
        }
        NSString *BASE_URL = @"https://touch1.hhi.co.kr/";
        [imageViewer setBaseUrl:BASE_URL];
        [imageViewer setParamInformation:urlString];
         [[[UIApplication sharedApplication] keyWindow] addSubview:imageViewer.view];
        
    }else if([[url scheme]isEqualToString:@"dbcall"]){
        NSString *_paramString = urlString;
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
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"documentPath : %@",documentPath);
        
        if ([fileManager isReadableFileAtPath:documentPath]) {
            [self oldDbConnection:[paramArray objectAtIndex:1] :[paramArray objectAtIndex:2] :[paramArray objectAtIndex:3] :documentPath];
        }else{
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
            [self dismissModalViewControllerAnimated:YES];
        }
        
    }else if([[url scheme] isEqualToString:@"mfnp"]||[[url scheme] isEqualToString:@"mfinity"]){
        
        NSString *host = [url host];
        NSLog(@"host : %@", host);
        NSArray *params = [[url query] componentsSeparatedByString:@"&"];
        if ([host isEqualToString:@"camera"]) {
            CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
            appDelegate.mediaControl = @"camera";
            vc.isWebApp = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if([host isEqualToString:@"movetab"]){
            self.tabBarController.selectedIndex = [[url host] intValue]-1;
            
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
            
        }else if([host isEqualToString:@"gps"]){
            [self getGpsLocation:@"CBLocation" :nil];

        }else if([host isEqualToString:@"addressbook"]){
            NSDictionary *dic = [appDelegate contracts];
            NSString *dicString = [NSString stringWithFormat:@"%@",dic];
            NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString URLEncode]];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"signpad"]){
            SignPadViewController *vc = [[SignPadViewController alloc]init];
            UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
            
        }else if([host isEqualToString:@"photosave"]){
            PhotoViewController *vc = [[PhotoViewController alloc] init];
            vc.imagePath = _imgFileName;
            vc.isWebApp = YES;
            [vc rightBtnClick];
            
        }else if([host isEqualToString:@"barcode"]){
            [self barCodeReaderOpen];
            
        }else if([host isEqualToString:@"blobstring"]){
            NSLog(@"[url query] : %@",[url query]);
            NSString *query = [url query];
            NSString *jsCommand = [NSString stringWithFormat:@"receive_blob('%@');",query];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"filePath"]){
            //photo 폴더 경로 넘겨주면 됨
            NSString *photoPath =[self getPhotoFilePath];
            photoPath = [photoPath URLEncode];
            NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"saveFile"]){
            //
        }else if([host isEqualToString:@"executePush"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executePush:callBackFunc :userSpecific :userList :msg];
            
        }else if([host isEqualToString:@"executeRetrieve"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"selectStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
        }else if([host isEqualToString:@"executeNonQuery"]){
            
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeCamera"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeCamera:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeSignpad"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeSignpad:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBarcode"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeBarcode:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeFileUpload"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileType = [dic objectForKey:@"fileType"];
            NSString *fileList = [dic objectForKey:@"fileList"];
            NSError *jsonError;
            NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
            [self executeFileUpload:fileType :json :upLoadPath];
            
        }else if([host isEqualToString:@"getGpsLocation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGpsLocation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getFilePath"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getFilePath:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"setFileNames"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileList = [dic objectForKey:@"fileList"];
            [self setFileNames:fileList];
            
        }else if([host isEqualToString:@"getNetworkStatus"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getNetworkStatus:callBackFunc :userSpecific];
            
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
            
        }else if([host isEqualToString:@"executeNotification"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *useVibrator = [dic objectForKey:@"useVibrator"];
            NSString *useBeep = [dic objectForKey:@"useBeep"];
            NSString *time = [dic objectForKey:@"time"];
            
            if([dic objectForKey:@"sound"]!=nil){
                NSString *beepSound = [dic objectForKey:@"sound"];
                [self executeNotification:useVibrator :useBeep :time :beepSound];
            } else {
                [self executeNotification:useVibrator :useBeep :time];
            }
            
        }else if([host isEqualToString:@"getAccelerometer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getAccelerometer:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getGyroscope"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGyroscope:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getMagneticField"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getMagneticField:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getOrientation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getOrientation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getProximity"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            
            [self getProximity:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"getFileList"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *_directoryPath = [dic objectForKey:@"directoryPath"];
            [self getFileList:callBackFunc :userSpecific :_directoryPath];

        }else if([host isEqualToString:@"executeDatagate"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
            NSString *sprocName = [dic objectForKey:@"sprocName"];
            NSString *args = [dic objectForKey:@"args"];
            [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
            
        }else if([host isEqualToString:@"isRoaming"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self isRoaming:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"executeSms"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            [self executeSms:callBackFunc :userSpecific :msg :userList];
            
        }else if([host isEqualToString:@"executeRecognizeSpeech"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRecognizeSpeech:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeExitWebBrowser"]){
            [self executeExitWebBrowser];
            
        }else if([host isEqualToString:@"getCheckSession"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getCheckSession:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"setBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"setBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"getUserInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getUserInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getmFinityOtherInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getmFinityOtherInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeProgressDialogStart"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
            
        }else if([host isEqualToString:@"executeProgressDialogStop"]){
            [self executeProgressDialogStop];
            
        }else if([host isEqualToString:@"getConvertImageToBase64"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *imagePath = [dic objectForKey:@"imagePath"];
            [self getConvertImageToBase64:callBackFunc :imagePath];
            
        }else if([host isEqualToString:@"executeMenu"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *menuNo = [dic objectForKey:@"menuNo"];
            [self executeMenu:menuNo];
            
        }else if([host isEqualToString:@"executeVideoPlayer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *streamingUrl = [dic objectForKey:@"streamingUrl"];
            [self executeVideoPlayer:streamingUrl];
        
        }else if([host isEqualToString:@"executeImageViewer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *imagePath = [dic objectForKey:@"url"];
            [self executeImageViewer:imagePath];
            
        } else if([host isEqualToString:@"windowClose"]){
            NSLog(@"클로즈ㅠㅠ");
//            [self.createdWKWebViews removeAllObjects];
//            NSLog(@"createdWKWebViews !! : %@", self.createdWKWebViews);
//            if ([self.webView canGoBack]) {
//                NSLog(@"canGoBack");
//                [self.webView goBack];
//            }else{
//                NSLog(@"reload");
//                [self.webView reload];
//            }
        }
    }
    else {
        NSLog(@"%s else",__FUNCTION__);
    }
     */
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences * _Nonnull))decisionHandler API_AVAILABLE(ios(13.0)){
    NSLog(@"%s",__func__);
    preferences.preferredContentMode = WKContentModeMobile;

    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//        NSLog(@"iPadOS13 userAgent : %@", result);
    }];
//    NSLog(@"Action webView.URL : %@", webView.URL);
    
    NSURL *url = navigationAction.request.URL;
    NSLog(@"SCHEME : %@", url.scheme);
    
    NSString *urlString = [url absoluteString];
    
    if ([[url scheme]isEqualToString:@"ezmovetab"]) {
        self.tabBarController.selectedIndex = [[url host] intValue]-1;
       
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        
    }else if([[url scheme]isEqualToString:@"toiphoneapp"]){
        if (imageViewer == nil) {
            NSLog(@"imageViewer is nil");
        }
        NSString *BASE_URL = @"https://touch1.hhi.co.kr/";
        [imageViewer setBaseUrl:BASE_URL];
        [imageViewer setParamInformation:urlString];
         [[[UIApplication sharedApplication] keyWindow] addSubview:imageViewer.view];
        
//        [imageViewer.topView setFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, imageViewer.view.frame.size.width, imageViewer.view.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
        [imageViewer.view setFrame:CGRectMake(0, 0, imageViewer.view.frame.size.width, imageViewer.view.frame.size.height)];
        [imageViewer.topView setFrame:CGRectMake(0, 22+[UIApplication sharedApplication].statusBarFrame.size.height, imageViewer.view.frame.size.width, imageViewer.topView.frame.size.height)];
       
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        
    }else if([[url scheme]isEqualToString:@"dbcall"]){
        NSString *_paramString = urlString;
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
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"documentPath : %@",documentPath);
        
        if ([fileManager isReadableFileAtPath:documentPath]) {
            [self oldDbConnection:[paramArray objectAtIndex:1] :[paramArray objectAtIndex:2] :[paramArray objectAtIndex:3] :documentPath];
        }else{
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
            [self dismissModalViewControllerAnimated:YES];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        
    }else if([[url scheme] isEqualToString:@"mfnp"]||[[url scheme] isEqualToString:@"mfinity"]){
        NSString *host = [url host];
        NSLog(@"host : %@", host);
        NSArray *params = [[url query] componentsSeparatedByString:@"&"];
        if ([host isEqualToString:@"camera"]) {
            CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
            appDelegate.mediaControl = @"camera";
            vc.isWebApp = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if([host isEqualToString:@"movetab"]){
            self.tabBarController.selectedIndex = [[url host] intValue]-1;
            
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
            
        }else if([host isEqualToString:@"gps"]){
            [self getGpsLocation:@"CBLocation" :nil];

        }else if([host isEqualToString:@"addressbook"]){
            NSDictionary *dic = [appDelegate contracts];
            NSString *dicString = [NSString stringWithFormat:@"%@",dic];
            NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString URLEncode]];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"signpad"]){
            SignPadViewController *vc = [[SignPadViewController alloc]init];
            UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
            
        }else if([host isEqualToString:@"photosave"]){
            PhotoViewController *vc = [[PhotoViewController alloc] init];
            vc.imagePath = _imgFileName;
            vc.isWebApp = YES;
            [vc rightBtnClick];
            
        }else if([host isEqualToString:@"barcode"]){
            [self barCodeReaderOpen];
            
        }else if([host isEqualToString:@"blobstring"]){
            NSLog(@"[url query] : %@",[url query]);
            NSString *query = [url query];
            NSString *jsCommand = [NSString stringWithFormat:@"receive_blob('%@');",query];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"filePath"]){
            //photo 폴더 경로 넘겨주면 됨
            NSString *photoPath =[self getPhotoFilePath];
            photoPath = [photoPath URLEncode];
            NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"saveFile"]){
            //
        }else if([host isEqualToString:@"executePush"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executePush:callBackFunc :userSpecific :userList :msg];
            
        }else if([host isEqualToString:@"executeRetrieve"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"selectStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
        }else if([host isEqualToString:@"executeNonQuery"]){
            
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeCamera"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeCamera:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeSignpad"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeSignpad:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBarcode"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeBarcode:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeFileUpload"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileType = [dic objectForKey:@"fileType"];
            NSString *fileList = [dic objectForKey:@"fileList"];
            NSError *jsonError;
            NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
            [self executeFileUpload:fileType :json :upLoadPath];
            
        }else if([host isEqualToString:@"getGpsLocation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGpsLocation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getFilePath"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getFilePath:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"setFileNames"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileList = [dic objectForKey:@"fileList"];
            [self setFileNames:fileList];
            
        }else if([host isEqualToString:@"getNetworkStatus"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getNetworkStatus:callBackFunc :userSpecific];
            
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
            
        }else if([host isEqualToString:@"executeNotification"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *useVibrator = [dic objectForKey:@"useVibrator"];
            NSString *useBeep = [dic objectForKey:@"useBeep"];
            NSString *time = [dic objectForKey:@"time"];
            
            if([dic objectForKey:@"sound"]!=nil){
                NSString *beepSound = [dic objectForKey:@"sound"];
                [self executeNotification:useVibrator :useBeep :time :beepSound];
            } else {
                [self executeNotification:useVibrator :useBeep :time];
            }
            
        }else if([host isEqualToString:@"getAccelerometer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getAccelerometer:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getGyroscope"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGyroscope:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getMagneticField"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getMagneticField:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getOrientation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getOrientation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getProximity"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            
            [self getProximity:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"getFileList"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *_directoryPath = [dic objectForKey:@"directoryPath"];
            [self getFileList:callBackFunc :userSpecific :_directoryPath];

        }else if([host isEqualToString:@"executeDatagate"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
            NSString *sprocName = [dic objectForKey:@"sprocName"];
            NSString *args = [dic objectForKey:@"args"];
            [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
            
        }else if([host isEqualToString:@"isRoaming"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self isRoaming:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"executeSms"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            [self executeSms:callBackFunc :userSpecific :msg :userList];
            
        }else if([host isEqualToString:@"executeRecognizeSpeech"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRecognizeSpeech:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeExitWebBrowser"]){
            [self executeExitWebBrowser];
            
        }else if([host isEqualToString:@"getCheckSession"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getCheckSession:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"setBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"setBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"getUserInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getUserInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getmFinityOtherInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getmFinityOtherInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeProgressDialogStart"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
            
        }else if([host isEqualToString:@"executeProgressDialogStop"]){
            [self executeProgressDialogStop];
            
        }else if([host isEqualToString:@"getConvertImageToBase64"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *imagePath = [dic objectForKey:@"imagePath"];
            [self getConvertImageToBase64:callBackFunc :imagePath];
            
        }else if([host isEqualToString:@"executeMenu"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *menuNo = [dic objectForKey:@"menuNo"];
            [self executeMenu:menuNo];
            
        }else if([host isEqualToString:@"executeVideoPlayer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *streamingUrl = [dic objectForKey:@"streamingUrl"];
            [self executeVideoPlayer:streamingUrl];
        
        }else if([host isEqualToString:@"executeImageViewer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *imagePath = [dic objectForKey:@"url"];
            [self executeImageViewer:imagePath];
            
        } else if([host isEqualToString:@"windowClose"]){
//            [self.createdWKWebViews removeAllObjects];
//            NSLog(@"createdWKWebViews !! : %@", self.createdWKWebViews);
//            if ([self.webView canGoBack]) {
//                NSLog(@"canGoBack");
//                [self.webView goBack];
//            }else{
//                NSLog(@"reload");
//                [self.webView reload];
//            }
        }
        
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        
    } else if([[url scheme] isEqualToString:@"http"]||[[url scheme] isEqualToString:@"https"]){
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    
    } else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//    }];
//    NSLog(@"Action webView.URL : %@", webView.URL);
    
    NSURL *url = navigationAction.request.URL;
    NSLog(@"SCHEME : %@", url.scheme);
    
    NSString *urlString = [url absoluteString];
    
    if ([[url scheme]isEqualToString:@"ezmovetab"]) {
        self.tabBarController.selectedIndex = [[url host] intValue]-1;
       
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }else if([[url scheme]isEqualToString:@"toiphoneapp"]){
        if (imageViewer == nil) {
            NSLog(@"imageViewer is nil");
        }
        NSString *BASE_URL = @"https://touch1.hhi.co.kr/";
        [imageViewer setBaseUrl:BASE_URL];
        [imageViewer setParamInformation:urlString];
         [[[UIApplication sharedApplication] keyWindow] addSubview:imageViewer.view];
        
//        [imageViewer.topView setFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, imageViewer.view.frame.size.width, imageViewer.view.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
        [imageViewer.view setFrame:CGRectMake(0, 0, imageViewer.view.frame.size.width, imageViewer.view.frame.size.height)];
        [imageViewer.topView setFrame:CGRectMake(0, 22+[UIApplication sharedApplication].statusBarFrame.size.height, imageViewer.view.frame.size.width, imageViewer.topView.frame.size.height)];
       
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }else if([[url scheme]isEqualToString:@"dbcall"]){
        NSString *_paramString = urlString;
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
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }else if([[url scheme] isEqualToString:@"mfnp"]||[[url scheme] isEqualToString:@"mfinity"]){
        NSString *host = [url host];
        NSLog(@"host : %@", host);
        NSArray *params = [[url query] componentsSeparatedByString:@"&"];
        if ([host isEqualToString:@"camera"]) {
            CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
            appDelegate.mediaControl = @"camera";
            vc.isWebApp = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if([host isEqualToString:@"movetab"]){
            self.tabBarController.selectedIndex = [[url host] intValue]-1;
            
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
            
        }else if([host isEqualToString:@"gps"]){
            [self getGpsLocation:@"CBLocation" :nil];

        }else if([host isEqualToString:@"addressbook"]){
            NSDictionary *dic = [appDelegate contracts];
            NSString *dicString = [NSString stringWithFormat:@"%@",dic];
            NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString URLEncode]];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"signpad"]){
            SignPadViewController *vc = [[SignPadViewController alloc]init];
            UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
            
        }else if([host isEqualToString:@"photosave"]){
            PhotoViewController *vc = [[PhotoViewController alloc] init];
            vc.imagePath = _imgFileName;
            vc.isWebApp = YES;
            [vc rightBtnClick];
            
        }else if([host isEqualToString:@"barcode"]){
            [self barCodeReaderOpen];
            
        }else if([host isEqualToString:@"blobstring"]){
            NSLog(@"[url query] : %@",[url query]);
            NSString *query = [url query];
            NSString *jsCommand = [NSString stringWithFormat:@"receive_blob('%@');",query];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"filePath"]){
            //photo 폴더 경로 넘겨주면 됨
            NSString *photoPath =[self getPhotoFilePath];
            photoPath = [photoPath URLEncode];
            NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else if([host isEqualToString:@"saveFile"]){
            //
        }else if([host isEqualToString:@"executePush"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executePush:callBackFunc :userSpecific :userList :msg];
            
        }else if([host isEqualToString:@"executeRetrieve"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"selectStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
        }else if([host isEqualToString:@"executeNonQuery"]){
            
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *dbName = [dic objectForKey:@"dbName"];
            NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeCamera"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeCamera:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeSignpad"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeSignpad:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBarcode"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeBarcode:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeFileUpload"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileType = [dic objectForKey:@"fileType"];
            NSString *fileList = [dic objectForKey:@"fileList"];
            NSError *jsonError;
            NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
            [self executeFileUpload:fileType :json :upLoadPath];
            
        }else if([host isEqualToString:@"getGpsLocation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGpsLocation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getFilePath"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getFilePath:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"setFileNames"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *fileList = [dic objectForKey:@"fileList"];
            [self setFileNames:fileList];
            
        }else if([host isEqualToString:@"getNetworkStatus"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getNetworkStatus:callBackFunc :userSpecific];
            
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
            
        }else if([host isEqualToString:@"executeNotification"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *useVibrator = [dic objectForKey:@"useVibrator"];
            NSString *useBeep = [dic objectForKey:@"useBeep"];
            NSString *time = [dic objectForKey:@"time"];
            
            if([dic objectForKey:@"sound"]!=nil){
                NSString *beepSound = [dic objectForKey:@"sound"];
                [self executeNotification:useVibrator :useBeep :time :beepSound];
            } else {
                [self executeNotification:useVibrator :useBeep :time];
            }
            
        }else if([host isEqualToString:@"getAccelerometer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getAccelerometer:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getGyroscope"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGyroscope:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getMagneticField"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getMagneticField:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getOrientation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getOrientation:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getProximity"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSLog(@"dic : %@",dic);
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            
            [self getProximity:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"getFileList"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *_directoryPath = [dic objectForKey:@"directoryPath"];
            [self getFileList:callBackFunc :userSpecific :_directoryPath];

        }else if([host isEqualToString:@"executeDatagate"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
            NSString *sprocName = [dic objectForKey:@"sprocName"];
            NSString *args = [dic objectForKey:@"args"];
            [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
            
        }else if([host isEqualToString:@"isRoaming"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self isRoaming:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"executeSms"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            NSString *msg = [dic objectForKey:@"msg"];
            NSString *userList = [dic objectForKey:@"userList"];
            [self executeSms:callBackFunc :userSpecific :msg :userList];
            
        }else if([host isEqualToString:@"executeRecognizeSpeech"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self executeRecognizeSpeech:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeExitWebBrowser"]){
            [self executeExitWebBrowser];
            
        }else if([host isEqualToString:@"getCheckSession"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getCheckSession:callBackFunc :userSpecific];
        }else if([host isEqualToString:@"setBackKeyEvent"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"setBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else if([host isEqualToString:@"getUserInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getUserInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"getmFinityOtherInfo"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getmFinityOtherInfo:callBackFunc :userSpecific];
            
        }else if([host isEqualToString:@"executeProgressDialogStart"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
            
        }else if([host isEqualToString:@"executeProgressDialogStop"]){
            [self executeProgressDialogStop];
            
        }else if([host isEqualToString:@"getConvertImageToBase64"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *imagePath = [dic objectForKey:@"imagePath"];
            [self getConvertImageToBase64:callBackFunc :imagePath];
            
        }else if([host isEqualToString:@"executeMenu"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *menuNo = [dic objectForKey:@"menuNo"];
            [self executeMenu:menuNo];
            
        }else if([host isEqualToString:@"executeVideoPlayer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *streamingUrl = [dic objectForKey:@"streamingUrl"];
            [self executeVideoPlayer:streamingUrl];
        
        }else if([host isEqualToString:@"executeImageViewer"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *imagePath = [dic objectForKey:@"url"];
            [self executeImageViewer:imagePath];
            
        } else if([host isEqualToString:@"windowClose"]){
            NSLog(@"클로즈ㅠㅠ");
//            [self.createdWKWebViews removeAllObjects];
//            NSLog(@"createdWKWebViews !! : %@", self.createdWKWebViews);
//            if ([self.webView canGoBack]) {
//                NSLog(@"canGoBack");
//                [self.webView goBack];
//            }else{
//                NSLog(@"reload");
//                [self.webView reload];
//            }
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
    } else if([[url scheme] isEqualToString:@"http"]||[[url scheme] isEqualToString:@"https"]){
        decisionHandler(WKNavigationActionPolicyAllow);
    
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
};

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"Response webView.URL : %@", webView.URL);
    
    if (@available(iOS 11.0, *)) {  //available on iOS 11+
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray* cookies) {
            if (cookies.count > 0) {
                for (NSHTTPCookie *cookie in cookies) {
                    //TODO...
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }

                decisionHandler(WKNavigationResponsePolicyAllow);
            }
        }];
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];

        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }

        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
//    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
//    [self.webViews addObject:webView];
    [self.progressView setHidden:YES];
}
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"%s", __func__);
//    if ([webView canGoBack]) {
//        [webView goBack];
//    }else{
//        [webView reload];
//    }
    
    if(createTabCount>0){
        if (createTabCount==1) {
            UIView *tmpView = [self.view viewWithTag:9009];
            [tmpView removeFromSuperview];
            tmpView = nil;
        }
        createTabCount--;
    }
    WKWebView *wkView = [self.createdWKWebViews lastObject];
    [wkView removeFromSuperview];
    [self.createdWKWebViews removeLastObject];
    wkView = nil;
    
    if (self.createdWKWebViews.count>0) {
        self.webView = [self.createdWKWebViews lastObject];
    }
}

#pragma mark
#pragma mark Action Event Handler
- (void) receiveTestNotification:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"HideImageViewer"])
    {
        NSLog(@"receiveTestNotification");
        // 만일 이미지 뷰어가 종료되었을 때 이벤트를 받아서 처리할게 있다면 이곳에서 처리 한다.
        [imageViewer dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)errorButtonClicked2:(UploadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked2:(UploadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked2:(UploadListViewController *)aSecondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = [NSURL URLWithString:appDelegate.target_url];

    JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}

- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    vc.isDMS = _isDMS;
    if (!_isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
        appDelegate.scrollView.hidden = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)getExecuteMenuInfo:(NSString *)menuNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    NSString *_paramString = [NSString stringWithFormat:@"menuNo=%@&cuserNo=%@&encType=AES256",menuNo,appDelegate.user_no];
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
-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
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
        [self getExecuteMenuInfo:menuNo];
        
    }else{
        
        @try {
            NSString *jsCommand = [NSString stringWithFormat:@"CBPushMessage('%@');",body];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
        }
        @catch (NSException *exception) {
            NSLog(@"msg exception : %@",exception);
        }
    }
}
- (void)menuHandler{
    if ([menuKind isEqualToString:@"M"]) {
        //SubMenu
        MFTableViewController *subMenuList = [[MFTableViewController alloc]init];
        subMenuList.urlString = @"ezMainMenu2";
        [self.navigationController pushViewController:subMenuList animated:YES];
    }
    else if ([menuKind isEqualToString:@"P"]) {
        //실행메뉴일때
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
                    WKWebViewController *vc = [[WKWebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                        appDelegate.scrollView.hidden = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                        appDelegate.scrollView.hidden = NO;
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
                    WKWebViewController *vc = [[WKWebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                        appDelegate.scrollView.hidden = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                        appDelegate.scrollView.hidden = NO;
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
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
                appDelegate.scrollView.hidden = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
                appDelegate.scrollView.hidden = NO;
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
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            vc.type = @"A3";
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
                appDelegate.scrollView.hidden = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
                appDelegate.scrollView.hidden = NO;
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
    if (_backMode) {
        NSLog(@"back define mode");
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",_backDefineFunc,_backUserSpecific];
//        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        [self evaluateJavaScript:jsCommand];
    }else{
        NSLog(@"history back mode");
        if ([_webView canGoBack]) {
            [_webView goBack];
        }else{
            [_webView reload];
        }
    }
}

-(void)leftBtnClick {
    if(appDelegate.isInitPwd){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark
#pragma mark Location Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // 위치 정보 가져오는 것 실패 때
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
// CLLocation *)newLocation 여기에 위도경도가 변수에 들어가 있다.
    double latitude;  //더블형
    double longitude;
    
    latitude = newLocation.coordinate.latitude; //위도정보
    longitude =newLocation.coordinate.longitude;//경도 정보
    
    NSString *lbl_laText = [NSString stringWithFormat:@"위도는 : %g",latitude];
    NSString *lbl_loText = [NSString stringWithFormat:@"경도는 : %g",longitude];
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    //NSLog(@"didFinishDeferredUpdatesWithError");
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"didExitRegion");
}
#pragma mark
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString:NSLocalizedString(@"message91", @"")]){
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        [_webView reload];
    }
}

#pragma mark
#pragma mark WebViewController Utils
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
        [locationManager startUpdatingLocation];
        NSString *latitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%@', '%@');",[latitude URLEncode],[longitude URLEncode]];
        //NSLog(@"jsCommand : %@",jsCommand);
//        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific URLEncode],[fileName URLEncode]];
    NSLog(@"jsCommand : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    NSString *jsCommand = [NSString stringWithFormat:@"CBSignPad('%@','%@');",[fileName URLEncode],[[fileName lastPathComponent] URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    NSString *jsCommand = [NSString stringWithFormat:@"photoSave('%@','%@');",[fileName URLEncode],[[fileName lastPathComponent] URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific URLEncode],[fileName URLEncode]];
    NSLog(@"PhotoSave jsCommand : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
//이게 호출됨
-(void)dbConnection:(NSString *)page :(NSString *)crud :(NSString *)sql :(NSString *)dbName :(NSString *)cbName{
    sqlite3 *database;
    NSString *returnStr = @"{";
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
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
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    NSString *returnStr = @"{";
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
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
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
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
    NSString *returnStr = @"{";
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    
                    NSString *valueString = nil;
                    NSData *valueData = nil;
                    
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
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
//            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
}

#pragma mark
#pragma mark Barcode Call
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[errMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    }
}
-(void) savePicture:(UIImage *)sendImage :(NSString*)file{
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
    CGSize newSize;
    newSize.width = image.size.width/3;
    newSize.height = image.size.height/3;
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    [image drawInRect:rect];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.05)];
    NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".jpg"]];
    NSString *filePath3 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".thum"]];
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
#pragma mark MFNP
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
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific URLEncode],[returnString urlEncodeUsingEncoding:NSUTF8StringEncoding]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void) executeVideoPlayer:(NSString *)streamingUrl{
    NSLog(@"streamingUrl : %@",streamingUrl);
    NSURL *movieURL = [NSURL URLWithString:streamingUrl];
    MPMoviePlayerViewController *playView = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
    MPMoviePlayerController *moviePlayer = [playView moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:playView];
}

-(void) setBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)backKeyMode{
    if ([backKeyMode isEqualToString:@"0"]) {
        _backMode = NO;
    }else if([backKeyMode isEqualToString:@"1"]){
        _backMode = YES;
    }
    NSString *tmp = @"true";
    tmp = [tmp URLEncode];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific URLEncode],tmp];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
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
-(void) executeBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific{
    _backDefineFunc = callBackFunc;
    _backUserSpecific = userSpecific;
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
    }
}
-(void) executeRecognizeSpeech:(NSString *)callBackFunc :(NSString *)userSpecific{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeRecognizeSpeech" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}
-(void) executeExitWebBrowser{
    if(appDelegate.isInitPwd){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)executeImageViewer:(NSString *)imagePath{
    ImageViewerController *vc = [[ImageViewerController alloc]init];
    vc.imgPath = imagePath;
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];;
}

-(void)executeMenu:(NSString *)menuNo{
    [self getExecuteMenuInfo:menuNo];
}
-(void)getUserInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:appDelegate.user_id forKey:@"UserId"];
    [returnDic setObject:appDelegate.passWord forKey:@"UserPw"];
    [returnDic setObject:@"NONE" forKey:@"PhoneNum"];
    [returnDic setObject:language forKey:@"DeviceLanguage"];
    [returnDic setObject:appDelegate.exCompany forKey:@"ExCompany"];
    NSLog(@"returnDic : %@", returnDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[jsonString URLEncode]];
    NSLog(@"jsCommand : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}

-(void)getmFinityOtherInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    
    [returnDic setObject:appDelegate.user_no forKey:@"UserNo"];
    [returnDic setObject:appDelegate.user_id forKey:@"UserId"];
    [returnDic setObject:appDelegate.passWord forKey:@"UserPw"];
    [returnDic setObject:[MFinityAppDelegate getUUID] forKey:@"DeviceId"];
    [returnDic setObject:appDelegate.comp_no forKey:@"CompNo"];
    [returnDic setObject:appDelegate.app_no forKey:@"AppNo"];
    [returnDic setObject:@"I" forKey:@"DevOs"];
    [returnDic setObject:@"P" forKey:@"DevTy"];
    
    NSLog(@"returnDic : %@", returnDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[jsonString URLEncode]];
    NSLog(@"jsCommand : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}

-(void)getConvertImageToBase64:(NSString *)callBackFunc :(NSString *)imagePath {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:[imagePath lastPathComponent] forKey:@"title"];
    [returnDic setObject:base64 forKey:@"value"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callBackFunc,[jsonString URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)executeProgressDialogStart:(NSString *)title :(NSString *)msg :(NSString *)callbackFunc{
    [SVProgressHUD showWithStatus:msg];
    NSString *jsCommand = [NSString stringWithFormat:@"%@();",callbackFunc];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)executeProgressDialogStop{
    [SVProgressHUD dismiss];
}
-(void)executePush:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)userList :(NSString *)message{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSString *urlString = [NSString stringWithFormat:@"%@/sendPushService",appDelegate.main_url];
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
-(void)executeFileUpload:(NSString *)fileType :(NSDictionary *)fileList :(NSString *)upLoadPath{
    NSLog(@"%s", __func__);
    NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
    NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[fileList count]; i++) {
        [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
        [uploadUrlArray addObject:upLoadPath];
    }
    
    UploadListViewController *vc = [[UploadListViewController alloc]init];
    
    vc.uploadFilePathArray = uploadFilePathArray;
    vc.uploadUrlArray = uploadUrlArray;
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
-(void)executeRetrieve:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = dbDirectoryPath;
    
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
    NSString *returnStr = @"";
    sqlite3 *database;
    if (sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = selectStmt;
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            returnStr = @"{\"RESULT\":\"SUCCEED\",";
            int rowCount = 0;
            returnStr = [returnStr stringByAppendingFormat:@"\"DATASET\":{"];
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount++;
                NSString *LKey = [NSString stringWithFormat:@"ROW%d",i++];
                
                returnStr = [returnStr stringByAppendingFormat:@"\"%@\":{",LKey];
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
            returnStr = [returnStr stringByAppendingFormat:@"}}"];
            
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
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific URLEncode],[returnStr URLEncode]];
    NSLog(@"executeRetrive : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)executeNonQuery:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = dbDirectoryPath;
    
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
        NSLog(@"sql2 : %@",sql2);
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
   
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific URLEncode],[returnStr URLEncode]];
    NSLog(@"executeNonQuery : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)executeCamera:(NSString *)callBackFunc :(NSString *)userSpecific{
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
-(void)executeSignpad:(NSString *)callBackFunc :(NSString *)userSpecific{
    SignPadViewController *vc = [[SignPadViewController alloc]init];
    vc.userSpecific = userSpecific;
    vc.callbackFunc = callBackFunc;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}
-(void)executeBarcode:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    [self barCodeReaderOpen];
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
-(void)executeNotification:(NSString *)useVibrator :(NSString *)useBeep :(NSString *)timer :(NSString *)beepSound{
    count=0;
    endCount=[timer intValue];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:useVibrator,@"useVibrator",useBeep,@"useBeep",beepSound,@"beepSound", nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(handleTimer:)
                                   userInfo:userInfo
                                    repeats:YES];
    
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    
    NSLog(@"timer user info : %@", timer.userInfo);
    
    if (count==endCount) {
        count=0;

        if([timer.userInfo objectForKey:@"beepSound"]!=nil){
            if ([[timer.userInfo objectForKey:@"useVibrator"] isEqualToString:@"true"]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
            if ([[timer.userInfo objectForKey:@"useBeep"] isEqualToString:@"true"]) {
                NSString *beepSound = [timer.userInfo objectForKey:@"beepSound"];
                NSString *path;
                
                if([beepSound isEqualToString:@"-1"]){
                    AudioServicesPlaySystemSound(1106);
                    
                } else {
                    if([beepSound isEqualToString:@"1"]){
                        NSString *confirm = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]] pathForResource:@"confirm" ofType:@"mp3"];
                        path = confirm;
                        
                    } else if([beepSound isEqualToString:@"2"]){
                        NSString *error = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]] pathForResource:@"error" ofType:@"mp3"];
                        path = error;
                        
                    } else if([beepSound isEqualToString:@"3"]){
                        NSString *ok = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]] pathForResource:@"ok" ofType:@"mp3"];
                        path = ok;
                    }
                    
                    SystemSoundID soundID;
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
                    AudioServicesPlaySystemSound(soundID);
                }
            }
            
        } else {
            if ([[timer.userInfo objectForKey:@"useVibrator"] isEqualToString:@"true"]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
            if ([[timer.userInfo objectForKey:@"useBeep"] isEqualToString:@"true"]) {
                AudioServicesPlaySystemSound(1106);
            }
        }
        
        [timer invalidate];
    }
}
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
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[accelorInfo objectAtIndex:1] URLEncode],[[accelorInfo objectAtIndex:2] URLEncode],[[accelorInfo objectAtIndex:3] URLEncode]];
    
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
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
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[accelorInfo objectAtIndex:0] URLEncode],[[accelorInfo objectAtIndex:1] URLEncode],[[accelorInfo objectAtIndex:2] URLEncode]];
    
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
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
-(void)stopMagneticField{
    [motionManager stopMagnetometerUpdates];
    NSArray *sensorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[sensorInfo objectAtIndex:0] URLEncode],[[sensorInfo objectAtIndex:1] URLEncode],[[sensorInfo objectAtIndex:2] URLEncode]];
    
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
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
    
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)getProximity:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    UIDevice *device = [UIDevice currentDevice];
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
-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific {
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate =self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (IS_OS_8_OR_LATER) {
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [locationManager respondsToSelector:requestSelector]) {
            [locationManager performSelector:requestSelector withObject:NULL];
        } else {
            [locationManager startUpdatingLocation];
        }
    }else{
        [locationManager startUpdatingLocation];
    }
    NSString *latitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
    NSString *jsCommand;
    if (userSpecific == nil) {
        jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude URLEncode],[longitude URLEncode]];
    }else{
        jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific URLEncode],[latitude URLEncode],[longitude URLEncode]];
    }
    
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)specName{
    NSDictionary *deviceSpec = [self getDeviceSpec];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[[deviceSpec objectForKey:specName] URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *spec = [self getJsonStringByDictionary:[self getDeviceSpec]];

    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[spec urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(NSDictionary *)getDeviceSpec{
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = @"iOS";
    NSString *osVersion = myDevice.systemVersion;
    // 통신사
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    // Get carrier name
    NSString *carrierName = [carrier carrierName];
    
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
    NSString *isCamera = @"";
    if ([self linearCameraAvailable]) {
        isCamera = @"YES";
    }else{
        isCamera = @"NO";
    }
    //front_camera
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
    [returnDic setObject:isCamera forKey:@"stillcam"];
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
-(void)getNetworkStatus:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *result = [MFinityAppDelegate deviceNetworkingType];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[result URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
- (void)isRoaming:(NSString *)callBackFunc :(NSString *)userSpecific{
    
    NSString *yesStr = @"YES";
    NSString *noStr = @"NO";
    
    NSString *jsCommand;
    
    if ([self isRoaming]) {
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[yesStr URLEncode]];
    }else{
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[noStr URLEncode]];
    }
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
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
-(void)getFilePath:(NSString *)callBackFunc :(NSString *)userSpecific {
    NSString *photoPath = [self getPhotoFilePath];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@');",callBackFunc,[userSpecific URLEncode],[photoPath URLEncode],[photoPath URLEncode]];
//    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [self evaluateJavaScript:jsCommand];
}
-(void)setFileNames:(NSString *)fileList{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
}


#pragma mark
#pragma mark URLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"%s error : %@", __FUNCTION__, error);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alert show];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [receiveData setLength:0];
//    NSLog(@"response : %@",response);
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
    
    if ([methodName isEqualToString:@"DataGate3"]) {
        
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSLog(@"decString : %@",decString);
        NSError *error;
        if(decString!=nil){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            if ([dic objectForKey:@"ERROR"]!=nil) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"DataGate Error" message:[dic objectForKey:@"ERROR"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
                [alertView show];
                
            }
        }
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               decString];
        NSLog(@"jsCommand : %@",jsCommand);
//        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
//        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        [self evaluateJavaScript:jsCommand];
        
    }else if([methodName isEqualToString:@"CheckSession"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[encString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               [dic objectForKey:@"V0"]];
        
        NSLog(@"jsCommand : %@",jsCommand);
//        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
            if ([dic objectForKey:@"V3"]==nil) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message165", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];

            }else{
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
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                @try {
                    for(int i=1; i<=[paramDic count]; i++){
                        NSDictionary *subParamDic = [paramDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                        NSString *key = [[subParamDic objectForKey:@"PARAM_KEY"] urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        NSString *value = [[subParamDic objectForKey:@"PARAM_VAL"] urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        if([[[NSString urlDecodeString:value] substringToIndex:2] isEqualToString:@"{@"]){
                            if([key isEqualToString:@"PWD"]) value = appDelegate.passWord;
                            else if([key isEqualToString:@"AUTO_LOGIN_DATE"]) value = [prefs objectForKey:@"AUTO_LOGIN_DATE"];
                            else if([key isEqualToString:@"DEVICE_ID"]) value = [prefs objectForKey:@"DEVICE_ID"];
                        }
                        paramString = [paramString stringByAppendingFormat:@"%@",key];
                        paramString = [paramString stringByAppendingFormat:@"="];
                        paramString = [paramString stringByAppendingFormat:@"%@",value];
                        
                        paramString = [paramString stringByAppendingFormat:@"&"];
                    }
                    if ([[paramString substringFromIndex:paramString.length-1] isEqualToString:@"&"]) {
                        paramString = [paramString substringToIndex:paramString.length-1];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"paramString exception : %@",[exception name]);
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
            }
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
    BOOL accelerometer = motionManager.accelerometerAvailable;
    return accelerometer;
}

- (BOOL) gyroscopeAvailable
{
#ifdef __IPHONE_4_0
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
            
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = @"Failed";
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            resultString = @"Succeed";
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
#pragma mark Docuzen Custom
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (imageViewer != nil)
    {
        [imageViewer setImageViewOrientation:(UIInterfaceOrientation)toInterfaceOrientation];
    }
    return YES;
}
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // 추가
    if (imageViewer != nil)
    {
        [imageViewer setImageViewOrientation:(UIInterfaceOrientation)toInterfaceOrientation];
    }
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideImageViewer" object:nil];
}

#pragma mark
#pragma mark PullRefreshTableView
// 새로고침이 시작될 때 호출 될 메소드
- (void)startLoading
{
    //PullRefreshTableView의 StartLoading 호출
    [SVProgressHUD show];
    [_webView reload];
    [self startLoading2];
    
}
- (void)stopLoading
{
    [self performSelector:@selector(_stopLoading) withObject:nil afterDelay:1.f];
}
- (void)deleteLoading
{
    ivRefreshArrow.hidden = YES;
    lbRefreshTime.hidden = YES;
    spRefresh.hidden = YES;
    
}
// 새로고침이 완료될 때 호출 할 메소드
- (void)_stopLoading
{
    isRefresh = NO;
    refreshTime = nil;
    refreshTime = [[self performSelector:@selector(_getCurrentStringTime)] copy];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    
    [UIView setAnimationDidStopSelector:@selector(_stopLoadingComplete)];
    [_webView.scrollView setContentInset:UIEdgeInsetsZero];
    
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    [UIView commitAnimations];
}
- (void)startLoading2
{
    isRefresh = YES;
    lbRefreshTime.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [_webView.scrollView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
    NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_LOAD, refreshTime];
    [ivRefreshArrow setHidden:YES];
    [lbRefreshTime setText:lbString];
    [spRefresh startAnimating];
    
    [UIView commitAnimations];
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = NO;
    if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT)
    {
        [self startLoading];
    }
}
- (void)scrollViewDidScroll2:(UIScrollView *)scrollView
{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            _webView.scrollView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _webView.scrollView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_RELEASE, refreshTime];
            [lbRefreshTime setText:lbString];
            NSLog(@"lblString : %@", lbString);
            [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        }
        [UIView commitAnimations];
    }
}
// 최근 새로고침 시간을 String형으로 반환
- (NSString *)_getCurrentStringTime
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:REFRESH_TIME_FORMAT];
    NSString *returnString = [dateFormatter stringFromDate:date];
    return returnString;
}

// 테이블뷰 상단의 헤더뷰 초기화
- (void)_initializeRefreshViewOnTableViewTop
{
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, _webView.scrollView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [vRefresh setBackgroundColor:[UIColor clearColor]];
    
    if(spRefresh == nil)
    {
        spRefresh = [[UIActivityIndicatorView alloc] init];
    }
    [spRefresh setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 30) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 20) / 2, 20, 20)];
    [spRefresh setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spRefresh setColor:[UIColor blackColor]];
    [spRefresh setHidesWhenStopped:YES];
    [vRefresh addSubview:spRefresh];
    
    if(ivRefreshArrow == nil)
    {
        ivRefreshArrow = [[UIImageView alloc] init];
    }
    UIImage *imgArrow = [UIImage imageNamed:@"arrow.png"];
    [ivRefreshArrow setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 34) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 44) / 2, 24, 37)];
    [ivRefreshArrow setImage:imgArrow];
    [vRefresh addSubview:ivRefreshArrow];
    
    if(lbRefreshTime == nil)
    {
        lbRefreshTime = [[UILabel alloc] init];
    }
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, _webView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [_webView.scrollView addSubview:vRefresh];
}
// 새로고침 애니메이션을 정지할 때 호출할 메소드
- (void)_stopLoadingComplete
{
    NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_PULL, refreshTime];
    
    [ivRefreshArrow setHidden:NO];
    
    [lbRefreshTime setText:lbString];
    [spRefresh stopAnimating];
}

#pragma mark
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentSize.height-scrollView.contentOffset.y<self.view.frame.size.height) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        float reload_distance = 10;
        
        if(y > h + reload_distance) {
            //데이터로드
        }
    }
    
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            _webView.scrollView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _webView.scrollView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_RELEASE, refreshTime];
            [lbRefreshTime setText:lbString];
            [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        }
        [UIView commitAnimations];
    }
}

// 테이블뷰를 드래깅 할 때 호출
// 테이블뷰가 현재 새로고침 중이라면 무시
// 새로고침 중이 아니라면 드래깅 중이라는 것을 알려줌
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = YES;
}


#pragma mark
#pragma mark Util
- (void)evaluateJavaScript:(NSString *)jsCommand{
    NSLog(@"jsCommand : %@",jsCommand);
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
     {
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
         
     }];
}

@end
