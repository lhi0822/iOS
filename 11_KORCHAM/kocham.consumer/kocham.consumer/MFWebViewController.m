//
//  MFWebViewController.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFWebViewController.h"
//#import "WebViewAdditions.h"
#import "sqlite3.h"

#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 320
#define TAB_BAR_HEIGHT 49

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface MFWebViewController ()<MFNewWebViewDelegate>{
    int count;
    int endCount;
    int labelTag;
    int labelTextTag;
    int buttonTag;
    int labelSizePercent;
    int createTabCount;
    
    BOOL isForeground;
}

@end

@implementation MFWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    createTabCount = 0;
    labelTag = 1001;
    buttonTag = 2001;
    labelTextTag = 3001;
    labelSizePercent = 90;
    
    self.createdWKWebViews = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //UIApplicationDidBecomeActiveNotification
    
}
-(void)applicationDidBecomeActive:(UIApplication *)application{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.inactivePushInfo != nil) {
        [self throwPushNotification:appDelegate.inactivePushInfo];
        appDelegate.inactivePushInfo = nil;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    motionManager = [[CMMotionManager alloc]init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push Protocol
-(void)throwPushNotification:(NSDictionary *)dictionary{
    NSLog(@"dictionary : %@",dictionary);
    
    @try{
        NSDictionary *aps = [dictionary objectForKey:@"aps"];
        NSString *message = [aps objectForKey:@"alert"];
        NSString *badge = [aps objectForKey:@"badge"];
        
        NSString *type = [dictionary objectForKey:@"MSG_TYPE"];
        NSString *pushNo = [dictionary objectForKey:@"PUSH_NO"];
        NSString *etc1 = [dictionary objectForKey:@"ETC1"];
        NSString *etc2 = [dictionary objectForKey:@"ETC2"];
        NSString *etc3 = [dictionary objectForKey:@"ETC3"];
        NSString *etc4 = [dictionary objectForKey:@"ETC4"];
        
//        NSString *_data = [dictionary objectForKey:@"data"];
//        NSError *jsonError;
//        NSData *plainData = [_data dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:plainData options:NSJSONReadingMutabLeaves error:&jsonError];
//        NSString *type = [data objectForKey:@"MSG_TYPE"];
//        NSString *pushNo = [data objectForKey:@"PUSH_NO"];
//        NSString *etc1 = [data objectForKey:@"ETC1"];
//        NSString *etc2 = [data objectForKey:@"ETC2"];
//        NSString *etc3 = [data objectForKey:@"ETC3"];
//        NSString *etc4 = [data objectForKey:@"ETC4"];
        
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        [returnDic setObject:message forKey:@"MESSAGE"];
        [returnDic setObject:badge==nil?@"":badge forKey:@"BADGE"];
        [returnDic setObject:type==nil?@"":type forKey:@"TYPE"];
        [returnDic setObject:pushNo==nil?@"":pushNo forKey:@"PUSH_NO"];
        [returnDic setObject:etc1==nil?@"":etc1 forKey:@"ETC1"];
        [returnDic setObject:etc2==nil?@"":etc2 forKey:@"ETC2"];
        [returnDic setObject:etc3==nil?@"":etc3 forKey:@"ETC3"];
        [returnDic setObject:etc4==nil?@"":etc4 forKey:@"ETC4"];
        
        if(isForeground){
            //포그라운드일때는 푸시 알림 확인 눌러야 이동
            isForeground = NO;
            
            NSString *pushNotification = [self getJsonStringByDictionary:returnDic];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *callbackFunc = [prefs objectForKey:@"RECEIVE_PUSH_FUNC_NAME"];
            
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callbackFunc,[pushNotification stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self evaluateJavaScript:jsCommand];
            
        } else {
            //백그라운드나 꺼져있을때는 바로 이동
            if(etc1!=nil&&![etc1 isEqualToString:@""]){
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:etc1]]];
            }
            
        }
        
    } @catch(NSException *e){
        NSLog(@"throwPushNotification error : %@",e);
    }
}
-(void)pushNotificationReceived:(NSNotification *)notification{
    isForeground = YES;
    
    NSDictionary *userInfo = notification.userInfo;
    [self throwPushNotification:userInfo];
}
#pragma mark - WKWebViewDelegate Method
- (void)setMfnpMethod:(WKUserContentController *)userController{
    NSLog(@"%s",__FUNCTION__);
    [userController addScriptMessageHandler:self name:@"windowClose"];
    [userController addScriptMessageHandler:self name:@"windowOpen"];
    
    [userController addScriptMessageHandler:self name:@"executeBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"executeBarcode"];
    [userController addScriptMessageHandler:self name:@"executeCamera"];
    [userController addScriptMessageHandler:self name:@"executeDatagate"];
    [userController addScriptMessageHandler:self name:@"executeExitWebBrowser"];
    [userController addScriptMessageHandler:self name:@"executeFileUpload"];
    [userController addScriptMessageHandler:self name:@"executeMenu"];
    [userController addScriptMessageHandler:self name:@"executeNonQuery"];
    [userController addScriptMessageHandler:self name:@"executeNotification"];
    [userController addScriptMessageHandler:self name:@"executeRecognizeSpeech"];
    [userController addScriptMessageHandler:self name:@"executeRetrieve"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStart"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStop"];
    [userController addScriptMessageHandler:self name:@"executePush"];
    [userController addScriptMessageHandler:self name:@"executeSignpad"];
    [userController addScriptMessageHandler:self name:@"executeSms"];
    
    [userController addScriptMessageHandler:self name:@"getAccelerometer"];
    [userController addScriptMessageHandler:self name:@"getCheckSession"];
    [userController addScriptMessageHandler:self name:@"getConvertImageToBase64"];
    [userController addScriptMessageHandler:self name:@"getDeviceInfo"];
    [userController addScriptMessageHandler:self name:@"getDeviceSpec"];
    [userController addScriptMessageHandler:self name:@"getFilePath"];
    [userController addScriptMessageHandler:self name:@"getGpsLocation"];
    [userController addScriptMessageHandler:self name:@"getGyroscope"];
    [userController addScriptMessageHandler:self name:@"getMagneticField"];
    [userController addScriptMessageHandler:self name:@"getNetworkStatus"];
    [userController addScriptMessageHandler:self name:@"getProximity"];
    [userController addScriptMessageHandler:self name:@"getUserInfo"];
    [userController addScriptMessageHandler:self name:@"getImage"];
    [userController addScriptMessageHandler:self name:@"getAddress"];
    [userController addScriptMessageHandler:self name:@"getPushCallback"];
    
    [userController addScriptMessageHandler:self name:@"setBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"setFileNames"];
    [userController addScriptMessageHandler:self name:@"setIconBadge"];
    [userController addScriptMessageHandler:self name:@"setPushCallback"];
    
    [userController addScriptMessageHandler:self name:@"isRoaming"];
    
}
/*
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    NSLog(@"windowFeatures.allowsResizing : %@",windowFeatures.allowsResizing);
    NSLog(@"windowFeatures.height : %@",windowFeatures.height);
    NSLog(@"windowFeatures.width : %@",windowFeatures.width);
    NSLog(@"windowFeatures.x : %@",windowFeatures.x);
    NSLog(@"windowFeatures.y : %@",windowFeatures.y);
    NSLog(@"windowFeatures.menuBar : %@",windowFeatures.menuBarVisibility);
    NSLog(@"windowFeatures.statusBar : %@",windowFeatures.statusBarVisibility);
    NSLog(@"windowFeatures.toolBar : %@",windowFeatures.toolbarsVisibility);
    NSLog(@"navigationAction.request : %@",navigationAction.request);
    NSLog(@"configuration : %@",configuration);
    
    MFNewWebViewController *vc = [[MFNewWebViewController alloc]init];
    
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    nvc.navigationBarHidden=NO;
    
    [self presentPopupViewController:nvc animationType:MJPopupViewAnimationSlideRightLeft];
    
    return nil;
}
 */
-(void)closeButtonClick:(MFNewWebViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
}
 

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    /*
    createTabCount++;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    //UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight)];
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
    [self.view addSubview:tmpView];
    //CGFloat labelSize = (screenWidth/100)*(labelSizePercent-(createTabCount*5));
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
    
    
    //UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-44, 20, 44, 44)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    backButton.tag = buttonTag++;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    //| UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    //[backButton setBackgroundColor:[UIColor blackColor]];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_closeContentLayer-4.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    [self setMfnpMethod:userController];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    
    //CGRect webViewRect = CGRectMake(webViewFrame.frame.origin.x, 64, screenWidth, screenHeight-64);
    CGRect webViewRect = CGRectMake(webViewFrame.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+44, screenWidth, screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height);
    WKWebView *newWebView = [[WKWebView alloc] initWithFrame:webViewRect configuration:configuration];
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
    
    [self.createdWKWebViews addObject:newWebView];
    
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.4];
    [applicationLoadViewIn setType:kCATransitionPush];
    [applicationLoadViewIn setSubtype:kCATransitionFromRight];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[newWebView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [self.view addSubview:newWebView];    // 눈에 보여지도록

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
        
         [self.view addSubview:titleLabel];
         [self.view addSubview:backButton];
     }];
    */
    
    
    createTabCount++;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
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
    [self.view addSubview:tmpView];
    
    CGFloat labelSize =(screenWidth/100)*90;
    __block UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width-labelSize, [UIApplication sharedApplication].statusBarFrame.size.height, labelSize+10, 44)];
    titleLabel.tag = labelTag++;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
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
    
    __block UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(screen.size.width-labelSize, [UIApplication sharedApplication].statusBarFrame.size.height, labelSize-30, 44)];
    textLabel.tag = labelTextTag++;
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    textLabel.layer.masksToBounds = YES;
    textLabel.layer.cornerRadius = 5.f;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:20.0f weight:6.0f];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    backButton.tag = buttonTag++;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_closeContentLayer-4.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    [self setMfnpMethod:userController];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    
    CGRect webViewRect = CGRectMake(webViewFrame.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+44, screenWidth, screenHeight-[UIApplication sharedApplication].statusBarFrame.size.height);
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
    
    NSLog(@"newWebView : %@",newWebView.title);
    [newWebView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error)
     {
         //result == title
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
        
         textLabel.text = [NSString stringWithFormat:@"\t%@",result];
         CATransition *applicationLoadViewIn =[CATransition animation];
         [applicationLoadViewIn setDuration:0.4];
         [applicationLoadViewIn setType:kCATransitionPush];
         [applicationLoadViewIn setSubtype:kCATransitionFromRight];
         [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
         [[titleLabel layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
         [[textLabel layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
         [[backButton layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
        
         [self.view addSubview:titleLabel];
         [self.view addSubview:textLabel];
         [self.view addSubview:backButton];
     }];
    
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
    
    UIButton *backButton = (UIButton *)[self.view viewWithTag:--buttonTag];
    [backButton removeFromSuperview];
    backButton = nil;
    
    UILabel *label = (UILabel *)[self.view viewWithTag:--labelTag];
    [label removeFromSuperview];
    label = nil;
    
    UILabel *textLabel = (UILabel *)[self.view viewWithTag:--labelTextTag];
    [textLabel removeFromSuperview];
    textLabel = nil;
}
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"%s",__FUNCTION__);
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
    
    UIButton *backButton = (UIButton *)[self.view viewWithTag:--buttonTag];
    [backButton removeFromSuperview];
    backButton = nil;
    
    UILabel *label = (UILabel *)[self.view viewWithTag:--labelTag];
    [label removeFromSuperview];
    label = nil;
    
    UILabel *textLabel = (UILabel *)[self.view viewWithTag:--labelTextTag];
    [textLabel removeFromSuperview];
    textLabel = nil;
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
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    NSString *mfnpName = [NSString stringWithString:message.name];
    NSString *mfnpParam = [NSString stringWithString:message.body];
    NSDictionary *dic ;
    if (![mfnpParam isEqualToString:@""]) {
        dic = [self getParameters:mfnpParam];
    }
    
    
    if ([mfnpName isEqualToString:@"executeBackKeyEvent"]) {
         //[self executeBackKeyEvent];

    }else if ([mfnpName isEqualToString:@"windowClose"]) {
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
        
        UIButton *backButton = (UIButton *)[self.view viewWithTag:--buttonTag];
        [backButton removeFromSuperview];
        backButton = nil;
        
        UILabel *label = (UILabel *)[self.view viewWithTag:--labelTag];
        [label removeFromSuperview];
        label = nil;
        
        UILabel *textLabel = (UILabel *)[self.view viewWithTag:--labelTextTag];
        [textLabel removeFromSuperview];
        textLabel = nil;
        
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@')",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self evaluateJavaScript:jsCommand];
    }else if ([mfnpName isEqualToString:@"windowOpen"]) {
        NSLog(@"windowOpen");
        
    }else if ([mfnpName isEqualToString:@"executeBarcode"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeBarcode:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeCamera"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeCamera:callBackFunc :userSpecific];
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
        
        self.callbackFunc = [dic objectForKey:@"callbackFunc"];
        self.userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *_fileName = [dic objectForKey:@"fileList"];
        NSError *jsonError;
        NSDictionary *fileNameDic = [NSJSONSerialization JSONObjectWithData:[_fileName dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        NSString *upLoadPath = [dic objectForKey:@"uploadPath"];
        [self executeFileUpload :fileNameDic :upLoadPath];
    }
    else if ([mfnpName isEqualToString:@"executeMenu"]) {
        NSString *menuNo = [dic objectForKey:@"menuNo"];
        [self executeMenu:menuNo];
    }
    else if ([mfnpName isEqualToString:@"executeNonQuery"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeNotification"]) {
        NSString *useVibrator = [dic objectForKey:@"useVibrator"];
        NSString *useBeep = [dic objectForKey:@"useBeep"];
        NSString *time = [dic objectForKey:@"time"];
        [self executeNotification:useVibrator :useBeep :time];
    }
    else if ([mfnpName isEqualToString:@"executeRecognizeSpeech"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeRecognizeSpeech:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeRetrieve"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"selectStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeProgressDialogStart"]) {
        
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
     
    }
    else if ([mfnpName isEqualToString:@"executeProgressDialogStop"]) {
        [self executeProgressDialogStop];
    }
    else if ([mfnpName isEqualToString:@"executePush"]) {
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *userList = [dic objectForKey:@"userList"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executePush:callBackFunc :userSpecific :userList :msg];
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
    else if ([mfnpName isEqualToString:@"getConvertImageToBase64"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *imagePath = [dic objectForKey:@"imagePath"];
        [self getConvertImageToBase64:callBackFunc :imagePath];
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
    else if ([mfnpName isEqualToString:@"getDeviceInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getDeviceSpec:callBackFunc :userSpecific];
        
    }
    else if ([mfnpName isEqualToString:@"getFilePath"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getFilePath:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getGpsLocation"]) {
        NSLog(@"dic : %@",dic);
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
    else if ([mfnpName isEqualToString:@"getProximity"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getProximity:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getUserInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getUserInfo:callBackFunc :userSpecific];
    }else if([mfnpName isEqualToString:@"getImage"]){
        
        [self getImage:dic];
    }else if([mfnpName isEqualToString:@"getAddress"]){
        
        [self getAddress:dic];
    }else if([mfnpName isEqualToString:@"getPushCallback"]){
        
        [self getPushCallback:dic];
    }
    
    
    
    else if ([mfnpName isEqualToString:@"setBackKeyEvent"]) {
        /*
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *backkeyMode = [dic objectForKey:@"backkeyMode"];
        [self setBackKeyEvent:callBackFunc :userSpecific :backkeyMode];
         */
    }
    else if ([mfnpName isEqualToString:@"setFileNames"]) {
        NSString *fileList = [dic objectForKey:@"fileList"];
        [self setFileNames:fileList];
    }
    else if([mfnpName isEqualToString:@"setIconBadge"]){
        
        [self setIconBadge:dic];
    }else if([mfnpName isEqualToString:@"setPushCallback"]){
        
        [self setPushCallback:dic];
        
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
            //NSLog(@"webView.URL same");
            [self.view addSubview:webView];
        }
    }
    
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
    [self.progressView setHidden:YES];
    
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s : %@",__FUNCTION__,error);
    [self.progressView setHidden:YES];
    //UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
    //[alertView show];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

    if (@available(iOS 11.0, *)) {  //available on iOS 11+
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray* cookies) {
            if (cookies.count > 0) {
                for (NSHTTPCookie *cookie in cookies) {
                    //TODO...
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }
                
                //decisionHandler(WKNavigationResponsePolicyAllow);
            }
        }];
        decisionHandler(WKNavigationResponsePolicyAllow);
        
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);

    @try{
        __block UILabel *label = (UILabel *)[self.navigationController.view viewWithTag:labelTextTag-1]; //네비게이션 바 덮음
        if([label.text isEqualToString:@""] || [[label.text urlEncodeUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"%09"]){
            [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error)
             {
                 //result == title
                 NSString *text = [result componentsSeparatedByString:@"|"][0];
                 text = [NSString stringWithFormat:@"\t%@",text];
                 text = [self splitString:label :text];
                 label.text = text;
             }];
        }
        
    } @catch(NSException *e){
        NSLog(@"exception : %@", e);
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
    
    @try{
        if (strikeWidth>maxWidth) {
            NSArray *arr = [text componentsSeparatedByString:@" "];
        
            for (int i=0; i<=arr.count-2; i++) {
                NSString *tmp = [arr objectAtIndex:i];
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
    }@catch(NSException *e){
        NSLog(@"exception : %@", e);
    }
    
    return editText;
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"PhotoSave jsCommand : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    //카메라뷰일때
    UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //UIImageWriteToSavedPhotosAlbum(sendImage, self, nil, nil);
    
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"editImage : %@",editImage);
    //동영상일때
    //NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    
    // 현재시간 알아오기
    
    if (sendImage!=nil) {
        [self savePicture:sendImage :[self createPhotoFileName] :YES];
    }
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    
    
}
#pragma mark - SMS Delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = NSLocalizedString(@"CANCEL", @"");
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = NSLocalizedString(@"FAIL", @"");
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            resultString = NSLocalizedString(@"SUCCESS", @"");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Send SMS %@",resultString] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alertView show];
    }];
}

#pragma mark - MFNP EXECUTE
- (void)executeMFSync:(NSString *)callbackFunc :(NSString *)userSpecific :(NSString *)dbName :(NSString *)tableName{
    NSString *dbFilePath = [self makeDBFile];
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    dbFilePath = [dbFilePath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:dbFilePath]) {
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSString *query =[NSString stringWithFormat:@"select * from %@",tableName];
        NSArray *resultArray = [self selectQuery:dbFilePath :query];
        if([resultArray count]>0){
            NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
            [param setObject:resultArray forKey:@"DATA_LIST"];
            [param setObject:tableName forKey:@"TABLE_NM"];
            NSString *paramString = [NSString stringWithFormat:@"%@",param];
            NSString *urlString = [NSString stringWithFormat:@"%@",self.webServiceURL];
            MFURLSession *session = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:urlString] option:paramString];
            if([session start]){
                //progress
                [SVProgressHUD show];
            }
        }else{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"FAILED" forKey:@"RESULT"];
            [dic setObject:@"No search local data." forKey:@"ERR_MSG"];
            NSString *returnStr = [MFUtil getJsonStringByDictionary:dic];
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self evaluateJavaScript:jsCommand];
            
        }
    }
}

-(void)executePush:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)userList :(NSString *)message{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSString *_paramString = [NSString stringWithFormat:@"encType=AES256&mode=C&msg=%@&userList=%@",message,dic];
    NSString *urlString = @"";
    MFURLSession *session = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:urlString] option:_paramString];
    if ([session start]) {
        //progress
        [SVProgressHUD show];
    }
}
-(void)executeRetrieve:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    //documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
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
            //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
        sqlite3_finalize(compiledStatement);
        
    }else{
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    NSLog(@"returnStr : %@",returnStr);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeRetrive : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
    //[mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeNonQuery:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"documentPath : %@",documentPath);
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
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
                //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
                
            }else{
                returnStr = @"{\"RESULT\":\"SUCCEED\"}";
            }
            
            if(sqlite3_finalize(compiledStatement) != SQLITE_OK){
                NSLog(@"SQL Error : %s",sqlite3_errmsg(database));
                NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
                returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
                returnStr = [returnStr stringByAppendingString:@"\"}"];
                //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            }
            
            
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
            returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
            returnStr = [returnStr stringByAppendingString:@"\"}"];
            //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
    }else{
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeNonQuery : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
    //[mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeCamera:(NSString *)callBackFunc :(NSString *)userSpecific{
    self.callbackFunc = callBackFunc;
    self.userSpecific = userSpecific;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        //self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:NULL];
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
    /*
     self.callbackFunc = callBackFunc;
     self.userSpecific = userSpecific;
     MFSignPadViewController *vc = [[MFSignPadViewController alloc]init];
     vc.delegate = self;
     [self presentSemiViewController:vc withOptions:@{
     KNSemiModalOptionKeys.pushParentBack : @(NO),
     KNSemiModalOptionKeys.parentAlpha : @(0.5),
     KNSemiModalOptionKeys.transitionStyle : @(KNSemiModalTransitionStyleSlideUp)
     }];
     */
}

-(void)executeBarcode:(NSString *)callBackFunc :(NSString *)userSpecific{
    MFBarcodeScannerViewController *vc = [[MFBarcodeScannerViewController alloc]init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
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

-(void)executeFileUpload:(NSDictionary *)fileList :(NSString *)upLoadPath{
    
     NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
     NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
     for (int i=0; i<[fileList count]; i++) {
         NSString *filePath = [fileList objectForKey:[NSString stringWithFormat:@"%d",i]];
         if (![filePath isEqualToString:@""] || ![filePath isEqualToString:@"\"\""] || filePath != nil) {
             [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
             [uploadUrlArray addObject:upLoadPath];
         }
     }
    [self fileUploads:uploadFilePathArray :uploadUrlArray];
     
}

-(void)executeDataGate:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)dbConfigKey :(NSString *)sprocName :(NSString *)args{
    self.callBackDic = [[NSMutableDictionary alloc]init];
    [self.callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [self.callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    [self.callBackDic setValue:[dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"dbConfigKey"];
    [self.callBackDic setValue:[sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"sprocName"];
    [self.callBackDic setValue:[args urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"args"];
    
    NSString *_dbConfigKey =[FBEncryptorAES encryptBase64String:dbConfigKey
                                                      keyString:[MFUtil getAES256Key]
                                                  separateLines:NO];
    NSString *_sprocName =[FBEncryptorAES encryptBase64String:sprocName
                                                    keyString:[MFUtil getAES256Key]
                                                separateLines:NO];
    NSString *_args =[FBEncryptorAES encryptBase64String:args
                                               keyString:[MFUtil getAES256Key]
                                           separateLines:NO];
    NSString *_compNo =[FBEncryptorAES encryptBase64String:[MFUtil getCompNo]
                                                 keyString:[MFUtil getAES256Key]
                                             separateLines:NO];
    NSString *urlString = [NSString stringWithFormat:@"%@/DataGate3",[MFUtil getMainURL]];
    NSString *paramString = [[NSString alloc]initWithFormat:@"jsonPCallback=?&dbConfigKey=%@&sprocName=%@&args=%@&jsonPCallback?&compNo=%@&encType=AES256",[_dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding],[_sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding],[_args urlEncodeUsingEncoding:NSUTF8StringEncoding],[_compNo urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:urlString] option:paramString];
    if([session start]){
        //progress
        [SVProgressHUD show];
    }
    
}
-(void)executeProgressDialogStart:(NSString *)title :(NSString *)msg :(NSString *)callbackFunc{
    [SVProgressHUD show];
}
-(void)executeProgressDialogStop{
    [SVProgressHUD dismiss];
}
-(void)executeSms:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)msg :(NSString *)userList{
    self.callBackDic = [[NSMutableDictionary alloc]init];
    [self.callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [self.callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
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
-(void)executeRecognizeSpeech:(NSString *)callBackFunc :(NSString *)userSpecific{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeRecognizeSpeech" message:NSLocalizedString(@"지원하지 않는 기능입니다.", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
    [alertView show];
}
-(void)executeExitWebBrowser{
    // 보류
}
-(void)executeMenu:(NSString *)menuNo{
    // 보류
}

#pragma mark - MFNP GET
- (void)getPushCallback:(NSDictionary *)dic{
    NSString *callbackFunc = [dic objectForKey:@"callbackFunc"];
    NSString *userSpecific = [dic objectForKey:@"userSpecific"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *functionName = [prefs objectForKey:@"RECEIVE_PUSH_FUNC_NAME"];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,userSpecific,functionName];
    [self evaluateJavaScript:jsCommand];
}
- (void)getAddress:(NSDictionary *)dic{
    self.callbackFunc = [dic objectForKey:@"callbackFunc"];
    self.userSpecific = [dic objectForKey:@"userSpecific"];
    
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    // Select property to pick
    
    [contactPicker setDisplayedPropertyKeys:[[NSArray alloc] initWithObjects:CNContactPhoneNumbersKey, nil] ];
    //[contactPicker setPredicateForEnablingContact:[NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"]];
    //[contactPicker setPredicateForSelectionOfContact:[NSPredicate predicateWithFormat:@"emailAddresses.@count == 1"]];
    // Respond to selection
    contactPicker.delegate = self;
    // Display picker
    [self presentViewController:contactPicker animated:YES completion:nil];
    
}
- (void)getImage:(NSDictionary *)dic{
    self.callbackFunc = [dic objectForKey:@"callbackFunc"];
    self.userSpecific = [dic objectForKey:@"userSpecific"];
    //UIImagePickerControllerSourceTypeCamera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        //self.picker.allowsEditing = YES;
        
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.picker animated:YES completion:NULL];
    }
    //[self performSegueWithIdentifier:@"MODAL_PHLIB_VIEW" sender:@"PHOTO"];
}
-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific {
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    
    /*
     if (self.locationManager.location.coordinate.latitude==0 && self.locationManager.location.coordinate.longitude==0) {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
     }*/
    /*
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    */
    if ([self.latitude intValue]==0 || [self.longitude intValue] == 0) {
        NSLog(@"latitude is value = %d",[self.latitude intValue]);
        NSLog(@"longitude is value = %d",[self.longitude intValue]);
    }else{
        NSString *jsCommand;
        if (userSpecific == nil) {
            jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[self.latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else{
            jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        //[self.locationManager stopUpdatingLocation];
        [self evaluateJavaScript:jsCommand];
        
    }
    
    
}
-(void)getFilePath:(NSString *)callBackFunc :(NSString *)userSpecific {
    NSString *photoPath = [self getPhotoFilePath];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void)getNetworkStatus:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *result;
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
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)specName{
    NSDictionary *deviceSpec = [self getDeviceSpec];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[deviceSpec objectForKey:specName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *spec = [self getJsonStringByDictionary:[self getDeviceSpec]];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[spec stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
-(NSDictionary *)getDeviceSpec{
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = myDevice.systemName;
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
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *modelName = [[UIDevice currentDevice] modelName];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
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
    
    if (IDIOM==IPAD) [returnDic setObject:@"T" forKey:@"DEV_KIND"];
    else [returnDic setObject:@"P" forKey:@"DEV_KIND"];
    
    [returnDic setObject:@"I" forKey:@"OS_TYPE"];
    [returnDic setObject:[MFUtil getUUID] forKey:@"DEV_ID"];
//    [returnDic setObject:appDelegate.appDeviceToken forKey:@"PUSH_ID1"];
    [returnDic setObject:appDelegate.fcmToken forKey:@"PUSH_ID1"];
    [returnDic setObject:@"-" forKey:@"PUSH_ID2"];
    
    return returnDic;
}
-(void)getAccelerometer:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogUserAccelerationData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopAccelerometer) withObject:self afterDelay:1.0];
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
-(void)getOrientation:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogRotationRateData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopRotationRate) withObject:self afterDelay:1.0];
    
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
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Proximity" message:NSLocalizedString(@"지원하지 않는 기능입니다.", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)getCheckSession:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSString *sessionURL = [NSString stringWithFormat:@"%@/CheckSession",[MFUtil getMainURL]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:sessionURL] option:nil];
    if([session start]){
        [SVProgressHUD show];
    }
    
}
-(void)getUserInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    // 보류
}
-(void)getConvertImageToBase64:(NSString *)callBackFunc :(NSString *)imagePath{
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
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callBackFunc,[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}

#pragma mark - MFNP SET
- (void)setPushCallback:(NSDictionary *)dic{
    NSString *callbackFunc = [dic objectForKey:@"callbackFunc"];
    NSString *functionName = [dic objectForKey:@"functionName"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:functionName forKey:@"RECEIVE_PUSH_FUNC_NAME"];
    [prefs synchronize];
    NSString *jsCommand = [NSString stringWithFormat:@"%@(%d);",callbackFunc,YES];
    [self evaluateJavaScript:jsCommand];
}
- (void)setIconBadge:(NSDictionary *)dic{
    NSString *callbackFunc = [dic objectForKey:@"callbackFunc"];
    NSString *userSpecific = [dic objectForKey:@"userSpecific"];
    NSString *badgeCount = [dic objectForKey:@"badgeCount"];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[badgeCount intValue]];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@',%d);",callbackFunc,userSpecific,YES];
    [self evaluateJavaScript:jsCommand];
}
-(void)setFileNames:(NSString *)fileList{
    // 보류
}
#pragma mark - MFNP IS
-(void)isRoaming:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *yesStr = @"YES";
    NSString *noStr = @"NO";
    
    NSString *jsCommand;
    
    if ([self isRoaming]) {
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[yesStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[noStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [self evaluateJavaScript:jsCommand];
    
}
#pragma mark
#pragma mark Location Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status==kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"위치 정보를 가져 오려면 사용자의 위치에 접근하도록 허용해야 합니다.", @"위치 접근 허용") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"취소", @"취소") otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
        alertView.tag = 1001;
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
    //double latitude;  //더블형
    //double longitude;
    
    self.latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude]; //위도정보
    self.longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];//경도 정보
    
    //NSString *lbl_laText = [NSString stringWithFormat:@"위도는 : %@",self.latitude];
    //NSString *lbl_loText = [NSString stringWithFormat:@"경도는 : %@",self.longitude];
    
    
    //NSLog(@"%@",lbl_loText);
    //NSLog(@"%@",lbl_laText);
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    //NSLog(@"didFinishDeferredUpdatesWithError");
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"didExitRegion");
}

#pragma mark - MFBarcode Delegate
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
#pragma mark - MFSignPad Delegate
-(void)returnSignFilePath:(NSString *)fileName{
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self evaluateJavaScript:jsCommand];
}
#pragma mark -
#pragma mark CNContactPickerDelegate
/*!
 * @abstract Invoked when the picker is closed.
 * @discussion The picker will be dismissed automatically after a contact or property is picked.
 */
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    NSLog(@"User canceled picker");
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    NSLog(@"contact : %@",contact);
    //NAME
    NSString *name = contact.familyName;
    name = [name stringByAppendingString:contact.givenName];
    
    NSString *phoneNumber = @"";
    NSArray *phoneNumbers = contact.phoneNumbers;
    if (phoneNumbers.count>1) {
        for (CNLabeledValue *labelValue in phoneNumbers) {
            CNPhoneNumber *phoneNum = labelValue.value;
            if ([labelValue.label isEqualToString:@"_$!<Mobile>!$_"]) {
                phoneNumber = [phoneNum stringValue];
            }
        }
    }else{
        CNLabeledValue *labelValue = phoneNumbers[0];
        CNPhoneNumber *phoneNum = labelValue.value;
        phoneNumber = [phoneNum stringValue];
    }
    
    NSDictionary *returnDic = [[NSDictionary alloc]initWithObjectsAndKeys:name,@"NAME",phoneNumber,@"PHONE", nil];
    NSString *returnString = [self getJsonStringByDictionary:returnDic];
    NSLog(@"returnString : %@",returnString);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
#pragma mark - CNContactViewControllerDelegate
-(BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property{
    NSLog(@"property : %@",property);
    return YES;
}
#pragma mark - UploadList Delegate
- (void)errorButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked2:(UploadListViewController *)aSecondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)returnUploadDataWithDictionary:(NSDictionary *)dictionary error:(NSString *)error{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    if (error!=nil) {
        NSString *result = error;
        result = [result urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],result];
        
        [self evaluateJavaScript:jsCommand];
    }else{
        NSString *result = [[self getJsonStringByDictionary:dictionary] urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],result];
        
        [self evaluateJavaScript:jsCommand];
    }
    

}
#pragma mark - MFURLSession Delegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    NSString *wsName = session.url.absoluteString.lastPathComponent;
    if([wsName isEqualToString:@"DataGate3"]){
        NSString *encString =[[NSString alloc]initWithData:session.returnData encoding:NSUTF8StringEncoding];
        NSString *decString = [encString AES256DecryptWithKeyString:[MFUtil getAES256Key]];
        
        
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if ([dic objectForKey:@"ERROR"]!=nil) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"DataGate Error" message:[dic objectForKey:@"ERROR"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"확인") otherButtonTitles: nil];
            [alertView show];
            
        }
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               decString];
        
        [self evaluateJavaScript:jsCommand];
    }else if([wsName isEqualToString:@"mfsync"]){
        
    }else if([wsName isEqualToString:@"CheckSession"]){
        NSString *encString =[[NSString alloc]initWithData:session.returnData encoding:NSUTF8StringEncoding];
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
        
    }
    NSDictionary *returnDic = session.returnDictionary;
    NSLog(@"returnDic : %@",returnDic);
}

