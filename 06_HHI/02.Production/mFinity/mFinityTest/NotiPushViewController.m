//
//  NotiPushViewController.m
//  mFinity_HHI
//
//  Created by hilee on 2018. 7. 2..
//  Copyright © 2018년 Jun hyeong Park. All rights reserved.
//

#import "NotiPushViewController.h"
#import "CustomSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>
#import "IntroViewController.h"
#import "NoticeCell.h"
#import "CustomSegmentedControl.h"
#import "LockInsertView.h"
#import "SVProgressHUD.h"

#import "MFTableViewController.h"
#import "LockInsertView.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"

#import "NSData+AES256.h"
#import "CameraMenuViewController.h"
#import "SecurityManager.h"

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

@interface NotiPushViewController ()

@end

@implementation NotiPushViewController {
    BOOL isPushDelete;
    NSString *deletePushNo;
    NSInteger deleteIdx;
}

BOOL isEditMode;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"bottom_icon02.png"];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    CGFloat viewHeight = [[UIScreen mainScreen]bounds].size.height;
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, 0 , self.segContainView.frame.size.width, 50)];
            
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-self.segContainView.frame.size.height)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, self.segContainView.frame.origin.y, self.segContainView.frame.size.width, 50)];
            
            if([appDelegate isIphoneX]){
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, _tableView.frame.size.height)];
            } else {
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, viewHeight-(appDelegate.scrollView.frame.origin.y+self.tabBarController.tabBar.frame.size.height)-self.segContainView.frame.origin.y)];
            }
            
            [self.bgImgView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, self.bgImgView.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, 0 , self.segContainView.frame.size.width, 50)];
            
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, self.tabBarController.tabBar.frame.origin.y-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-self.segContainView.frame.size.height)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, self.segContainView.frame.origin.y, self.segContainView.frame.size.width, 50)];
            
            if([appDelegate isIphoneX]){
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, _tableView.frame.size.height)];
            } else {
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, viewHeight-(appDelegate.scrollView.frame.origin.y+self.tabBarController.tabBar.frame.size.height)-self.segContainView.frame.origin.y)];
            }
            
            [self.bgImgView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, self.bgImgView.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, 0 , self.segContainView.frame.size.width, 50)];
            
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-self.segContainView.frame.size.height)];
            
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [self.segContainView setFrame:CGRectMake(self.segContainView.frame.origin.x, self.segContainView.frame.origin.y, self.segContainView.frame.size.width, 50)];
            
            if([appDelegate isIphoneX]){
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, _tableView.frame.size.height)];
            } else {
                [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.segContainView.frame.origin.y+self.segContainView.frame.size.height+1, _tableView.frame.size.width, viewHeight-(appDelegate.scrollView.frame.origin.y+appDelegate.scrollView.frame.size.height)-self.segContainView.frame.origin.y)];
            }
            
            [self.bgImgView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, self.bgImgView.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height)];
        }
    }
  
    CGFloat mainWidth = [[UIScreen mainScreen]bounds].size.width;
    if(noticeViewFlag){
        //탭 선택 UI
        [self.noticeLine setFrame:CGRectMake(5, 15, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height-9)];
        self.noticeLine.backgroundColor = [UIColor clearColor];
        self.noticeLine.layer.borderWidth = 1.0;
        self.noticeLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
        self.noticeLine.layer.cornerRadius = 5;
        
        //[self.noticeBtn setFrame:CGRectMake(0, 0, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height)];
        [self.noticeBtn setFrame:CGRectMake(0, 0, self.noticeLine.frame.size.width, self.noticeLine.frame.size.height)];
        
        self.btnLine.hidden = YES;
        
        [self.hideView1 setFrame:CGRectMake(0, self.noticeLine.frame.origin.y+self.noticeLine.frame.size.height-5, self.noticeLine.frame.size.width+5, 5)];
        self.hideView1.backgroundColor = [UIColor whiteColor];
        
        [self.bottomLine1 setFrame:CGRectMake(self.hideView1.frame.origin.x+self.hideView1.frame.size.width, self.hideView1.frame.origin.y-1, mainWidth-(self.hideView1.frame.origin.x+self.hideView1.frame.size.width)-5, 1.0)];
        self.bottomLine1.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
        
        
        [self.pushLine setFrame:CGRectMake(self.noticeLine.frame.origin.x+self.noticeLine.frame.size.width, 15, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height-9)];
        self.pushLine.backgroundColor = [UIColor clearColor];
        self.pushLine.layer.borderWidth = 1.0;
        self.pushLine.layer.borderColor = [UIColor clearColor].CGColor;
        self.pushLine.layer.cornerRadius = 5;
        
        //[self.pushBtn setFrame:CGRectMake(self.noticeBtn.frame.size.width+self.btnLine.frame.size.width+5, 0, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height)];
        [self.self.pushBtn setFrame:CGRectMake(0, 0, self.pushLine.frame.size.width, self.pushLine.frame.size.height)];
        
        [self.hideView2 setFrame:CGRectMake(self.pushLine.frame.origin.x, self.pushLine.frame.origin.y+self.pushLine.frame.size.height-5, self.pushLine.frame.size.width+5, 5)];
        self.hideView2.backgroundColor = [UIColor clearColor];
        
        [self.bottomLine2 setFrame:CGRectMake(self.pushLine.frame.origin.x+self.pushLine.frame.size.width, self.hideView2.frame.origin.y-1, mainWidth-(self.hideView1.frame.origin.x+self.hideView1.frame.size.width)-5, 1.0)];
        self.bottomLine2.backgroundColor = [UIColor clearColor];
        
    } else {
        self.bottomLine2.hidden = NO;
        _noticeLine.layer.borderColor = [UIColor clearColor].CGColor;
        _pushLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
        
        [self.pushLine setFrame:CGRectMake(self.noticeLine.frame.origin.x+self.noticeLine.frame.size.width, 15, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height-9)];
        self.pushLine.backgroundColor = [UIColor clearColor];
        self.pushLine.layer.borderWidth = 1.0;
        self.pushLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
        self.pushLine.layer.cornerRadius = 5;
        
        [self.hideView2 setFrame:CGRectMake(self.pushLine.frame.origin.x, self.pushLine.frame.origin.y+self.pushLine.frame.size.height-5, self.pushLine.frame.size.width+5, 5)];
        self.hideView2.backgroundColor = [UIColor whiteColor];
        
        [self.bottomLine1 setFrame:CGRectMake(5, self.hideView2.frame.origin.y-1, self.pushLine.frame.origin.x-5, 1.0)];
        self.bottomLine1.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
        
        [self.bottomLine2 setFrame:CGRectMake(self.pushLine.frame.origin.x+self.pushLine.frame.size.width, self.hideView2.frame.origin.y-1, mainWidth-(self.hideView2.frame.origin.x+self.hideView2.frame.size.width), 1.0)];
        self.bottomLine2.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
        
    }
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    self.bgImgView.image = bgImage;
    
    nPno = 0;
    pPno = 0;
    isEditMode = NO;
    _isNotice = YES;
    noticeViewFlag = YES;
    isPushDelete = NO;
    
    self.indexArray = [NSMutableArray array];
    self.checkArray = [NSMutableArray array];
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    
    [self.noticeBtn addTarget:self action:@selector(noticeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.noticeBtn setTitle:@"공지사항" forState:UIControlStateNormal];
    
    [self.pushBtn addTarget:self action:@selector(pushAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pushBtn setTitle:@"알림메시지" forState:UIControlStateNormal];
    
    
    if(noticeViewFlag){
        [self.noticeBtn setTitleColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor] forState:UIControlStateNormal];
        [self.pushBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self noticeAction:self.noticeBtn];
    } else {
        [self.noticeBtn setTitleColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor] forState:UIControlStateNormal];
        [self.pushBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self pushAction:self.pushBtn];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    [self performSelector:@selector(_initializeRefreshViewOnTableViewTop)];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]} forState:UIControlStateNormal];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    //_tableView.rowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70;
    _tableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"appDelegate.receivePush : %d",appDelegate.receivePush);
    
    if (appDelegate.receivePush) {
        [self getExecuteMenuInfo:appDelegate.receiveMenuNo];
        
        appDelegate.receivePush = NO;
        
    }else {
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
            self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
            self.navigationController.navigationBar.translucent = NO;
        }else {
            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
        }
        if (appDelegate.isOffLine) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message112", @"")];
        }else{
            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
            label.text =appDelegate.noticeTitle;
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            }
            
            self.navigationItem.titleView = label;
            [self performSelector:@selector(_startConnection)];
            
            if (![appDelegate.demo isEqualToString:@"DEMO"]) {
                //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Push" style:UIBarButtonItemStyleBordered target:self action:@selector(leftButtonClick)];
            }
            
        }
    }
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badgeInt = [appDelegate.badgeCount intValue];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeInt];
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeInt]];
        }
    }
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Background Delegate
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    NSUserDefaults *pres = [NSUserDefaults standardUserDefaults];
    if ([[pres stringForKey:@"Lock"] isEqualToString:@"YES"] && appDelegate.isLogin) {
        
        LockInsertView *vc = [[LockInsertView alloc]init];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
#pragma mark
#pragma mark Action Event Handler
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
    NSString *menuNo = [userInfo objectForKey:@"menuNo"];
    [self getExecuteMenuInfo:menuNo];
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

-(void)noticeAction:(UIButton *)sender{
    NSLog(@"공지");
    
    //탭 선택 UI
    CGFloat mainWidth = [[UIScreen mainScreen]bounds].size.width;
    _noticeLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
    _pushLine.layer.borderColor = [UIColor clearColor].CGColor;
    [self.bottomLine1 setFrame:CGRectMake(self.hideView1.frame.origin.x+self.hideView1.frame.size.width, self.hideView1.frame.origin.y-1, mainWidth-(self.hideView1.frame.origin.x+self.hideView1.frame.size.width)-5, 1.0)];
    self.bottomLine1.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
    self.bottomLine2.hidden = YES;
    
    noticeViewFlag = YES;
    isPushDelete = NO;
    
    [self.noticeBtn setTitleColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor] forState:UIControlStateNormal];
    [self.pushBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
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
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    NSString *url;
    NSString *param;
    
    NSString *devId = [MFinityAppDelegate getUUID];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (appDelegate.isAES256) {
        url = [NSString stringWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&devId=%@&psize=%@&pno=%@&returnType=JSON&encType=AES256",appDelegate.app_no,appDelegate.user_no,[prefs objectForKey:@"UUID"],appDelegate.moreCount,[NSString stringWithFormat:@"%d",nPno]];
    }else{
        url = [NSString stringWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&devId=%@&psize=%@&pno=%@&returnType=JSON",appDelegate.app_no,appDelegate.user_no,[prefs objectForKey:@"UUID"],appDelegate.moreCount,[NSString stringWithFormat:@"%d",nPno]];
        
    }
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(urlConnection){
        receiveData = [[NSMutableData alloc] init];
        [SVProgressHUD show];
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

-(void)pushAction:(UIButton *)sender{
    NSLog(@"푸시");
    noticeViewFlag = NO;
    
    //탭 선택 UI
    self.bottomLine2.hidden = NO;
    _noticeLine.layer.borderColor = [UIColor clearColor].CGColor;
    _pushLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
    
    [self.pushLine setFrame:CGRectMake(self.noticeLine.frame.origin.x+self.noticeLine.frame.size.width, 15, self.segContainView.frame.size.width/4, self.segContainView.frame.size.height-9)];
    self.pushLine.backgroundColor = [UIColor clearColor];
    self.pushLine.layer.borderWidth = 1.0;
    self.pushLine.layer.borderColor = [appDelegate myRGBfromHex:@"DEE2E6"].CGColor;
    self.pushLine.layer.cornerRadius = 5;
    
    [self.hideView2 setFrame:CGRectMake(self.pushLine.frame.origin.x, self.pushLine.frame.origin.y+self.pushLine.frame.size.height-5, self.pushLine.frame.size.width+5, 5)];
    self.hideView2.backgroundColor = [UIColor whiteColor];
    
    CGFloat mainWidth = [[UIScreen mainScreen]bounds].size.width;
    [self.bottomLine1 setFrame:CGRectMake(5, self.hideView2.frame.origin.y-1, self.pushLine.frame.origin.x-5, 1.0)];
    self.bottomLine1.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
    
    [self.bottomLine2 setFrame:CGRectMake(self.pushLine.frame.origin.x+self.pushLine.frame.size.width, self.hideView2.frame.origin.y-1, mainWidth-(self.hideView2.frame.origin.x+self.hideView2.frame.size.width), 1.0)];
    self.bottomLine2.backgroundColor = [appDelegate myRGBfromHex:@"DEE2E6"];
    
    [self.noticeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.pushBtn setTitleColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor] forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"알림";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    NSString *url;
    NSString *param;
    
    if (appDelegate.isAES256) {
        url = [NSString stringWithFormat:@"%@/getPushList2",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@&returnType=JSON&encType=AES256",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],appDelegate.moreCount];
    }else{
        url = [NSString stringWithFormat:@"%@/getPushList2",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&pno=%@&psize=%@returnType=JSON",appDelegate.app_no,appDelegate.user_no,[NSString stringWithFormat:@"%d",pPno],appDelegate.moreCount];
    }
    
    
    NSLog(@"push url : %@", url);
    NSLog(@"push param : %@", param);
    
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(urlConnection){
        receiveData = [[NSMutableData alloc] init];
        [SVProgressHUD show];
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)rightButtonClick{
    
    //    MFUserListViewController *userListViewController = [[MFUserListViewController alloc]init];
    //    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:userListViewController];
    //    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)deleteButtonClick{
    NSLog(@"%s", __func__);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"삭제" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCompleteClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    isPushDelete = YES;
    [self.tableView reloadData];
}

-(void)deleteCompleteClick{
    NSLog(@"%s", __func__);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    //NSLog(@"rowcheckDic2 : %@", self.rowCheckDictionary);
    
    if(self.checkArray.count>0){
        NSData* data = [NSJSONSerialization dataWithJSONObject:self.checkArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonData = [jsonData urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"jsonData : %@", jsonData);
        
        NSString* url = [NSString stringWithFormat:@"%@/deletePush",appDelegate.main_url];
        NSString* param = [[NSString alloc]initWithFormat:@"cuser_no=%@&delete_push_no=%@&returnType=JSON&encType=AES256",appDelegate.user_no,jsonData];
        
        NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:10.0];
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

-(void)cancelButtonClick{
    NSLog(@"%s", __func__);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"편집" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]];
    
    isPushDelete = NO;
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    self.checkArray = [NSMutableArray array];
    self.indexArray = [NSMutableArray array];
    [self.tableView reloadData];
    
}

- (void)_startConnection{
    NSLog(@"%s", __func__);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlString;
    NSString *param;
    
    NSString *devId = [MFinityAppDelegate getUUID];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (appDelegate.isAES256) {
        if (noticeViewFlag) {
            urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&devId=%@&psize=%@&pno=%@&returnType=JSON&encType=AES256",appDelegate.app_no,appDelegate.user_no,[prefs objectForKey:@"UUID"],appDelegate.moreCount,[NSString stringWithFormat:@"%d",nPno]];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&psize=%@&pno=%@&returnType=JSON&encType=AES256",appDelegate.app_no,appDelegate.user_no,appDelegate.moreCount,[NSString stringWithFormat:@"%d",pPno]];
        }
    }else{
        if (noticeViewFlag) {
            urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&devId=%@&psize=%@&pno=%@&returnType=JSON",appDelegate.app_no,appDelegate.user_no,[prefs objectForKey:@"UUID"],appDelegate.moreCount,[NSString stringWithFormat:@"%d",nPno]];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/getPushList2",appDelegate.main_url];
            param = [[NSString alloc]initWithFormat:@"app_no=%@&cuser_no=%@&devId=%@&psize=%@&pno=%@&returnType=JSON",appDelegate.app_no,appDelegate.user_no,[prefs objectForKey:@"UUID"],appDelegate.moreCount,[NSString stringWithFormat:@"%d",pPno]];
        }
    }
    NSLog(@"_startConnection urlString : %@",urlString);
    NSLog(@"_startConnection param : %@",param);
    
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(urlConnection){
        receiveData = [[NSMutableData alloc] init];
        [SVProgressHUD show];
        self.tableView.scrollEnabled = NO;
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
#pragma mark JSON Data Parsing
//JSON데이터를 해석하는 메소드
- (void)_fetchedData:(NSData *)responseData {
    NSLog(@"%s", __func__);
    [SVProgressHUD show];
    NSError *error;
    
    NSString *encString =[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *decString;
    if (appDelegate.isAES256) {
        decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
    }
    else{
        decString = encString;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[dic count]; i++) {
        NSDictionary *tempDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i]];
        [mdic setObject:[MFinityAppDelegate getAllValueUrlDecoding:tempDic] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    //NSLog(@"mdic : %@", mdic);
    
    NSString *v0 =[[mdic objectForKey:@"0"] objectForKey:@"V0"];
    [mdic removeObjectForKey:@"0"];
    
    //if(mdic.count==0) [self.tableView reloadData];
    
    if ([v0 isEqualToString:@"True"]) {
        if (noticeViewFlag) {
            if (nPno==0) {
                badgeList = [[NSMutableDictionary alloc]init];
                noticeList =[[NSMutableDictionary alloc]init];
                for (int i=1; i<[mdic count]+1; i++) {
                    [noticeList setObject:[mdic objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",i-1]];
                }
                NSLog(@"noticelist :%@", noticeList);
                
                @try{
                    for (int i=0; i<[noticeList count]; i++) {
                        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",i]];
                        [badgeList setObject:[dic objectForKey:@"BADGE"] forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                } @catch(NSException *e){
                    NSLog(@"11 notice execption : %@", e);
                    noticeViewFlag = YES;
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
                    NSLog(@"22 notice execption : %@", e);
                    noticeViewFlag = YES;
                    nPno = 0;
                    badgeList = [[NSMutableDictionary alloc]init];
                    noticeList =[[NSMutableDictionary alloc]init];
                    [self _startConnection];
                }
            }
            
        } else {
            if (pPno==0) {
                //pushList=[[NSMutableDictionary alloc]init];
                pushList=[[NSMutableArray alloc]init];
                @try{
                    for (int i=1; i<[mdic count]+1; i++) {
                        //[pushList setObject:[mdic objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",i-1]];
                        [pushList addObject:[mdic objectForKey:[NSString stringWithFormat:@"%d",i]]];
                        //NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%d",i-1]];
                        NSDictionary *dic = [pushList objectAtIndex:i-1];
                        NSString *pushNo = [dic objectForKey:@"V4"];
                        
                        NSLog(@"pushDic : %@",dic);
                        
                        self.rowCheckDictionary = [NSMutableDictionary dictionary];
                        [self.rowCheckDictionary setObject:@"N" forKey:pushNo];
                    }
                    //pushList = [[NSMutableDictionary alloc]initWithDictionary:mdic];
                }@catch(NSException *e){
                    NSLog(@"11 push execption : %@", e);
                    noticeViewFlag = NO;
                    //pushList=[[NSMutableDictionary alloc]init];
                    pushList=[[NSMutableArray alloc]init];
                    pPno = 0;
                    [self _startConnection];
                }
                
            }else{
                NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]initWithDictionary:mdic];
                for (int i=1; i<[dic2 count]+1; i++) {
                    //[pushList setValue:[dic2 objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",(pPno*30)+i-1]];
                    [pushList addObject:[dic2 objectForKey:[NSString stringWithFormat:@"%d",i]]];
                }
                
                //NSLog(@"pushList : %@", pushList);
                NSLog(@"pushlist count : %lu", (unsigned long)pushList.count);
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
        //self.tableView.scrollEnabled = YES;
        
        //PullRefreshTableView의 StopLoading 호출
        [self stopLoading];
        
    } else if ([v0 isEqualToString:@"False"]) {
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
    
    self.tableView.scrollEnabled = YES;
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
        return 70;
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
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NoticeCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[NoticeCell class]]) {
                cell = (NoticeCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    CGFloat mainWidth = [[UIScreen mainScreen]bounds].size.width;
    
    NSString *titleString;
    cell.titleLabel.tag = indexPath.row;
    cell.titleLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    int fontSize = 16;
    int fontSize2 = 12;
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
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    cell.dateLabel.font = [UIFont systemFontOfSize:fontSize2];
    cell.dateLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    
    cell.dateLabel.backgroundColor = [UIColor clearColor];
    cell.dateLabel.alpha = 0.6;
    
    
    NSDate *today = [NSDate date];
    cell.imgView.image = nil;
    cell.imgView.hidden = YES;
    
    if (noticeViewFlag) {
        cell.checkButton.hidden = YES;
        cell.selectButton.hidden = YES;
        cell.checkBtnWidthConstraint.constant = 0;
        
        cell.titleLabel.numberOfLines = 2;
        
        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
        titleString = [dic objectForKey:@"TITLE"];
        cell.titleLabel.text = titleString;
        
        cell.imgView.image = [UIImage imageNamed:@"notice_new.png"];
        
        NSString *dateText = [dic objectForKey:@"WRITE_DATE"];
        //NSLog(@"dateText : %@", dateText);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *tmp = [dateText substringToIndex:dateText.length-3];
        NSDate *regiDate = [formatter dateFromString:tmp];
        
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSCalendarUnitDay;
        NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:today options:0];//날짜 비교해서 차이값 추출
        NSInteger date = dateComp.day;
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
        formatter2.dateFormat = @"M월 dd일";
        NSString *prevDate = [formatter2 stringFromDate:regiDate];
        
        NSDateFormatter *formatter3 = [[NSDateFormatter alloc]init];
        formatter3.dateFormat = @"a HH:mm";
        NSString *currTime = [formatter3 stringFromDate:regiDate];
        
        NSString *dateStr = [[NSString alloc]init];
        if(date > 0){
            dateStr = prevDate;
        } else{
            dateStr = currTime;
        }
        //        NSRange range = [dateText rangeOfString:@" "];
        //        if (range.length>0) {
        //            dateText = [dateText stringByReplacingCharactersInRange:range withString:@"\n"];
        //        }
        cell.dateLabel.text = dateStr;
        
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
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonClick)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [cell addGestureRecognizer:longPress];
        
        cell.titleLabel.numberOfLines = 1;
        
        //NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        NSDictionary *dic = [pushList objectAtIndex:indexPath.row];
        
        titleString = [dic objectForKey:@"V2"];
        NSString *pushNo = [dic objectForKey:@"V4"];
        
        NSString *dateString = [dic objectForKey:@"V3"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *tmp = [dateString substringToIndex:dateString.length-3];
        NSDate *regiDate = [formatter dateFromString:tmp];
        
        
        NSInteger date = 0;
        if(![dateString isEqualToString:@""] && dateString!=nil){
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:today options:0];//날짜 비교해서 차이값 추출
            date = dateComp.day;
        }
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
        formatter2.dateFormat = @"M월 d일";
        NSString *prevDate = [formatter2 stringFromDate:regiDate];
        
        NSDateFormatter *formatter3 = [[NSDateFormatter alloc]init];
        formatter3.dateFormat = @"a HH:mm";
        NSString *currTime = [formatter3 stringFromDate:regiDate];
        
        NSString *dateStr = [[NSString alloc]init];
        if(date > 0){
            dateStr = prevDate;
        } else{
            dateStr = currTime;
        }
        //        NSRange range = [dateString rangeOfString:@" "];
        //        if (range.length>0) {
        //            dateString = [dateString stringByReplacingCharactersInRange:range withString:@"\n"];
        //        }
        
        if(isPushDelete){
            cell.checkButton.hidden = NO;
            cell.checkButton.backgroundColor = [UIColor clearColor];
            cell.checkBtnWidthConstraint.constant = 40;
            
            [cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.checkButton setTitle:@"" forState:UIControlStateNormal];
            //[cell.checkButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
            
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
        cell.dateLabel.text = dateStr;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGSize labelSize = [cell.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    //    if(labelSize.width < mainWidth) cell.titleWidthConstraint.constant = labelSize.width;
    //    else cell.titleWidthConstraint.constant = 200;
    
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
        
        NSString *url = [NSString stringWithFormat:@"%@/NoticeDetail.jsp?cuser_no=%@&app_no=%@&notice_no=%@",appDelegate.main_url, appDelegate.user_no,appDelegate.app_no,[dic objectForKey:@"NOTICE_NO"]];
        appDelegate.target_url = url;
        
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
            [request setTimeoutInterval:10.0];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            
            if(urlConnection){
                receiveData = [[NSMutableData alloc] init];
            }else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
        }else{
            //WebPageView를 호출
//            WebViewController *vc = [[WebViewController alloc] init];
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }else{
        if(!isPushDelete){
            //NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            NSDictionary *dic = [pushList objectAtIndex:indexPath.row];
            NSLog(@"dic : %@", dic);
            
            deletePushNo = [dic objectForKey:@"V4"];
            deleteIdx = indexPath.row;
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dic objectForKey:@"V3"] message:[dic objectForKey:@"V2"] delegate:self cancelButtonTitle:NSLocalizedString(@"message84", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
            alertView.tag = 1;
            [alertView show];
            
        }
    }
}

-(void)checkAction:(UIButton *)sender{
    UIButton *button = sender;
    NSInteger buttonTag = button.tag;
    
    //NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%ld",(long)buttonTag]];
    NSDictionary *dic = [pushList objectAtIndex:buttonTag];
    NSString *pushNo = [dic objectForKey:@"V4"];
    
    NSString *checked = [self.rowCheckDictionary objectForKey:pushNo];
    if([checked isEqualToString:@"Y"]){
        [self.rowCheckDictionary setObject:@"N" forKey:pushNo];
        [self.checkArray removeObject:pushNo];
        [self.indexArray removeObject:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
        
    } else {
        [self.rowCheckDictionary setObject:@"Y" forKey:pushNo];
        [self.checkArray addObject:pushNo];
        [self.indexArray addObject:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:buttonTag inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}

#pragma mark
#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
    
    self.tableView.scrollEnabled = NO;
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
        
        self.tableView.scrollEnabled = NO;
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
        
        //if seed
        //NSData *data = [MFinityAppDelegate getDecodeData:responseData];
        
        //if AES256
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        @try {
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            //dic = [NSJSONSerialization JSONObjectWithData:receiveData options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        [SVProgressHUD dismiss];
        if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
            //WebPageView를 호출
//            WebViewController *vc = [[WebViewController alloc] init];
            WKWebViewController *vc = [[WKWebViewController alloc] init];
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
            
            isDMS = [[dic objectForKey:@"V16"] isEqualToString:@"Y"];
            isTabBar = [[dic objectForKey:@"V17"] isEqualToString:@"Y"];
            
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
        
    } else if([[methodNames objectAtIndex:0] isEqualToString:@"deletePush"]){
        NSDictionary *dic;
        NSError *error;
        
        //if AES256
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        @try {
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        
        if ([[dic objectForKey:@"V0"] isEqualToString:@"True"]) {
            isPushDelete = NO;
            noticeViewFlag = NO;
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            NSInteger count = self.indexArray.count;
            
            @try{
                for(int i=0; i<count; i++){
                    [indexPaths addObject:[NSIndexPath indexPathForRow:[[self.indexArray objectAtIndex:i] intValue] inSection:0]];
                    [pushList removeObjectAtIndex:[[self.indexArray objectAtIndex:i] intValue]];
                }
                
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                
                self.rowCheckDictionary = [NSMutableDictionary dictionary];
                self.checkArray = [NSMutableArray array];
                self.indexArray = [NSMutableArray array];
                
                [_tableView reloadData];
                
                
            } @catch(NSException *e){
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
    //[_tableView reloadData];
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
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
            if(noticeViewFlag) ++nPno;
            else ++pPno;
            [SVProgressHUD showWithStatus:@"Loading"];
            [self _startConnection];
        }
    }
    
    //        if (scrollView.contentSize.height-scrollView.contentOffset.y<320) {
    //
    //            CGPoint offset = scrollView.contentOffset;
    //            CGRect bounds = scrollView.bounds;
    //            CGSize size = scrollView.contentSize;
    //            UIEdgeInsets inset = scrollView.contentInset;
    //            float y = offset.y + bounds.size.height - inset.bottom;
    //            float h = size.height;
    //
    //            float reload_distance = 10;
    //
    //
    //
    //            if(y > h + reload_distance) {
    //                ++pPno;
    //                [SVProgressHUD showWithStatus:@"Loading"];
    //                [self performSelector:@selector(_startConnection)];
    //            }
    //        }
    
    //}
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //NSLog(@"scrollOffsetY : %f",scrollOffsetY);
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
    /*
     if (scrollView.contentSize.height-scrollView.contentOffset.y<320) {
     if (!noticeViewFlag && pno< 2) {
     
     }
     CGPoint offset = scrollView.contentOffset;
     CGRect bounds = scrollView.bounds;
     CGSize size = scrollView.contentSize;
     UIEdgeInsets inset = scrollView.contentInset;
     float y = offset.y + bounds.size.height - inset.bottom;
     float h = size.height;
     
     float reload_distance = 10;
     
     NSLog(@"scrollView.contentSize.height : %f",scrollView.contentSize.height);
     NSLog(@"scrollView.contentOffset.y : %f",scrollView.contentOffset.y);
     if(y > h + reload_distance) {
     ++pno;
     [self performSelector:@selector(_startConnection)];
     }
     }
     */
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
        exit(0);
    }
    
    if(alertView.tag == 1 && buttonIndex == 0){
        [self.rowCheckDictionary setObject:@"Y" forKey:deletePushNo];
        [self.checkArray addObject:deletePushNo];
        [self.indexArray addObject:[NSString stringWithFormat:@"%ld", (long)deleteIdx]];
        [self deleteCompleteClick];
        
    }
}

@end
