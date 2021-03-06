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

#import "PdfViewController.h"
#import "ImageSetViewController.h"

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

@interface WebViewController (){
    HISImageViewer *imageViewer;
    CGFloat tabHeight;
    
    NSTimer *gpsTimer;
}

@end

@implementation WebViewController

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
    
//    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
//        //NSLog(@"%s : isMovingFromParentViewController",__FUNCTION__);
//    }
    
    appDelegate.isSettingPwd = NO;
}

#pragma mark
-(void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    CGFloat viewHeight = [[UIScreen mainScreen]bounds].size.height;
    
    if(appDelegate.isWebviewTab) _isTabBar = YES;
    tabHeight = 0;
    
    NSArray *controllers = [self.navigationController viewControllers];
    UIViewController *controller = [controllers objectAtIndex:0];
    NSString *tempString = [NSString stringWithFormat:@"%@", controller.class];
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        appDelegate.scrollView.hidden = YES;
        
        if(_isTabBar){
            self.tabBarController.tabBar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        } else {
            self.tabBarController.tabBar.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
        }
        
        if(appDelegate.isInitPwd||appDelegate.isSettingPwd){
            self.navigationController.navigationBar.hidden = NO;
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        appDelegate.scrollView.hidden = YES;
        
        if(_isTabBar){
            self.tabBarController.tabBar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        } else {
            self.tabBarController.tabBar.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
        }
        
        if(appDelegate.isInitPwd||appDelegate.isSettingPwd){
            self.navigationController.navigationBar.hidden = NO;
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
            self.navigationController.navigationBar.hidden = NO;
        }
        else {
            tabHeight = 0;
            appDelegate.scrollView.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
        }
        
        if(appDelegate.isInitPwd||appDelegate.isSettingPwd){
            self.navigationController.navigationBar.hidden = NO;
        }
       
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            if(_isTabBar){
                [mywebView setFrame:CGRectMake(mywebView.frame.origin.x, mywebView.frame.origin.y, mywebView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height+tabHeight)];
            } else {
                [mywebView setFrame:CGRectMake(mywebView.frame.origin.x, 0, mywebView.frame.size.width, appDelegate.scrollView.frame.origin.y)];
            }
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            if([appDelegate isIphoneX]){
                [mywebView setFrame:CGRectMake(mywebView.frame.origin.x, tabHeight, mywebView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-tabHeight)];
            } else {
                [mywebView setFrame:CGRectMake(mywebView.frame.origin.x, tabHeight, mywebView.frame.size.width, viewHeight-(appDelegate.scrollView.frame.origin.y+tabHeight))];
            }
        }
    }
    
    
    if ([tempString isEqualToString:@"NotiPushViewController"]) {
        self.navigationController.navigationBar.hidden = NO;
    }
    
    NSLog(@"_isTabBar : %d", _isTabBar);
    
    NSString *currentClass = NSStringFromClass([self.parentViewController class]);
    if([currentClass isEqualToString:@"UIMoreNavigationController"]){
        self.navigationItem.hidesBackButton = YES;
    }
    
    
    
}


