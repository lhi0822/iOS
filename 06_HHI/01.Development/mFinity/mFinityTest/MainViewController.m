//
//  FirstViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MainViewController.h"
#import "MFinityAppDelegate.h"
#import "MFTableViewController.h"
#import "IntroViewController.h"
#import "LockInsertView.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import "SubMenuViewCell.h"
#import "NSData+AES256.h"
#import "CameraMenuViewController.h"
#import "SecurityManager.h"
#import "SVProgressHUD.h"


#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 504
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define MENU_ICON_TAG 1000
#define MENU_LABEL_TAG 2000
#define MENU_BADGE_ICON_TAG 3000
#define MENU_BADGE_LABEL_TAG 4000

@interface MainViewController (){
    BOOL _isLogin;
    NSString *menuTitle;
    
}

@end

@implementation MainViewController
@synthesize isLogin = _isLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"bottom_icon01.png"];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            if([appDelegate isIphoneX]) [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-appDelegate.scrollView.frame.size.height)];
            else [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, imageView.frame.size.height)];
            
            [pageControl setFrame:CGRectMake(pageControl.frame.origin.x, imageView.frame.size.height, pageControl.frame.size.width, pageControl.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            if([appDelegate isIphoneX]) [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-appDelegate.scrollView.frame.size.height)];
            else [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, imageView.frame.size.height)];
            
            [pageControl setFrame:CGRectMake(pageControl.frame.origin.x, imageView.frame.size.height, pageControl.frame.size.width, pageControl.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
            [pageControl setFrame:CGRectMake(pageControl.frame.origin.x, imageView.frame.size.height-30, pageControl.frame.size.width, pageControl.frame.size.height)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            if([appDelegate isIphoneX]) [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-appDelegate.scrollView.frame.size.height)];
            else [imageView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, imageView.frame.size.height)];
            
            [pageControl setFrame:CGRectMake(pageControl.frame.origin.x, imageView.frame.size.height, pageControl.frame.size.width, pageControl.frame.size.height)];
        }
    }
  
    NSString *currentClass = NSStringFromClass([self.parentViewController class]);
    if([currentClass isEqualToString:@"UIMoreNavigationController"]){
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationItem setTitle: title_name];
    
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [refresh setImage:[self getScaledImage:[UIImage imageNamed:@"navi_refresh.png"] scaledToMaxWidth:21.0f] forState:UIControlStateNormal];
    refresh.frame = CGRectMake(0, 0, 30, 30);
    [refresh addTarget:self action:@selector(refreshMainMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:refresh];
    self.navigationItem.rightBarButtonItem = customBarItem;
    
    myTableView.rowHeight = 50;
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]} forState:UIControlStateNormal];
    
}

-(void)refreshMainMenu{
    [self menuCall];
}