#pragma mark - WebView Util
- (void)getImageNotification:(NSNotification *)notification {
    
    NSArray *imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    NSLog(@"imageArray : %@",imageArray);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
    [self savePicture:imageArray[0] :[self createPhotoFileName] :NO];
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
- (void) proximityChanged:(NSNotification *)notification {
    UIDevice *device = [notification object];
    NSLog(@"In proximity: %i", device.proximityState);
}
-(void)stopRotationRate{
    [_myDataLogger stopLoggingMotionDataAndSave];
    NSArray *accelorInfo = [_myDataLogger.rotationRateString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self evaluateJavaScript:jsCommand];
}
-(void)stopMagneticField{
    [motionManager stopMagnetometerUpdates];
    NSArray *sensorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self evaluateJavaScript:jsCommand];
    
}
-(void)stopGyroscope{
    [motionManager stopGyroUpdates];
    NSArray *accelorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self evaluateJavaScript:jsCommand];
    
}
-(void)stopAccelerometer{
    [_myDataLogger stopLoggingMotionDataAndSave];
    
    NSArray *accelorInfo = [_myDataLogger.userAccelerationString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:3] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self evaluateJavaScript:jsCommand];
}

-(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
-(void)fileUploads:(NSMutableArray *)uploadFilePathArray :(NSMutableArray *)uploadUrlArray{
    
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
-(NSArray *)selectQuery:(NSString *)dbFilePath :(NSString *)selectStmt{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:dbFilePath]) {
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    sqlite3 *database;
    if (sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = selectStmt;
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dic setObject:valueString forKey:keyString];
                }
                [resultArray addObject:dic];
            }
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:NSLocalizedString(@"SQL Error", @"SQL Error")
                    subTitle:str
            closeButtonTitle:NSLocalizedString(@"확인", @"확인") duration:0.0f];
            
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
        sqlite3_finalize(compiledStatement);
    }else{
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    
    return resultArray;
}
- (void)evaluateJavaScript:(NSString *)jsCommand{
    NSLog(@"jsCommand : %@",jsCommand);
    //if (IS_OS_8_OR_LATER) {
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
     {
         //result == title
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
         
     }];
    //[mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

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
-(NSString *)getPhotoFilePath{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
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
-(void) savePicture:(UIImage *)sendImage :(NSString*)file :(BOOL)isCameraCall{
    
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
    CGSize newSize;
    if (isCameraCall) {
        newSize.width = image.size.width/3;
        newSize.height = image.size.height/3;
    }else{
        newSize.width = image.size.width;
        newSize.height = image.size.height;
    }
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
- (void)photoSave:(NSString *)fileName{
    
}
- (void)photoSave:(NSString *)fileName :(NSString *)userSpectific :(NSString *)callbackFunc{
    NSLog(@"photoSave");
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc
                           ,[userSpectific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ,[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"PhotoSave jsCommand : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}
-(void)rightBtnClick {
    
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
- (NSString *)makeDBFile{
    
    NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"Application Support"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"dbvalley"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"sqlite_db"];
    NSString *dbFilePath = [libraryPath stringByAppendingPathComponent:@"mFinity.db"];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mFinity.sqlite" ofType:nil];
    NSError *error;
    
    if (![manager isReadableFileAtPath:libraryPath]) {
        [manager createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![manager isReadableFileAtPath:dbFilePath]) {
        [manager copyItemAtPath:filePath toPath:dbFilePath error:&error];
    }
    
    return libraryPath;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageNotification:)
                                                 name:@"getImageNotification"
                                               object:nil];
}


@end
