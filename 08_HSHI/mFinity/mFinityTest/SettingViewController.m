//
//  SettingViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "SettingViewController.h"
#import "MymenuSettingViewController.h"
#import "PWChangeViewController.h"
#import "MFinityAppDelegate.h"
#import "SubMenuViewCell.h"
#import "MFInfoViewController.h"
#import "LockSettingViewController.h"
#import "CustomAlertView.h"
#import "NotificationSettingViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "ZipArchive.h"

#import "LockInsertView.h"
#import "StartSettingViewController.h"
#import "RemoveContentsViewController.h"
#import "FontSettingViewController.h"
#import "DownloadListViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFTableViewController.h"
#import "LockInsertView.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"


#import "NSData+AES256.h"
#import "CameraMenuViewController.h"
#import "SecurityManager.h"
#import "SVProgressHUD.h"


#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 320
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (self) {
            //self.title = NSLocalizedString(@"Fourth", @"Fourth");
            self.tabBarItem.image = [UIImage imageNamed:@"bottom_icon04.png"];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [imageView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height+self.navigationController.navigationBar.frame.size.height)];
            [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [imageView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height+self.navigationController.navigationBar.frame.size.height)];
            [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, myTableView.frame.size.width, imageView.frame.size.height-appDelegate.scrollView.frame.size.height-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-60)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [imageView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height+self.navigationController.navigationBar.frame.size.height)];
            [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, appDelegate.scrollView.frame.size.height, myTableView.frame.size.width, myTableView.frame.size.height)];
            
        }
    }
}