- (void)viewDidAppear:(BOOL)animated{
    if (!appDelegate.isLogin) {
        IntroViewController *introView = [[IntroViewController alloc]init];
        UINavigationController *vc = [[UINavigationController alloc]initWithRootViewController:introView];
        //vc.navigationBar.tintColor= [UIColor grayColor];
		[vc setNavigationBarHidden:TRUE];
        [self presentViewController:vc animated:NO completion:nil];
    }else{
        for (int index = 0; index < [menuArray count]; index++) {
            UIButton *menuIcon = (UIButton *)[self.view viewWithTag:MENU_ICON_TAG+index];
            UILabel *menuLabel = (UILabel *)[self.view viewWithTag:MENU_LABEL_TAG+index];
            UIImageView *badgeImage = (UIImageView *)[self.view viewWithTag:MENU_BADGE_ICON_TAG+index];
            UILabel *badgeLabel = (UILabel *)[self.view viewWithTag:MENU_BADGE_LABEL_TAG+index];
            
            [menuIcon removeFromSuperview];
            [menuLabel removeFromSuperview];
            [badgeImage removeFromSuperview];
            [badgeLabel removeFromSuperview];
        }
        //[appDelegate chageTabBarColor:NO];
        
        //if (!isDrawMenu) {
        
            NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            if ([[ver objectAtIndex:0] intValue] >= 7) {
                self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
                self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
                self.navigationController.navigationBar.translucent = NO;
            }else {
                [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
            }
            NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.bgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
            UIImage *bgImage = [UIImage imageWithData:decryptData];
            imageView.image = bgImage;
            if (![appDelegate.demo isEqualToString:@"DEMO"]) {
                int badge = [appDelegate.badgeCount intValue];
                [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
                if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
                    [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badge]];
                }
            }
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
            
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
            label.text = appDelegate.app_name;
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            }
            self.navigationItem.titleView = label;
            
            if (appDelegate.isOffLine) {
                NSLog(@"isOffLine yes");
                NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
                UIImage *bgImage = [UIImage imageWithData:decryptData];
                imageView.image = bgImage;
                NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                //save = [save stringByAppendingPathComponent:appDelegate.comp_no];
                save = [save stringByAppendingFormat:@"/getOffLineMenuList"];
                
                NSData *data = [NSData dataWithContentsOfFile:save];
                //data = [data AES256DecryptWithKey:appDelegate.AES256Key];
                //data = [NSData decodeData:data];
                //[self parserJsonData:data];
                
                //if seed
                //[self parserJsonData:[MFinityAppDelegate getDecodeData:data]];
                myTableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
                //if nomal
                [self parserJsonData:data];
                
                pageControl.hidden = YES;
                
            }else{
                [self menuCall];
            }
            
        }
        
    //}
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void) animateToView:(UIView *)newView {
}
- (void)menuCall{
    NSString *paramStr;
    NSString *urlString;
    if (appDelegate.isAES256) {
        
        if ([appDelegate.demo isEqualToString:@"DEMO"]) {
            urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
            paramStr = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=P&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.root_menu_no,appDelegate.user_no];
        }else{
            //urlString = [[NSString alloc] initWithFormat:@"http://192.168.0.54:1598/dataservice41/ezMainMenu2"];
            urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
//            paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=P&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.root_menu_no];
            paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=P&isPLte=%@&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.root_menu_no, [MFinityAppDelegate isPLteResult]];
        }
    }else{
        if ([appDelegate.demo isEqualToString:@"DEMO"]) {
            urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
            paramStr = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=P&cuser_no=%@&returnType=JSON",appDelegate.root_menu_no,appDelegate.user_no];
            
            
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
//            paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=P&returnType=JSON",appDelegate.user_no, appDelegate.root_menu_no];
            paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=P&isPLte=%@&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.root_menu_no, [MFinityAppDelegate isPLteResult]];
            
            
        }
    }
    //NSLog(@"urlStr : %@", urlString);
    //NSLog(@"param : %@",paramStr);

    [SVProgressHUD show];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:15.0];
    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(urlCon){
        NSLog(@"urlCon not null");
        receiveData = [[NSMutableData alloc]init];
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    _methodName = methodName;
    NSString *errorMessage = [error localizedDescription];
    errorMessage = [errorMessage stringByAppendingString:@"\n 다시 시도 하시겠습니까?"];
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"error : %@",error);
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message56", @"") message:errorMessage delegate:self
										cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
	[alert show];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    if ([methodName isEqualToString:@"MLogout"]) {
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.isMDM){
            appDelegate.mdmCallAPI = @"exitWorkApp";
            [MFinityAppDelegate exitWorkApp];
        } else {
            exit(0);
        }
    }else{
        if(statusCode == 404 || statusCode == 500){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            [connection cancel];
            [SVProgressHUD dismiss];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else{
            NSString *urlStr = connection.currentRequest.URL.absoluteString;
            NSArray *tempArr = [urlStr componentsSeparatedByString:@"."];
            if ([[tempArr lastObject]isEqualToString:@"zip"]) {
                [fileData setLength:0];
                totalFileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
                
            }else {
                [receiveData setLength:0];
            }
        }
    }
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    /*
     if ([connection.currentRequest.URL.lastPathComponent isEqualToString:@"getBadgeCount"]) {
     NSLog(@"isLogin : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
     }
     */
    
    
    NSArray *tempArr = [urlStr componentsSeparatedByString:@"."];
    if ([[tempArr lastObject]isEqualToString:@"zip"]) {
        
        [fileData appendData:data];
      
        
    }else{
        [receiveData appendData:data];
    }
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    
    NSArray *tempArr = [urlStr componentsSeparatedByString:@"."];
    if ([[tempArr lastObject]isEqualToString:@"zip"]) {
        
        
    }else{
        if ([methodName isEqualToString:@"ezMainMenu2"]) {
            
            //if seed
            //[self parserJsonData:[MFinityAppDelegate getDecodeData:receiveData]];
            //if nomal
            [self parserJsonData:receiveData];
            
        }else if ([methodName isEqualToString:@"ezPubMenu2"]) {
            
            //if seed
            //[self parserJsonData:[MFinityAppDelegate getDecodeData:receiveData]];
            
            //if nomal
            [self parserJsonData:receiveData];
            //[self parserJsonData:receiveData];
        } else if([methodName isEqualToString:@"addMenuHist"]) {
            NSDictionary *dic;
            NSError *error;
            @try {
                // if AES256
                NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
                NSString *decString ;
                if (appDelegate.isAES256) {
                    decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
                }
                else{
                    decString = encString;
                }
                
                dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                
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
                
                isDMS = [[dic objectForKey:@"V16"] isEqualToString:@"Y"];
                isTabBar = [[dic objectForKey:@"V17"] isEqualToString:@"Y"];
                
                paramString = @"";
                appDelegate.menu_no = menu_no;
                nativeAppMenuNo = menu_no;
                currentAppVersion = versionFromServer;
                appDelegate.target_url = target_url;
                
//                NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:param_data options:kNilOptions error:&error];
//                @try {
//                    for(int i=1; i<=[paramDic count]; i++){
//                        NSDictionary *subParamDic = [paramDic objectForKey:[NSString stringWithFormat:@"%d",i]];
//                        paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_KEY"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
//                        paramString = [paramString stringByAppendingFormat:@"="];
//                        paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_VAL"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
//                        paramString = [paramString stringByAppendingFormat:@"&"];
//                    }
//                    if ([[paramString substringFromIndex:paramString.length-1] isEqualToString:@"&"]) {
//                        paramString = [paramString substringToIndex:paramString.length-1];
//                    }
//
//                }
//                @catch (NSException *exception) {
//                    //NSLog(@"exception : %@",[exception name]);
//                }
                
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
                    if (isDMS) {
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
            
            
            
            
        }
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark
#pragma mark MainView Utils
- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
//    WebViewController *vc = [[WebViewController alloc] init];
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    vc.isDMS = isDMS;
    if (!isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) parserJsonData:(NSData *)data{
    
    menuArray = [[NSMutableArray alloc]init];
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    NSError *error;
    NSDictionary *dic;
    @try {
        
        
        // if AES256
        NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        // if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    //NSLog(@"dic : %@",dic);
    for (int i=0; i<[dic count]; i++) {
        [tempArr addObject:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
    }
    
    for (NSDictionary *menuDic in tempArr) {
        [menuArray addObject: [MFinityAppDelegate getAllValueUrlDecoding:menuDic]];
    }
    if ([menuArray count]>1) {
        //NSLog(@"v0 : %@",[[menuArray objectAtIndex:0]objectForKey:@"V0"]);
        if ([[[menuArray objectAtIndex:0]objectForKey:@"V0"] isEqualToString:@"False"]) {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"관리자 메시지") message:NSLocalizedString(@"message127", @"세션이 종료되었습니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
            //UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"eoeoeoeoeoeoeo" message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else {
            colCount = [[[menuArray objectAtIndex:1]objectForKey:@"V8"] intValue];
            rowCount = [[[menuArray objectAtIndex:1] objectForKey:@"V8_1"] intValue];
            
            if ([[[menuArray objectAtIndex:1]objectForKey:@"V8_1"]isEqualToString:@"#"] ) {
                mainScrollView.hidden = YES;
                myTableView.hidden = NO;
                [menuArray removeObjectAtIndex:0];
                [myTableView reloadData];
            }else{
                //2018.06 UI개선
                if ([appDelegate.mainType isEqualToString:@"1"]) {
                    [menuArray removeObjectAtIndex:0];
                    [self menuSetting];
                    pageControl.hidden = NO;
                    
                }else if([appDelegate.mainType isEqualToString:@"2"]){
                    [menuArray removeObjectAtIndex:0];
                    [self coverFlowSetting];
                    pageControl.hidden=YES;
                    
                } else if([appDelegate.mainType isEqualToString:@"3"]){
                    [menuArray removeObjectAtIndex:0];
                    [self verticalMenuSetting];
                    pageControl.hidden = YES;
                }
            }
        }
        
    }else{
        [SVProgressHUD dismiss];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message64", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
        [alertView show];
    }
    
    isDrawMenu = YES;
    /*
     if (colCount == 0) {
     mainScrollView.hidden = YES;
     myTableView.hidden = NO;
     [myTableView reloadData];
     }else{
     if ([menuArray count] > 0) {
     //메뉴세팅
     
     
     } else {
     
     //[self showAlertMessage: Title:nil Btn:];
     //[self getXmlFromServer];
     }
     }
     */
}
- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    scaleFactor = width / oldWidth;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark
#pragma mark Menu setting
-(void) menuSetting {
    [powerName setText:@"Powered by DBValley"];
    [powerName setTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]];
    
    CGFloat viewWidth = [[UIScreen mainScreen]bounds].size.width;
    NSString *platform = [[UIDevice currentDevice] modelName];
    
//    NSRange range = NSMakeRange(7, 1);
//    NSString *platformNumber = [platform substringWithRange:range];
//    if([platformNumber isEqualToString:@"5"] || [platformNumber isEqualToString:@"S"]){
//        platformNumber = @"5";
//
//    } else if([platformNumber isEqualToString:@"X"]){
//        platformNumber = @"10";
//    }
//    BOOL isPlusDevice;
//    NSArray *arr = [platform componentsSeparatedByString:@" "];
//    if ([[arr objectAtIndex:arr.count-1] isEqualToString:@"plus"] || [[arr objectAtIndex:arr.count-1] isEqualToString:@"Plus"]) {
//        isPlusDevice = YES;
//    }else{
//        isPlusDevice = NO;
//    }
    
    BOOL isPlusDevice;
    NSArray *platformArr = [platform componentsSeparatedByString:@" "];
    
    NSString *modelStr = [[[UIDevice currentDevice] modelIdentifier] stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
    NSArray *modelIdArr = [modelStr componentsSeparatedByString:@","];
    NSLog(@"modelStr : %@", modelStr);
    
    NSString *platformNumber = [modelIdArr objectAtIndex:0];
    int modelNum = [platformNumber intValue];
    if(modelNum <= 6){
        //5s 이하
    } else if(modelNum > 6 && modelNum < 10){
        //6~8, X
        if([modelStr isEqualToString:@"8,4"]){ //SE
            platformNumber = @"5";
        }
    } else {
        if([modelStr isEqualToString:@"10,1"]||[modelStr isEqualToString:@"10,2"]||[modelStr isEqualToString:@"10,5"]){ //8
            platformNumber = @"9";
        }
        if([modelStr isEqualToString:@"12,8"]){ //SE2
            platformNumber = @"9";
        }
    }
    
    NSString *largeModel = [[platformArr objectAtIndex:platformArr.count-1] lowercaseString];
    if ([largeModel isEqualToString:@"plus"]||[largeModel isEqualToString:@"max"]) {
        isPlusDevice = YES;
    }else{
        isPlusDevice = NO;
    }
    
    int countForPage=0;
    /*
     //아이콘 넓이
     int ICON_WIDTH = 60;
     //아이콘 높이
     int ICON_HEIGHT = 60;
     //아이콘 그리기 시작좌표
     int ICON_START_HORIZONTAL = 0;
     int ICON_START_VERTICAL = 0;
     //아이콘 그리기 증가좌표
     int ICON_INCRESE_HORIZONTAL = 0;
     int ICON_INCRESE_VERTICAL = 0;
     //메뉴이름 넓이
     //int TITLE_WIDTH = 81;    //UITextView
     int TITLE_WIDTH = 68;    //UILabel
     //메뉴이름 높이
     int TITLE_HEIGHT = 15;
     //메뉴이름 그리기 시작좌표
     int TITLE_START_HORIZONTAL = 0;
     int TITLE_START_VERTICAL = 0;
     //메뉴이름 그리기 증가좌표
     int TITLE_INCRESE_HORIZONTAL = 0;
     int TITLE_INCRESE_VERTICAL = 0;
     
     //아이콘 가로배열 갯수에 따라 초기변수값 지정
     if (colCount == 3) {
     ICON_START_HORIZONTAL = 40;
     ICON_START_VERTICAL = 20; //100;
     ICON_INCRESE_HORIZONTAL = 90;
     ICON_INCRESE_VERTICAL = 98;
     TITLE_START_HORIZONTAL = 36;
     TITLE_START_VERTICAL = 84; //160;
     TITLE_INCRESE_HORIZONTAL = 90;
     TITLE_INCRESE_VERTICAL = 97;
     if (platformNumber.intValue < 5) {
     countForPage = 9;
     }else{
     countForPage = 12;
     [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, mainScrollView.frame.size.height+100)];
     }
     pageControl.numberOfPages = ([menuArray count] - 1) / countForPage + 1;
     mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / countForPage + 1), mainScrollView.frame.size.height);
     } else if (colCount ==4) {
     if (platformNumber.intValue < 5) {
     countForPage = 12;
     }else{
     countForPage = 16;
     [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, mainScrollView.frame.size.height+100)];
     }
     
     ICON_START_HORIZONTAL = 18;
     ICON_START_VERTICAL = 10; //100;
     ICON_INCRESE_HORIZONTAL = 75;
     ICON_INCRESE_VERTICAL = 105;
     //TITLE_START_HORIZONTAL = 8;    //UITextView
     TITLE_START_HORIZONTAL = 18;    //UILabel
     //TITLE_START_VERTICAL = 70;        //UITextView
     TITLE_START_VERTICAL = 73;        //UILabel
     TITLE_INCRESE_HORIZONTAL = 75;
     TITLE_INCRESE_VERTICAL = 105;
     pageControl.numberOfPages = ([menuArray count] - 1) / countForPage + 1;
     mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / countForPage + 1), mainScrollView.frame.size.height);
     
     }
     
     //아이콘 현재좌표
     int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
     int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
     //메뉴이름 현재좌표
     int TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL;
     int TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
     
     //아이콘갯수에 따라 페이지컨트롤 갯수 지정
     
     pageControl.currentPage = 0;
     
     //아이콘갯수에 따라 스크롤뷰 가로 넓이 지정
     mainScrollView.pagingEnabled = YES;
     
     mainScrollView.showsHorizontalScrollIndicator = NO;
     mainScrollView.showsVerticalScrollIndicator = NO;
     mainScrollView.scrollsToTop = NO;
     mainScrollView.delegate = self;
     
     //현재페이지
     int curPage = 0;
     //그리기시작
     NSString *_menuType = [[menuArray objectAtIndex:0]objectForKey:@"V7"];
     //NSLog(@"_menuType : %@",_menuType);
     //NSLog(@"menuType : %@",menuType);
     //NSLog(@"menuArray count : %d",[menuArray count]);
     for (int index = 0; index < [menuArray count]; index++) {
     //NSLog(@"index : %d",index);
     if ([_menuType isEqualToString:@"E"]) {
     //관리메뉴일때 (아이콘을 그리지않고 메뉴경로만 얻는다)
     //EzSmartAppDelegate *appDelegate = (EzSmartAppDelegate *)[[UIApplication sharedApplication] delegate];
     }
     
     //실행메뉴 또는 하위메뉴가 있는 중간메뉴일때
     if (([_menuType isEqualToString:@"P"]) || ([_menuType isEqualToString:@"M"])) {
     
     //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
     if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > 320 * ( curPage + 1 )) {
     ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + 320 * curPage;
     ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
     TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + 320 * curPage;
     TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
     }
     
     //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
     if (colCount == 4) {
     //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
     if ( index > 0 && index % countForPage == 0) {
     ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + 320 * ( curPage + 1 );
     ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
     TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + 320 * ( curPage + 1 );
     TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
     
     curPage += 1;
     }
     }else if (colCount == 3) {
     //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
     if ( index > 0 && index % countForPage == 0) {
     ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + 320 * ( curPage + 1 );
     ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
     TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + 320 * ( curPage + 1 );
     TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
     
     curPage += 1;
     }
     }*/
    
    //아이콘 넓이
    int ICON_WIDTH = 0;
    //아이콘 높이
    int ICON_HEIGHT = 0;
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    //메뉴이름 넓이
    int TITLE_WIDTH = 0;    //UILabel
    //메뉴이름 높이
    int TITLE_HEIGHT = 0;
    //메뉴이름 그리기 시작좌표
    int TITLE_START_HORIZONTAL = 0;
    int TITLE_START_VERTICAL = 0;
    //메뉴이름 그리기 증가좌표
    int TITLE_INCRESE_HORIZONTAL = 0;
    int TITLE_INCRESE_VERTICAL = 0;
    
    int FONT_SIZE = 0;
    
    if(!isPlusDevice){
        if([platformNumber intValue]<=6){
            ICON_WIDTH = 60;
            ICON_HEIGHT = 60;
            TITLE_WIDTH = 68;
            TITLE_HEIGHT = 15;
            FONT_SIZE = 12;
            
        } else {
            ICON_WIDTH = 70;
            ICON_HEIGHT = 70;
            TITLE_WIDTH = 80;
            TITLE_HEIGHT = 30;
            FONT_SIZE = 15;
        }
        
    } else {
        ICON_WIDTH = 80;
        ICON_HEIGHT = 80;
        TITLE_WIDTH = 90;
        TITLE_HEIGHT = 60;
        FONT_SIZE = 19;
    }
    
    //아이콘 가로배열 갯수에 따라 초기변수값 지정
    if (colCount == 3) {
        ICON_START_HORIZONTAL = 40;
        ICON_START_VERTICAL = 20;
        ICON_INCRESE_HORIZONTAL = 90;
        ICON_INCRESE_VERTICAL = 98;
        TITLE_START_HORIZONTAL = 36;
        TITLE_START_VERTICAL = 84;
        TITLE_INCRESE_HORIZONTAL = 90;
        TITLE_INCRESE_VERTICAL = 97;
        
        //2018.06 UI개선
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, mainScrollView.frame.size.height+50)];
        }
        
        if (platformNumber.intValue <= 6) {
            countForPage = 9;
            
        } else{
            countForPage = 12;
            //[mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, mainScrollView.frame.size.height+100)];
            
        }
        pageControl.numberOfPages = ([menuArray count] - 1) / countForPage + 1;
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / countForPage + 1), mainScrollView.frame.size.height);
        
    } else if (colCount ==4) {
        //2018.06 UI개선
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, mainScrollView.frame.size.height+50)];
        }
        
        if (platformNumber.intValue <= 6) {
            countForPage = 16;
            
            ICON_START_HORIZONTAL = 18;
            ICON_START_VERTICAL = 10;
            ICON_INCRESE_HORIZONTAL = 75;
            ICON_INCRESE_VERTICAL = 105;
            TITLE_START_HORIZONTAL = 18;
            TITLE_START_VERTICAL = 73;
            TITLE_INCRESE_HORIZONTAL = 75;
            TITLE_INCRESE_VERTICAL = 105;
            
        } else{
            if (platformNumber.intValue >= 10) countForPage = 20;
            else countForPage = 16;
            [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, mainScrollView.frame.size.height+100)];
            
            ICON_START_HORIZONTAL = 20;
            ICON_START_VERTICAL = 20;
            TITLE_START_HORIZONTAL = 28;
            
            if(!isPlusDevice){
                ICON_INCRESE_HORIZONTAL = 88;
                ICON_INCRESE_VERTICAL = 122;
                TITLE_START_VERTICAL = 95;
                TITLE_INCRESE_HORIZONTAL = 85;
                TITLE_INCRESE_VERTICAL = 122;
                
            } else {
                ICON_INCRESE_HORIZONTAL = 98;
                ICON_INCRESE_VERTICAL = 139;
                TITLE_START_VERTICAL = 105;
                TITLE_INCRESE_HORIZONTAL = 95;
                TITLE_INCRESE_VERTICAL = 139;
            }
        }
        
        pageControl.numberOfPages = ([menuArray count] - 1) / countForPage + 1;
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / countForPage + 1), mainScrollView.frame.size.height);
        
    }
    
    //아이콘 현재좌표
    int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
    int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
    //메뉴이름 현재좌표
    int TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL;
    int TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
    
    //아이콘갯수에 따라 페이지컨트롤 갯수 지정
    
    pageControl.currentPage = 0;
    
    //아이콘갯수에 따라 스크롤뷰 가로 넓이 지정
    mainScrollView.pagingEnabled = YES;
    
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.scrollsToTop = NO;
    mainScrollView.delegate = self;
    
    //현재페이지
    int curPage = 0;
    //그리기시작
    NSString *_menuType = [[menuArray objectAtIndex:0]objectForKey:@"V7"];
    //NSLog(@"_menuType : %@",_menuType);
    //NSLog(@"menuType : %@",menuType);
    //NSLog(@"menuArray count : %d",[menuArray count]);
    for (int index = 0; index < [menuArray count]; index++) {
        //NSLog(@"index : %d",index);
        if ([_menuType isEqualToString:@"E"]) {
            //관리메뉴일때 (아이콘을 그리지않고 메뉴경로만 얻는다)
            //EzSmartAppDelegate *appDelegate = (EzSmartAppDelegate *)[[UIApplication sharedApplication] delegate];
        }
        
        //실행메뉴 또는 하위메뉴가 있는 중간메뉴일때
        if (([_menuType isEqualToString:@"P"]) || ([_menuType isEqualToString:@"M"])) {
            
            //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
            if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > viewWidth * ( curPage + 1 )) {
                ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + viewWidth * curPage;
                ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + viewWidth * curPage;
                TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
            }
            
            //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
            if (colCount == 4) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( index > 0 && index % countForPage == 0) {
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + viewWidth * ( curPage + 1 );
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + viewWidth * ( curPage + 1 );
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
            }else if (colCount == 3) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( index > 0 && index % countForPage == 0) {
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + viewWidth * ( curPage + 1 );
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + viewWidth * ( curPage + 1 );
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
            }
            
            //아이콘 생성
            UIButton *btnIcon = [[UIButton alloc] init];
            UIImage *icon =[[UIImage alloc] init];
            
            //아이콘 이미지
            NSString *btnIconImagePath = [[menuArray objectAtIndex:index] objectForKey:@"V5"];
            
            //NSLog(@"btnIconImagePath : %@",btnIconImagePath);
            NSMutableString *btnIconImage = [NSMutableString stringWithString:btnIconImagePath];
            NSString *filename = [btnIconImage lastPathComponent];
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            documentFolder = [documentFolder stringByAppendingPathComponent:@"icon"];
            NSString *filePath = [documentFolder stringByAppendingPathComponent:filename];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSData *decryptData = [data AES256DecryptWithKey:appDelegate.AES256Key];
            icon = [UIImage imageWithData:decryptData];
            
            //icon = [UIImage imageWithContentsOfFile:filePath];
            
            if (icon==nil) {
                icon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:btnIconImage]]];
                NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
                NSData *enryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
                [enryptData writeToFile:filePath atomically:YES];
                //NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
                
            }
            
            //NSString *btnIconImagePath_touched = [[NSString alloc] initWithFormat:@"%@_on.png",[[col3 objectAtIndex:index] substringWithRange:NSMakeRange(0, [[col3 objectAtIndex:index] length] - 4)]];
            //UIImage *icon_touched = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:btnIconImagePath_touched]]];
            UIImageView *BackButton = [[UIImageView alloc]initWithFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            
            
            
            [BackButton setImage:[UIImage imageWithContentsOfFile:appDelegate.bgIconImagePath]];
            //icon = [UIImage imageNamed:@"icon_01_1.png"];
            
            //[btnIcon setBackgroundImage:icon forState:UIControlStateNormal];
            //[btnIcon setImage:[UIImage imageNamed:@"back_02.png"] forState:UIControlStateSelected];
            //[btnIcon setBackgroundImage:[UIImage imageNamed:@"icon_0001.png"] forState:UIControlStateNormal];
            [mainScrollView addSubview:BackButton];
            
            
            //아이콘 관련 정보 세팅
            [btnIcon setBackgroundImage:icon forState:UIControlStateNormal];
            //[btnIcon setBackgroundImage:icon_touched forState:UIControlStateSelected];
            btnIcon.tag = MENU_ICON_TAG+index;
            [btnIcon setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            
            
            
            
            
            //메뉴이름텍스트 생성
            UITextView *txtTitle = [[UITextView alloc] init];
            //텍스트 속성 지정
            NSString *titleText = [[menuArray objectAtIndex:index] objectForKey:@"V4"];
            NSRange range = [titleText rangeOfString:@" "];
            if (range.length>0) {
                titleText = [titleText stringByReplacingCharactersInRange:range withString:@"\n"];
            }
            
            
            UIColor *color = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
            
            UILabel *label = [[UILabel alloc]init];
            label.tag = MENU_LABEL_TAG+index;
            //titleText = [titleText stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
            label.text= titleText;
            label.textColor = color;
            label.numberOfLines = 0;
            if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                label.shadowOffset = CGSizeMake(2.0f, 2.0f);
            }
            label.font = [UIFont boldSystemFontOfSize:FONT_SIZE]; //13
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            
            //label.lineBreakMode = NSLineBreakByCharWrapping;
            
            ////NSLog(@"titleText.length = %d",titleText.length);
            CGSize textSize = [[label text] sizeWithFont:[label font]];
            CGFloat strikeWidth = textSize.width;
            
            if (strikeWidth > 68.0f) {
                //label.numberOfLines=2;
                TITLE_HEIGHT = 30;
            }else{
                TITLE_HEIGHT = 15;
            }
            
            [label setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            label.lineBreakMode = UILineBreakModeWordWrap;
            [label sizeToFit];
            //[label setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            CGPoint p = CGPointMake(btnIcon.center.x, label.center.y);
            [label setCenter:p];
            
            [txtTitle setText:titleText];
            txtTitle.font = [UIFont boldSystemFontOfSize:FONT_SIZE]; //12
            txtTitle.textColor = color;
            txtTitle.backgroundColor = [UIColor clearColor];
            txtTitle.inputView = label;
            txtTitle.textAlignment = NSTextAlignmentCenter;
            txtTitle.editable = FALSE;
            txtTitle.scrollEnabled = FALSE;
            
            [txtTitle setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            
            //텍스트 추가
            //아이콘 추가
            
            
            [mainScrollView addSubview:btnIcon];
            [mainScrollView addSubview:label];
            
            
            //뱃지 아이콘 셋팅 및 추가
            NSString *badgeText = [[menuArray objectAtIndex:index] objectForKey:@"V18"];
            //NSString *badgeText = @"123";
            UIFont *badgeFont =  [UIFont fontWithName:@"SFCompactDisplay-Light" size:17];
            if([badgeText intValue]>0){
                UILabel *badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                [badgeLabel setCenter:CGPointMake(ICON_WIDTH+ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL)];
                [badgeLabel setFont:badgeFont];
                //[badgeLabel setAttributedText:attributedString];
                [badgeLabel setText:badgeText];
                [badgeLabel setTextColor:[UIColor whiteColor]];
                [badgeLabel setTextAlignment:NSTextAlignmentCenter];
                //[badgeLabel setFont:[UIFont systemFontOfSize:16]];
                CGSize badgeTextSize = [[badgeLabel text] sizeWithFont:[badgeLabel font]];
                CGFloat badgeStrikeWidth = badgeTextSize.width;
                
                UIImage *badgeImage;
                UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 18, 2, 18);
                CGRect badgeImageSize;
                NSLog(@"badgeStrikeWidth : %f",badgeStrikeWidth);
                if (badgeStrikeWidth>16 ) {
                    badgeImage = [[UIImage imageNamed:@"icon_badge_40.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
                    badgeImageSize = CGRectMake(0, 0, 30, 23);
                }else {
                    badgeImage = [UIImage imageNamed:@"icon_badge_40.png"];
                    badgeImageSize = CGRectMake(0, 0, 23, 23);
                }
                if (badgeStrikeWidth>28) {
                    badgeImage = [[UIImage imageNamed:@"icon_badge_40.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
                    badgeImageSize = CGRectMake(0, 0, 37, 23);
                    
                }
                UIImageView *badgeImageView = [[UIImageView alloc]initWithImage:badgeImage];
                
                [badgeImageView setFrame:badgeImageSize];
                [badgeImageView setCenter:CGPointMake(ICON_WIDTH+ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL)];
                
                badgeImageView.tag = MENU_BADGE_ICON_TAG+index;
                badgeLabel.tag = MENU_BADGE_LABEL_TAG+index;
                [mainScrollView addSubview:badgeImageView];
                [mainScrollView addSubview:badgeLabel];
            }
            
            
            //[btnIcon addTarget:self action:@selector(buttonTouched3:) forControlEvents:UIControlEventTouchDragExit];
            //[btnIcon addTarget:self action:@selector(buttonTouched2:) forControlEvents:UIControlEventTouchDown];
            [btnIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
            //관련좌표 다시 계산
            ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            TITLE_CURRENT_HORIZONTAL += TITLE_INCRESE_HORIZONTAL;
            
            
        }
    }
    [SVProgressHUD dismiss];
    
}

- (void) coverFlowSetting {
    covers = [[NSMutableArray alloc] init];
    for (int index=0; index<[menuArray count]; index++) {
        
        UIImage *icon =[[UIImage alloc] init];
        //아이콘 이미지
        NSString *btnIconImagePath = [[menuArray objectAtIndex:index]objectForKey:@"V5"];
        
        NSMutableString *btnIconImage = [NSMutableString stringWithString:btnIconImagePath];
        NSString *filename = [btnIconImage lastPathComponent];
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        documentFolder = [documentFolder stringByAppendingFormat:@"/%@/icon",appDelegate.comp_no];
        NSString *filePath = [documentFolder stringByAppendingPathComponent:filename];
        //icon = [UIImage imageWithContentsOfFile:filePath];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSData *decryptData = [data AES256DecryptWithKey:appDelegate.AES256Key];
        icon = [UIImage imageWithData:decryptData];
        if (icon==nil) {
            icon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:btnIconImage]]];
            NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
            [data writeToFile:filePath atomically:YES];
        }
        [covers insertObject:icon atIndex:index];
        
    }
    
    coverflow = [[TKCoverflowView alloc]initWithFrame:CGRectMake(0, 50, 320, 300)];
    coverflow.coverflowDelegate = self;
    coverflow.coverSize= CGSizeMake(100, 100);
    coverflow.backgroundColor = [UIColor clearColor];
    coverflow.dataSource =self;
    
    [self.view addSubview:coverflow];
    [coverflow setNumberOfCovers:[menuArray count]];
    [SVProgressHUD dismiss];
    //isDrawMenu = YES;
}

-(void)verticalMenuSetting{
    NSLog(@"%s", __func__);
    [powerName setText:@"Powered by DBValley"];
    [powerName setTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]];
    
    CGFloat viewWidth = [[UIScreen mainScreen]bounds].size.width;
    
    //폰트 크기
    int FONT_SIZE = 13;
    //아이콘 넓이
    int ICON_WIDTH = 70;
    //아이콘 높이
    int ICON_HEIGHT = 70;
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 25;
    int ICON_START_VERTICAL = 25;
    //메뉴이름 넓이
    int TITLE_WIDTH = ICON_WIDTH+8;
    //메뉴이름 높이
    int TITLE_HEIGHT = 30;
    
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    //메뉴이름 그리기 시작좌표
    int TITLE_START_HORIZONTAL = 0;
    int TITLE_START_VERTICAL = 0;
    //메뉴이름 그리기 증가좌표
    int TITLE_INCRESE_HORIZONTAL = 0;
    int TITLE_INCRESE_VERTICAL = 0;
    
    int horizonSpace = 0;
    int verticalSpace = 0;

    horizonSpace = (viewWidth - (ICON_START_HORIZONTAL*2) - (ICON_WIDTH*colCount)) / (colCount-1);
    verticalSpace = horizonSpace;
    NSLog(@"verticalSpace : %d / horizonSpace : %d", verticalSpace, horizonSpace);
  
    if(verticalSpace<=0 && horizonSpace<=0){
        ICON_WIDTH = 50;
        ICON_HEIGHT = 50;
        
        horizonSpace = (viewWidth - (ICON_START_HORIZONTAL*2) - (ICON_WIDTH*colCount)) / (colCount-1);
        verticalSpace = horizonSpace;
    }
    
    ICON_INCRESE_HORIZONTAL = ICON_WIDTH + horizonSpace;
    ICON_INCRESE_VERTICAL = ICON_HEIGHT+TITLE_HEIGHT + verticalSpace;
    TITLE_START_HORIZONTAL = ICON_START_HORIZONTAL+5;
    TITLE_START_VERTICAL = ICON_START_VERTICAL+ICON_HEIGHT+5;
    TITLE_INCRESE_HORIZONTAL = TITLE_WIDTH;
    TITLE_INCRESE_VERTICAL = ICON_INCRESE_VERTICAL;
    
    if([appDelegate.tabBarType isEqualToString:@"B"]){
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    } else if([appDelegate.tabBarType isEqualToString:@"T"]){
        [mainScrollView setFrame:CGRectMake(mainScrollView.frame.origin.x, appDelegate.scrollView.frame.size.height, mainScrollView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-appDelegate.scrollView.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
    }
    
    int q = (int)[menuArray count]/colCount;
    int r = [menuArray count]%colCount;
    
    int result = 1;
    if(q>0) result = q;
    if(r>0) result = result+1;
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, ((ICON_HEIGHT+TITLE_HEIGHT+verticalSpace)*result)+ICON_START_VERTICAL);
    
    //아이콘 현재좌표
    int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
    int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
    //메뉴이름 현재좌표
    int TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL;
    int TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
    
    //아이콘갯수에 따라 스크롤뷰 가로 넓이 지정
    mainScrollView.pagingEnabled = NO;
    mainScrollView.scrollEnabled = YES;
    
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = YES;
    mainScrollView.scrollsToTop = NO;
    mainScrollView.delegate = self;
    
    //현재페이지
    int curPage = 0;
    //그리기시작
    NSString *_menuType = [[menuArray objectAtIndex:0]objectForKey:@"V7"];
    
    for (int index = 0; index < [menuArray count]; index++) {
        if ([_menuType isEqualToString:@"E"]) {
            //관리메뉴일때 (아이콘을 그리지않고 메뉴경로만 얻는다)
        }
        
        //실행메뉴 또는 하위메뉴가 있는 중간메뉴일때
        if (([_menuType isEqualToString:@"P"]) || ([_menuType isEqualToString:@"M"])) {
            //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
            if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL - ICON_START_HORIZONTAL > viewWidth * ( curPage + 1 )) {
                ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + viewWidth * curPage;
                ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + viewWidth * curPage;
                TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
            }
            
            //아이콘 생성
            UIButton *btnIcon = [[UIButton alloc] init];
            UIImage *icon =[[UIImage alloc] init];
            
            //아이콘 이미지
            NSString *btnIconImagePath = [[menuArray objectAtIndex:index] objectForKey:@"V5"];
            NSMutableString *btnIconImage = [NSMutableString stringWithString:btnIconImagePath];
            NSString *filename = [btnIconImage lastPathComponent];
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            documentFolder = [documentFolder stringByAppendingPathComponent:@"icon"];
            NSString *filePath = [documentFolder stringByAppendingPathComponent:filename];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSData *decryptData = [data AES256DecryptWithKey:appDelegate.AES256Key];
            icon = [UIImage imageWithData:decryptData];
            
            if (icon==nil) {
                icon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:btnIconImage]]];
                NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
                NSData *enryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
                [enryptData writeToFile:filePath atomically:YES];
            }
            
            UIImageView *BackButton = [[UIImageView alloc]initWithFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            [BackButton setImage:[UIImage imageWithContentsOfFile:appDelegate.bgIconImagePath]];
            [mainScrollView addSubview:BackButton];
            
            
            //아이콘 관련 정보 세팅
            [btnIcon setBackgroundImage:icon forState:UIControlStateNormal];
            btnIcon.tag = MENU_ICON_TAG+index;
            [btnIcon setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            
            //메뉴이름텍스트 생성
            UITextView *txtTitle = [[UITextView alloc] init];
            //텍스트 속성 지정
            NSString *titleText = [[menuArray objectAtIndex:index] objectForKey:@"V4"];
            NSRange range = [titleText rangeOfString:@" "];
            if (range.length>0) {
                titleText = [titleText stringByReplacingCharactersInRange:range withString:@"\n"];
            }
            
            UIColor *color = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
            
            UILabel *label = [[UILabel alloc]init];
            label.tag = MENU_LABEL_TAG+index;
            label.text= titleText;
            label.textColor = color;
            label.numberOfLines = 0;
            if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                label.shadowOffset = CGSizeMake(2.0f, 2.0f);
            }
            label.font = [UIFont boldSystemFontOfSize:FONT_SIZE]; //13
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            CGSize textSize = [[label text] sizeWithFont:[label font]];
            CGFloat strikeWidth = textSize.width;
            
            if (strikeWidth > 68.0f) {
                TITLE_HEIGHT = 30;
            }else{
                TITLE_HEIGHT = 15;
            }
            
            [label setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [label sizeToFit];
            
            CGPoint p = CGPointMake(btnIcon.center.x, label.center.y);
            [label setCenter:p];
            
            [txtTitle setText:titleText];
            txtTitle.font = [UIFont boldSystemFontOfSize:FONT_SIZE]; //12
            txtTitle.textColor = color;
            txtTitle.backgroundColor = [UIColor clearColor];
            txtTitle.inputView = label;
            txtTitle.textAlignment = NSTextAlignmentCenter;
            txtTitle.editable = FALSE;
            txtTitle.scrollEnabled = FALSE;
            
            [txtTitle setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            
            //텍스트 추가 아이콘 추가
            [mainScrollView addSubview:btnIcon];
            [mainScrollView addSubview:label];
            
            
            //뱃지 아이콘 셋팅 및 추가
            NSString *badgeText = [[menuArray objectAtIndex:index] objectForKey:@"V18"];
            UIFont *badgeFont =  [UIFont fontWithName:@"SFCompactDisplay-Light" size:17];
            if([badgeText intValue]>0){
                UILabel *badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                [badgeLabel setCenter:CGPointMake(ICON_WIDTH+ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL)];
                [badgeLabel setFont:badgeFont];
                [badgeLabel setText:badgeText];
                [badgeLabel setTextColor:[UIColor whiteColor]];
                [badgeLabel setTextAlignment:NSTextAlignmentCenter];
                CGSize badgeTextSize = [[badgeLabel text] sizeWithFont:[badgeLabel font]];
                CGFloat badgeStrikeWidth = badgeTextSize.width;
                
                UIImage *badgeImage;
                UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 18, 2, 18);
                CGRect badgeImageSize;
                if (badgeStrikeWidth>16 ) {
                    badgeImage = [[UIImage imageNamed:@"icon_badge_40.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
                    badgeImageSize = CGRectMake(0, 0, 30, 23);
                }else {
                    badgeImage = [UIImage imageNamed:@"icon_badge_40.png"];
                    badgeImageSize = CGRectMake(0, 0, 23, 23);
                }
                if (badgeStrikeWidth>28) {
                    badgeImage = [[UIImage imageNamed:@"icon_badge_40.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
                    badgeImageSize = CGRectMake(0, 0, 37, 23);
                    
                }
                UIImageView *badgeImageView = [[UIImageView alloc]initWithImage:badgeImage];
                
                [badgeImageView setFrame:badgeImageSize];
                [badgeImageView setCenter:CGPointMake(ICON_WIDTH+ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL)];
                
                badgeImageView.tag = MENU_BADGE_ICON_TAG+index;
                badgeLabel.tag = MENU_BADGE_LABEL_TAG+index;
                [mainScrollView addSubview:badgeImageView];
                [mainScrollView addSubview:badgeLabel];
            }
            
            [btnIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            //관련좌표 다시 계산
            ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            TITLE_CURRENT_HORIZONTAL += TITLE_INCRESE_HORIZONTAL;
        }
    }
    
    [SVProgressHUD dismiss];
}



#pragma mark
#pragma mark Action Event Handler
-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo : %@",userInfo);
    NSString *menuNo = [userInfo objectForKey:@"menuNo"];
    [self getExecuteMenuInfo:menuNo];
    
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
-(void) buttonTouched:(id)sender {
    
	//메뉴아이콘이 터치 되었을때
    
	int indexBtn = [sender tag] - (int)MENU_ICON_TAG;
	[self buttonToIndex:indexBtn];
    /*
    if (indexBtn==0) {
        UIButton *button = (UIButton *)sender;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_02.png"] forState:UIControlStateNormal];
    }*/
    
}

-(void) buttonToIndex:(int)indexBtn {
    //메뉴번호,사용자번호,메뉴구분 가져오기
    
    
    NSString *menu_no = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V3"];
    
    NSString *target_url = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V6"];
    
    NSString *param_String = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V6_1"];
    
    NSData *param_data = [param_String dataUsingEncoding:NSUTF8StringEncoding];
	menuKind = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V7"];
    
    appDelegate.menu_title = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V9"];
    
    menuType = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V10"];
    
    NSString *versionFromServer = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V12"];
    
    nativeAppURL = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V13"];
    
    isDMS = [[[menuArray objectAtIndex:indexBtn]objectForKey:@"V16"] isEqualToString:@"Y"];
    isTabBar = [[[menuArray objectAtIndex:indexBtn]objectForKey:@"V17"] isEqualToString:@"Y"];
    
    menuTitle = [NSString urlDecodeString:[[menuArray objectAtIndex:indexBtn]objectForKey:@"V4"]];
    
    NSLog(@"[menuArr] : %@", menuArray);
    
	paramString = @"";
    appDelegate.menu_no = menu_no;
    nativeAppMenuNo = menu_no;
    currentAppVersion = versionFromServer;
    appDelegate.target_url = target_url;
    NSError *error;
    
    NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:param_data options:kNilOptions error:&error];
    NSLog(@"[paramDic] : %@", paramDic);
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
        NSLog(@"buttonToIndex paramString exception : %@",[exception name]);
    }
    if (IS_OS_8_OR_LATER) {
        if (isDMS) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message163", @"iOS8 버전 이상은 지원하지 않습니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }else{
            [self addMenuHist:appDelegate.menu_no];
        }
    }else{
        [self addMenuHist:appDelegate.menu_no];
    }
    
	
    
}

- (void)menuHandler{
    NSLog(@"appDelegate.menu_no : %@",appDelegate.menu_no);
    if ([menuKind isEqualToString:@"M"]) {
        //SubMenu
        MFTableViewController *subMenuList = [[MFTableViewController alloc]init];
        subMenuList.urlString = @"ezMainMenu2";
        [self.navigationController pushViewController:subMenuList animated:YES];
        NSLog(@"%s",__FUNCTION__);
        //[MFinityAppDelegate checkWebappDirectory:nil];
        //[MFinityAppDelegate checkWebappDirectory:@"585"];
    }
    else if ([menuKind isEqualToString:@"P"]) {
        //실행메뉴일때
        if ([menuType isEqualToString:@"B1"]) {
            //바코드를 사용하는 메뉴일때
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Barcode" message:NSLocalizedString(@"message88", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                
                kind = @"barcode";
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
            
            NSLog(@"main nativeAppURL : %@",nativeAppURL);
            NSLog(@"current : %@, versionFromServer : %@", current, versionFromServer);
            
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
                        if([nativeAppURL rangeOfString:@"SNS"].location!=NSNotFound){
                            NSLog(@"urlString : %@",url);
                            
                            if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",appDelegate.target_url]]]){
                                NSLog(@"설치됨");
                                NSString * stringURLScheme = nil;
                                NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
                                if (URLTypes && [URLTypes count]) {
                                    NSDictionary * dict = [URLTypes objectAtIndex:0];
                                    NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
                                    if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
                                        stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
                                    }
                                }
                                NSLog(@"stringURLScheme : %@", stringURLScheme);

                                NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", appDelegate.target_url, stringURLScheme];
                                callUrl = [callUrl stringByAppendingFormat:@"%@", paramString];
                                NSLog(@"callUrl : %@", callUrl);
                                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:callUrl]];

                            } else {
                                NSLog(@"설치안됨");
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nativeAppURL]];
                            }
                            
                            NSLog(@"urlString : %@",url);
                            NSLog(@"target_url : %@",appDelegate.target_url);
                            
                        } else {
                            BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                            if (!isInstall) {
                                NSURL *browser = [NSURL URLWithString:nativeAppURL];
                                [[UIApplication sharedApplication] openURL:browser];
                            }
                        }
                        
                    }
                }
                
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }
            
        } else if([menuType isEqualToString:@"C1"]){
            NSString *url = appDelegate.target_url;
            NSLog(@"main nativeAppURL : %@",nativeAppURL); //V13값
            
            
            @try {
                if ([nativeAppURL isEqualToString:@"#"]) {
                    BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                    if (!isInstall) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                        [alertView show];
                    }
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nativeAppURL]];
                }
                
            } @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }
        }
        else if ([menuType isEqualToString:@"A1"]){
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
            
            NSLog(@"appDelegate.target_url : %@",appDelegate.target_url);
            NSData *data = [NSData dataWithContentsOfFile:htmlFilePath];
            
            NSPropertyListFormat format;
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
            NSMutableDictionary *dic = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:nil];
            //NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
            NSLog(@"dic : %@",dic);
            if (appDelegate.isOffLine) {
                if ([dic objectForKey:appDelegate.menu_no]!=nil && ![[dic objectForKey:appDelegate.menu_no] isEqualToString:currentAppVersion]) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message113", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                    
                }else if([dic objectForKey:appDelegate.menu_no]==nil){
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message114", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
//                    WebViewController *vc = [[WebViewController alloc] init];
                    WKWebViewController *vc = [[WKWebViewController alloc] init];
                    vc.isDMS = isDMS;
                    vc.isTabBar = isTabBar;
                    if (!isTabBar) {
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
                    NSMutableArray *downloadUrlArray = [NSMutableArray array];
                    NSMutableArray *menuTitles = [NSMutableArray array];
                    NSString *naviteAppDownLoadUrl = [temp stringByAppendingString:lastPath];
                    [downloadUrlArray addObject:naviteAppDownLoadUrl];
                    [menuTitles addObject:appDelegate.menu_title];
                    
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
                            [downloadUrlArray addObject:[prefs objectForKey:@"COMMON_DOWNLOAD"]];
                            [menuTitles addObject:@"COMMON"];
                        }
                    }
                    
                    DownloadListViewController *vc = [[DownloadListViewController alloc]init];
                    
                    vc.downloadNoArray = [NSMutableArray arrayWithArray:@[nativeAppMenuNo]];
                    vc.downloadVerArray = [NSMutableArray arrayWithArray:@[currentAppVersion]];
                    
                    vc.downloadUrlArray = downloadUrlArray;
                    vc.downloadMenuTitleList = menuTitles;
                    vc.delegate = self;
                    //vc.view.frame = CGRectMake(0, 0, 320, 100);
                    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                    nvc.navigationBarHidden=NO;
                    int increaseRow = 0;
                    for (int i=1; i<[downloadUrlArray count]; i++) {
                        increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
                    }
                    if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
                    
                    nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
                    [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
                    
                    //vc.downloadURL = naviteAppDownLoadUrl;
                    //vc.currentAppVersion = currentAppVersion;
                    //vc.nativeAppMenuNo = nativeAppMenuNo;
                    
                    
                }else{
//                    WebViewController *vc = [[WebViewController alloc] init];
                    WKWebViewController *vc = [[WKWebViewController alloc] init];
                    vc.isDMS = isDMS;
                    vc.isTabBar = isTabBar;
                    if (!isTabBar) {
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
//            WebViewController *vc = [[WebViewController alloc] init];
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            vc.isDMS = isDMS;
            vc.isTabBar = isTabBar;
            if (!isTabBar) {
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
//            WebViewController *vc = [[WebViewController alloc] init];
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            vc.type = @"A3";
            vc.isDMS = isDMS;
            vc.isTabBar = isTabBar;
            if (!isTabBar) {
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
            NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSURL *rankUrl = [NSURL URLWithString:menuHitURL];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody: postData];
            
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            [urlCon start];
        }
    }else{
        [self menuHandler];
    }
    
}