- (void)viewDidLoad
{
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    
    mywebView.scrollView.delegate = self;
    //mywebView.scrollView.bounces = NO;
    //mywebView.scrollView.alwaysBounceVertical = YES;
    //mywebView.scrollView.alwaysBounceHorizontal = NO;
    
    //쿠키허용
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"HideImageViewer" object: nil];
    
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
    
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [mywebView addGestureRecognizer:longPressRecognizer];
    
    mywebView.scalesPageToFit = YES;
    mywebView.mediaPlaybackRequiresUserAction = NO;
    mywebView.allowsInlineMediaPlayback = YES;
    mywebView.delegate = self;
    
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
    
    
    //모달팝업 완료버튼이 흰색으로 나오는 이슈가 있음(190308)
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UIToolbar.class]]setTintColor:[appDelegate myRGBfromHex:@"#007AFF"]]; //화살표만 바뀜
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[appDelegate myRGBfromHex:@"#007AFF"], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    if(appDelegate.isInitPwd){
        if(!_pwdParentView){
            UIImage *buttonImageLeft = [UIImage imageNamed:@"prev_bt_03.png"];
            
            UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
            [leftButton setImage:buttonImageLeft forState:UIControlStateNormal];
            leftButton.frame = CGRectMake(0, 0, buttonImageLeft.size.width,buttonImageLeft.size.height);
            
            [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *customBarItemLeft = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem = customBarItemLeft;
            
        } else {
            self.navigationItem.hidesBackButton = NO;
        }
        
    }
    
    /*
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *buttonImageRight = [UIImage imageNamed:@"btn_back_49.png"];
    
    
    CGRect rect = CGRectMake(0, 0,buttonImageRight.size.width, buttonImageRight.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, buttonImageRight.CGImage);
    CGContextSetFillColorWithColor(context, [[appDelegate myRGBfromHex:appDelegate.naviFontColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    
    
    UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [rightButton setImage:flippedImage forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, buttonImageRight.size.width,buttonImageRight.size.height);
    
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItemRight = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.leftBarButtonItem = customBarItemRight;
    */
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
    
	NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
	mywebView.scalesPageToFit = YES;
    mywebView.mediaPlaybackRequiresUserAction = NO;
    mywebView.allowsInlineMediaPlayback = YES;
    
    //user-agent
    //NSString *secretAgent = [mywebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
        
        if (appDelegate.isOffLine) {
            //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message109", @"")];
        }else{
            [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:page_url]]];
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
            //str = [str stringByAppendingFormat:@"&uid=%@",appDelegate.user_id];
            [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            //[mywebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:tempString]];
        }
        
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
    
    //
    //[appDelegate chageTabBarColor:YES];
    ////NSLog(@"UITabBar appearance2 : %@",[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected]);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"jsCode : %@",jsCode);
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
#pragma mark WebView Delegate
- (void)webView:(IMTWebView *)_webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources {
    [self.progressView setProgress:((float)resourceNumber) / ((float)totalResources)];
    if (resourceNumber == totalResources) {
        _webView.resourceCount = 0;
        _webView.resourceCompletedCount = 0;
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"error : %@",error);
    
    self.progressView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    if (error.code == 102) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"message159", @"지원하지 않는 포멧입니다.") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
        
    }else if(error.code == -999){
        return;
    }else if(error.code == 101){
        return;
    }else{
      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"오류" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
      [alertView show];
    }
    
}
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"[request URL] : %@",[request URL]);
    //NSLog(@"request url : %@",[[request URL] absoluteURL]);
    
    NSLog(@"navigationType : %ld", (long)navigationType);
    
    if (UIWebViewNavigationTypeLinkClicked == navigationType || UIWebViewNavigationTypeOther == navigationType) {
        ////NSLog(@"a tag url : %@",[[request URL] absoluteURL]);
        if ([[[request URL] scheme]isEqualToString:@"ezmovetab"]) {
            self.tabBarController.selectedIndex = [[[request URL] host] intValue]-1;
            return NO;
        }else if([[[request URL] scheme]isEqualToString:@"toiphoneapp"]){
            if (imageViewer == nil) {
                NSLog(@"imageViewer is nil");
                return NO;
            }
            NSString *BASE_URL = @"https://smart1.hshi.co.kr/";
            [imageViewer setBaseUrl:BASE_URL];
            [imageViewer setParamInformation:[[request URL] absoluteString]];
            [[[UIApplication sharedApplication] keyWindow] addSubview:imageViewer.view];
            
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
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *time = [dic objectForKey:@"time"];
                if(time==nil) {
                    time = @"7";
                }
                //[self getGpsLocation:@"CBLocation" :nil];
                [self getGpsLocation:@"CBLocation" :nil :time];
                
            }else if([host isEqualToString:@"addressbook"]){
                NSDictionary *dic = [appDelegate contracts];
                NSString *dicString = [NSString stringWithFormat:@"%@",dic];
                NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString URLEncode]];
                [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
                
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
                [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
                
            }else if([host isEqualToString:@"filePath"]){
                //photo 폴더 경로 넘겨주면 됨
                NSString *photoPath =[self getPhotoFilePath];
                photoPath = [photoPath URLEncode];
                NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
                [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
                
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
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *fileList = [dic objectForKey:@"fileList"];
                NSError *jsonError;
                NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
                NSString *afterDropFlag = [dic objectForKey:@"afterDropFlag"];
                [self executeFileUpload:callBackFunc :userSpecific :json :upLoadPath :afterDropFlag];
                
                /*
                NSString *fileType = [dic objectForKey:@"fileType"];
                NSString *fileList = [dic objectForKey:@"fileList"];
                NSError *jsonError;
                NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
                [self executeFileUpload:fileType :json :upLoadPath];
                */
            }else if([host isEqualToString:@"getGpsLocation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *time = [dic objectForKey:@"time"];
                if(time==nil) {
                    time = @"7";
                }
                //[self getGpsLocation:callBackFunc :userSpecific];
                [self getGpsLocation:callBackFunc :userSpecific :time];
                
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
                [self executeNotification:useVibrator :useBeep :time];
                
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
                /*
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeBackKeyEvent:callBackFunc :userSpecific];
                 */
                
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
                /*
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *backkeyMode = [dic objectForKey:@"backkeyMode"];
                [self setBackKeyEvent:callBackFunc :userSpecific :backkeyMode];
                 */
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
                [self executeProgressDialogStart:callBackFunc :[dic objectForKey:@"title"] :[dic objectForKey:@"msg"]];
                
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
            
            }else if([host isEqualToString:@"executeGallery"]){ //181127_추가
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"executeGallery dic : %@", dic);
                [self getImage:dic];
                
            }else if([host isEqualToString:@"executePDFView"]){ //181127_추가
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"executePDFView dic : %@", dic);
                NSString *url = [dic objectForKey:@"url"];
                [self executePDFView:url];
                
//                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
//                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
//                [self getMDMInfo:callBackFunc :userSpecific];
//                [self executeHSHIImageUpload:@"CBHSHIImageUpload" :@"http://eqmnew.e-hshi.co.kr/Weblogic/PhotoSave" :@"6" :@"0"];
            
            }else if([host isEqualToString:@"executeHSHIImageUpload"]){ //181127_추가
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"executeHSHIImageUpload dic : %@", dic);
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *uploadUrl = [dic objectForKey:@"upLoadUrl"];
                NSString *count = [dic objectForKey:@"count"];
                NSString *size = [dic objectForKey:@"size"];
                
//                [self executeHSHIImageUpload:@"HSHIImageUpload" :@"getUploadResult" :@"http://ehse.hshi.co.kr/CommonPhotoSaveServlet.do" :@"5" :@"8000"];

                [self executeHSHIImageUpload:callBackFunc :userSpecific :uploadUrl :count :size];
                
            }else if([host isEqualToString:@"getMDMInfo"]){ //181205_추가
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"getMDMInfo dic : %@", dic);
                
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                
                [self getMDMInfo:callBackFunc :userSpecific];
            }
            return NO;
        }
        else {
            NSLog(@"%s else",__FUNCTION__);
            return YES;
        }
    }
    return YES;
}

