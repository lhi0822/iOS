//
//  MymenuViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFTableViewController.h"
#import "IntroViewController.h"
#import "WebViewController.h"
#import "CameraMenuViewController.h"

#import "SubMenuViewCell.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import "ZipArchive.h"
#import "SVProgressHUD.h"

#import <TapkuLibrary/TapkuLibrary.h>


#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 504
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MFTableViewController (){
    BOOL isDraw;
}

@end

@implementation MFTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    isDraw = NO;

    // Do any additional setup after loading the view from its nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
//    myTableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
//    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    
    imageView.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.cNaviColor]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor];//[appDelegate myRGBfromHex:appDelegate.naviFontColor];

    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = [appDelegate.badgeCount intValue];
        if ([appDelegate.badgeCount intValue] <= 0) {
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]]setBadgeValue:nil];
        }else {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",[appDelegate.badgeCount intValue]]];
        }
    }
    
    label.text =appDelegate.menu_title;
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    
//	UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
//	self.navigationItem.backBarButtonItem = left;
    
//	myTableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	myTableView.rowHeight = 50;
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.cNaviFontColor]} forState:UIControlStateNormal];
    
}
-(void) viewDidAppear:(BOOL)animated{
    if (appDelegate.receivePush) {
        [self getExecuteMenuInfo:appDelegate.receiveMenuNo];
        appDelegate.receivePush = NO;
    }
    else {
//        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//        if ([[ver objectAtIndex:0] intValue] >= 7) {
//            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
//            self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
//            self.navigationController.navigationBar.translucent = NO;
//        }else {
//            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
//        }
        if (!isDraw) {
            NSString *urlString;
            NSString *param;
            if (appDelegate.isAES256) {
                if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                    if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMymenu",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"app_no=&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.dvcGubn,appDelegate.user_no];
                    }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.menu_no,appDelegate.dvcGubn,appDelegate.user_no];
                    }
                }else{
                    if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_CALL",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=%@&returnType=JSON&encType=AES256",appDelegate.user_no,appDelegate.dvcGubn];
                    }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=%@&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.menu_no,appDelegate.dvcGubn];
                    }
                }
            }else{
                if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                    if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMymenu",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"app_no=&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON",appDelegate.dvcGubn,appDelegate.user_no];
                    }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON",appDelegate.menu_no,appDelegate.dvcGubn,appDelegate.user_no];
                    }
                }else{
                    if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_CALL",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=%@&returnType=JSON",appDelegate.user_no,appDelegate.dvcGubn];
                    }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                        param = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=%@&returnType=JSON",appDelegate.user_no, appDelegate.menu_no,appDelegate.dvcGubn];
                    }
                }
            }
            NSLog(@"urlString : %@",urlString);
            NSLog(@"paramString : %@",param);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
            
            NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody: postData];
            [request setTimeoutInterval:30.0];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            
            if(urlConnection){
                receiveData = [[NSMutableData alloc] init];
            }else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
            isDraw = YES;
        }else{
            [myTableView reloadData];
        }
	}
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badge = [appDelegate.badgeCount intValue];
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badge]];
        }
    }
    
    
}
-(void) viewWillAppear:(BOOL)animated {
    
//	[self.navigationController setNavigationBarHidden:FALSE];
	[myTableView reloadData];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Action Event Handler
-(void)getExecuteMenuInfo:(NSString *)menuNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    //NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://192.168.0.54:1598/dataservice41/GetExecuteMenuInfo"]];
    NSString *_paramString = [NSString stringWithFormat:@"menuNo=%@&cuserNo=%@&encType=AES256",menuNo,appDelegate.user_no];
    NSData *paramData = [_paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: paramData];
    [request setTimeoutInterval:30.0];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn!=nil) {
        [SVProgressHUD show];
        receiveData = [[NSMutableData alloc]init];
    }
    [conn start];
}
-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *menuNo = [userInfo objectForKey:@"menuNo"];
    [self getExecuteMenuInfo:menuNo];
    
}

