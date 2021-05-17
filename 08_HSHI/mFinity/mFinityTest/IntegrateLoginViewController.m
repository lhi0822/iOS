//
//  IntegrateLoginViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "IntegrateLoginViewController.h"
#import "MFinityAppDelegate.h"
#import "ZipArchive.h"
#import "UIDevice-Hardware.h"
#import <sys/utsname.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "UIDevice+IdentifierAddition.h"
#import "FBEncryptorAES.h"
#import "ZipArchive.h"
#import "Reachability.h"
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#import "SVProgressHUD.h"

#import "AgreementViewController.h"

#import "KeychainItemWrapper.h"
@interface IntegrateLoginViewController (){

  
}

@end

@implementation IntegrateLoginViewController

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
	// Do any additional setup after loading the view.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MDMIntroNotification:) name:@"MDMIntroNotification" object:nil];
}
- (BOOL) saveFile {
    NSLog(@"saveFile");
    NSLog(@"saveFile documentPath : %@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *compDocFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    if (![fileManager isReadableFileAtPath:compDocFolder]) {
        [fileManager createDirectoryAtPath:compDocFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	NSString *photoFolder = @"icon";
    NSString *webAppFolder = @"webapp";
    NSString *iconSaveFolder = [compDocFolder stringByAppendingFormat:@"/%@",photoFolder];
    NSString *webAppSaveFolder = [compDocFolder stringByAppendingFormat:@"/%@",webAppFolder];
	NSString *webPlistAppFolder = [documentFolder stringByAppendingPathComponent:webAppFolder];
    
    BOOL issue = [fileManager isReadableFileAtPath:iconSaveFolder];
    BOOL issue2 = [fileManager isReadableFileAtPath:webAppSaveFolder];
    BOOL issue3 = [fileManager isReadableFileAtPath:webPlistAppFolder];
    if (!issue2) {
        [fileManager createDirectoryAtPath:webAppSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (!issue) {
        [fileManager createDirectoryAtPath:iconSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (!issue3) {
        [fileManager createDirectoryAtPath:webPlistAppFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *iconBgFilename = [appDelegate.bgIconImagePath lastPathComponent];
    NSString *mainBgFilename = [appDelegate.bgImagePath lastPathComponent];
    NSString *subBgFilename = [appDelegate.subBgImagePath lastPathComponent];
    
    //그룹사수정
    NSString *introBgFilename = [appDelegate.introImagePath lastPathComponent];
    NSString *loginImageFilename = [appDelegate.loginImagePath lastPathComponent];
    

    //그룹사수정
    NSString *introfilePath = [iconSaveFolder stringByAppendingPathComponent:introBgFilename];
    NSString *loginBgfilePath = [iconSaveFolder stringByAppendingPathComponent:loginImageFilename];

    NSString *mainBgfilePath = [iconSaveFolder stringByAppendingPathComponent:mainBgFilename];
    NSString *subBgfilePath = [iconSaveFolder stringByAppendingPathComponent:subBgFilename];
    NSString *iconBgfilePath = [iconSaveFolder stringByAppendingString:iconBgFilename];

    UIImage *mainBgImage = [UIImage imageWithContentsOfFile:mainBgfilePath];
    
    UIImage *subBgImage = [UIImage imageWithContentsOfFile:subBgfilePath];
    

    //그룹사수정
    UIImage *introImage = [UIImage imageWithContentsOfFile:introfilePath];
    UIImage *loginBgImage = [UIImage imageWithContentsOfFile:loginBgfilePath];
    
    UIImage *iconBgImage = [UIImage imageWithContentsOfFile:iconBgfilePath];
    
    NSData *data=nil;
    NSData *encryptData = nil;
    if (![fileManager isReadableFileAtPath:mainBgfilePath] || ![fileManager isReadableFileAtPath:subBgfilePath] || ![fileManager isReadableFileAtPath:introfilePath]||![fileManager isReadableFileAtPath:loginBgfilePath]||![fileManager isReadableFileAtPath:iconBgfilePath]) {
        
        NSLog(@"downloading");
        mainBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.bgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(mainBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:mainBgfilePath atomically:YES];
        
        subBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.subBgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(subBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:subBgfilePath atomically:YES];
        
        //그룹사수정
        introImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.introImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(introImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:introfilePath atomically:YES];

        loginBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.loginImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(loginBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:loginBgfilePath atomically:YES];
        
        iconBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.bgIconImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(iconBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:iconBgfilePath atomically:YES];
    }
    
    appDelegate.bgImagePath = mainBgfilePath;
    appDelegate.subBgImagePath = subBgfilePath;
    //그룹사수정
    appDelegate.loginImagePath = loginBgfilePath;
    appDelegate.bgIconImagePath = iconBgfilePath;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //그룹사수정
    [prefs setObject:introfilePath forKey:@"IntroImagePath"];
    [prefs setObject:loginBgfilePath forKey:@"LoginImagePath"];
//    NSLog(@"loginBgfilePath : %@",loginBgfilePath);
    
    [prefs setObject:mainBgfilePath forKey:@"MainBgFilePath"];
    [prefs setObject:subBgfilePath forKey:@"SubBgFilePath"];
    
    [prefs setObject:appDelegate.tabBarColor forKey:@"TabBarColor"];
    //[prefs setObject:htmlFilePath forKey:@"HtmlFilePath"];
    NSError *error;
    //NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //documents = [documents stringByAppendingPathComponent:@"10"];
    //documents = [documents stringByAppendingPathComponent:@"webapp"];
    //NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documents error:&error];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSPropertyListFormat format;
    //NSDictionary *currentWebAppDic = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    NSDictionary *currentWebAppDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];


    NSData *webApp_data = [appDelegate.htmlPath dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *webAppDic = [NSJSONSerialization JSONObjectWithData:webApp_data options:kNilOptions error:&error];

    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    save = [save stringByAppendingFormat:@"/%@/webapp/common",appDelegate.comp_no];
    NSLog(@"==============================================================================");
    NSLog(@"webAppDic : %@",webAppDic);
    NSLog(@"filePath : %@",filePath);
    NSLog(@"[fileManager isReadableFileAtPath:filePath] : %@",[fileManager isReadableFileAtPath:filePath]?@"YES":@"NO");
    NSLog(@"[manager isReadableFileAtPath:save] : %@", [manager isReadableFileAtPath:save]?@"YES":@"NO");
    NSLog(@"UPDATED == Y : %@",[[webAppDic objectForKey:@"UPDATED"] isEqualToString:@"Y"]?@"YES":@"NO");
    NSLog(@"UPDATED == R : %@",[[webAppDic objectForKey:@"UPDATED"] isEqualToString:@"R"]?@"YES":@"NO");
    NSLog(@"RES_VER : %@",[[currentWebAppDic objectForKey:@"RES_VER"]isEqualToString:[webAppDic objectForKey:@"RES_VER"]]?@"YES":@"NO");
    NSLog(@"current RES_VER : %@",[currentWebAppDic objectForKey:@"RES_VER"]);
    NSLog(@"server RES_VER : %@",[webAppDic objectForKey:@"RES_VER"]);
    NSLog(@"==============================================================================");
    
    if (!appDelegate.isOffLine) {
        if ([[webAppDic objectForKey:@"UPDATED"] isEqualToString:@"Y"] ||
            [[webAppDic objectForKey:@"UPDATED"] isEqualToString:@"R"] ||
            ![fileManager isReadableFileAtPath:filePath] ||
            ![manager isReadableFileAtPath:save] ||
            ![[currentWebAppDic objectForKey:@"RES_VER"]isEqualToString:[webAppDic objectForKey:@"RES_VER"]]) {
            
            NSString *file = [webAppDic objectForKey:@"FILE"];
            if (file==nil) {
                NSArray *tempArray = [webAppDic objectForKey:@"LIST"];
                for(int i=0; i<[tempArray count]; i++){
                    
                    NSDictionary *fileDic = [tempArray objectAtIndex:i];
                    NSLog(@"fileDic : %@",fileDic);
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    [prefs setObject:[fileDic objectForKey:@"FILE"] forKey:@"COMMON_DOWNLOAD"];
                    [prefs setObject:[webAppDic objectForKey:@"RES_VER"] forKey:@"RES_VER"];
                    [prefs synchronize];
                    NSString *filePath = [fileDic objectForKey:@"FILE"];
                    NSString *tmp = [filePath lastPathComponent];
                    
                    tmp = [NSString urlDecodeString:tmp];
                    
                    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[fileDic objectForKey:@"FILE"]]];
                    
                    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    save = [save stringByAppendingPathComponent:appDelegate.comp_no];
                    save = [save stringByAppendingFormat:@"/webapp/common.zip"];
                    NSString *unZipFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,[[save lastPathComponent] stringByDeletingPathExtension]];
                    [htmlData writeToFile:save atomically:YES];
                    ZipArchive *zip = [[ZipArchive alloc]init];
                    if ([zip UnzipOpenFile:save]) {
                        [zip UnzipFileTo:unZipFolder overWrite:YES];
                    }
                    [zip UnzipCloseFile];
                    
                    [manager removeItemAtPath:save error:&error];
                }
            }else{
                NSString *filePath = [webAppDic objectForKey:@"FILE"];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:filePath forKey:@"COMMON_DOWNLOAD"];
                [prefs setObject:[webAppDic objectForKey:@"RES_VER"] forKey:@"RES_VER"];
                [prefs synchronize];
                
                NSString *tmp = [filePath lastPathComponent];
                
                tmp = [NSString urlDecodeString:tmp];
                
                NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
                
                NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                save = [save stringByAppendingPathComponent:appDelegate.comp_no];
                save = [save stringByAppendingFormat:@"/webapp/common.zip"];
                NSString *unZipFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,[[save lastPathComponent] stringByDeletingPathExtension]];
                [htmlData writeToFile:save atomically:YES];
                ZipArchive *zip = [[ZipArchive alloc]init];
                if ([zip UnzipOpenFile:save]) {
                    [zip UnzipFileTo:unZipFolder overWrite:YES];
                }
                [zip UnzipCloseFile];
                
                [manager removeItemAtPath:save error:&error];
            }
            
        }
    }
    
    NSData *offLine_data = [appDelegate.offLineInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *offLineDic;

    @try {
        offLineDic = [NSJSONSerialization JSONObjectWithData:offLine_data options:kNilOptions error:&error];

        [prefs setObject:[offLineDic objectForKey:@"OFFLINE_PASSWD"] forKey:@"OFFLINE_PASSWD"];
        [prefs setObject:[offLineDic objectForKey:@"OFFLINE_FLAG"] forKey:@"OFFLINE_FLAG"];
        [prefs setObject:[offLineDic objectForKey:@"OFFLINE_ID"] forKey:@"OFFLINE_ID"];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    
    NSMutableDictionary *dic;
    NSError *dicError;

    if (currentWebAppDic==nil) {
        dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[webAppDic objectForKey:@"RES_VER"],@"RES_VER",nil];
        
    }else{
        
        dic = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath] options:NSPropertyListMutableContainersAndLeaves format:&format error:&dicError];
        //dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
        [dic setObject:[webAppDic objectForKey:@"RES_VER"] forKey:@"RES_VER"];
        
    }

    [dic writeToFile:filePath atomically:YES];
    [prefs synchronize];
    return YES;
}

- (NSString *)resultUserCheck:(NSDictionary *)loginDic{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [loginDic objectForKey:@"V1"];
    NSLog(@"userid : %@",userid);
    NSLog(@"pwd : %@",pwd);
    NSLog(@"loginDic : %@", loginDic);
    
    personalAgree = nil;
    
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"DEVID : %@", appDelegate.device_id] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
//    [alertView show];
    
    //로그인이력 저장
    [appDelegate loginHistoryToLogFile:[NSString stringWithFormat:@"%s //리턴처리시작",__func__] result:result];
    
    if ([result isEqualToString:@"SUCCEED"]) {
        appDelegate.isLogin = YES;
        appDelegate.passWord = pwd;
        //appDelegate.user_id = userid;
        appDelegate.user_id = [loginDic objectForKey:@"V2_1"];
        appDelegate.user_no = [loginDic objectForKey:@"V2"];
        
        appDelegate.mdmFlag = [loginDic objectForKey:@"V2_3"];
//        appDelegate.mdmFlag = @"T"; //테스트
//        NSLog(@"mdmFlag ; %@", appDelegate.mdmFlag);
        
        appDelegate.comp_no = [loginDic objectForKey:@"V3"];
        [prefs setObject:[appDelegate.comp_no AES256EncryptWithKeyString:appDelegate.AES256Key] forKey:@"COMP_NO"];
        appDelegate.root_menu_no = [loginDic objectForKey:@"V4"];
        appDelegate.app_name = [loginDic objectForKey:@"V5"];
        appDelegate.app_no = [loginDic objectForKey:@"V5_1"];
        appDelegate.noAuth = [loginDic objectForKey:@"V6"];
        appDelegate.comp_name = [loginDic objectForKey:@"V7"];
        appDelegate.dmsHost = [loginDic objectForKey:@"V7_1"];
        //isDMS "T" or "F"
        appDelegate.isDMS = [loginDic objectForKey:@"V7_2"];
        appDelegate.fileSyncURL = [loginDic objectForKey:@"V7_3"];
        syncFlag = [loginDic objectForKey:@"V7_4"];
        appDelegate.version = [loginDic objectForKey:@"V9"];
        appDelegate.badgeCount = [loginDic objectForKey:@"V9_1"];
        appDelegate.bgImagePath = [loginDic objectForKey:@"V10"];
        appDelegate.mainFontColor = [loginDic objectForKey:@"V11"];
        appDelegate.mainIsShadow = [loginDic objectForKey:@"V11_1"];
        appDelegate.mainShadowColor = [loginDic objectForKey:@"V11_2"];
        appDelegate.mainShadowOffset = [loginDic objectForKey:@"V11_3"];

        [prefs setObject:appDelegate.mainFontColor forKey:@"MAINFONTCOLOR"];
        //메뉴 아이콘 배경이미지 [loginDic objectForKey:@"V11_4"];
        appDelegate.bgIconImagePath = [loginDic objectForKey:@"V11_4"];
        appDelegate.subBgImagePath = [loginDic objectForKey:@"V12"];
        appDelegate.subFontColor = [loginDic objectForKey:@"V13"];
        appDelegate.subIsShadow = [loginDic objectForKey:@"V13_1"];
        appDelegate.subShadowColor = [loginDic objectForKey:@"V13_2"];
        appDelegate.subShadowOffset = [loginDic objectForKey:@"V13_3"];
        
        //그룹사수정
        appDelegate.introImagePath = [loginDic objectForKey:@"V16"];
        appDelegate.loginImagePath = [loginDic objectForKey:@"V17"];
        
        [prefs setObject:[loginDic objectForKey:@"V17_2"] forKey:@"LOGINOFFCOLOR"];
        [prefs setObject:[loginDic objectForKey:@"V17_3"] forKey:@"LOGINONCOLOR"];

        appDelegate.naviBarColor = [loginDic objectForKey:@"V18"];
        [prefs setObject:appDelegate.naviBarColor forKey:@"NAVIBARCOLOR"];
        
        appDelegate.naviFontColor = [loginDic objectForKey:@"V18_1"];
        [prefs setObject:appDelegate.naviFontColor forKey:@"NAVIFONTCOLOR"];
        
        appDelegate.naviIsShadow = [loginDic objectForKey:@"V18_2"];
        [prefs setObject:appDelegate.naviFontColor forKey:@"NAVIISSHADOW"];
        
        appDelegate.naviShadowColor = [loginDic objectForKey:@"V18_3"];
        [prefs setObject:appDelegate.naviFontColor forKey:@"NAVISHADOWCOLOR"];
        
        appDelegate.naviShadowOffset = [loginDic objectForKey:@"V18_4"];
        [prefs setObject:appDelegate.naviFontColor forKey:@"NAVISHAODWOFFSET"];
        
        appDelegate.tabBarColor = [loginDic objectForKey:@"V19"];
        appDelegate.tabFontColor = [loginDic objectForKey:@"V19_1"];
        
        //2018.06 UI개선
        appDelegate.tabBarType = [loginDic objectForKey:@"V19_5"];
        appDelegate.tabTitleType = [loginDic objectForKey:@"V19_6"];
        
        
        appDelegate.mainType = [loginDic objectForKey:@"V20"];
        appDelegate.htmlPath = [loginDic objectForKey:@"V30"];
        NSString *webAppMenus = [loginDic objectForKey:@"V31"];
        appDelegate.offLineInfo = [loginDic objectForKey:@"V40"];
        appDelegate.serverVersion = [loginDic objectForKey:@"V90"];
        deployURL = [loginDic objectForKey:@"V91"];
        forcedDownFlag =[loginDic objectForKey:@"V92"];
        forcedDownMessage =[loginDic objectForKey:@"V93"];
        
        /*
        NSString *str = @"%7B%221%22%3A%7B%22TAB%22%3A%221%22%2C%22TITLE%22%3A%22%EB%A9%94%EC%9D%B8%EB%A9%94%EB%89%B4%22%2C%22ICON%22%3A%221%22%2C%22ICONTITLE%22%3A%22%EB%A9%94%EC%9D%B8%EB%A9%94%EB%89%B4%22%2C%22URL%22%3A%22Reserved%20Functionality%22%7D%2C%222%22%3A%7B%22TAB%22%3A%222%22%2C%22TITLE%22%3A%22%EC%95%8C%EB%A6%BC%22%2C%22ICON%22%3A%222%22%2C%22ICONTITLE%22%3A%22%EC%95%8C%EB%A6%BC%22%2C%22URL%22%3A%22Reserved%20Functionality%22%7D%2C%223%22%3A%7B%22TAB%22%3A%223%22%2C%22TITLE%22%3A%22%EC%A6%90%EA%B2%A8%EC%B0%BE%EA%B8%B0%22%2C%22ICON%22%3A%223%22%2C%22ICONTITLE%22%3A%22%EC%A6%90%EA%B2%A8%EC%B0%BE%EA%B8%B0%22%2C%22URL%22%3A%22Reserved%20Functionality%22%7D%2C%224%22%3A%7B%22TAB%22%3A%224%22%2C%22TITLE%22%3A%22%EC%84%A4%EC%A0%95%22%2C%22ICON%22%3A%224%22%2C%22ICONTITLE%22%3A%22%EC%84%A4%EC%A0%95%22%2C%22URL%22%3A%22Reserved%20Functionality%22%7D%2C%225%22%3A%7B%22TAB%22%3A%225%22%2C%22TITLE%22%3A%22%EC%A2%85%EB%A3%8C%22%2C%22ICON%22%3A%225%22%2C%22ICONTITLE%22%3A%22%EC%A2%85%EB%A3%8C%22%2C%22URL%22%3A%22Reserved%20Functionality%22%7D%2C%226%22%3A%7B%22TAB%22%3A%226%22%2C%22TITLE%22%3A%22%EB%84%A4%EC%9D%B4%EB%B2%84%22%2C%22ICON%22%3A%2210%22%2C%22ICONTITLE%22%3A%22%EB%84%A4%EC%9D%B4%EB%B2%84%22%2C%22URL%22%3A%22http%3A%2F%2Fm.naver.com%22%7D%2C%227%22%3A%22*%22%2C%228%22%3A%22*%22%2C%229%22%3A%22*%22%2C%2210%22%3A%22*%22%7D";
        tabInfo = [NSString urlDecodeString:str];
        */
        
        tabInfo = [loginDic objectForKey:@"V100"];
        
//        personalAgree = [loginDic objectForKey:@"V2_4"];
//        NSLog(@"succeed일때 v2_4 : %@", personalAgree);
        personalAgree = @"T"; //201012 개인정보동의 사용안함 (로직 안타도록 강제적용시킴)
        
        NSLog(@"webAppMenus : %@",webAppMenus);
        NSError * error;
        if (webAppMenus!=nil) {
            NSData *webAppData = [webAppMenus dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *webAppDic = [NSJSONSerialization JSONObjectWithData:webAppData options:kNilOptions error:&error];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webapp/",appDelegate.comp_no];
            
            NSMutableArray * directoryContents = [NSMutableArray arrayWithArray:[manager contentsOfDirectoryAtPath:filePath error:&error]];
            [directoryContents removeObject:@"common"];

            for (int i=0; i<[webAppDic count]; i++) {
                NSString *serverMenu = [webAppDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                for (int j=0; j<[directoryContents count]; j++) {
                    if ([serverMenu isEqualToString:[directoryContents objectAtIndex:j]]) {
                        [directoryContents removeObjectAtIndex:j];
                    }
                }
            }
            for (int i=0; i<[directoryContents count]; i++) {
                NSString *removePath = [filePath stringByAppendingPathComponent:[directoryContents objectAtIndex:i]];
                [manager removeItemAtPath:removePath error:&error];
            }
        }
		[prefs setInteger:[[loginDic objectForKey:@"V16_1"] intValue] forKey:@"IntroCount"];
		[prefs synchronize];
        
        if (!appDelegate.isOffLine) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = [appDelegate.badgeCount intValue];
            if ([appDelegate.badgeCount intValue] <= 0) {
                [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]]setBadgeValue:nil];
            }else {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",[appDelegate.badgeCount intValue]]];
            }
            NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            save = [save stringByAppendingFormat:@"/HHILogin"];
            NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            }
            else{
                decString = encString;
            }
            
            //NSData *encryptData = [receiveData AES256EncryptWithKey:appDelegate.AES256Key];
            [[decString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:save atomically:YES];
        }
        
    }else if([result isEqualToString:@"NOTCERT"]){
        appDelegate.isLogin = YES;
        appDelegate.passWord = pwd;
        appDelegate.user_id = userid;
        appDelegate.noAuth = [loginDic objectForKey:@"V6"];
//        personalAgree = [loginDic objectForKey:@"V2_4"]; //201012 개인정보동의 사용안함 (로직 안타도록 강제적용시킴)
        
        
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message6", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
//        [alertView show];
		
    }else if([result isEqualToString:@"FAILED"]){
        appDelegate.isLogin = NO;
        failedMessage = [loginDic objectForKey:@"V6"];
        
        
    }else if([result isEqualToString:@"NOUSERINFO"]){
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message99", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else if([result isEqualToString:@"DENIED"]){
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message7", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else if([result isEqualToString:@"NOTMATCH"]){
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message8", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else if([result isEqualToString:@"ABORTED"]){
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message10", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else if([result isEqualToString:@"DEVICEHACKED"]){
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message120", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else{
        appDelegate.isLogin = NO;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
    return result;
}
- (void)updateApplication{
    NSError *error;
    NSData *login_data = [tabInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *loginDic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
    
    appDelegate.isLogin = YES;
    
    //메인타입, 탭바위치 테스트
    //appDelegate.mainType = @"3"; /*1,2,3*/
    //appDelegate.tabBarType = @"B"; /*B,T*/
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [appDelegate setTabBar:loginDic];
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [appDelegate setScrollTabBar:loginDic];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [appDelegate setTabBar:loginDic];
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [appDelegate setScrollTabBar:loginDic];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        [appDelegate setScrollTabBar:loginDic];
    }
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *newVersionStr = [appDelegate.serverVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    if (newVersionStr.length == 3) {
        newVersionStr = [newVersionStr stringByAppendingString:@"00"];
    }
    
    NSString *currentVersionStr=[versionStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (currentVersionStr.length == 3) {
        currentVersionStr = [currentVersionStr stringByAppendingString:@"00"];
    }
    NSLog(@"newVersionStr : %@",newVersionStr);
    NSLog(@"currentVersionStr : %@",currentVersionStr);
    NSLog(@"deployURL : %@",deployURL);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([appDelegate.serverVersion isEqualToString:@"#"]) {
        if(appDelegate.isMDM){
//            [self enterWorkApp];
            [self executeMDM];
        } else {
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
        }
        
    }else{
        if([prefs objectForKey:@"Update"]==nil){
            [prefs setValue:@"YES" forKey:@"Update"];
            [prefs synchronize];
        }
        
        if (!appDelegate.isOffLine) {
            if ([newVersionStr intValue]>[currentVersionStr intValue] && [[prefs objectForKey:@"Update"] isEqualToString:@"YES"]) {
                [SVProgressHUD dismiss];
                if ([forcedDownFlag isEqualToString:@"True"]) {
                    UIAlertView *alert;
                    if ([forcedDownMessage isEqualToString:@"#"]) {
                        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message128", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    }else{
                        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:forcedDownMessage delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    }
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message4", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
                    [alert show];
                }
            }else if([newVersionStr intValue]<[currentVersionStr intValue] && [[prefs objectForKey:@"Update"] isEqualToString:@"YES"]){
                [SVProgressHUD dismiss];
                if ([forcedDownFlag isEqualToString:@"True"]) {
                    UIAlertView *alert;
                    if ([forcedDownMessage isEqualToString:@"#"]) {
                        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message128", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    }else{
                        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:forcedDownMessage delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    }
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message97", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
                    [alert show];
                }
                
            } else {
                NSLog(@"updateApplication personalAgree : %@", personalAgree);
                if([personalAgree isEqualToString:@"F"]){
                    AgreementViewController *vc = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil];
                    vc.loginResult = @"SUCCEED";
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:vc animated:YES completion:nil];
                    
                } else {
                    if(appDelegate.isMDM) [self enterWorkApp];
                    else [appDelegate.window setRootViewController:appDelegate.tabBarController];
                }
            }
            
        }else{
            if(appDelegate.isMDM){
                [self executeMDM];
            } else {
                [appDelegate.window setRootViewController:appDelegate.tabBarController];
            }
        }
    }
}

-(void)executeMDM{
//    if([appDelegate.mdmFlag isEqualToString:@"T"]){
        NSURL *url = [NSURL URLWithString:@"com.gaia.mobikit.apple://"];

        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"MDM이 설치되지 않았습니다." preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];

                NSURL *url = [NSURL URLWithString:@"https://exafe.hshi.co.kr:8080/exafe_admin/download/agent"];
                [[UIApplication sharedApplication] openURL:url];
                exit(0);
            });

        } else {
            //MDM 실행 루틴
            if ([self getMDMExageInfo:@"queries_getStatus_getRichStatus_enterWorkApp"]) {

            }else{
                //MDM이 실행되지 않아 앱을 종료합니다.
                exit(0);
            }
        }