#pragma mark - MFNP 181127
- (void)getImage:(NSDictionary *)dic{
    self.callbackFunc = [dic objectForKey:@"callbackFunc"];
    self.userSpecific = [dic objectForKey:@"userSpecific"];
    
    //UIImagePickerControllerSourceTypeCamera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.navigationBar.backgroundColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
-(void) executePDFView:(NSString *)url{
    NSLog(@"url : %@",url);
    
    PdfViewController *vc = [[PdfViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

    nav.modalTransitionStyle = UIModalPresentationFullScreen;

    vc.isTabBar = _isTabBar;
    vc.fileUrl = url;

    [self presentViewController:nav animated:YES completion:nil];
}
-(void)executeHSHIImageUpload:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)uploadUrl :(NSString *)count :(NSString *)size{
    self.callbackFunc = callbackFunc;
    self.userSpecific = userSpecific;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(executeHSHIImageUploadReturn:) name:@"executeHSHIImageUploadReturn" object:nil];
    
    if(uploadUrl!=nil&&![uploadUrl isEqualToString:@""]){
        ImageSetViewController *vc = [[ImageSetViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.uploadUrl = uploadUrl;
        vc.count = count;
        vc.maxSize = size;
        
        appDelegate.scrollView.hidden = YES;
        [self.navigationController pushViewController:vc animated:YES];
    
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"업로드 경로가 없습니다.", @"업로드 경로가 없습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)executeHSHIImageUploadReturn:(NSNotification *)notification {
    NSLog(@"executeHSHIImageUploadReturn userinfo : %@", notification.userInfo);
    NSArray *array = [notification.userInfo objectForKey:@"RETURN"];
    
    NSError *_error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&_error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getMDMInfo:(NSString *)callbackFunc :(NSString *)userSpecific{
    self.callbackFunc = callbackFunc;
    self.userSpecific = userSpecific;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MDMResultNotification:) name:@"MDMResultNotification" object:nil];
    
    NSURL *url = [NSURL URLWithString:@"com.gaia.mobikit.apple://"];
    
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url = [NSURL URLWithString:@"https://exafe.hshi.co.kr:8080/exafe_admin/download/agent"];
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        if ([self getMDMExageInfo:@"queries_getStatus_getRichStatus_getMDMUserInfo"]) {
            NSLog(@"MDM호출");
        }else{
            NSLog(@"MDM이 실행되지 않아 앱을 종료합니다.");
            
        }
    }
}
-(BOOL)getMDMExageInfo:(NSString*)command{
    NSString * stringURLScheme = nil;
    BOOL isBe;
    NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (URLTypes && [URLTypes count]) {
        NSDictionary * dict = [URLTypes objectAtIndex:0];
        NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
            stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
        }
    }
    
    if (stringURLScheme) {
        NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=%@",command];
        
        [urlString appendFormat:@"&caller=%@", stringURLScheme];
        NSLog(@"urlString : %@",urlString);
        isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        return isBe;
    }
    else{
        NSLog(@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.");
        UIAlertView * alert = [[UIAlertView alloc]
                               initWithTitle: nil
                               message: @"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다."
                               delegate:nil
                               cancelButtonTitle:@"확인"
                               otherButtonTitles:nil, nil];
        alert.tag = 2000;
        alert.delegate = self;
        [alert show];
        
        return NO;
    }
}
- (void)MDMResultNotification:(NSNotification *)notification {
    NSLog(@"MDMResultNotification userinfo : %@", notification.userInfo);
    /* notification.userInfo값
     {
     authtoken = "B0B58E7E-B435-4B70-A185-50B3624F706E";
     customUserType = insaSync;
     isLastVersion = 1;
     isRooted = 0;
     isVendorPushEnabled = 1;
     loginid = W117436;
     mdmactive = 1;
     memberNum = W117436;
     operationStatus = 2;
     rooting = 0;
     status = 2;
     userEmail = "kimhr202@hshi.co.kr";
     userId = W117436;
     userName = "%EA%B9%80%ED%98%95%EB%A0%AC";
     }
     */
    
    BOOL mdmInstalled = [[notification.userInfo objectForKey:@"mdmactive"] integerValue]; //1:정상, 0:미설치
    BOOL mdmIsRooted = [[notification.userInfo objectForKey:@"isRooted"] integerValue];
    NSString *mdmStatus = [notification.userInfo objectForKey:@"status"];
    NSString *mdmUserId = [notification.userInfo objectForKey:@"userId"];
    //NSString *mdmServerUrl = @"";
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    [resultDict setObject:[NSNumber numberWithBool:mdmInstalled] forKey:@"MDM_INSTALLED"];
    [resultDict setObject:[NSNumber numberWithBool:mdmIsRooted] forKey:@"ROOTED_DEVICE"];
    
    if([mdmStatus isEqualToString:@"0"]){
        [resultDict setObject:@"STATUS_UNREGISTERED" forKey:@"MDM_STATUS"];
        [resultDict setObject:@"NONE" forKey:@"USER_ID"];
    } else if([mdmStatus isEqualToString:@"1"]){
        [resultDict setObject:@"STATUS_DISABLED" forKey:@"MDM_STATUS"];
        [resultDict setObject:mdmUserId forKey:@"USER_ID"];
    } else if([mdmStatus isEqualToString:@"2"]){
        [resultDict setObject:@"STATUS_FINE" forKey:@"MDM_STATUS"];
        [resultDict setObject:mdmUserId forKey:@"USER_ID"];
    } else {
        [resultDict setObject:mdmUserId forKey:@"USER_ID"];
    }
    
    NSLog(@"MDM resultDict : %@", resultDict);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MDMResultNotification" object:nil];
    
    NSError *_error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDict options:0 error:&_error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    ////NSLog(@"webViewDidFinishLoad");
    self.progressView.hidden = YES;
    
    [mywebView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    //[mywebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%ld;', false);", (long)mywebView.frame.size.width]];
    
    if([webView isLoading]){
        //NSLog(@"loading");
    }
    [locationManager stopUpdatingLocation];
    //NSLog(@"type :%@",_type );
    
    if ([_type isEqualToString:@"A3"]) {
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%f', '%f');",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
        //NSLog(@"jsCommand : %@",jsCommand);
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
    }
    
    NSLog(@"webView : %@",[webView request]);
    //[myIndicator stopAnimating];
    //[myIndicator removeFromSuperview];
    
    //[mywebView stringByEvaluatingJavaScriptFromString:@"callbackUserInfo('a','{\"UserId\" : \"A401226\",\"PhoneNum\" : \"NONE\",\"DeviceLanguage\" : \"ko\"}');"];
    
    //[activityAlert close];
    
    [mywebView.scrollView setContentSize: CGSizeMake(self.view.frame.size.width, mywebView.scrollView.contentSize.height)];

    
    [SVProgressHUD dismiss];
    [self stopLoading];
    
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

- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isDMS = _isDMS;
    if (!_isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
        appDelegate.scrollView.hidden = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)getExecuteMenuInfo:(NSString *)menuNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    //NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://192.168.0.54:1598/dataservice41/GetExecuteMenuInfo"]];
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
    NSString *alert = [aps objectForKey:@"alert"];
    NSString *type = [userInfo objectForKey:@"type"];
    NSError *error;
    
    if ([type isEqualToString:@"E"]) {
        NSString *menuNo = [userInfo objectForKey:@"menuNo"];
        [self getExecuteMenuInfo:menuNo];
        
    }else{
        
        @try {
            NSString *jsCommand = [NSString stringWithFormat:@"CBPushMessage('%@');",alert];
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
                    
                    //vc.downloadURL = naviteAppDownLoadUrl;
                    //vc.currentAppVersion = currentAppVersion;
                    //vc.nativeAppMenuNo = nativeAppMenuNo;
                    
                    
                }else{
                    WebViewController *vc = [[WebViewController alloc] init];
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
            WebViewController *vc = [[WebViewController alloc] init];
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
            WebViewController *vc = [[WebViewController alloc] init];
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
	//NSLog(@"rightBTNCLick");
    if (_backMode) {
        NSLog(@"back define mode");
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",_backDefineFunc,_backUserSpecific];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }else{
        NSLog(@"history back mode");
//        if ([mywebView canGoBack])  [mywebView goBack];
//        else                        [self.navigationController popViewControllerAnimated:YES];
//        
        if ([mywebView canGoBack]) {
            [mywebView goBack];
        }else{
            [mywebView reload];
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
	
	
	//NSLog(@"%@",lbl_loText);
	//NSLog(@"%@",lbl_laText);
	
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
    NSLog(@"##############");
    if([alertView.title isEqualToString:NSLocalizedString(@"message91", @"")]){
        //[self.navigationController popViewControllerAnimated:YES];
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        [mywebView reload];
        
    } else{
        
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
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
   
    if([callbackFunc isEqualToString:@"CBGallery"]){
        NSError *error;
        NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE",@"STATUS", [fileName URLEncode],@"PATH", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific URLEncode], jsonString];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
         NSLog(@"CBGallery PhotoSave jsCommand : %@",jsCommand);
        
    } else {
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific URLEncode],[fileName URLEncode]];
        NSLog(@"PhotoSave jsCommand : %@",jsCommand);
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
   
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
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
		}else {
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
			printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    //
    
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
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
		}else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
			printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    
    //
    
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
                    NSData *valueData = nil;
                    
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
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
            
		}else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
			printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
#pragma mark Barcode Call
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[errMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void) barCodeReaderOpen{
    MFBarcodeScannerViewController *vc = [[MFBarcodeScannerViewController alloc]init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nvc animated:YES completion:nil];
    /*
     //등록한 외부라이브러리를 이용해 바코드리더 오픈 ---------------
     _reader = [ZBarReaderViewController new];
     _reader.readerDelegate = self;
     ZBarImageScanner *scanner = _reader.scanner;
     [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
     //------------------------------------------------------
     
     //바코드리더뷰 열기
     [self presentViewController:_reader animated:YES completion:nil];
     */
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"취소 PhotoSave jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if (isCamera) {
        //카메라뷰일때
        UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //동영상일때
        //NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];

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
        //삼호중공업테스트
        UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"sendImage : %@",sendImage);
        
        if (sendImage!=nil) {
            [self savePicture:sendImage :[self createPhotoFileName]];
        } else {
            NSError *error;
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE",@"STATUS", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific URLEncode], jsonString];
            [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        }
        
        [reader dismissViewControllerAnimated:YES completion:nil];
    }
}
//삼호중공업테스트
-(NSString *)createPhotoFileName{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSString *filename = @"";
    filename = [filename stringByAppendingString:@"("];
    
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@")"];
    return filename;
}

-(void) savePicture:(UIImage *)sendImage :(NSString*)file{
    NSLog(@"savePicture ImgSize : %f*%f", sendImage.size.width, sendImage.size.height);
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
//    CGSize newSize;
//    newSize.width = image.size.width/3;
//    newSize.height = image.size.height/3;
//    NSLog(@"newSize : %f*%f", newSize.width, newSize.height);
    
    //디폴트사이즈설정------------------------------------------------
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    int fixSize = 1024;
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
    
//    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    CGRect rect = CGRectMake(0, 0, fixedNewSize.width, fixedNewSize.height);
    [image drawInRect:rect];
    
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.05)];
    NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".jpg"]];
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

-(CGSize) defaultResizeImg:(UIImage *)img {
    CGSize reSized;
    
    return reSized;
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
        
        //[self presentModalViewController:controller animated:YES];
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

-(void)executeMenu:(NSString *)menuNo{
    [self getExecuteMenuInfo:menuNo];
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
    [returnDic setObject:appDelegate.passWord forKey:@"UserPw"];
    [returnDic setObject:@"NONE" forKey:@"PhoneNum"];
    [returnDic setObject:language forKey:@"DeviceLanguage"];
    NSLog(@"returnDic : %@", returnDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[jsonString URLEncode]];
    //NSString *jsCommand = [NSString stringWithFormat:@"callbackUserInfo2('%@');",jsonString];
    //NSString *jsCommand = @"callbackUserInfo2('jhpark');";
    NSLog(@"jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];

}

-(void)getmFinityOtherInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    
    [returnDic setObject:appDelegate.user_no forKey:@"UserNo"];
    [returnDic setObject:appDelegate.user_id forKey:@"UserId"];
    [returnDic setObject:appDelegate.passWord forKey:@"UserPw"];
    [returnDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"DeviceId"];
    [returnDic setObject:appDelegate.comp_no forKey:@"CompNo"];
    [returnDic setObject:appDelegate.app_no forKey:@"AppNo"];
    [returnDic setObject:@"I" forKey:@"DevOs"];
    [returnDic setObject:@"P" forKey:@"DevTy"];
    
    [appDelegate loginHistoryToLogFile:[NSString stringWithFormat:@"%s",__func__] result:nil];
    
    NSLog(@"returnDic : %@", returnDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[jsonString URLEncode]];
    NSLog(@"jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

-(void)executeProgressDialogStart:(NSString *)callbackFunc :(NSString *)title :(NSString *)msg {
    [SVProgressHUD showWithStatus:msg];
    NSString *jsCommand = [NSString stringWithFormat:@"%@();",callbackFunc];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeProgressDialogStop{
    [SVProgressHUD dismiss];
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
/*
-(void)executeFileUpload:(NSString *)fileType :(NSDictionary *)fileList :(NSString *)upLoadPath{
    NSLog(@"%s", __func__);
    //@property (nonatomic, strong) NSMutableArray *uploadFilePathArray;
    //@property (nonatomic, strong) NSMutableArray *uploadUrlArray;
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
*/
-(void)executeFileUpload:(NSString *)callBackFunc :(NSString *)userSpecific :(NSDictionary *)fileList :(NSString *)upLoadPath :(NSString *)flag{
    NSLog(@"callBackFunc : %@", callBackFunc);
    NSLog(@"userSpecific : %@", userSpecific);
    NSLog(@"fileList : %@", fileList);
    NSLog(@"upLoadPath : %@", upLoadPath);
    NSLog(@"flag : %@", flag);
    
    //upLoadPath = @"http://eqmnew.e-hshi.co.kr/Weblogic/PhotoSave";
    //upLoadPath = @"http://192.168.0.186:8080/dataservice41/PhotoSave";
    
    self.callbackFunc = callBackFunc;
    
    NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
    NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[fileList count]; i++) {
        [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
        [uploadUrlArray addObject:upLoadPath];
    }
    NSLog(@"uploadFilePathArray : %@", uploadFilePathArray);
    NSLog(@"uploadUrlArray : %@", uploadUrlArray);
    
    [self fileUploads:uploadFilePathArray :uploadUrlArray :flag];

}
-(void)fileUploads:(NSMutableArray *)uploadFilePathArray :(NSMutableArray *)uploadUrlArray :(NSString *)flag{
    UploadListViewController *vc = [[UploadListViewController alloc]init];
    vc.uploadFilePathArray = uploadFilePathArray;
    vc.uploadUrlArray = uploadUrlArray;
    vc.deleteFlag = [flag boolValue];
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
-(void)returnArray:(NSMutableArray *)array WithError:(NSString *)error{
    //executeFileUpload리턴
    NSError *_error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&_error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",self.callbackFunc,[jsonString URLEncode]];
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
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
                rowCount++;
                //rowCount = sqlite3_column_int(compiledStatement, 0);
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
	
}
-(void)executeCamera:(NSString *)callBackFunc :(NSString *)userSpecific{
    //MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    /*
    CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
    appDelegate.mediaControl = @"camera";
    vc.isWebApp = YES;
    vc.callbackFunc = callBackFunc;
    vc.userSpecific = userSpecific;
    [self.navigationController pushViewController:vc animated:NO];
    */
}
-(void)executeSignpad:(NSString *)callBackFunc :(NSString *)userSpecific{
    SignPadViewController *vc = [[SignPadViewController alloc]init];
    vc.userSpecific = userSpecific;
    vc.callbackFunc = callBackFunc;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    //[self.navigationController pushViewController:vc animated:YES];
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
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[accelorInfo objectAtIndex:0] URLEncode],[[accelorInfo objectAtIndex:1] URLEncode],[[accelorInfo objectAtIndex:2] URLEncode]];
    
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
-(void)stopMagneticField{
    [motionManager stopMagnetometerUpdates];
    NSArray *sensorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific URLEncode],[[sensorInfo objectAtIndex:0] URLEncode],[[sensorInfo objectAtIndex:1] URLEncode],[[sensorInfo objectAtIndex:2] URLEncode]];
    
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
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)time {
    int time2 = [time intValue];
    
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
    NSLog(@"latitude : %@, longitude : %@", latitude, longitude);
    
    if([latitude intValue]==0&&[longitude intValue]==0){
        NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:callBackFunc,@"callBackFunc", userSpecific,@"userSpecific", nil];
        gpsTimer = [NSTimer scheduledTimerWithTimeInterval:time2 target:self selector:@selector(gpsLocationTimer:) userInfo:userInfo repeats:YES];
    } else {
        NSString *jsCommand;
        if (userSpecific == nil) {
            jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude URLEncode],[longitude URLEncode]];
        }else{
            jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific URLEncode],[latitude URLEncode],[longitude URLEncode]];
        }
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
}
-(void)gpsLocationTimer:(NSTimer *)timer {
    NSDictionary *userInfo = (NSDictionary*)timer.userInfo;
    NSString *callBackFunc = [userInfo objectForKey:@"callBackFunc"];
    NSString *userSpecific = [userInfo objectForKey:@"userSpecific"];
    
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
    
    if([latitude intValue]==0&&[longitude intValue]==0){
        NSString *jsCommand;
        if (userSpecific == nil) {
            jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude URLEncode],[longitude URLEncode]];
        }else{
            jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific URLEncode],[latitude URLEncode],[longitude URLEncode]];
        }
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    [timer invalidate];
}