- (void)cancelButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isTabBar = isTabBar;
    if (!isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }else{
        vc.hidesBottomBarWhenPushed = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void) rightBtnClick{
    if(![UIApplication sharedApplication].networkActivityIndicatorVisible){
        NSString *urlString;
        NSString *param;
        if (appDelegate.isAES256) {
            if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMymenu",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"app_no=&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.dvcGubn,appDelegate.user_no];
                }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.menu_no,appDelegate.dvcGubn,appDelegate.user_no];
                }
            }else{
                if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                    urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_CALL",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=%@&returnType=JSON&encType=AES256",appDelegate.user_no,appDelegate.dvcGubn];
                }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=%@&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.menu_no,appDelegate.dvcGubn];
                }
            }
        }else{
            if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMymenu",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"app_no=&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON",appDelegate.dvcGubn,appDelegate.user_no];
                }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=%@&cuser_no=%@&returnType=JSON",appDelegate.menu_no,appDelegate.dvcGubn,appDelegate.user_no];
                }
            }else{
                if ([_urlString isEqualToString:@"MY_MENU_CALL"]) {
                    urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_CALL",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=%@&returnType=JSON",appDelegate.user_no,appDelegate.dvcGubn];
                }else if([_urlString isEqualToString:@"ezMainMenu2"]){
                    urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                    param = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=%@&returnType=JSON",appDelegate.user_no, appDelegate.menu_no,appDelegate.dvcGubn];
                }
            }
        }
       
        NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
        
        if(urlConnection){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
    }
}
-(void) buttonTouched:(id)sender{
    //메뉴번호,사용자번호,메뉴구분 가져오기
    
    int indexBtn = (int)[sender tag];
    
    NSString *menu_no = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V3"];
    NSString *target_url = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V6"];
    NSData *param_data = [[[menuArray objectAtIndex:indexBtn]objectForKey:@"V6_1"] dataUsingEncoding:NSUTF8StringEncoding];
	menuKind = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V7"];
    appDelegate.menu_title = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V9"];
    menuType = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V10"];
    NSString *versionFromServer = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V12"];
    nativeAppURL = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V13"];
	paramString = @"";
    appDelegate.menu_no = menu_no;
    nativeAppMenuNo = menu_no;
    currentAppVersion = versionFromServer;
    appDelegate.target_url = target_url;
    NSError *error;
    
    
    
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
        NSLog(@"exception : %@",[exception name]);
    }
    
    [self addMenuHist:appDelegate.menu_no];
	
    
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
            
        } else if ([menuType isEqualToString:@"A0"]||[menuType isEqualToString:@"A4"]){
            //Mobile web 메뉴일때
            NSString *page_url;
            if ([methodType isEqualToString:@"1"]) {
                if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
                else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                appDelegate.target_url = page_url;
                appDelegate.target_method = @"GET";
                appDelegate.target_param = @"";
            }else if([methodType isEqualToString:@"2"]) {
                page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
                appDelegate.target_url = page_url;
                appDelegate.target_method = @"POST";
                appDelegate.target_param = paramString;
            }else{
                if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
                else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                appDelegate.target_url = page_url;
                appDelegate.target_method = @"GET";
                appDelegate.target_param = @"";
            }
			WebViewController *vc = [[WebViewController alloc] init];
            vc.isTabBar = isTabBar;
            if (!isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
			[self.navigationController pushViewController:vc animated:YES];
			
		} else if ([menuType isEqualToString:@"A3"]){
            NSString *page_url;
            appDelegate.isMainWebView = NO;
            if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
			appDelegate.target_url = page_url;
			WebViewController *vc = [[WebViewController alloc] init];
            vc.isTabBar = isTabBar;
            if (!isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
            vc.type = @"A3";
			[self.navigationController pushViewController:vc animated:YES];
			
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
            
            NSLog(@"url : %@",url);
            NSLog(@"current ver : %d",[current intValue]);
            NSLog(@"server ver : %d", [versionFromServer intValue]);
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
                            NSLog(@"!isInstall");
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
            
            if ([appDelegate.target_url hasPrefix:@"/"]) {
                appDelegate.target_url = [appDelegate.target_url substringFromIndex:1];
            }
            
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
                NSString *naviteAppDownLoadUrl = [NSString urlDecodeString:[temp stringByAppendingString:lastPath]];
                [downloadUrlArray addObject:naviteAppDownLoadUrl];
                [menuTitles addObject:appDelegate.menu_title];
                
                NSFileManager *fileManager = [[NSFileManager alloc]init];
                NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *compFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
                NSString *commonFolder = [compFolder stringByAppendingPathComponent:@"webapp"];
                commonFolder = [commonFolder stringByAppendingPathComponent:@"common"];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
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
                NSLog(@"=====================here=====================");
                WebViewController *vc = [[WebViewController alloc] init];
                vc.isTabBar = isTabBar;
                if (!isTabBar) {
                    vc.hidesBottomBarWhenPushed = YES;
                }else{
                    vc.hidesBottomBarWhenPushed = NO;
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
	}
}

-(void) addMenuHist:(NSString *)menu_no {
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
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody: postData];
        
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [urlCon start];
    }
    
    
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alertView show];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
    
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];

        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
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

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSString *urlStr = connection.currentRequest.URL.absoluteString;
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
    

    if ([methodName isEqualToString:@"MY_MENU_CALL"]||[methodName isEqualToString:@"ezMainMenu2"]||[methodName isEqualToString:@"ezPubMymenu"]||[methodName isEqualToString:@"ezPubMenu2"]) {
        
        [self parserJsonData:receiveData];
    }else if([methodName isEqualToString:@"addMenuHist"]) {
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
    }else if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
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
            methodType = [dic objectForKey:@"V10_1"];
             
            
            NSString *versionFromServer = [dic objectForKey:@"V12"];
            
            nativeAppURL = [dic objectForKey:@"V13"];
            isTabBar = [[dic objectForKey:@"V17"] isEqualToString:@"Y"];
            
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
            [self addMenuHist:appDelegate.menu_no];
        }
        [SVProgressHUD dismiss];
    }
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark
#pragma mark JSON Data Parsing
-(void) parserJsonData:(NSData *)data{
    /*
     menuArray = [[NSMutableArray alloc]init];
     NSError *error;
     NSDictionary *dic;
     @try {
     dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
     }
     
     @catch (NSException *exception) {
     //NSLog(@"error : %@",error);
     //NSLog(@"exception : %@",exception);
     }
     
     for (int i=0; i<[dic count]; i++) {
     [menuArray addObject:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
     }
     */
    menuArray = [[NSMutableArray alloc]init];
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    NSError *error;
    NSDictionary *dic;
    @try {
        //if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //if seed
        //dic = [NSJSONSerialization JSONObjectWithData:[MFinityAppDelegate getDecodeData:data] options:kNilOptions error:&error];
        //if AES256
        NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    if([[[dic objectForKey:@"0"]objectForKey:@"V0"]isEqualToString:@"False"]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else {
        for (int i=1; i<[dic count]; i++) {
            
            [tempArr addObject:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
        }
        for (NSDictionary *menuDic in tempArr) {
            [menuArray addObject: [MFinityAppDelegate getAllValueUrlDecoding:menuDic]];
        }
        [myTableView reloadData];
    }
    
}

#pragma mark
#pragma mark Barcode Call & Delegate
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Barcode Error" message:errMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    appDelegate.target_url = [[NSString alloc] initWithFormat:@"%@%@%@", appDelegate.target_url, result,paramString];
    
    //웹뷰 호출
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isTabBar = isTabBar;
    if (!isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }else{
        vc.hidesBottomBarWhenPushed = NO;
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
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [menuArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int indexBtn = (int)indexPath.row;
    NSString *menu_no = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V3"];
    NSString *target_url = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V6"];
    NSData *param_data = [[[menuArray objectAtIndex:indexBtn]objectForKey:@"V6_1"] dataUsingEncoding:NSUTF8StringEncoding];
	menuKind = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V7"];
    appDelegate.menu_title = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V9"];
    menuType = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V10"];
    methodType = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V10_1"];
     
    
    NSString *versionFromServer = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V12"];
    nativeAppURL = [[menuArray objectAtIndex:indexBtn]objectForKey:@"V13"];
    isTabBar = [[[menuArray objectAtIndex:indexBtn]objectForKey:@"V17"] isEqualToString:@"Y"];
	paramString = @"";
    appDelegate.menu_no = menu_no;
    nativeAppMenuNo = menu_no;
    currentAppVersion = versionFromServer;
    appDelegate.target_url = target_url;
    
    NSError *error;
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
        NSLog(@"exception : %@",[exception name]);
    }
    [self addMenuHist:appDelegate.menu_no];
}

// Customize the appearance of table view cells.
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
    UIImageView *_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, (44/2)-10 , 27.5, 27.5)];
    _imageView.image = [UIImage imageNamed:@"list.png"];
    if ([menuArray count]>0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, 255, 50)];

        int fontSize = 17;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        switch ([prefs integerForKey:@"FONT_SIZE"]) {
            case 1:
                fontSize = fontSize+5;
                break;
            case 2:
                fontSize = fontSize+10;
                break;
            default:
                break;
        }
        label.font = [UIFont systemFontOfSize:fontSize];
        label.text = [[menuArray objectAtIndex:indexPath.row]objectForKey:@"V9"];
        label.textColor = [appDelegate myRGBfromHex:appDelegate.cFontColor]; //[appDelegate myRGBfromHex:appDelegate.subFontColor];
        if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.subShadowColor];
            label.shadowOffset = CGSizeMake([appDelegate.subShadowOffset floatValue], [appDelegate.subShadowOffset floatValue]);
        }
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;

        [cell.contentView addSubview:_imageView];
        [cell.contentView addSubview:label];
	}
	return cell;
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
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        SSLVPNConnect *vpn = [[SSLVPNConnect alloc] init];
        [vpn stopTunnel];
        exit(0);
    }
}
@end