//    } else {
//        [appDelegate.window setRootViewController:appDelegate.tabBarController];
//    }
}

//- (void)MDMIntroNotification:(NSNotification *)notification{
//    [appDelegate.window setRootViewController:appDelegate.tabBarController];
//}

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
        NSLog(@"INTRO MDM urlString : %@",urlString);
        
        isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        return isBe;
        
    } else{
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

-(void)enterWorkApp{
    appDelegate.isExcuteMDM = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[prefs objectForKey:@"Lock"] forKey:@"preLock"];
    [prefs setObject:@"NO" forKey:@"Lock"];
    [prefs synchronize];
    
    appDelegate.mdmCallAPI = @"enterWorkApp";
    
//    NSString * stringURLScheme = nil;
//    BOOL isBe;
//    NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
//    if (URLTypes && [URLTypes count]) {
//        NSDictionary * dict = [URLTypes objectAtIndex:0];
//        NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
//        if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
//            stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
//        }
//    }
//
//    NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=enterWorkApp"];
//
//    [urlString appendFormat:@"&caller=%@", stringURLScheme];
//    NSLog(@"urlString : %@",urlString);
//    isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
    NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
    NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/enterWorkApp?authToken=%@&osType=IOS", authToken];
    NSLog(@"[%s] url : %@", __func__, urlString);
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
    NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];

    if([dataDic objectForKey:@"result"]){
        NSLog(@"MDM 업무앱 실행정책이 적용되었습니다.");
        [appDelegate.window setRootViewController:appDelegate.tabBarController];
    } else {
        NSLog(@"MDM 업무앱 실행정책이 적용되지 않았습니다.");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 실행정책이 적용되지 않았습니다.", @"MDM 업무앱 실행정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             exit(0);
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - File Upload
-(void)fileUploadNotification{
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
    if (readFile==nil) {
        [SVProgressHUD showSuccessWithStatus:@"Succeed"];
        NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
        documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
        documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
        
        documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
        NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:documentPath error:&error];
        
    }else{
        NSData *data = [readFile readDataToEndOfFile];
        NSString *readStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        readArray = [NSMutableArray arrayWithArray:[readStr componentsSeparatedByString:@"\n"]];
        [readArray removeLastObject];
        [self performSelectorOnMainThread:@selector(fileUpload:) withObject:[readArray objectAtIndex:0] waitUntilDone:YES];
    }
}

-(void)fileUpload:(NSString *)filePath {
	NSString *filename = [filePath lastPathComponent];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
	NSData *imageData = UIImageJPEGRepresentation(image,90);
	
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSArray *paths = [appDelegate.dmsHost pathComponents];
    
	if (appDelegate.fileSyncURL == nil || [appDelegate.fileSyncURL isEqualToString:@""]) {
        appDelegate.fileSyncURL = [NSString stringWithFormat:@"%@//%@/samples/PhotoSave",[paths objectAtIndex:0],[paths objectAtIndex:1]];
    }
    NSLog(@"upload url : %@",appDelegate.fileSyncURL);
	NSURL *url = [NSURL URLWithString:appDelegate.fileSyncURL];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection!=nil) {
        [SVProgressHUD showWithStatus:@"File Sync"];
    }
    [connection start];

}

#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
