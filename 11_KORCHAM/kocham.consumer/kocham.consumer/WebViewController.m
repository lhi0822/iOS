//
//  WebViewController.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 5..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "WebViewController.h"
@interface WebViewController (){
    NSMutableString * htmlObjectName;
    
    float lastOffsetY;
    float scrollViewHeight;
    CGRect keyboardBounds;
    float keyboardBoundsHeight;
    BOOL isKeyPad;
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
-(void)viewDidLoad{
    keyboardBoundsHeight = 333.500000;
    [super viewDidLoad];

    self.createdWKWebViews = [NSMutableArray array];
    self.urlHistoryArray = [NSMutableArray array];
    isKeyPad = NO;

    //쿠키허용
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
    
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openUrlNotification:) name:@"OpenUrlNotification" object:nil];
    //

    
    NSLog(@"%@",self.startURL);
    
    // #########################################################################################################################################################
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // #########################################################################################################################################################
     [self initWKWebView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self becomeFirstResponder];
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)openUrlNotification:(NSNotification *)notification{
    NSDictionary *paramDic = notification.userInfo;
    if ([paramDic objectForKey:@"request_url"]!=nil) {
        NSString *page_url = [paramDic objectForKey:@"request_url"];
        if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
            NSURL *nsurl=[NSURL URLWithString:page_url];
            NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
            [self.webView loadRequest:nsrequest];
        }else{
            NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [NSString stringWithFormat:@"file://%@",self.startURL];
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
                [self.webView loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];
            }else{
                [self.webView loadHTMLString:filePath baseURL:[NSURL fileURLWithPath:documentsDir]];
            }
        }
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    // Respond to changes in device orientation
    /*
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"webViewFrame.frame.origin.x : %f",webViewFrame.frame.origin.x);
    NSLog(@"webViewFrame.frame.origin.y : %f",webViewFrame.frame.origin.y);
    NSLog(@"webViewFrame.frame.size.width : %f",webViewFrame.frame.size.width);
    NSLog(@"webViewFrame.frame.size.height : %f",webViewFrame.frame.size.height);
    CGRect webViewRect;
    if (orientation==1) {
        webViewRect = CGRectMake(webViewFrame.frame.origin.x, webViewFrame.frame.origin.y, webViewFrame.frame.size.width, webViewFrame.frame.size.height-20);
    }else{
        webViewRect = CGRectMake(webViewFrame.frame.origin.x, webViewFrame.frame.origin.y-20, webViewFrame.frame.size.width, webViewFrame.frame.size.height);
    }
    
    self.webView.frame = webViewRect;
    */
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        NSLog(@"### shake ### : %@",event);
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"%s",__FUNCTION__);
    
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = navigationAction.request.URL;
    NSLog(@"SCHEME : %@ ##### %@", url, url.scheme);
    
    //PAYNOW
    NSString *paynow = @"lguthepay";
    NSString *paynow2 = @"lguthepay-xpay";
    
    //계좌이체
    NSString *smartxpay = @"smartxpay-transfer";
    NSString *nhAppCash = @"nhappcash-acp";
    NSString *woori = @"SmartBank2WIB";
    NSString *woori2 = @"NewSmartPib";
    NSString *woori3 = @"PortalCenterWB";
    NSString *woori4 = @"woorimembers";
    NSString *woori5 = @"wibeetalk";
    
    //현대카드
    NSString *hyundaiAppCard = @"hdcardappcardansimclick";
    NSString *hyundai = @"smhyundaiansimclick";
    
    //우리카드
    NSString *wooriAppCard = @"wooripay";
    
    //신한카드
    NSString *shinhanAppCard = @"shinhan-sr-ansimclick";
    NSString *shinhan = @"smshinhanansimclick";
    
    //국민카드
    NSString *kbAppCard = @"kb-acp";
    
    //삼성카드
    NSString *samsungAppCard = @"mpocket.online.ansimclick";
    NSString *samsung = @"ansimclickscard";
    NSString *samsung2 = @"tswansimclick";
    NSString *samsung3 = @"ansimclickipcollect";
    NSString *samsung4 = @"scardcertiapp";
    NSString *samsungVaccine = @"vguardstart";
    NSString *samsungCard = @"samsungpay";
    
    //롯데카드
    NSString *lotte = @"lottesmartpay";
    NSString *lotteAppCard = @"lotteappcard";
    
    //하나카드
    NSString *hanaAppCard = @"cloudpay";
    NSString *hana = @"hanawalletmembers";
    
    //농협카드
    NSString *nonghyupAppCard = @"nhappcardansimclick";
    NSString *nonghyup = @"nhallonepayansimclick";
    NSString *nonghyup2 = @"nonghyupcardansimclick";
    
    //씨티카드
    NSString *citiAppCard = @"citispay";
    NSString *citi = @"citicardappkr";
    NSString *citi2 = @"citimobileapp";
    
    //ISP계열카드
    NSString *isp = @"ispmobile";
    
    //은련카드
    NSString *uni = @"uppay";
    
    //간편결제카드
    NSString *ssgpay = @"shinsegaeeasypayment";
    NSString *payco = @"payco";
    NSString *lpay = @"lpayapp";
    NSString *smilepay = @"smilepayapp";
    NSString *kakaopay = @"kakaotalk";
    
    //모바일PASS
    NSString *skt = @"tauthlink";
    NSString *lguplus = @"upluscorporation";
    NSString *kt = @"ktauthexternalcall";
    
    NSString *toss = @"supertoss";
    
    if ([url.scheme isEqualToString:paynow]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/paynow/id760098906?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:paynow2]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/paynow/id760098906?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:smartxpay]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id393794374?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:nhAppCash]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id1177915709?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:woori]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:woori2]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        } else{
//            NSString *downloadURL = @"";
//            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:woori3]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:woori4]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:woori5]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:hyundaiAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id702653088?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:hyundai]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id702653088?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:wooriAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        } else{
            NSString *downloadURL = @"https://itunes.apple.com/app/id1201113419";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:shinhanAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:shinhan]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:kbAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/kbgugmin-aebkadue/id695436326?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:samsungAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/mpokes/id535125356?mt=8&ls=1";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsung]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsung2]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id430282710";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsung3]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsung4]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsungVaccine]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:samsungCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:lotte]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/losde-aebkadeu/id688047200?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:lotteAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/losde-aebkadeu/id688047200?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:hanaAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/app/id847268987";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:hana]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([url.scheme isEqualToString:nonghyupAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:nonghyup]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id1177889176?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:nonghyup2]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([url.scheme isEqualToString:citiAppCard]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:citi]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:citi2]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/citi-cards-mobile-ssitikadeu/id373559493?l=en&mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:isp]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id369125087?mt=8";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:uni]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([url.scheme isEqualToString:ssgpay]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:payco]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://itunes.apple.com/kr/app/id924292102";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:lpay]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:smilepay]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:kakaopay]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([url.scheme isEqualToString:skt]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:lguplus]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:kt]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.scheme isEqualToString:toss]){
        if ([app canOpenURL:url]) {
            NSLog(@"%s url  :%@",__FUNCTION__ ,url);
            [app openURL:url];
        }else{
            NSString *downloadURL = @"https://apps.apple.com/kr/app/toss/id839333328";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
}
#pragma mark - WKWebView Setting
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"%s webView.URL : %@",__FUNCTION__,webView.URL.absoluteString);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    
    NSLog(@"webView.URL !!!!!! : %@",webView.URL.absoluteURL);
    
    NSString *isp = @"itunes.apple.com/kr/app/id369125087?mt=8";
    NSString *Paynow = @"itunes.apple.com/kr/app/paynow/id760098906?mt=8";
    NSString *hyundaiCard = @"itunes.apple.com/kr/app/id702653088?mt=8";
    NSString *shinhanCard = @"itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8";
    NSString *kbCard = @"itunes.apple.com/kr/app/kbgugmin-aebkadue/id695436326?mt=8";
    NSString *samsungCard = @"itunes.apple.com/kr/app/mpokes/id535125356?mt=8&ls=1";
    NSString *lotteCard = @"itunes.apple.com/kr/app/losde-aebkadeu/id688047200?mt=8";
    NSString *hanaCard = @"itunes.apple.com/app/id847268987";
    NSString *nhCard = @"itunes.apple.com/kr/app/id1177889176?mt=8";
    NSString *ctMobile = @"appsto.re/kr/YqBugb.i";
    NSString *ctCard = @"itunes.apple.com/kr/app/citi-cards-mobile-ssitikadeu/id373559493?l=en&mt=8";
    NSString *payco =  @"itunes.apple.com/kr/app/id924292102";
    NSString *syrup =  @"itunes.apple.com/kr/app/id430282710";
    
    NSString *nhAppCash =  @"itunes.apple.com/kr/app/id1177915709?mt=8";
    NSString *ssgpay = @"itunes.apple.com/kr/app/sinsegyegipeuteu/id666237916?mt=8";
    NSString *wooriAppCard = @"itunes.apple.com/app/id1201113419";
    
    NSString *toss = @"itunes.apple.com/kr/app/id839333328";
    
    NSString *urlScheme = webView.URL.scheme;
    NSLog(@"%s urlScheme : %@",__FUNCTION__,urlScheme);
    
    if ([urlScheme isEqualToString:@"tel"]) {
        NSLog(@"webView.URL : %@",webView.URL);
        NSString *telScheme = webView.URL.absoluteString;
        NSArray *arr = [webView.URL.absoluteString componentsSeparatedByString:@":"];
        NSString *telNo = [arr objectAtIndex:1];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:telNo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"걸기", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:telScheme]];
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
       
    }else{
        NSArray *arr = [webView.URL.absoluteString componentsSeparatedByString:@"://"];
        NSString *absoluteString = [arr objectAtIndex:1];
        
        if ([absoluteString isEqualToString:Paynow]) {
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:hyundaiCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:shinhanCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:isp]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:kbCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:samsungCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:lotteCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:hanaCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:nhCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:ctMobile]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:ctCard]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString hasPrefix:payco]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString hasPrefix:syrup]){
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        
        if ([absoluteString isEqualToString:nhAppCash]) {
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:ssgpay]) {
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:wooriAppCard]) {
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        if ([absoluteString isEqualToString:toss]) {
            [[UIApplication sharedApplication]openURL:webView.URL];
        }
        
    }
    

}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s webView.URL : %@",__FUNCTION__,error);
}
- (void)initWKWebView{
    NSLog(@"%s",__FUNCTION__);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    NSString *page_url = [NSString stringWithFormat:@"%@", self.startURL];
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    [self setMfnpMethod:userController];
    webViewConfig.userContentController = userController;
    
    CGRect webViewRect = CGRectMake(webViewFrame.frame.origin.x, webViewFrame.frame.origin.y, webViewFrame.frame.size.width, webViewFrame.frame.size.height-10);
    
    if(@available(iOS 11, *)) webViewRect = CGRectMake(webViewFrame.frame.origin.x, webViewFrame.frame.origin.y-20, webViewFrame.frame.size.width, webViewFrame.frame.size.height+10);
    
    self.webView = [[WKWebView alloc] initWithFrame:webViewRect configuration:webViewConfig];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //self.webView.scrollView.bounces = NO;
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight
                                  | UIViewAutoresizingFlexibleBottomMargin
                                  | UIViewAutoresizingFlexibleLeftMargin
                                  | UIViewAutoresizingFlexibleRightMargin
                                  | UIViewAutoresizingFlexibleTopMargin
                                  | UIViewAutoresizingFlexibleBottomMargin;
    
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
        
        NSURL *nsurl=[NSURL URLWithString:page_url];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:nsrequest];
        
    }else{
        NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [NSString stringWithFormat:@"file://%@",self.startURL];
        NSLog(@"filePath : %@",filePath);
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
            [self.webView loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];
            
        }else{
            [self.webView loadHTMLString:filePath baseURL:[NSURL fileURLWithPath:documentsDir]];
        }
    }
    
    [webViewFrame addSubview:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    if (!flag) {
        self.progressView.hidden = NO;
        self.progressView.progress = 0.0f;
        flag = YES;
    }
}
- (void)setMfnpMethod:(WKUserContentController *)userController{
    [super setMfnpMethod:userController];
    [userController addScriptMessageHandler:self name:@"executeExafeKeySec"];
    [userController addScriptMessageHandler:self name:@"executeNativeBrowser"];
    [userController addScriptMessageHandler:self name:@"executeImageCrop"];
    
    
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSString *mfnpName = [NSString stringWithString:message.name];
    NSString *mfnpParam = [NSString stringWithString:message.body];
    NSDictionary *dic ;
    if (![mfnpParam isEqualToString:@""]) {
        dic = [self getParameters:mfnpParam];
    }
    if([mfnpName isEqualToString:@"executeNativeBrowser"]){
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@',true)",callBackFunc,userSpecific];
        [self evaluateJavaScript:jsCommand];
        NSString *url = [dic objectForKey:@"url"];
        NSURL *browser = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:browser];
    }else if([mfnpName isEqualToString:@"executeImageCrop"]){
        [self executeImageCrop:dic];
        
    }
    [super userContentController:userContentController didReceiveScriptMessage:message];
    
}
- (void)executeImageCrop:(NSDictionary *)dic{
    self.callbackFunc = [dic objectForKey:@"callbackFunc"];
    self.userSpecific = [dic objectForKey:@"userSpecific"];
    NSString *path = [dic objectForKey:@"path"];
    if (path==nil || [path isEqualToString:@""]) {
        
    }else{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
        self.croppingStyle = TOCropViewCroppingStyleDefault;
        
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
        cropController.delegate = self;
        
        // -- Uncomment these if you want to test out restoring to a previous crop setting --
        //cropController.angle = 90; // The initial angle in which the image will be rotated
        //cropController.imageCropFrame = CGRectMake(0,0,2848,4288); //The
        
        // -- Uncomment the following lines of code to test out the aspect ratio features --
        //cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare; //Set the initial aspect ratio as a square
        //cropController.aspectRatioLockEnabled = YES; // The crop box is locked to the aspect ratio and can't be resized away from it
        //cropController.resetAspectRatioEnabled = NO; // When tapping 'reset', the aspect ratio will NOT be reset back to default
        
        // -- Uncomment this line of code to place the toolbar at the top of the view controller --
        // cropController.toolbarPosition = TOCropViewControllerToolbarPositionTop;
        
        self.image = image;
        [self presentViewController:cropController animated:YES completion:nil];
        
    }
    
}
#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    //NSLog(@"image : %@",image);
    if (image!=nil) {
        
        if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
            //self.imageView.hidden = YES;
            [cropViewController dismissAnimatedFromParentViewController:self
                                                       withCroppedImage:image
                                                                 toView:nil
                                                                toFrame:CGRectZero
                                                                  setup:^{}
                                                             completion:^{
                                                                 [self korchamSavePicture:image :[self createPhotoFileName] :NO];
                                                             }];
        }
        
    }
}
-(void) korchamSavePicture:(UIImage *)sendImage :(NSString*)file :(BOOL)isCameraCall{
    
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
    CGSize newSize;
    /*
    if (isCameraCall) {
        newSize.width = image.size.width/3;
        newSize.height = image.size.height/3;
    }else{
        newSize.width = image.size.width;
        newSize.height = image.size.height;
    }*/
    newSize.width = 400;
    newSize.height = 500;
    NSLog(@"newSize width : %f",newSize.width);
    NSLog(@"newSize height : %f",newSize.height);
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    [image drawInRect:rect];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.05)];
    NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".jpg"]];
    NSString *filePath3 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".thum"]];
    [imageData writeToFile:filePath2 atomically:YES];
    UIImage *thumImage = [self resizedImage:image inRect:CGRectMake(0, 0, 60, 60)];
    NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    [thumData writeToFile:filePath3 atomically:YES];
    if (self.userSpecific ==nil) {
        [self photoSave:filePath2];
    }else{
        [self photoSave:filePath2 :self.userSpecific :self.callbackFunc];
    }
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}
-(NSString *)getPhotoFilePath{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *photoFolder = @"photo";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@/",photoFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        //NSLog(@"directory success");
    }else{
        //NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
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
- (void)photoSave:(NSString *)fileName{
    
}
- (void)photoSave:(NSString *)fileName :(NSString *)userSpectific :(NSString *)callbackFunc{
    //NSLog(@"photoSave");
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"PhotoSave jsCommand : %@",jsCommand);
    [self evaluateJavaScript:jsCommand];
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    /*
    BOOL hide = scrollView.contentOffset.y>=lastOffsetY;
    if (hide) {
        [UIView animateWithDuration:2.0 animations:^{
            self.toolbarBottomSpace.constant = 0;
            [self.toolBar setHidden:YES];
            [self.backButton setHidden:NO];
        }];
     
    }else{
        [UIView animateWithDuration:2.0 animations:^{
            self.toolbarBottomSpace.constant = -44;
            [self.toolBar setHidden:NO];
            [self.backButton setHidden:YES];
        }];
        
    }
     */
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentSize.height>scrollView.frame.size.height+2) {
        if(scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)/2) {
            //[self.topButton setHidden:NO];
            
        } else {
            
            //[self.topButton setHidden:YES];
        }
    }
    
    /* {
     if(scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)){
     if (self.toolBar.isHidden) {
     
     self.toolbarBottomSpace.constant = -44;
     [self.toolBar setHidden:NO];
     [self.backButton setHidden:YES];
     }
     }
     if(scrollView.contentOffset.y <= 0.0){
     NSLog(@"TOP REACHED");
     }
     }*/
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
   
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //lastOffsetY = scrollView.contentOffset.y;
    
}
#pragma mark -  keyboard show/hide
- (void)keyboardWillShow:(NSNotification *)note {
    
    UIWindow* tempWindow;
    UIView* keyboard;
    for(int c = 0; c < [[[UIApplication sharedApplication] windows] count]; c ++)
    {
        tempWindow = [[[UIApplication sharedApplication]
                       windows] objectAtIndex:c];
        // Loop through all views in the current window
        for(int i = 0; i < [tempWindow.subviews count]; i++) {
            keyboard = [tempWindow.subviews objectAtIndex:i];
            //the keyboard view description always starts with <UIKeyboard
            NSLog(@"[keyboard description]= %@", [keyboard description]);
            if([[[keyboard class] description] isEqualToString:@"UIInputSetContainerView"]) {
                keyboard.hidden = YES;
            }
            else if([[[keyboard class] description] isEqualToString:@"UIKeyboard"]) {
                keyboard.hidden = YES;
            }
        }
    }
}
- (void)keyboardDidHide:(NSNotification *)note {
    //NSLog(@"### hide notification : %@",note);
}
- (void)keyboardDidShow:(NSNotification *)note {
    //NSLog(@"### show notification : %@",note);
}



@end