#pragma mark
#pragma mark Coverflow Delegate
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasBroughtToFront:(int)index{
	menuName.text = [[menuArray objectAtIndex:index]objectForKey:@"V9"];
    
    menuName.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
    menuName.font = [UIFont boldSystemFontOfSize:20.0];
    menuName.backgroundColor = [UIColor clearColor];
    menuName.textAlignment = NSTextAlignmentCenter;
    
    if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
        menuName.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
        menuName.shadowOffset = CGSizeMake([appDelegate.mainShadowOffset floatValue], [appDelegate.mainShadowOffset floatValue]);
    }
}
- (TKCoverflowCoverView*) coverflowView:(TKCoverflowView*)coverflowView coverAtIndex:(int)index{
	
	TKCoverflowCoverView *cover = [coverflowView dequeueReusableCoverView];
	if(cover == nil){
        
		CGRect rect = CGRectMake(0, 0, 100, 100);
		cover = [[TKCoverflowCoverView alloc] initWithFrame:rect]; // 224
		cover.baseline = 100;
		
	}
	cover.image = [covers objectAtIndex:index%[covers count]];
    
	return cover;
	
}
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasDoubleTapped:(int)index{
	
	
	TKCoverflowCoverView *cover = [coverflowView coverAtIndex:index];
	if(cover == nil) return;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cover cache:YES];
	[UIView commitAnimations];
    [self buttonToIndex:index];
}