-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)specName{
    NSDictionary *deviceSpec = [self getDeviceSpec];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[[deviceSpec objectForKey:specName] URLEncode]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *spec = [self getJsonStringByDictionary:[self getDeviceSpec]];

    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[spec urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
	//NSString *isCamera = [self isValue:@"still-camera"];
	NSString *isCamera = @"";
    if ([self linearCameraAvailable]) {
        isCamera = @"YES";
    }else{
        isCamera = @"NO";
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
    
    /*
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            NSLog(@"No wifi or cellular");
            break;
        case 1:
            result = @"Cellular";
            break;
        case 2:
            result = @"Cellular";
            break;
        case 3:
            result = @"Cellular";
            break;
        case 4:
            result = @"Cellular";
            break;
        case 5:
            result = @"WIFI";
            break;
        default:
            break;
    }
     */
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific URLEncode],[result URLEncode]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
-(void)getFilePath:(NSString *)callBackFunc :(NSString *)userSpecific {
    NSString *photoPath = [self getPhotoFilePath];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@');",callBackFunc,[userSpecific URLEncode],[photoPath URLEncode],[photoPath URLEncode]];
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
    NSLog(@"response : %@",response);
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
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
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
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
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
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
        
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
    [mywebView reload];
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
    //[mywebView setContentInset:UIEdgeInsetsZero];
    [mywebView.scrollView setContentInset:UIEdgeInsetsZero];
    
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    spRefresh.hidden = YES;
    ivRefreshArrow.hidden = YES;
    lbRefreshTime.hidden = YES;
    
    [UIView commitAnimations];
    
}
- (void)startLoading2
{
    isRefresh = YES;
    lbRefreshTime.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [mywebView.scrollView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
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
    if(scrollView.contentOffset.x==0 && scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT)
    {
        [self startLoading];
    }
}
- (void)scrollViewDidScroll2:(UIScrollView *)scrollView {
    CGFloat scrollOffsetX = scrollView.contentOffset.x;
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetX==0 && scrollOffsetY > 0)
        {
            mywebView.scrollView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetX==0 && scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            mywebView.scrollView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetX==0 && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetX==0 && scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
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
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, mywebView.scrollView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
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
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, mywebView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [mywebView.scrollView addSubview:vRefresh];
    
    spRefresh.hidden = YES;
    ivRefreshArrow.hidden = YES;
    lbRefreshTime.hidden = YES;
}
// 새로고침 애니메이션을 정지할 때 호출할 메소드
- (void)_stopLoadingComplete
{
    NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_PULL, refreshTime];
    
    //[ivRefreshArrow setHidden:NO];
    
    [lbRefreshTime setText:lbString];
    [spRefresh stopAnimating];
}

#pragma mark
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //if (!noticeViewFlag) {
    
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
            //[SVProgressHUD showWithStatus:@"Loading"];
            
        }
    }
    
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetX = scrollView.contentOffset.x;
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //NSLog(@"scrollOffsetX : %f", scrollOffsetX);
    
    if(isRefresh)
    {
        if(scrollOffsetX==0 && scrollOffsetY>0)
        {
            mywebView.scrollView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetX==0 && scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            mywebView.scrollView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetX==0 && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetX==0 && scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
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
@end


@implementation UIWebView (Javascript)
BOOL diagStat = NO;
BOOL clicked = NO;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SmartOne" message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame {
    clicked = NO;
    
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:@"SmartOne" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"취소", @"취소") otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
    [confirmDiag show];
    
    while (clicked == NO) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    
    //NSLog(@"diagStat : %d", diagStat);
    
    return diagStat;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //index 0 : NO , 1 : YES
    clicked = YES;
    if (buttonIndex == 0){
        diagStat = NO;
    } else if (buttonIndex == 1) {
        diagStat = YES;
    }
}

@end
