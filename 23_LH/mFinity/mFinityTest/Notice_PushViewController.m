//
//  TempNoticeViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "Notice_PushViewController.h"
#import "CustomSegmentedControl.h"
#import "IntroViewController.h"
#import "MFTableViewController.h"
#import "WebViewController.h"
#import "MFMessageViewController.h"
#import "MFUserListViewController.h"
#import "CameraMenuViewController.h"
#import "NoticeCell.h"

#import "SVProgressHUD.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import "NSData+AES256.h"
#import "SecurityManager.h"

#import <QuartzCore/QuartzCore.h>


#define REFRESH_TABLEVIEW_DEFAULT_ROW               44.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               44.f

#define REFRESH_TITLE_TABLE_PULL                    @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_RELEASE                 @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_LOAD                    @"Refreshing ..."

#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"

#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 504
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface Notice_PushViewController ()

@end

@implementation Notice_PushViewController {
    //푸시삭제 기능추가(2018.09)
    BOOL isPushDelete;
    NSString *deletePushNo;
    NSInteger deleteIdx;
    BOOL isAllCheck;
    NSDictionary *alertData;
}

BOOL isEditing;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"bottom_icon02.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    _imageView.image = bgImage;
    pPno = 0;
    moreCount = @"20";
    isEditing = NO;
    _isNotice = NO;
    noticeViewFlag = NO;
    
    //푸시삭제 기능추가(2018.09)
    isPushDelete = NO;
    isAllCheck = NO;
    self.indexArray = [NSMutableArray array];
    self.checkArray = [NSMutableArray array];
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    
    tmpPush = [NSMutableArray array];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Back", @"");
	self.navigationItem.backBarButtonItem = back;
    [self performSelector:@selector(_initializeRefreshViewOnTableViewTop)];
    
    if(appDelegate.isPushEdit) self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    
    _tableView.rowHeight = 50;
    _tableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.cNaviColor]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [UIColor whiteColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"Push";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;

    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }

    self.navigationItem.titleView = label;
    
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notice" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
    }
}
-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"appDelegate.receivePush : %d",appDelegate.receivePush);
    if (appDelegate.receivePush) {
        [self getExecuteMenuInfo:appDelegate.receiveMenuNo];
        appDelegate.receivePush = NO;
        
    }else {
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
            self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.cNaviColor]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor];
            self.navigationController.navigationBar.translucent = NO;
        }else {
            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
        }
        
        [self performSelector:@selector(_startConnection)];
    }
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badgeInt = [appDelegate.badgeCount intValue];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeInt];
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeInt]];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Action Event Handler
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
-(void)getExecuteMenuInfo:(NSString *)menuNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
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
- (void)menuHandler{
    NSLog(@"menuKind : %@ / menuType : %@", menuKind, menuType);
    
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
            NSLog(@"htmlFilePath : %@",htmlFilePath);
            
            NSData *data = [NSData dataWithContentsOfFile:htmlFilePath];
            
            NSPropertyListFormat format;
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
            NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
            NSLog(@"dic : %@",dic);
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
                NSLog(@"naviteAppDownLoadUrl : %@",naviteAppDownLoadUrl);
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
                WebViewController *vc = [[WebViewController alloc] init];
                vc.isTabBar = isTabBar;
                if (!isTabBar) {
                    vc.hidesBottomBarWhenPushed = YES;
                }else{
                    vc.hidesBottomBarWhenPushed = NO;
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else if ([menuType isEqualToString:@"A0"]||[menuType isEqualToString:@"A4"]){
            //Mobile web 메뉴일때
            NSString *page_url;
            if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            appDelegate.target_url = page_url;
            appDelegate.isMainWebView = NO;
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
            
            if ([paramString isEqualToString:@""])
                page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else
                page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            
            appDelegate.target_url = page_url;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.type = @"A3";
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
- (void)segmentButtonClick:(UISegmentedControl *)sender{
    NSString *url;
    if (sender.selectedSegmentIndex == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        noticeViewFlag = YES;
        _isNotice = YES;
        _tableView.rowHeight = 44;
        url = [NSString stringWithFormat:@"%@/getNoticeList2?cuser_no=%@&app_no=%@",appDelegate.main_url,appDelegate.user_no,appDelegate.app_no];
        NSURL *rankUrl = [NSURL URLWithString:url];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if(urlCon){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
    }else if(sender.selectedSegmentIndex == 1){
        CustomSegmentedControl *button;
        button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Edit",nil]
                                                    offColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                     onColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                offTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                 onTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                    fontSize:12];
        button.momentary = YES;
        [button addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem=left;
        CustomSegmentedControl *button2;
        button2= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"New",nil]
                                                     offColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                      onColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                 offTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                  onTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                     fontSize:12];
        button2.momentary = YES;
        [button2 addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button2];
        self.navigationItem.rightBarButtonItem=right;
        noticeViewFlag =  NO;
        self.isNotice = NO;
        [self deleteLoading];
        _tableView.rowHeight = 80;
        [_tableView reloadData];
    }
}

- (void)leftButtonClick{
    if (noticeViewFlag) {
        noticeViewFlag = NO;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        label.text = @"Push";
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        }
        self.navigationItem.titleView = label;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:appDelegate.noticeTitle style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
        
        //푸시삭제 기능추가(2018.09)
        if(appDelegate.isPushEdit) self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
        
        NSString *url;
        NSString *param;
        if (appDelegate.isAES256) {
            url = [NSString stringWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@&encType=AES256",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],moreCount];
        }else{
            url = [NSString stringWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],moreCount];
            
        }
        NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        if(urlConnection){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
        
    }else{
        noticeViewFlag = YES;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        label.text = appDelegate.noticeTitle;
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        }
        self.navigationItem.titleView = label;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Push" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];

        //푸시삭제 기능추가(2018.09)
        self.navigationItem.rightBarButtonItem = nil;
        
        NSString *url;
        NSString *param;
        if (appDelegate.isAES256) {
            url = [NSString stringWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"cuser_no=%@&app_no=%@&encType=AES256",appDelegate.user_no,appDelegate.app_no];
        }else{
            url = [NSString stringWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"cuser_no=%@&app_no=%@",appDelegate.user_no,appDelegate.app_no];
            
        }
        NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        if(urlConnection){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
    }
}
- (void)rightButtonClick{
    
    MFUserListViewController *userListViewController = [[MFUserListViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:userListViewController];
    [self presentViewController:nvc animated:YES completion:nil];
}

//푸시삭제 기능추가(2018.09)----------------------------------------
-(void)deleteButtonClick{
    NSLog(@"%s", __func__);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"삭제" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCompleteClick)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"전체선택" style:UIBarButtonItemStylePlain target:self action:@selector(allCheckButtonClick)];
    
    self.navigationItem.rightBarButtonItems=@[right1,right2];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    isPushDelete = YES;
    [_tableView reloadData];
}

-(void)deleteCompleteClick{
    NSLog(@"%s", __func__);
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:appDelegate.noticeTitle style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
    self.navigationItem.leftBarButtonItem = nil;
    
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.rightBarButtonItems=@[right1,right2];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    NSLog(@"checkArr : %@", self.checkArray);
    
    if(self.checkArray.count>0){
        //NSString *dvcid = [MFinityAppDelegate getUUID];
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:self.checkArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonData = [jsonData urlEncodeUsingEncoding:NSUTF8StringEncoding];
        jsonData = [jsonData stringByReplacingOccurrencesOfString:@"%22" withString:@"%27"];
        NSLog(@"jsonData : %@", jsonData);

        NSString* url = [NSString stringWithFormat:@"%@/deletePush",appDelegate.main_url];
        //NSString* param = [[NSString alloc]initWithFormat:@"cuser_no=%@&delete_push_no=%@&dev_id=%@&returnType=JSON&encType=AES256",appDelegate.user_no, jsonData, dvcid];
        NSString* param = [[NSString alloc]initWithFormat:@"cuser_no=%@&delete_push_no=%@&returnType=JSON&encType=AES256",appDelegate.user_no, jsonData];

        NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];

        if(urlConnection){
            receiveData = [[NSMutableData alloc] init];
            [SVProgressHUD show];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
        
    } else {
        [self cancelButtonClick];
    }
    
}

-(void)allCheckButtonClick{
    NSLog(@"%s", __func__);
    //NSLog(@"pushList : %@", pushList);
    tmpPush = [[NSMutableArray alloc]init];
    
    NSUInteger count = pushList.count;
    
    if(isAllCheck){
        UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
        UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"전체선택" style:UIBarButtonItemStylePlain target:self action:@selector(allCheckButtonClick)];
        self.navigationItem.rightBarButtonItems=@[right1,right2];
        
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
        
        
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(int i=0; i<count; i++){
            NSString *pushNo = [[pushList objectAtIndex:i] objectForKey:@"V4"];
            NSLog(@"pushNo : %@", pushNo);
            [self.rowCheckDictionary setObject:@"N" forKey:pushNo];
            [self.checkArray removeObject:pushNo];
            [self.indexArray removeObject:[NSString stringWithFormat:@"%d",i]];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
        
        isAllCheck = NO;
        
    } else {
        UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
        UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"선택취소" style:UIBarButtonItemStylePlain target:self action:@selector(allCheckButtonClick)];
        self.navigationItem.rightBarButtonItems=@[right1,right2];
        
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
        
        self.checkArray = [NSMutableArray array];
        self.indexArray = [NSMutableArray array];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(int i=0; i<count; i++){
            NSString *pushNo = [[pushList objectAtIndex:i] objectForKey:@"V4"];
            [self.rowCheckDictionary setObject:@"Y" forKey:pushNo];
            [self.checkArray addObject:pushNo];
            [self.indexArray addObject:[NSString stringWithFormat:@"%d",i]];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
        
        isAllCheck = YES;
    }
    
}

-(void)cancelButtonClick{
    NSLog(@"%s", __func__);
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:appDelegate.noticeTitle style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
    self.navigationItem.leftBarButtonItem = nil;

    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.rightBarButtonItems=@[right1,right2];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    isAllCheck = NO;
    isPushDelete = NO;
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    self.checkArray = [NSMutableArray array];
    self.indexArray = [NSMutableArray array];
    tmpPush = [[NSMutableArray alloc]init];
    [_tableView reloadData];
    
}


- (void)_startConnection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlString;
    NSString *param;
    if (appDelegate.isAES256) {
        if (noticeViewFlag) {
            urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"cuser_no=%@&app_no=%@&encType=AES256",appDelegate.user_no,appDelegate.app_no];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@&encType=AES256",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],moreCount];
        }
    }else{
        if (noticeViewFlag) {
            urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"cuser_no=%@&app_no=%@",appDelegate.user_no,appDelegate.app_no];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],moreCount];
        }
    }
    NSLog(@"urlString : %@",urlString);
    NSLog(@"param : %@",param);
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:30.0];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(urlConnection){
        receiveData = [[NSMutableData alloc] init];
        _tableView.scrollEnabled = NO;
        
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
    isDraw = YES;
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
#pragma mark JSON Data Parsing
//JSON데이터를 해석하는 메소드
- (void)_fetchedData:(NSData *)responseData
{
    NSError *error;
    //if seed
    //NSData *data = [MFinityAppDelegate getDecodeData:responseData];
    
    //if AES256
    NSString *encString =[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *decString ;
    if (appDelegate.isAES256) {
        decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
    }
    else{
        decString = encString;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    //if nomal
    //NSData *data = responseData;
    //NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[dic count]; i++) {
        NSDictionary *tempDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i]];
        [mdic setObject:[MFinityAppDelegate getAllValueUrlDecoding:tempDic] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    NSString *v0 =[[mdic objectForKey:@"0"] objectForKey:@"V0"];
    [mdic removeObjectForKey:@"0"];
    if ([v0 isEqualToString:@"True"]) {
        //푸시삭제 기능추가(2018.09)
        if (noticeViewFlag) {
            if (nPno==0) {
                badgeList = [[NSMutableDictionary alloc]init];
                noticeList =[[NSMutableDictionary alloc]init];
                for (int i=1; i<[mdic count]+1; i++) {
                    [noticeList setObject:[mdic objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",i-1]];
                }
                
                @try{
                    for (int i=0; i<[noticeList count]; i++) {
                        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",i]];
                        [badgeList setObject:[dic objectForKey:@"BADGE"] forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                } @catch(NSException *e){
                    badgeList = [[NSMutableDictionary alloc]init];
                    noticeList =[[NSMutableDictionary alloc]init];
                    nPno = 0;
                    [self _startConnection];
                }
                
            } else {
                NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]initWithDictionary:mdic];
                for (int i=1; i<[dic2 count]+1; i++) {
                    [noticeList setValue:[dic2 objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",(nPno*30)+i-1]];
                }
                
                @try{
                    for (int i=0; i<[noticeList count]; i++) {
                        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",i]];
                        [badgeList setObject:[dic objectForKey:@"BADGE"] forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                } @catch(NSException *e){
                    //noticeViewFlag = YES;
                    nPno = 0;
                    badgeList = [[NSMutableDictionary alloc]init];
                    noticeList =[[NSMutableDictionary alloc]init];
                    [self _startConnection];
                }
            }
            
        } else {
            if (pPno==0) {
                pushList=[[NSMutableArray alloc]init];
                self.indexArray = [NSMutableArray array];
                self.checkArray = [NSMutableArray array];
                tmpPush = [[NSMutableArray alloc]init];
                isAllCheck = NO;
                
                if(isPushDelete){
                    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
                    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"전체선택" style:UIBarButtonItemStylePlain target:self action:@selector(allCheckButtonClick)];
                    
                    self.navigationItem.rightBarButtonItems=@[right1,right2];
                }
                
                @try{
                    for (int i=1; i<[mdic count]+1; i++) {
                        [pushList addObject:[mdic objectForKey:[NSString stringWithFormat:@"%d",i]]];
                        NSDictionary *dic = [pushList objectAtIndex:i-1];
                        NSString *pushNo = [dic objectForKey:@"V4"];
                        
                        self.rowCheckDictionary = [NSMutableDictionary dictionary];
                        [self.rowCheckDictionary setObject:@"N" forKey:pushNo];
                    }
                    
                }@catch(NSException *e){
                    noticeViewFlag = NO;
                    pushList=[[NSMutableArray alloc]init];
                    pPno = 0;
                    [self _startConnection];
                }
                
            }else{
                NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]initWithDictionary:mdic];
                for (int i=1; i<[dic2 count]+1; i++) {
                    [pushList addObject:[dic2 objectForKey:[NSString stringWithFormat:@"%d",i]]];
                }
                
                for(int j=0; j<pushList.count; j++){
                    NSDictionary *dic = [pushList objectAtIndex:j];
                    NSString *pushNo = [dic objectForKey:@"V4"];
                    
                    if(isAllCheck){
                        self.indexArray = [NSMutableArray array];
                        self.checkArray = [NSMutableArray array];
                        
                        [self.rowCheckDictionary setObject:@"Y" forKey:pushNo];
                        [self.checkArray addObject:pushNo];
                        [self.indexArray addObject:[NSString stringWithFormat:@"%d", j]];
                    }
                }
            }
            
        }
        if (![appDelegate.demo isEqualToString:@"DEMO"]) {
            int badgeCount = 0;
            for (int i=0; i<[badgeList count]; i++) {
                if ([[badgeList objectForKey:[NSString stringWithFormat:@"%d",i]]isEqualToString:@"Y"]) {
                    badgeCount++;
                }
            }
            if (badgeCount <= 0) {
                [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:nil];
            }else {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
            }
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
        }
        
        
        //이상없이 해석이 완료되면 테이블뷰 리로드
        [_tableView reloadData];
        
        //PullRefreshTableView의 StopLoading 호출
        [self stopLoading];
        
    }else if ([v0 isEqualToString:@"False"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
    
}
#pragma mark
#pragma mark PullRefreshTableView

// 새로고침이 시작될 때 호출 될 메소드
- (void)startLoading {
    //PullRefreshTableView의 StartLoading 호출
    if(noticeViewFlag) nPno = 0;
    else pPno = 0;
    [self startLoading2];
    [self performSelector:@selector(_startConnection)];
    
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
    [_tableView setContentInset:UIEdgeInsetsZero];
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    [UIView commitAnimations];
    
    _tableView.scrollEnabled = YES;
}
- (void)startLoading2
{
    if (_isNotice) {
        isRefresh = YES;
        lbRefreshTime.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [_tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
        NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_LOAD, refreshTime];
        [ivRefreshArrow setHidden:YES];
        [lbRefreshTime setText:lbString];
        [spRefresh startAnimating];
        
        [UIView commitAnimations];
    }
    
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
    ////NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            _tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
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
    //NSLog(@"_initializeRefreshViewOnTableViewTop");
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, _tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
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
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, _tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [_tableView addSubview:vRefresh];
}
// 새로고침 애니메이션을 정지할 때 호출할 메소드
- (void)_stopLoadingComplete
{
    NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_PULL, refreshTime];
    if (_isNotice) {
        [ivRefreshArrow setHidden:NO];
    }
    [lbRefreshTime setText:lbString];
    [spRefresh stopAnimating];
}

#pragma mark
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs integerForKey:@"FONT_SIZE"]==2) {
        return 70;
    }else{
        return 50;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (noticeViewFlag) {
        return [noticeList count];
    }else{
        return [pushList count];
    }
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //-----------
    static NSString *CellIdentifier = @"NoticeCell";
    
    NoticeCell *cell = (NoticeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NoticeCell" owner:self options:nil];
		
		for (id currentObject in topLevelObject) {
			if ([currentObject isKindOfClass:[NoticeCell class]]) {
				cell = (NoticeCell *) currentObject;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			}
		}
    }
    //푸시삭제 기능추가(2018.09)
    CGFloat mainWidth = [[UIScreen mainScreen]bounds].size.width;
    
    NSString *titleString;
    cell.titleLabel.tag = indexPath.row;
    cell.titleLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    int fontSize = 16;
    int fontSize2 = 11;
    cell.dateLabel.numberOfLines = 2;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch ([prefs integerForKey:@"FONT_SIZE"]) {
        case 1:
            fontSize = fontSize+5;
            fontSize2 = fontSize2+2.5;
            [cell.dateLabel setFrame:CGRectMake(mainWidth-75, 0, 70, 50)];
            break;
        case 2:
            fontSize = fontSize+10;
            fontSize2 = fontSize2+5;
            cell.dateLabel.numberOfLines = 4;
            [cell.dateLabel setFrame:CGRectMake(mainWidth-85, 0, 70, 70)];
            break;
        default:
            break;
    }
    cell.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    cell.dateLabel.font = [UIFont systemFontOfSize:fontSize2];
    cell.dateLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    
    cell.dateLabel.backgroundColor = [UIColor clearColor];
    cell.dateLabel.alpha = 0.6;
    
    cell.imgView.image = nil;
    cell.imgView.hidden = YES;
    
    if (noticeViewFlag) {
        cell.checkButton.hidden = YES;
        cell.selectButton.hidden = YES;
        cell.checkBtnWidthConstraint.constant = 0;
        
        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        titleString = [dic objectForKey:@"TITLE"];
        cell.titleLabel.text = titleString;
        
        cell.imgView.image = [UIImage imageNamed:@"notice_new.png"];
        
        NSString *dateText = [dic objectForKey:@"WRITE_DATE"];
        //NSLog(@"dateText : %@", dateText);
        
        NSRange range = [dateText rangeOfString:@" "];
        if (range.length>0) {
            dateText = [dateText stringByReplacingCharactersInRange:range withString:@"\n"];
        }
        cell.dateLabel.text = dateText;
        if (![appDelegate.demo isEqualToString:@"DEMO"]) {
            if ([[badgeList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] isEqualToString:@"Y"]) {
                cell.imgView.hidden = NO;
            }
        }
        
    } else {
        cell.imgView.image = nil;
        cell.imgView.hidden = YES;
        cell.checkButton.hidden = YES;
        cell.selectButton.hidden = YES;
        
        if(appDelegate.isPushEdit){
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonClick)];
            longPress.minimumPressDuration = 0.5;
            longPress.delegate = self;
            [cell addGestureRecognizer:longPress];
        }
        
        cell.titleLabel.numberOfLines = 1;
        
        NSDictionary *dic = [pushList objectAtIndex:indexPath.row];
        titleString = [dic objectForKey:@"V2"];
        NSString *pushNo = [dic objectForKey:@"V4"];
        
        NSString *dateString = [dic objectForKey:@"V3"];
        
        if(isPushDelete){
            cell.checkButton.hidden = NO;
            cell.checkButton.backgroundColor = [UIColor clearColor];
            cell.checkBtnWidthConstraint.constant = 40;
            
            [cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.checkButton setTitle:@"" forState:UIControlStateNormal];
            
            cell.selectButton.hidden = NO;
            [cell.selectButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.selectButton setTitle:@"" forState:UIControlStateNormal];
            
            if ([[self.rowCheckDictionary objectForKey:pushNo] isEqualToString:@"Y"]) {
                [cell.checkButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
            }else{
                [cell.checkButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
            }
            
        } else {
            cell.checkButton.hidden = YES;
            cell.checkBtnWidthConstraint.constant = 0;
            
            cell.selectButton.hidden = YES;
        }
        
        cell.checkButton.tag = indexPath.row;
        cell.selectButton.tag = indexPath.row;
        
        cell.titleLabel.text = titleString;
        cell.dateLabel.text = dateString;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    CGSize labelSize = [cell.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    if(labelSize.width > mainWidth) cell.titleWidthConstraint.constant = 450;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (noticeViewFlag) {
        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
        if ([[dic objectForKey:@"BADGE"] isEqualToString:@"Y"]) {
            int badgeCount=0;
            [badgeList setObject:@"N" forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            for (int i=0; i<[badgeList count]; i++) {
                if ([[badgeList objectForKey:[NSString stringWithFormat:@"%d",i]] isEqualToString:@"Y"]) {
                    badgeCount++;
                }
            }
            if (![appDelegate.demo isEqualToString:@"DEMO"]) {
                appDelegate.badgeCount = [NSString stringWithFormat:@"%d",badgeCount];
                [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
                if (badgeCount <= 0) {
                    [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]]setBadgeValue:nil];
                }else {
                    [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
                }
            }
        }
        
        NSString *url =
        [NSString stringWithFormat:@"%@/NoticeDetail.jsp?cuser_no=%@&app_no=%@&notice_no=%@",appDelegate.main_url,
         appDelegate.user_no,appDelegate.app_no,[dic objectForKey:@"NOTICE_NO"]];
        NSLog(@"Notice url : %@",url);
        appDelegate.target_url = url;
        appDelegate.menu_title = [dic objectForKey:@"TITLE"];
        
        if (![appDelegate.demo isEqualToString:@"DEMO"]) {
            [SVProgressHUD show];
            NSString *menuHitURL;
            NSString *param;
            if (appDelegate.isAES256) {
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addNoticeHist",appDelegate.main_url];
                param = [[NSString alloc]initWithFormat:@"cuser_no=%@&notice_no=%@&encType=AES256",appDelegate.user_no,[dic objectForKey:@"NOTICE_NO"]];
            }else{
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addNoticeHist",appDelegate.main_url];
                param = [[NSString alloc]initWithFormat:@"cuser_no=%@&notice_no=%@",appDelegate.user_no,[dic objectForKey:@"NOTICE_NO"]];
            }
            NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:menuHitURL]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody: postData];
            [request setTimeoutInterval:30.0];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            
            if(urlConnection){
                receiveData = [[NSMutableData alloc] init];
            }else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
        }else{
            //WebPageView를 호출
            WebViewController *vc = [[WebViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else{
        //푸시삭제 기능추가(2018.09)
        if(appDelegate.isPushEdit){
            if(!isPushDelete){
                NSDictionary *dic = [pushList objectAtIndex:indexPath.row];
                NSLog(@"dic : %@", dic);
                
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                NSLog(@"appName : %@", appName);
                
                NSString *title = @"";
                if([dic objectForKey:@"TITLE"]!=nil){
                    if(![[dic valueForKey:@"TITLE"] isEqualToString:@""]){
                        title = [dic objectForKey:@"TITLE"];
                    } else {
                        title = appName;
                    }
                } else {
                    title = appName;
                }
                
                deletePushNo = [dic objectForKey:@"V4"];
                deleteIdx = indexPath.row;
                
                alertData = [[NSDictionary alloc]initWithDictionary:dic];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@\n%@",title, [dic objectForKey:@"V3"]] message:[dic objectForKey:@"V2"] delegate:self cancelButtonTitle:NSLocalizedString(@"message84", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 1;
                [alertView show];
            }
            
        } else {
            NSDictionary *dic = [pushList objectAtIndex:indexPath.row];
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            
            NSString *title = @"";
            if([dic objectForKey:@"TITLE"]!=nil){
                if(![[dic valueForKey:@"TITLE"] isEqualToString:@""]){
                    title = [dic objectForKey:@"TITLE"];
                } else {
                    title = appName;
                }
            } else {
                title = appName;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@\n%@",title, [dic objectForKey:@"V3"]] message:[dic objectForKey:@"V2"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
            alertView.tag = 1;
            [alertView show];
        }
        
    }
}

//푸시삭제 기능추가(2018.09)
-(void)checkAction:(UIButton *)sender{
    UIButton *button = sender;
    NSInteger buttonTag = button.tag;
    
    NSDictionary *dic = [pushList objectAtIndex:buttonTag];
    NSString *pushNo = [dic objectForKey:@"V4"];
    
    NSString *checked = [self.rowCheckDictionary objectForKey:pushNo];
    if([checked isEqualToString:@"Y"]){
        [self.rowCheckDictionary setObject:@"N" forKey:pushNo];
        [self.checkArray removeObject:pushNo];
        [self.indexArray removeObject:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
        
        [tmpPush removeObject:dic];
        
    } else {
        [self.rowCheckDictionary setObject:@"Y" forKey:pushNo];
        [self.checkArray addObject:pushNo];
        [self.indexArray addObject:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
        
        [tmpPush addObject:dic];
    }
    
    NSLog(@"checkArray : %@", self.checkArray);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:buttonTag inSection:0];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
}

#pragma mark
#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
    
    _tableView.scrollEnabled = NO;
    [self startLoading];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
        _tableView.scrollEnabled = NO;
        [self startLoading];
		
	}else{
		[receiveData setLength:0];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *requestUrl = connection.currentRequest.URL.absoluteString;
    NSArray *paths = [requestUrl componentsSeparatedByString:@"/"];
    NSString *temp = [paths objectAtIndex:4];
    NSArray *methodNames = [temp componentsSeparatedByString:@"?"];
    
    if ([[methodNames objectAtIndex:0]isEqualToString:@"getNoticeList2"]||[[methodNames objectAtIndex:0]isEqualToString:@"getPushList2"]) {
        [self _fetchedData:receiveData];
        
    }else if([[methodNames objectAtIndex:0] isEqualToString:@"addNoticeHist"]) {
        NSDictionary *dic;
        NSError *error;
        
        //if AES256
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        } else{
            decString = encString;
        }
        
        @try {
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        [SVProgressHUD dismiss];
        if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
            //WebPageView를 호출
            WebViewController *vc = [[WebViewController alloc] init];
            vc.isNotice = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
        
    }else if([[methodNames objectAtIndex:0] isEqualToString:@"addMenuHist"]) {
        NSDictionary *dic;
        NSError *error;
        @try {
            // if AES256
            NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            } else{
                decString = encString;
            }
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
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
        
    } else if([[methodNames objectAtIndex:0] isEqualToString:@"GetExecuteMenuInfo"]){
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
        
    } else if([[methodNames objectAtIndex:0] isEqualToString:@"deletePush"]){
        NSDictionary *dic;
        NSError *error;
        
        //if AES256
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        } else{
            decString = encString;
        }
        
        @try {
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        
        //NSLog(@"dic : %@", dic);
        if ([[dic objectForKey:@"V0"] isEqualToString:@"True"]) {
            isPushDelete = NO;
            noticeViewFlag = NO;
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            NSInteger count = self.indexArray.count;
            
            @try{
                if(isAllCheck){
                    pPno = 0;
                    [self _startConnection];
                    
                } else {
                    for(int i=0; i<count; i++){
                        [indexPaths addObject:[NSIndexPath indexPathForRow:[[self.indexArray objectAtIndex:i] intValue] inSection:0]];
                        [pushList removeObject:[tmpPush objectAtIndex:i]];
                    }
                    
                    [_tableView beginUpdates];
                    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                    
                    self.rowCheckDictionary = [NSMutableDictionary dictionary];
                    self.checkArray = [NSMutableArray array];
                    self.indexArray = [NSMutableArray array];
                    tmpPush = [NSMutableArray array];
                    
                    [_tableView reloadData];
                }
                
            } @catch(NSException *e){
                isAllCheck = NO;
                NSLog(@"exception : %@",e);
                
                self.rowCheckDictionary = [NSMutableDictionary dictionary];
                self.checkArray = [NSMutableArray array];
                self.indexArray = [NSMutableArray array];
                
                [_tableView reloadData];
            }
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    }
    
    [SVProgressHUD dismiss];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
#pragma mark
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!noticeViewFlag) {
        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.view.frame.size.height) {
            
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 10;
            
            
            if(y > h + reload_distance) {
                ++pPno;
                [SVProgressHUD showWithStatus:@"Loading"];
                [self performSelector:@selector(_startConnection)];
            }
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
            _tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
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
#pragma mark UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        SSLVPNConnect *vpn = [[SSLVPNConnect alloc] init];
        [vpn stopTunnel];
        exit(0);
    }
    
    if(appDelegate.isPushEdit){
        //푸시삭제 기능추가(2018.09)
        if(alertView.tag == 1 && buttonIndex == 0){
            [self.rowCheckDictionary setObject:@"Y" forKey:deletePushNo];
            [self.checkArray addObject:deletePushNo];
            [self.indexArray addObject:[NSString stringWithFormat:@"%ld", (long)deleteIdx]];
            [tmpPush addObject:alertData];
            [self deleteCompleteClick];
            
        }
    }
}




@end