BOOL backFlag = NO;
#pragma mark
#pragma mark Background Delegate
- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
}
- (void)applicationWillEnterForeground:(NSNotification *)notification{
    
}
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    
    
    
    NSUserDefaults *pres = [NSUserDefaults standardUserDefaults];
    if ([[pres stringForKey:@"Lock"] isEqualToString:@"YES"] && appDelegate.isLogin) {
        
        LockInsertView *vc = [[LockInsertView alloc]init];
        [self presentViewController:vc animated:NO completion:nil];
    }
}


#pragma mark
#pragma mark ScrollView Delegate

- (void)loadScrollViewWithPage:(int)page {
	//스크롤뷰 초기화
    if (page < 0) return;
    if (page >= 2) return;
    
	CGRect frame = mainScrollView.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    //2018.06 UI개선
    if(![appDelegate.mainType isEqualToString:@"3"]){
        //스크롤뷰가 스크롤 되었을때
        if (pageControlUsed) {
            return;
        }

        //예제소스 그대로임 ======================
        CGFloat pageWidth = mainScrollView.frame.size.width;
        int page = floor((mainScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;

        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
        //=====================================
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
	
	//페이지컨드롤로 인해 페이지가 변경되었을때
	UIView * newView = [views objectAtIndex:[pageControl currentPage]];
	[self animateToView:newView];
	
	//해당 페이지 번호
    int page = pageControl.currentPage;
	
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	//해당 페이지의 뷰를 구한다.
    CGRect frame = mainScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
	
	//해당 뷰로 스크롤 한다.
    [mainScrollView scrollRectToVisible:frame animated:YES];
    
    pageControlUsed = YES;
}
#pragma mark
#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [menuArray count];
}

// Customize the appearance of table view cells.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self buttonToIndex:indexPath.row];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//-----------
    static NSString *CellIdentifier = @"SubMenuViewCell";
    
    SubMenuViewCell *cell = (SubMenuViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"SubMenuViewCell" owner:self options:nil];
		
		for (id currentObject in topLevelObject) {
			if ([currentObject isKindOfClass:[SubMenuViewCell class]]) {
				cell = (SubMenuViewCell *) currentObject;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			}
		}
		
    }
    
    if ([menuArray count]>0) {
        //-----------
        //UIButton *myButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 7, 280, 40)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 280, 40)];
        label.font = [UIFont systemFontOfSize:17];
        NSString *v9 = [[menuArray objectAtIndex:indexPath.row]objectForKey:@"V9"];
        label.text = v9;
        label.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
        label.backgroundColor = [UIColor clearColor];
        if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.subShadowColor];
            label.shadowOffset = CGSizeMake([appDelegate.subShadowOffset floatValue], [appDelegate.subShadowOffset floatValue]);
        }
        label.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:label];
	}
    
	return cell;
}
#pragma mark
#pragma mark Barcode Delegate
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Barcode Error" message:errMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    appDelegate.target_url = [[NSString alloc] initWithFormat:@"%@%@%@", appDelegate.target_url, result,paramString];
    
    //웹뷰 호출
//    WebViewController *vc = [[WebViewController alloc] init];
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    vc.isDMS = isDMS;
    vc.isTabBar = isTabBar;
    if (!isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
        appDelegate.scrollView.hidden = YES;
    }else{
        vc.hidesBottomBarWhenPushed = NO;
        appDelegate.scrollView.hidden = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) barCodeReaderOpen{
    MFBarcodeScannerViewController *vc = [[MFBarcodeScannerViewController alloc]init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message54", @"알림")]) {
        if (buttonIndex == 0) {
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setValue:currentAppVersion forKey:appDelegate.menu_no];
            [pref synchronize];
            NSURL *browser = [NSURL URLWithString:nativeAppURL];
            [[UIApplication sharedApplication] openURL:browser];
        }
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        if (buttonIndex == 0) {
            if ([_methodName isEqualToString:@"ezMainMenu2"]) {
                [self menuCall];
            }else if([_methodName isEqualToString:@"addMenuHist"]){
                [self addMenuHist:appDelegate.menu_no];
            }
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"관리자 메시지")]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [conn start];
        //exit(0);
    }
    
}
@end
