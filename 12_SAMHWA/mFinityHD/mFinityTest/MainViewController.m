//
//  MainViewController.m
//  mFinityHD
//
//  Created by Park on 2014. 5. 27..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
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
#import "LoginViewController.h"

#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 570
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MainViewController (){
    BOOL _isLogin;
    BOOL backFlag;
    int width;
    BOOL goLoginView;
}

@end

@implementation MainViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.navigationItem setTitle: title_name];
    menuArray = [[NSMutableArray alloc]init];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
    self.navigationItem.backBarButtonItem = left;
    
    goLoginView = NO;
    
    if (appDelegate.isOffLine) {
        myTableView.rowHeight = 50;
    }else{
        myTableView = nil;
    }
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]} forState:UIControlStateNormal];
    NSLog(@"viewDidLoad end");
}
/*
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    //아이콘 넓이
    int ICON_WIDTH = 75;
    //아이콘 높이
    int ICON_HEIGHT = 75;
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    //메뉴이름 넓이
    int TITLE_WIDTH = 68;
    //메뉴이름 높이
    int TITLE_HEIGHT = 50;
    //메뉴이름 그리기 시작좌표
    int TITLE_START_HORIZONTAL = 0;
    int TITLE_START_VERTICAL = 0;
    //메뉴이름 그리기 증가좌표
    int TITLE_INCRESE_HORIZONTAL = 0;
    int TITLE_INCRESE_VERTICAL = 0;
    int curPage = 0;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.bgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"bg.png"];
        }
        imageView.image = bgImage;
        width = 768;
        pageControl.center = CGPointMake(381, 878);
        mainScrollView.frame = CGRectMake(0, 20, 773, 748);
        
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        NSLog(@"세로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);
        
        if (colCount == 5) {
            ICON_START_HORIZONTAL = 96;
            ICON_START_VERTICAL = 100; //100;
            ICON_INCRESE_HORIZONTAL = 125;
            ICON_INCRESE_VERTICAL = 155;
            TITLE_START_HORIZONTAL = 98;//-4
            TITLE_START_VERTICAL = 175; //160;
            TITLE_INCRESE_HORIZONTAL = 125;
            TITLE_INCRESE_VERTICAL = 155;
            pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        } else if (colCount == 4) {
            NSLog(@"colcount4");
            ICON_START_HORIZONTAL = 86;
            ICON_START_VERTICAL = 100; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 155;
            TITLE_START_HORIZONTAL = 89;
            TITLE_START_VERTICAL = 175; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 155;
            pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
            NSLog(@"");
        }
        //아이콘 현재좌표
        int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
        int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
        //메뉴이름 현재좌표
        int TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL;
        int TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
        for(int i=0; i<[menuArray count]; i++){
            //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
            if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * curPage;             //768
                TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
            }
            UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
            UILabel *uiLabel = (UILabel *)[self.view viewWithTag:200+i];
            if (colCount ==4) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( i > 0 && i % 16 == 0) {                                            //16
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 ); //768
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
            }else if (colCount==5) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( i > 0 && i % 20 == 0) {
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 );
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
            }
            [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            [uiLabel setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            //관련좌표 다시 계산
            ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            TITLE_CURRENT_HORIZONTAL += TITLE_INCRESE_HORIZONTAL;
        }
    }
    else{
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"bg_none_1024.png"];
        }
        
        imageView.image = lBgImage;
        width = 1024;
        pageControl.center = CGPointMake(510, 602);
        mainScrollView.frame = CGRectMake(0, 6,1024, 700);
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        NSLog(@"가로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);
        if (colCount == 5) {
            ICON_START_HORIZONTAL = 130;
            ICON_START_VERTICAL = 40; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 135;
            TITLE_START_HORIZONTAL = 134;
            TITLE_START_VERTICAL = 115; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 135;
            pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        } else if (colCount == 4) {
            ICON_START_HORIZONTAL = 220;
            ICON_START_VERTICAL = 40; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 135;
            TITLE_START_HORIZONTAL = 224;
            TITLE_START_VERTICAL = 115; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 135;
            pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
        }
        //아이콘 현재좌표
        int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
        int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
        //메뉴이름 현재좌표
        int TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL;
        int TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
        
        for(int i=0; i<[menuArray count]; i++){
            UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
            UILabel *uiLabel = (UILabel *)[self.view viewWithTag:200+i];
            if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * curPage;             //768
                TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
            }
            if (colCount==4) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( i > 0 && i % 16 == 0) {                                            //16
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 ); //768
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
                
            }else if (colCount==5) {
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if ( i > 0 && i % 20 == 0) {
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                    ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                    TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 );
                    TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                    
                    curPage += 1;
                }
            }
            [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            [uiLabel setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            //관련좌표 다시 계산
            ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            TITLE_CURRENT_HORIZONTAL += TITLE_INCRESE_HORIZONTAL;
        }
        
    }
    NSLog(@"curPage : %d",pageControl.currentPage);
    CGRect frame = mainScrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    NSLog(@"frame.origin.x : %f",frame.origin.x);
    [mainScrollView scrollRectToVisible:frame animated:YES];
    
}
*/
- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    NSLog(@"viewWillAppear");
    //아이콘 넓이
    int ICON_WIDTH = 120;
    //아이콘 높이
    int ICON_HEIGHT = 120;
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    int curPage = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"appDelegate.lBgImagePath : %@",[manager isReadableFileAtPath:appDelegate.lBgImagePath]?@"YES":@"NO");
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.bgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        @try{
            if (bgImage==nil) {
                bgImage = [UIImage imageNamed:@"default1.png"];
            }
            imageView.image = bgImage;
            width = 768;
            pageControl.center = CGPointMake(381, 878);
            mainScrollView.frame = CGRectMake(0, 20, 773, 850);
            
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 25 + 1), mainScrollView.frame.size.height);
            NSLog(@"세로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);
            
            if (colCount == 5) {
                ICON_START_HORIZONTAL = 20; //96
                ICON_START_VERTICAL = 50; //100
                ICON_INCRESE_HORIZONTAL = 135; //125
                ICON_INCRESE_VERTICAL = 155; //155
                
                pageControl.numberOfPages = ([menuArray count] - 1) / 25 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 25 + 1), mainScrollView.frame.size.height);
                
            } else if (colCount == 4) {
                NSLog(@"colcount4");
                ICON_START_HORIZONTAL = 70;
                ICON_START_VERTICAL = 50; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 155;
                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
                NSLog(@"");
            }
            //아이콘 현재좌표
            int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
            int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
            for(int i=0; i<[menuArray count]; i++){
                //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
                if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                    ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                }
                UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
                UILabel *uiLabel = (UILabel *)[self.view viewWithTag:200+i];
                uiButton.hidden = NO;
                uiLabel.hidden = NO;
                if (colCount ==4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }else if (colCount==5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 25 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }
                [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
                //관련좌표 다시 계산
                ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            }
            
        } @catch(NSException *e){
//            [appDelegate loginErrorToLogFile:@"Main1" :e];
        }
    }
    else{
        @try{
            if (lBgImage==nil) {
                lBgImage = [UIImage imageNamed:@"w_default1.png"];
            }
            
            imageView.image = lBgImage;
            width = 1024;
            pageControl.center = CGPointMake(510, 602);
            mainScrollView.frame = CGRectMake(0, 6,1024, 700);
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
            NSLog(@"가로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);
            if (colCount == 5) {
                ICON_START_HORIZONTAL = 120; //130
                ICON_START_VERTICAL = 40; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 135;
                pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
            } else if (colCount == 4) {
                ICON_START_HORIZONTAL = 220;
                ICON_START_VERTICAL = 40; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 135;
                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
            }
            //아이콘 현재좌표
            int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
            int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
            
            for(int i=0; i<[menuArray count]; i++){
                UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
                UILabel *uiLabel = (UILabel *)[self.view viewWithTag:200+i];
                uiButton.hidden = NO;
                uiLabel.hidden = NO;
                if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                    ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                }
                if (colCount==4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                    
                }else if (colCount==5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 20 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }
                [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
                //관련좌표 다시 계산
                ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            }
        } @catch(NSException *e){
//            [appDelegate loginErrorToLogFile:@"Main2" :e];
        }
    }
    
    CGRect frame = mainScrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    [mainScrollView scrollRectToVisible:frame animated:YES];
    
    if (!isDrawMenu) {
        @try{
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
            
            if(appDelegate.app_ci==nil){
                self.navigationItem.titleView = label;
            }else{
                NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.app_ci]];
                UIImage *logoImage = [UIImage imageWithData:logoData];
                UIImageView *logo = [[UIImageView alloc]initWithImage:[self imageByScalingAndCroppingForSize:CGSizeMake(90, 30) :logoImage]];
                [logo setFrame:CGRectMake(0, 0, 90, 30)];
                self.navigationItem.titleView = logo;
                
            }
            
            if (appDelegate.isOffLine) {
                NSLog(@"isOffLine yes");
                NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
                UIImage *bgImage = [UIImage imageWithData:decryptData];
                imageView.image = bgImage;
                NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                save = [save stringByAppendingFormat:@"/getOffLineMenuList"];
                
                NSData *data = [NSData dataWithContentsOfFile:save];
                myTableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
                //if nomal
                [self parserJsonData:data];
                pageControl.hidden = YES;
                
            }else{
                NSString *paramStr;
                NSString *urlString;
                if (appDelegate.isAES256) {
                    
                    if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                        paramStr = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=T&cuser_no=%@&returnType=JSON&encType=AES256",appDelegate.root_menu_no,appDelegate.user_no];
                    }else{
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                        paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=T&returnType=JSON&encType=AES256",appDelegate.user_no, appDelegate.root_menu_no];
                    }
                }else{
                    if ([appDelegate.demo isEqualToString:@"DEMO"]) {
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezPubMenu2",appDelegate.main_url];
                        paramStr = [[NSString alloc]initWithFormat:@"up_menu_no=%@&devOs=I&devTy=T&cuser_no=%@&returnType=JSON",appDelegate.root_menu_no,appDelegate.user_no];
                        
                        
                    }else{
                        urlString = [[NSString alloc] initWithFormat:@"%@/ezMainMenu2",appDelegate.main_url];
                        paramStr = [[NSString alloc]initWithFormat:@"usrNo=%@&rootMenuNo=%@&devOs=I&devTy=T&returnType=JSON",appDelegate.user_no, appDelegate.root_menu_no];
                    }
                }

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
                
                NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody: postData];
                [request setTimeoutInterval:10.0];
                NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                if(urlCon){
                    [SVProgressHUD show];
                    receiveData = [[NSMutableData alloc]init];
                }else {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                }
                [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
            }
            
        } @catch(NSException *e){
//            [appDelegate loginErrorToLogFile:@"Main3" :e];
        }
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    for(int i=0; i<[menuArray count]; i++){
        UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
        UILabel *uiLabel = (UILabel *)[self.view viewWithTag:200+i];
        uiButton.hidden = YES;
        uiLabel.hidden = YES;
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.bgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    
    if (appDelegate.isOffLine) {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ){
            if (bgImage==nil) {
                bgImage = [UIImage imageNamed:@"default1.png"];
            }
            imageView.image = bgImage;

            myTableView.frame = CGRectMake(0, 20, 773, 748);
        }else{
            if (lBgImage==nil) {
                lBgImage = [UIImage imageNamed:@"w_default1.png"];
            }
            imageView.image = lBgImage;
            
            myTableView.frame =  CGRectMake(0, 64, 1024, 600);
        }
        for (int index=0; index < [menuArray count]; index++) {
            UIButton *button = (UIButton *)[self.view viewWithTag:index+300];
            NSLog(@"button 1: %@",button);
            if ((toInterfaceOrientation==UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation==UIDeviceOrientationLandscapeRight)) {
                button.frame = CGRectMake(250, 50, 520, 70);
            } else {
                button.frame = CGRectMake(123, 50, 520, 70);
            }
            NSLog(@"button 2: %@",button);
        }
        [myTableView reloadData];
    }else{
        //아이콘 넓이
        int ICON_WIDTH = 120;
        //아이콘 높이
        int ICON_HEIGHT = 120;
        //아이콘 그리기 시작좌표
        int ICON_START_HORIZONTAL = 0;
        int ICON_START_VERTICAL = 0;
        //아이콘 그리기 증가좌표
        int ICON_INCRESE_HORIZONTAL = 0;
        int ICON_INCRESE_VERTICAL = 0;
        
        int curPage = 0;
        
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
            if (bgImage==nil) {
                bgImage = [UIImage imageNamed:@"default1.png"];
            }
            imageView.image = bgImage;
            width = 768;
            pageControl.center = CGPointMake(381, 878);
            mainScrollView.frame = CGRectMake(0, 20, 773, 850);

            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 25 + 1), mainScrollView.frame.size.height);
            NSLog(@"세로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);

            if (colCount == 5) {
                ICON_START_HORIZONTAL = 20; //96
                ICON_START_VERTICAL = 50; //100
                ICON_INCRESE_HORIZONTAL = 135; //125
                ICON_INCRESE_VERTICAL = 155; //155
               
                pageControl.numberOfPages = ([menuArray count] - 1) / 25 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 25 + 1), mainScrollView.frame.size.height);
            } else if (colCount == 4) {
                NSLog(@"colcount4");
                ICON_START_HORIZONTAL = 70;
                ICON_START_VERTICAL = 50; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 155;
                
                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
                NSLog(@"");
            }
            //아이콘 현재좌표
            int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
            int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
            
            for(int i=0; i<[menuArray count]; i++){
                //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
                if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                    ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                }
                UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
                if (colCount ==4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }else if (colCount==5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 25 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }
                [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
                //관련좌표 다시 계산
                ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            }
        }
        else{
            if (lBgImage==nil) {
                lBgImage = [UIImage imageNamed:@"w_default1.png"];
            }

            imageView.image = lBgImage;
            width = 1024;
            pageControl.center = CGPointMake(510, 602);
            mainScrollView.frame = CGRectMake(0, 6,1024, 700);
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
            NSLog(@"가로 mainScrollView.contentSize : %f",mainScrollView.contentSize.width);
            if (colCount == 5) {
                ICON_START_HORIZONTAL = 120; //130
                ICON_START_VERTICAL = 40; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 135;
                pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
            } else if (colCount == 4) {
                ICON_START_HORIZONTAL = 220;
                ICON_START_VERTICAL = 40; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 135;
                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
            }
            //아이콘 현재좌표
            int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
            int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
            
            for(int i=0; i<[menuArray count]; i++){
                UIButton *uiButton = (UIButton *)[self.view viewWithTag:100+i];
                if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                    ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                }
                if (colCount==4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                    
                }else if (colCount==5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( i > 0 && i % 20 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }
                [uiButton setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
                //관련좌표 다시 계산
                ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            }
            
        }
        NSLog(@"curPage : %d",curPage);
        CGRect frame = mainScrollView.frame;
        frame.origin.x = frame.size.width * pageControl.currentPage;
        frame.origin.y = 0;
        [mainScrollView scrollRectToVisible:frame animated:YES];
    }
    
}
#pragma mark
#pragma mark URLConnection
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    if(progressAlert.isVisible){
        [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"error : %@",error);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alert show];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    if ([methodName isEqualToString:@"MLogout"]) {
        [SVProgressHUD dismiss];
        if(goLoginView){
            //로그인화면으로 이동
            LoginViewController *lc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            lc.modalPresentationStyle = UIModalPresentationFullScreen;
            lc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [appDelegate.window setRootViewController:lc];
            
        } else{
            exit(0);
        }
        
    }else{
        if(statusCode == 404 || statusCode == 500){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            [connection cancel];
            [SVProgressHUD dismiss];
            if(progressAlert.isVisible){
                [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
            }
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
        
        NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[fileData length]];
        NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [totalFileSize floatValue] )];
        
        progressView.progress = [progress floatValue];
        
        const unsigned int bytes = 1024 * 1024;
        UILabel *alertLabel = (UILabel *)[progressAlert viewWithTag:1];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setPositiveFormat:@"##0.00"];
        NSNumber *partial = [NSNumber numberWithFloat:([resourceLength floatValue] / bytes)];
        NSNumber *total = [NSNumber numberWithFloat:([totalFileSize floatValue] / bytes)];
        
        alertLabel.text = [NSString stringWithFormat:@"%@ MB of %@ MB", [formatter stringFromNumber:partial], [formatter stringFromNumber:total]];
        
        
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [SVProgressHUD show];
                    goLoginView = YES;
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
                    [request setHTTPMethod:@"POST"];
                    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                    [conn start];
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
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
#pragma mark Data Parsing
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
        NSLog(@"dic : %@",dic);
        // if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    NSLog(@"");
    for (int i=0; i<[dic count]; i++) {
        [tempArr addObject:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
    }
    
    for (NSDictionary *menuDic in tempArr) {
        [menuArray addObject: [MFinityAppDelegate getAllValueUrlDecoding:menuDic]];
    }
    if ([menuArray count]>1) {
        @try{
            //NSLog(@"v0 : %@",[[menuArray objectAtIndex:0]objectForKey:@"V0"]);
            if ([[[menuArray objectAtIndex:0]objectForKey:@"V0"] isEqualToString:@"False"]) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [SVProgressHUD show];
                    goLoginView = YES;
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
                    [request setHTTPMethod:@"POST"];
                    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                    [conn start];
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            }else {
                colCount = [[[menuArray objectAtIndex:1]objectForKey:@"V8"] intValue];
                
                if ([[[menuArray objectAtIndex:1]objectForKey:@"V8_1"]isEqualToString:@"#"] ) {
                    mainScrollView.hidden = YES;
                    myTableView.hidden = NO;
                    [menuArray removeObjectAtIndex:0];
                    [myTableView reloadData];
                }else{
                    if ([appDelegate.mainType isEqualToString:@"1"]) {
                        [menuArray removeObjectAtIndex:0];
                        [self menuSetting];
                    }else if([appDelegate.mainType isEqualToString:@"2"]){
                        [menuArray removeObjectAtIndex:0];
    //                    [self coverFlowSetting];
                        pageControl.hidden=YES;
                    }else if([appDelegate.mainType isEqualToString:@"3"]){
                        [menuArray removeObjectAtIndex:0];
                        [self tileMenuSetting];
    //                    [self tileMenuSetting2];
                    }
                }
            }
            
        } @catch(NSException *e){
//            [appDelegate loginErrorToLogFile:@"call setting" :e];
        }
        
    }else{
        [SVProgressHUD dismiss];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message64", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
        [alertView show];
    }
    
    isDrawMenu = YES;
}
#pragma mark
#pragma mark Action Event Handler
-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *menuNo = [userInfo objectForKey:@"menuNo"];
    NSString *pushNo = [userInfo objectForKey:@"pushNo"];
    NSString *devNo = [userInfo objectForKey:@"devNo"];
    [self getExecuteMenuInfo:menuNo pushNo:pushNo devNo:devNo];
    
}
-(void)getExecuteMenuInfo:(NSString *)menuNo pushNo:(NSString *)pushNo devNo:(NSString *)devNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    NSString *_paramString = [NSString stringWithFormat:@"menuNo=%@&cuserNo=%@&pushNo=%@&devNo=%@&encType=AES256",menuNo,appDelegate.user_no,pushNo,devNo];
    NSLog(@"getExecuteMenuInfo url : %@", url);
    NSLog(@"getExecuteMenuInfo param : %@", _paramString);
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
#pragma mark
#pragma mark Menu Handle
-(void) tileMenuSetting {
    //아이콘 넓이
    int ICON_WIDTH = 120; //75
    //아이콘 높이
    int ICON_HEIGHT = 120; //75
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    @try{
        if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation == UIDeviceOrientationLandscapeRight)) {
            NSLog(@"가로");
            if (colCount == 5) {
                ICON_START_HORIZONTAL = 120; //130
                ICON_START_VERTICAL = 40; //40;
                ICON_INCRESE_HORIZONTAL = 170; //170
                ICON_INCRESE_VERTICAL = 135; //135
                
                pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
            } else if (colCount == 4) {
                ICON_START_HORIZONTAL = 220;
                ICON_START_VERTICAL = 40; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 135;

                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
            }
            
        }else {
            NSLog(@"세로");
            //아이콘 가로배열 갯수에 따라 초기변수값 지정
            if (colCount == 5) {
                ICON_START_HORIZONTAL = 20; //96
                ICON_START_VERTICAL = 50; //100
                ICON_INCRESE_HORIZONTAL = 149; //125
                ICON_INCRESE_VERTICAL = 155; //155

                pageControl.numberOfPages = ([menuArray count] - 1) / 25 + 1;
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 25 + 1), mainScrollView.frame.size.height);
            } else if (colCount == 4) {
                NSLog(@"colcount4");
                ICON_START_HORIZONTAL = 70;
                ICON_START_VERTICAL = 50; //100;
                ICON_INCRESE_HORIZONTAL = 170;
                ICON_INCRESE_VERTICAL = 155;

                pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
                
                mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
                NSLog(@"");
            }
            NSLog(@"end1");
        }
        
        
        //아이콘 현재좌표
        int ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL;
        int ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;

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
        NSLog(@"그리기 전");
        //그리기시작
        NSString *_menuType = [[menuArray objectAtIndex:0]objectForKey:@"V7"];
        NSLog(@"그리기 시작");
        NSLog(@"menuType : %@",_menuType);
        for (int index = 0; index < [menuArray count]; index++) {
            
            if ([_menuType isEqualToString:@"E"]) {
                //관리메뉴일때 (아이콘을 그리지않고 메뉴경로만 얻는다)
                //EzSmartAppDelegate *appDelegate = (EzSmartAppDelegate *)[[UIApplication sharedApplication] delegate];
            }
            
            //실행메뉴 또는 하위메뉴가 있는 중간메뉴일때
            if (([_menuType isEqualToString:@"P"]) || ([_menuType isEqualToString:@"M"])) {
                
                
                //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
                if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                    ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                    ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                }
                if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation == UIDeviceOrientationLandscapeRight)){
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if (colCount == 4) {
                        //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                        if ( index > 0 && index % 16 == 0) {                                            //16
                            ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                            ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                            
                            curPage += 1;
                        }
                    }else if (colCount == 5) {
                        //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                        if ( index > 0 && index % 20 == 0) {
                            ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                            ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                            
                            curPage += 1;
                        }
                    }
                }else{
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if (colCount == 4) {
                        //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                        if ( index > 0 && index % 16 == 0) {                                            //16
                            ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                            ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                            
                            curPage += 1;
                        }
                    }else if (colCount == 5) {
                        //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                        if ( index > 0 && index % 25 == 0) {
                            ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                            ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                            
                            curPage += 1;
                        }
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
                btnIcon.tag = index+100;
                [btnIcon setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
                
                
                
                //아이콘 추가
                [mainScrollView addSubview:btnIcon];
                //[btnIcon addTarget:self action:@selector(buttonTouched3:) forControlEvents:UIControlEventTouchDragExit];
                //[btnIcon addTarget:self action:@selector(buttonTouched2:) forControlEvents:UIControlEventTouchDown];
                [btnIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
                //관련좌표 다시 계산
                ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
                
                
            }
        }
        [SVProgressHUD dismiss];
        
        if (appDelegate.receivePush) {
            [self getExecuteMenuInfo:appDelegate.receiveMenuNo pushNo:appDelegate.receivePushNo devNo:appDelegate.receiveDevNo];
            appDelegate.receivePush = NO;
        }
        /*
         NSString *loginSessionUrl = [NSString stringWithFormat:@"%@/getBadgeCount?MODE=isLogin",appDelegate.main_url];
         NSURL *url = [NSURL URLWithString:loginSessionUrl];
         NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
         NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
         */
        //isDrawMenu = YES;
        
    } @catch(NSException *e){
//        [appDelegate loginErrorToLogFile:@"Tile" :e];
    }
}
-(void) menuSetting {
    //아이콘 넓이
    int ICON_WIDTH = 75;
    //아이콘 높이
    int ICON_HEIGHT = 75;
    //아이콘 그리기 시작좌표
    int ICON_START_HORIZONTAL = 0;
    int ICON_START_VERTICAL = 0;
    //아이콘 그리기 증가좌표
    int ICON_INCRESE_HORIZONTAL = 0;
    int ICON_INCRESE_VERTICAL = 0;
    //메뉴이름 넓이
    int TITLE_WIDTH = 68;
    //메뉴이름 높이
    int TITLE_HEIGHT = 50;
    //메뉴이름 그리기 시작좌표
    int TITLE_START_HORIZONTAL = 0;
    int TITLE_START_VERTICAL = 0;
    //메뉴이름 그리기 증가좌표
    int TITLE_INCRESE_HORIZONTAL = 0;
    int TITLE_INCRESE_VERTICAL = 0;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        NSLog(@"가로");
        if (colCount == 5) {
            ICON_START_HORIZONTAL = 130;
            ICON_START_VERTICAL = 40; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 135;
            TITLE_START_HORIZONTAL = 134;
            TITLE_START_VERTICAL = 115; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 135;
            pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        } else if (colCount == 4) {
            ICON_START_HORIZONTAL = 220;
            ICON_START_VERTICAL = 40; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 135;
            TITLE_START_HORIZONTAL = 224;
            TITLE_START_VERTICAL = 115; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 135;
            pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
        }
        
    }else {
        NSLog(@"세로");
        //아이콘 가로배열 갯수에 따라 초기변수값 지정
        if (colCount == 5) {
            ICON_START_HORIZONTAL = 96;
            ICON_START_VERTICAL = 100; //100;
            ICON_INCRESE_HORIZONTAL = 125;
            ICON_INCRESE_VERTICAL = 155;
            TITLE_START_HORIZONTAL = 98;//-4
            TITLE_START_VERTICAL = 175; //160;
            TITLE_INCRESE_HORIZONTAL = 125;
            TITLE_INCRESE_VERTICAL = 155;
            pageControl.numberOfPages = ([menuArray count] - 1) / 20 + 1;
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 20 + 1), mainScrollView.frame.size.height);
        } else if (colCount == 4) {
            NSLog(@"colcount4");
            ICON_START_HORIZONTAL = 86;
            ICON_START_VERTICAL = 100; //100;
            ICON_INCRESE_HORIZONTAL = 170;
            ICON_INCRESE_VERTICAL = 155;
            TITLE_START_HORIZONTAL = 89;
            TITLE_START_VERTICAL = 175; //160;
            TITLE_INCRESE_HORIZONTAL = 170;
            TITLE_INCRESE_VERTICAL = 155;
            pageControl.numberOfPages = ([menuArray count] - 1) / 16 + 1;
            
            mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * (([menuArray count] - 1) / 16 + 1), mainScrollView.frame.size.height);
            NSLog(@"");
        }
        NSLog(@"end1");
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
    NSLog(@"그리기 전");
    //그리기시작
    NSString *_menuType = [[menuArray objectAtIndex:0]objectForKey:@"V7"];
    NSLog(@"그리기 시작");
    NSLog(@"menuType : %@",_menuType);
    for (int index = 0; index < [menuArray count]; index++) {
        
        if ([_menuType isEqualToString:@"E"]) {
            //관리메뉴일때 (아이콘을 그리지않고 메뉴경로만 얻는다)
            //EzSmartAppDelegate *appDelegate = (EzSmartAppDelegate *)[[UIApplication sharedApplication] delegate];
        }
        
        //실행메뉴 또는 하위메뉴가 있는 중간메뉴일때
        if (([_menuType isEqualToString:@"P"]) || ([_menuType isEqualToString:@"M"])) {
            
            
            //아이콘배치할 위치가 가로폭을 넘어가면 가로좌표를 초기화하고 세로좌표를 올림.
            if (ICON_CURRENT_HORIZONTAL + ICON_INCRESE_HORIZONTAL > width * ( curPage + 1 )) {   //768
                ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * curPage;               //768
                ICON_CURRENT_VERTICAL += ICON_INCRESE_VERTICAL;
                TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * curPage;             //768
                TITLE_CURRENT_VERTICAL += TITLE_INCRESE_VERTICAL;
            }
            if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation == UIDeviceOrientationLandscapeRight)){
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if (colCount == 4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( index > 0 && index % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 ); //768
                        TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }else if (colCount == 5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( index > 0 && index % 20 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 );
                        TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }
            }else{
                //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                if (colCount == 4) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( index > 0 && index % 16 == 0) {                                            //16
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );   //768
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 ); //768
                        TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                        
                        curPage += 1;
                    }
                }else if (colCount == 5) {
                    //아이콘배치할 위치가 페이지를 넘어가게되면 페이지를 증가시키고 가로세로 모두 초기화
                    if ( index > 0 && index % 20 == 0) {
                        ICON_CURRENT_HORIZONTAL = ICON_START_HORIZONTAL + width * ( curPage + 1 );
                        ICON_CURRENT_VERTICAL = ICON_START_VERTICAL;
                        TITLE_CURRENT_HORIZONTAL = TITLE_START_HORIZONTAL + width * ( curPage + 1 );
                        TITLE_CURRENT_VERTICAL = TITLE_START_VERTICAL;
                        
                        curPage += 1;
                    }
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
            btnIcon.tag = index+100;
            [btnIcon setFrame:CGRectMake(ICON_CURRENT_HORIZONTAL, ICON_CURRENT_VERTICAL, ICON_WIDTH, ICON_HEIGHT)];
            
            
            //메뉴이름텍스트 생성
            
            //텍스트 속성 지정
            NSString *titleText = [[menuArray objectAtIndex:index] objectForKey:@"V4"];
            NSRange range = [titleText rangeOfString:@" "];
            if (range.length>0) {
                titleText = [titleText stringByReplacingCharactersInRange:range withString:@"\n"];
            }
            
            
            UIColor *color = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
            
            UILabel *label = [[UILabel alloc]init];
            label.tag = 200+index;
            //titleText = [titleText stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
            label.text= titleText;
            label.textColor = color;
            label.numberOfLines = 0;
            if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                label.shadowOffset = CGSizeMake(2.0f, 2.0f);
            }
            label.font = [UIFont boldSystemFontOfSize:13];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            
            //label.lineBreakMode = NSLineBreakByCharWrapping;
            
            ////NSLog(@"titleText.length = %d",titleText.length);
            //CGSize textSize = [[label text] sizeWithFont:[label font]];
            NSDictionary *attributes = @{NSFontAttributeName: [label font]};
            CGSize textSize = [[label text] sizeWithAttributes:attributes];
            CGFloat strikeWidth = textSize.width;
            
            if (strikeWidth > 68.0f) {
                //label.numberOfLines=2;
                TITLE_HEIGHT = 30;
            }else{
                TITLE_HEIGHT = 15;
            }
            
            [label setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            [label setLineBreakMode:NSLineBreakByWordWrapping];

            [label sizeToFit];
            //[label setFrame:CGRectMake(TITLE_CURRENT_HORIZONTAL, TITLE_CURRENT_VERTICAL, TITLE_WIDTH, TITLE_HEIGHT)];
            CGPoint p = CGPointMake(btnIcon.center.x, label.center.y);
            [label setCenter:p];
            
            //텍스트 추가
            //아이콘 추가
            [mainScrollView addSubview:btnIcon];
            [mainScrollView addSubview:label];
            //[btnIcon addTarget:self action:@selector(buttonTouched3:) forControlEvents:UIControlEventTouchDragExit];
            //[btnIcon addTarget:self action:@selector(buttonTouched2:) forControlEvents:UIControlEventTouchDown];
            [btnIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
            //관련좌표 다시 계산
            ICON_CURRENT_HORIZONTAL += ICON_INCRESE_HORIZONTAL;
            TITLE_CURRENT_HORIZONTAL += TITLE_INCRESE_HORIZONTAL;
            
            
        }
    }
    [SVProgressHUD dismiss];
    
    if (appDelegate.receivePush) {
        [self getExecuteMenuInfo:appDelegate.receiveMenuNo pushNo:appDelegate.receivePushNo devNo:appDelegate.receiveDevNo];
        appDelegate.receivePush = NO;
    }
    /*
     NSString *loginSessionUrl = [NSString stringWithFormat:@"%@/getBadgeCount?MODE=isLogin",appDelegate.main_url];
     NSURL *url = [NSURL URLWithString:loginSessionUrl];
     NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
     NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
     */
    //isDrawMenu = YES;
}
-(void) buttonTouched:(id)sender {
    
    //메뉴아이콘이 터치 되었을때
    int indexBtn = (int)[sender tag];
    [self buttonToIndex:indexBtn-100];
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
        //NSLog(@"exception : %@",[exception name]);
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
            if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            appDelegate.target_url = page_url;
            appDelegate.isMainWebView = NO;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.isDMS = isDMS;
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
            vc.isDMS = isDMS;
            if (!isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }
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
                    vc.isDMS = isDMS;
                    vc.isTabBar = isTabBar;
                    if (!isTabBar) {
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
                    NSMutableArray *downloadUrlArray = [NSMutableArray array];
                    NSMutableArray *menuTitles = [NSMutableArray array];
                    NSString *naviteAppDownLoadUrl = [temp stringByAppendingString:lastPath];
                    [downloadUrlArray addObject:naviteAppDownLoadUrl];
                    [menuTitles addObject:appDelegate.menu_title];
                    NSLog(@"naviteAppDownLoadUrl : %@",naviteAppDownLoadUrl);
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
                    NSLog(@"target_url : %@",appDelegate.target_url);
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.isDMS = isDMS;
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
            NSLog(@"addMenuHist parameter : %@",paramStr);
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
- (void)cancelButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isDMS = isDMS;
    if (!isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark
#pragma mark Background

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
}
- (void)applicationWillEnterForeground:(NSNotification *)notification{
    
}
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    /*
     NSString *loginSessionUrl = [NSString stringWithFormat:@"%@/getBadgeCount?MODE=isLogin",appDelegate.main_url];
     NSURL *url = [NSURL URLWithString:loginSessionUrl];
     NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
     NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
     */
    
    NSUserDefaults *pres = [NSUserDefaults standardUserDefaults];
    if ([[pres stringForKey:@"Lock"] isEqualToString:@"YES"] && appDelegate.isLogin) {
        
        LockInsertView *vc = [[LockInsertView alloc]init];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
#pragma mark
#pragma mark Scroll Handle
-(void) animateToView:(UIView *)newView {
}
- (void)loadScrollViewWithPage:(int)page {
    
    //스크롤뷰 초기화
    if (page < 0) return;
    if (page >= 2) return;
    
    CGRect frame = mainScrollView.frame;
    
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
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
    int page = (int)pageControl.currentPage;
    
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
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (menuArray==nil || [menuArray count]==0) {
        return 1;
    }else
        return [menuArray count];
}

// Customize the appearance of table view cells.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self buttonToIndex:(int)indexPath.row];
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
        //myButton.tag = indexPath.row;
        //NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subOffButtonPath] AES256DecryptWithKey:appDelegate.AES256Key];
        //[myButton setBackgroundImage:[UIImage imageWithData:decryptData] forState:UIControlStateNormal];
        //decryptData = [[NSData dataWithContentsOfFile:appDelegate.subOnButtonPath] AES256DecryptWithKey:appDelegate.AES256Key];
        
        //[myButton setBackgroundImage:[UIImage imageWithData:decryptData] forState:UIControlStateSelected];
        //[myButton addSubview:label];
        //[myButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:label];
        //[cell.contentView addSubview:myButton];
    }
    
    return cell;
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
    vc.isDMS = isDMS;
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
#pragma mark UIAlertView
- (void)createProgressionAlertWithMessage:(NSString *)message
{
    progressAlert = [[UIAlertView alloc] initWithTitle:message message:@"Downloading..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    [progressAlert addSubview:progressView];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    
    //indicator를 이용할 때
    //UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //activityView.frame = CGRectMake(139.0f-18.0f, 78.0f, 37.0f, 37.0f);
    //[activityView startAnimating];
    //[activityView release];
    //[progressAlert addSubview:activityView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 90.0f, 225.0f, 40.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.text = @"";
    label.tag = 1;
    [progressAlert addSubview:label];
    
    [progressAlert show];
    
}
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize :(UIImage *)image
{
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat _width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / _width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = _width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

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
}
#pragma mark

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