- (void)viewDidLoad
{
    NSLog(@"isMyMenu : %d", appDelegate.isMyMenu);
    
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    connectionCount = 0;
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    UILabel *navigationTitlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    navigationTitlelabel.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    navigationTitlelabel.text =appDelegate.menu_title;
    navigationTitlelabel.font = [UIFont boldSystemFontOfSize:20.0];
    navigationTitlelabel.backgroundColor = [UIColor clearColor];
    navigationTitlelabel.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        navigationTitlelabel.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        navigationTitlelabel.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    myTableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    self.navigationItem.titleView = navigationTitlelabel;
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    imageView.image = bgImage;
    //[self.navigationItem setTitle:@"설정"];
    
    
    //네비게이션 바 색상 변환
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
    
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = [appDelegate.badgeCount intValue];
        if ([appDelegate.badgeCount intValue] <= 0) {
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]]setBadgeValue:nil];
        }else {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",[appDelegate.badgeCount intValue]]];
        }
    }
    
    //2018.06 UI개선
    NSMutableArray *tmpIconArray = [NSMutableArray array];
    menuArray = [NSMutableArray array];
    
    //self.navigationItem.backBarButtonItem = left;
    myTableView.rowHeight = 50;
    if (appDelegate.isOffLine) {
        [menuArray addObject:NSLocalizedString(@"message26", @"시스템 정보")];
        [tmpIconArray addObject:@"set_systeminfo.png"];
        
    }else{
        if ([appDelegate.noAuth isEqualToString:@"DEMO"]) {
            [menuArray addObject:NSLocalizedString(@"message26", @"시스템 정보")];
            [menuArray addObject:NSLocalizedString(@"message37", @"시작페이지 설정")];
            [menuArray addObject:NSLocalizedString(@"message154", @"폰트 설정")];
            [menuArray addObject:NSLocalizedString(@"message32", @"알림 설정")];
            [menuArray addObject:NSLocalizedString(@"message38", @"컨텐츠 삭제")];
            
            [tmpIconArray addObject:@"set_systeminfo.png"];
            [tmpIconArray addObject:@"set_startpage.png"];
            [tmpIconArray addObject:@"font.png"];
            [tmpIconArray addObject:@"set_sound.png"];
            [tmpIconArray addObject:@"set_download.png"];
            
        }else{
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            if ([[prefs objectForKey:@"OFFLINE_FLAG"] isEqualToString:@"N"]) {
                [menuArray addObject:NSLocalizedString(@"message26", @"시스템 정보")];
                [menuArray addObject:NSLocalizedString(@"message37", @"시작페이지 설정")];
                
                [tmpIconArray addObject:@"set_systeminfo.png"];
                [tmpIconArray addObject:@"set_startpage.png"];
                
                if(appDelegate.isMyMenu){
                    [menuArray addObject:NSLocalizedString(@"message43", @"마이메뉴 설정")];
                    [tmpIconArray addObject:@"set_mymenu.png"];
                }
                
                [menuArray addObject:NSLocalizedString(@"message154", @"폰트 설정")];
                [menuArray addObject:NSLocalizedString(@"message32", @"알림 설정")];
                [menuArray addObject:NSLocalizedString(@"message38", @"컨텐츠 삭제")];
                [menuArray addObject:NSLocalizedString(@"message44", @"비밀번호 변경")];
                
                [tmpIconArray addObject:@"font.png"];
                [tmpIconArray addObject:@"set_sound.png"];
                [tmpIconArray addObject:@"set_delete.png"];
                [tmpIconArray addObject:@"set_password.png"];
                
                if ([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]) {
                    [menuArray addObject:NSLocalizedString(@"message169", @"자동 로그인 해제")];
                    [tmpIconArray addObject:@"open_lock.png"];
                }
                
            }else{
                [menuArray addObject:NSLocalizedString(@"message26", @"시스템 정보")];
                [menuArray addObject:NSLocalizedString(@"message37", @"시작페이지 설정")];
                
                [tmpIconArray addObject:@"set_systeminfo.png"];
                [tmpIconArray addObject:@"set_startpage.png"];
                
                if(appDelegate.isMyMenu){
                    [menuArray addObject:NSLocalizedString(@"message43", @"마이메뉴 설정")];
                    [tmpIconArray addObject:@"set_mymenu.png"];
                }
                
                [menuArray addObject:NSLocalizedString(@"message154", @"폰트 설정")];
                [menuArray addObject:NSLocalizedString(@"message32", @"알림 설정")];
                [menuArray addObject:NSLocalizedString(@"message38", @"컨텐츠 삭제")];
                [menuArray addObject:NSLocalizedString(@"message44", @"비밀번호 변경")];
                
                [tmpIconArray addObject:@"font.png"];
                [tmpIconArray addObject:@"set_sound.png"];
                [tmpIconArray addObject:@"set_delete.png"];
                [tmpIconArray addObject:@"set_password.png"];
                
                if ([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]) {
                    [menuArray addObject:NSLocalizedString(@"message169", @"자동 로그인 해제")];
                    [tmpIconArray addObject:@"open_lock.png"];
                }
            }
        }
    }
    
    self.iconArray = [NSArray arrayWithArray:tmpIconArray];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]} forState:UIControlStateNormal];
}
-(void)viewDidAppear:(BOOL)animated{
    if (appDelegate.receivePush) {
        [self getExecuteMenuInfo:appDelegate.receiveMenuNo];
        appDelegate.receivePush = NO;
    }
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    [myTableView reloadData];
}
- (void)didReceiveMemoryWarning
{
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
    int indexBtn = [indexPath row];
    
    //2018.06 UI개선
    if ([appDelegate.noAuth isEqualToString:@"DEMO"]) {
        if (indexBtn == 0) {
            //정보 창으로 이동
            [self systemInfoCall];
            
        }else if (indexBtn == 1){
            //시작화면 설정
            [self setStartPageCall];
            
        }else if(indexBtn == 2){
            //폰트 설정
            [self fontSettingCall];
            
        }else if(indexBtn == 3){
            //알림 설정
            [self alertSettingCall];
            
        }/*else if(indexBtn == 4){
            //잠금 버튼 터치
            [self lockSettingCall];
            
        }else if (indexBtn == 5){
            //데이터베이스 동기화 버튼
            [self dataSyncCall];
            
        }*/else if(indexBtn == 4){
            //컨텐츠 삭제
            [self removeDataCall];
            
        }else if(indexBtn == 7){
            //Off-Line 웹앱 다운로드
            //[self offLineWebAppDownload];
            
        }
        //데모가 아닐 때
    }else{
        if (appDelegate.isOffLine){
            if (indexBtn == 0) {
                //정보 창으로 이동
                [self systemInfoCall];
            }
            /*else if (indexBtn == 1){
                //잠금 버튼 터치
                [self lockSettingCall];
            }*/
        }else{
            if (indexBtn == 0) {
                //정보 창으로 이동
                [self systemInfoCall];
                
            }
            else if (indexBtn == 1) {
                //시작 화면 설정
                [self setStartPageCall];
            }
            
            if(appDelegate.isMyMenu){
                if (indexBtn == 2) {
                    //마이메뉴설정 버튼 터치
                    [self myMenuSettingCall];
                    
                }else if(indexBtn == 3){
                    //폰트 설정
                    [self fontSettingCall];
                    
                }else if(indexBtn == 4){
                    //알림 설정
                    [self alertSettingCall];
                    
                }
                /*else if(indexBtn == 5){
                 //잠금 버튼 터치
                 [self lockSettingCall];
                 
                 }
                 else if(indexBtn == 6){
                 //데이터베이스 동기화 버튼
                 [self dataSyncCall];
                 
                 }*/
                else if(indexBtn == 5/*7*/) {
                    //데이터 삭제 버튼 터치
                    [self removeDataCall];
                    
                }
                else if(indexBtn == 6/*8*/){
                    //비밀번호변경 버튼 터치
                    [self passwordSettingCall:NO];
                    
                }
                else if(indexBtn == 7/*8*/){
                    //자동로그인 해제 버튼 터치
                    [self removeAutoLogin];
                }
                /*else if(indexBtn == 9){
                 //Off-Line 비번 변경
                 //[self passwordSettingCall:YES];
                 
                 }
                 else if(indexBtn == 10){
                 //Off-Line 웹앱 다운로드
                 //[self offLineWebAppDownload];
                 
                 }*/
                
            } else {
                if(indexBtn == 2){
                    //폰트 설정
                    [self fontSettingCall];
                    
                }else if(indexBtn == 3){
                    //알림 설정
                    [self alertSettingCall];
                    
                } else if(indexBtn == 4) {
                    //데이터 삭제 버튼 터치
                    [self removeDataCall];
                    
                } else if(indexBtn == 5){
                    //비밀번호변경 버튼 터치
                    [self passwordSettingCall:NO];
                    
                } else if(indexBtn == 6){
                    //자동로그인 해제 버튼 터치
                    [self removeAutoLogin];
                }
                
            }
        }
    }
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
    //-----------
    UIImageView *_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20,(44/2)-10 , 27.5, 27.5)];
    _imageView.image = [UIImage imageNamed:[self.iconArray objectAtIndex:indexPath.row]];
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
    label.text = [menuArray objectAtIndex:indexPath.row];
    
    label.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.subShadowColor];
        label.shadowOffset = CGSizeMake(2.0f, 2.0f);
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;

    [cell.contentView addSubview:_imageView];
    [cell.contentView addSubview:label];
    
    return cell;
}
#pragma mark
#pragma mark URLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
    
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
        
        
    }else{
        [receiveData setLength:0];
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"addMenuHist"]) {
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
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
                    WebViewController *vc = [[WebViewController alloc] init];
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
            WebViewController *vc = [[WebViewController alloc] init];
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
            WebViewController *vc = [[WebViewController alloc] init];
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
#pragma mark
#pragma mark SettingView Utils

-(void)systemInfoCall{
    MFInfoViewController *vc = [[MFInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)setStartPageCall{
    StartSettingViewController *vc = [[StartSettingViewController alloc]init];
    [self presentSemiViewController:vc withOptions:@{
                                                     KNSemiModalOptionKeys.pushParentBack : @(NO),
                                                     KNSemiModalOptionKeys.parentAlpha : @(0.5),
                                                     KNSemiModalOptionKeys.transitionStyle : @(KNSemiModalTransitionStyleSlideUp)
                                                     }];
}
-(void)removeDataCall{
    RemoveContentsViewController *vc = [[RemoveContentsViewController alloc]init];
    [self presentSemiViewController:vc withOptions:@{
                                                     KNSemiModalOptionKeys.pushParentBack : @(NO),
                                                     KNSemiModalOptionKeys.parentAlpha : @(0.5),
                                                     KNSemiModalOptionKeys.transitionStyle : @(KNSemiModalTransitionStyleSlideUp)
                                                     }];
}
-(void)myMenuSettingCall{
    
    MymenuSettingViewController *vc = [[MymenuSettingViewController alloc] init];
    appDelegate.menu_title =NSLocalizedString(@"message43", @"");
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)fontSettingCall{
    FontSettingViewController *vc = [[FontSettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)alertSettingCall{
    NotificationSettingViewController *vc = [[NotificationSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)lockSettingCall{
    LockSettingViewController *vc = [[LockSettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)passwordSettingCall:(BOOL)isOffLine{
    
//    if(isOffLine) appDelegate.menu_title = NSLocalizedString(@"message110", @"");
//    else appDelegate.menu_title = NSLocalizedString(@"message44", @"");
//
//    PWChangeViewController *vc = [[PWChangeViewController alloc] init];
//    vc.isOffLine = isOffLine;
//    [self.navigationController pushViewController:vc animated:YES];
    
    appDelegate.isInitPwd = NO;
    appDelegate.isSettingPwd = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //appDelegate.naviBarColor = @"#535768";
    //appDelegate.naviFontColor = @"#ffffff";
    [prefs setObject:appDelegate.naviBarColor forKey:@"NAVIBARCOLOR"];
    [prefs setObject:appDelegate.naviFontColor forKey:@"NAVIFONTCOLOR"];
    
    appDelegate.menu_title = [[NSString alloc] initWithFormat:@"비밀번호 변경"];
    appDelegate.target_url = [[NSString alloc] initWithFormat:@"https://eoffice.hshi.co.kr/HSIM/pages/pw/ChgPass.aspx"];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.pwdParentView = YES;
    
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    //[self.navigationController presentViewController:nav animated:YES completion:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)removeAutoLogin{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message169", @"") message:NSLocalizedString(@"message170", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message52", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                                         [prefs removeObjectForKey:@"UserInfo_ID"];
                                                         [prefs removeObjectForKey:@"isSave"];
                                                         [prefs removeObjectForKey:@"AutoLogin_ID"];
                                                         [prefs removeObjectForKey:@"AutoLogin_PWD"];
                                                         [prefs removeObjectForKey:@"isAutoLogin"];
                                                         [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
                                                         [prefs synchronize];
                                                         
                                                        if(appDelegate.isMDM){
//                                                            if([appDelegate.mdmFlag isEqualToString:@"T"]){
                                                                appDelegate.mdmCallAPI = @"exitWorkApp";
                                                                [MFinityAppDelegate exitWorkApp];
//                                                            } else {
//                                                                exit(0);
//                                                            }
                                                        } else {
                                                            exit(0);
                                                        }
                                                     }];
    [alert addAction:cancelButton];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)offLineWebAppDownload{
    
    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    save = [save stringByAppendingFormat:@"/getOffLineMenuList"];
    NSData *data = [NSData dataWithContentsOfFile:save];
    webAppURLs = [[NSMutableArray alloc] init];
    menuNumbers = [[NSMutableArray alloc] init];
    webAppVersions = [[NSMutableArray alloc] init];
    menuTitles = [[NSMutableArray alloc] init];
    downloadUrlArray = [[NSMutableArray alloc] init];
    downloadNoArray = [[NSMutableArray alloc] init];
    downloadVerArray = [[NSMutableArray alloc] init];
    [self parserJsonData:data];
    int count = (int)[menuNumbers count];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSPropertyListFormat format;
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
    NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    //[dic setObject:currentAppVersion forKey:currentAppNo];
    //[dic writeToFile:filePath atomically:YES];
    NSLog(@"webAppURLs : %@",webAppURLs);
    for (int i=0; i<count; i++) {
        if ([dic objectForKey:[menuNumbers objectAtIndex:i]]==nil ||
            ![[dic objectForKey:[menuNumbers objectAtIndex:i]] isEqualToString:[webAppVersions objectAtIndex:i]]) {
            [downloadUrlArray addObject:[webAppURLs objectAtIndex:i]];
            [downloadNoArray addObject:[menuNumbers objectAtIndex:i]];
            [downloadVerArray addObject:[webAppVersions objectAtIndex:i]];
        }else{
            
        }
    }
    if ([downloadUrlArray count]==0) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message115", @"")];
    }else{
        
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
        vc.downloadNoArray = downloadNoArray;
        vc.downloadUrlArray = downloadUrlArray;
        vc.downloadVerArray = downloadVerArray;
        vc.downloadMenuTitleList = menuTitles;
        NSLog(@"menuTitles2 : %@",menuTitles);
        vc.delegate = self;
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        nvc.navigationBarHidden=NO;
        int increaseRow = 0;
        for (int i=1; i<[downloadUrlArray count]; i++) {
            increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
        }
        if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
        
        nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
        [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
    }
    
}


- (NSInteger)indexOfString:(NSString*)title{
    
    NSInteger rtnValue = 0;
    for(NSInteger i=0; i<[tabNameArray count]; i++)
    {
        NSString* tmpStr = [tabNameArray objectAtIndex:i];
        if([tmpStr isEqualToString:title])
        {
            
            rtnValue = i;
            break;
        }
    }
    
    return rtnValue;
}

- (void)stopIndicator{
    
    [activityAlert close];
    [myIndicator stopAnimating];
    myIndicator.hidesWhenStopped =YES;
    
}

#pragma mark
#pragma mark JSON Data Parsing
-(void) parserJsonData:(NSData *)data{
    
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
        //decString = [NSString urlDecodeString:decString];
        dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        // if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",error);
        NSLog(@"exception : %@",exception);
    }
    
    if ([[[dic objectForKey:@"0"] objectForKey:@"V0"]isEqualToString:@"True"]) {
        for (int i=1; i<[dic count]; i++) {
            NSDictionary *tempDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i]];
            if (![[tempDic objectForKey:@"V13"] isEqualToString:@"%23"]) {
                NSLog(@"[tempDic objectForKey:@\"V9\"] : %@",[NSString stringWithFormat:@"%@",[tempDic objectForKey:@"V9"]]);
                [webAppURLs addObject:[NSString stringWithFormat:@"%@",[tempDic objectForKey:@"V13"]]];
                [menuNumbers addObject:[NSString stringWithFormat:@"%@",[tempDic objectForKey:@"V3"]]];
                [webAppVersions addObject:[NSString stringWithFormat:@"%@",[tempDic objectForKey:@"V12"]]];
                [menuTitles addObject:[NSString stringWithFormat:@"%@",[tempDic objectForKey:@"V9"]]];
            }
        }
        NSLog(@"menuTitles : %@",menuTitles);
        NSLog(@"webAppURL : %@",webAppURLs);
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
    
}
#pragma mark
#pragma mark UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 0) {
        //labelText = [NSString stringWithString:@"종료 시간 설정 : "];
        indexTitle = [tabNameArray objectAtIndex:row];
        //labelText = [labelText stringByAppendingString:indexTitle];
        //labelText = [labelText stringByAppendingString:@"분"];
        selAlertTitleLabel.text = [tabNameArray objectAtIndex:row];
        [selAlertTitleLabel setTextAlignment:NSTextAlignmentCenter];
        selAlertTitleLabel.backgroundColor = [UIColor clearColor];
        selAlertTitleLabel.textColor = [UIColor whiteColor];
    }else if (pickerView.tag == 1){
        deleteTitle = [deleteArray objectAtIndex:row];
        delAlertTitleLabel.text = [deleteArray objectAtIndex:row];
        [delAlertTitleLabel setTextAlignment:NSTextAlignmentCenter];
        delAlertTitleLabel.backgroundColor = [UIColor clearColor];
        delAlertTitleLabel.textColor = [UIColor whiteColor];
    }
    
    
    //[self addSubview:label];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView.tag==0)  return [tabNameArray count];
    else if (pickerView.tag==1) return [deleteArray count];
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    if (pickerView.tag==0) return [tabNameArray objectAtIndex:row];
    else if (pickerView.tag==1) return [deleteArray objectAtIndex:row];
    return nil;
}
#pragma mark
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString:NSLocalizedString(@"message37", @"")]){
        if (buttonIndex == 0) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:indexTitle forKey:@"startString"];
            [prefs setInteger:[tabNameArray indexOfObject:indexTitle] forKey:@"startTabNumber"];
            [prefs synchronize];
            
        }
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"message66", @"")]){
        if (buttonIndex == 0) {
            exit(0);
        }else{
            
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        exit(0);
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"message38", @"")]){
        if(buttonIndex==0){
            if ([deleteTitle isEqualToString:NSLocalizedString(@"message39", @"")]) {
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                //NSLog(@"docdir : %@",docDir);
                docDir = [docDir stringByAppendingPathComponent:@"icon/"];
                //NSLog(@"current docdir : %@",docDir);
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                //NSLog(@"fileList : %@",fileList);
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    str = [docDir stringByAppendingPathComponent:str];
                    //NSLog(@"delete file : %@",str);
                    [manager removeItemAtPath:str error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            } else if([deleteTitle isEqualToString:NSLocalizedString(@"message40", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"photo/"];
                ////NSLog(@"docDir : %@",docDir);
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                ////NSLog(@"fileList : %@",fileList);
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    ////NSLog(@"jpg fileName : %@",fileName);
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            } else if([deleteTitle isEqualToString:NSLocalizedString(@"message41", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"video/"];
                
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            } else if([deleteTitle isEqualToString:NSLocalizedString(@"message42", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
                [alert show];
                
            } else if([deleteTitle isEqualToString:NSLocalizedString(@"message116", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"webapp/"];
                
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
                [alert show];
                
            }
        } else if(buttonIndex==1){
            
        }
    }
    
}


@end
