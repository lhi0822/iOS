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
//    NSString *introBgFilename = [appDelegate.introImagePath lastPathComponent];
//    NSString *loginImageFilename = [appDelegate.loginImagePath lastPathComponent];
    

    //그룹사수정
//    NSString *introfilePath = [iconSaveFolder stringByAppendingPathComponent:introBgFilename];
//    NSString *loginBgfilePath = [iconSaveFolder stringByAppendingPathComponent:loginImageFilename];

    NSString *mainBgfilePath = [iconSaveFolder stringByAppendingPathComponent:mainBgFilename];
    NSString *subBgfilePath = [iconSaveFolder stringByAppendingPathComponent:subBgFilename];
    NSString *iconBgfilePath = [iconSaveFolder stringByAppendingString:iconBgFilename];
    
    UIImage *mainBgImage = [UIImage imageWithContentsOfFile:mainBgfilePath];
    UIImage *subBgImage = [UIImage imageWithContentsOfFile:subBgfilePath];
    
    //그룹사수정
//    UIImage *introImage = [UIImage imageWithContentsOfFile:introfilePath];
//    UIImage *loginBgImage = [UIImage imageWithContentsOfFile:loginBgfilePath];
    
    UIImage *iconBgImage = [UIImage imageWithContentsOfFile:iconBgfilePath];
    
    NSData *data=nil;
    NSData *encryptData = nil;
    if (![fileManager isReadableFileAtPath:mainBgfilePath] || ![fileManager isReadableFileAtPath:subBgfilePath] || ![fileManager isReadableFileAtPath:iconBgfilePath]) {
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
//        introImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.introImagePath]]];
//        data = [NSData dataWithData:UIImagePNGRepresentation(introImage)];
//        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
//        [encryptData writeToFile:introfilePath atomically:YES];
//
//        loginBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.loginImagePath]]];
//        data = [NSData dataWithData:UIImagePNGRepresentation(loginBgImage)];
//        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
//        [encryptData writeToFile:loginBgfilePath atomically:YES];
        
        iconBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.bgIconImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(iconBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:iconBgfilePath atomically:YES];
    }
    appDelegate.bgImagePath = mainBgfilePath;
    appDelegate.subBgImagePath = subBgfilePath;
    //그룹사수정
//    appDelegate.loginImagePath = loginBgfilePath;
    appDelegate.bgIconImagePath = iconBgfilePath;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //그룹사수정
//    [prefs setObject:introfilePath forKey:@"IntroImagePath"];
//    [prefs setObject:loginBgfilePath forKey:@"LoginImagePath"];
//    NSLog(@"loginBgfilePath : %@",loginBgfilePath);
    
    [prefs setObject:mainBgfilePath forKey:@"MainBgFilePath"];
    [prefs setObject:subBgfilePath forKey:@"SubBgFilePath"];
    [prefs setObject:appDelegate.tabBarColor forKey:@"TabBarColor"];
    
    NSError *error;
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
- (NSString*) getUUID
{
    // initialize keychaing item for saving UUID.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0){
        // if there is not UUID in keychain, make UUID and save it.
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);
        
        // save UUID in keychain
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }
    
    return uuid;
}

- (NSString *)resultUserCheck:(NSDictionary *)loginDic{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [loginDic objectForKey:@"V1"];
    
//    if ([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]) {
//        userid = [prefs objectForKey:@"UserInfo_ID"];
//        pwd = [prefs objectForKey:@"UserInfo_PWD"];
//    }
    
    NSLog(@"userid : %@",userid);
    NSLog(@"pwd : %@",pwd);
    
    NSLog(@"loginDic : %@", loginDic);
    
    personalAgree = nil;
    
    if([prefs objectForKey:@"LOGIN_FAILED"]==nil){
        NSLog(@"로그인실패 키가 없으면 0으로 세팅");
        [prefs setInteger:0 forKey:@"LOGIN_FAILED"];
        [prefs synchronize];
    }
    
    if([self loginFailCheck:result]){
        if ([result isEqualToString:@"SUCCEED"]) {
            appDelegate.isLogin = YES;
            appDelegate.passWord = pwd;
            //appDelegate.user_id = userid;
            appDelegate.user_id = [loginDic objectForKey:@"V2_1"];
            appDelegate.user_no = [loginDic objectForKey:@"V2"];
            appDelegate.exCompany = [loginDic objectForKey:@"V2_4"];
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
            //appDelegate.introImagePath = [loginDic objectForKey:@"V16"];
            //appDelegate.loginImagePath = [loginDic objectForKey:@"V17"];
            
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
            
            personalAgree = [loginDic objectForKey:@"V2_3"];
            NSLog(@"succeed일때 v2_3 : %@", personalAgree);
    //        personalAgree = @"F";
            
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
            
        } else {
            if([result isEqualToString:@"NOTCERT"]){
                appDelegate.isLogin = YES;
                appDelegate.passWord = pwd;
                appDelegate.user_id = userid;
                appDelegate.noAuth = [loginDic objectForKey:@"V6"];
                personalAgree = [loginDic objectForKey:@"V2_3"];
        //        personalAgree = @"F";
                NSLog(@"notcert일때 v2_3 : %@", personalAgree);
                
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
        }
        
        return result;
        
    } else {
//        NSLog(@"리턴없음");
        isButtonClick = NO;
        return nil;
    }
    
    //return result;
}

-(BOOL)loginFailCheck:(NSString *)result{
    NSLog(@"%s", __func__);
    
    int currFailCnt = 0;
    BOOL value = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //여기에 현재시간 저장
    NSDate *now = [NSDate date];
    [prefs setObject:now forKey:@"CURR_LOGIN_DATE"];
    [prefs synchronize];
    
    if([result isEqualToString:@"FAILED"]) {
        currFailCnt = [[prefs objectForKey:@"LOGIN_FAILED"] intValue];
        currFailCnt++;
        [prefs setInteger:currFailCnt forKey:@"LOGIN_FAILED"];
        [prefs synchronize];
        NSLog(@"1. 로그인실패 키 값 : %d", [[prefs objectForKey:@"LOGIN_FAILED"] intValue]);
        NSLog(@"1-1. 로그인 실패 날짜 : %@", [prefs objectForKey:@"FAIL_LOGIN_DATE"]);
        
        if([prefs objectForKey:@"FAIL_LOGIN_DATE"]!=nil){
            NSDate *currLoginDate = [prefs objectForKey:@"CURR_LOGIN_DATE"];
            NSDate *failLoginDate = [prefs objectForKey:@"FAIL_LOGIN_DATE"];

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
            NSString *failStr = [dateFormatter stringFromDate:failLoginDate];
            NSString *currStr = [dateFormatter stringFromDate:currLoginDate];
            
            double fail = [failStr doubleValue];
            double curr = [currStr doubleValue];

            int compare = curr - fail;
            NSLog(@"**시간차이 : %d",compare);

            if(compare>=appDelegate.loginLockTime){
                NSLog(@"10분이 지나면 FailedCount, FailLoginDate를 초기화 해준다.");
                [prefs setInteger:0 forKey:@"LOGIN_FAILED"];
                [prefs removeObjectForKey:@"FAIL_LOGIN_DATE"];
                [prefs synchronize];

                currFailCnt = 0;
                currFailCnt++;
                [prefs setInteger:currFailCnt forKey:@"LOGIN_FAILED"];
                [prefs synchronize];
            }
        } else {
//            NSLog(@"로그인 날짜 없으니까 지금으로 저장?");
        }
        
        if(currFailCnt<appDelegate.loginFailCnt){
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"login_failed1", @"login_failed1"), [[prefs objectForKey:@"LOGIN_FAILED"] intValue], appDelegate.loginFailCnt, appDelegate.loginFailCnt, appDelegate.loginLockTime];
//            [self showToastView:msg];
            [self showLoginFailAlert:NSLocalizedString(@"login_failed_title1", @"login_failed_title1") message:msg];
        }
    }

    NSLog(@"2. 로그인실패 키 값 : %d", [[prefs objectForKey:@"LOGIN_FAILED"] intValue]);
    NSLog(@"2-1. 로그인 실패 날짜 : %@", [prefs objectForKey:@"FAIL_LOGIN_DATE"]);
    if([[prefs objectForKey:@"LOGIN_FAILED"] intValue]==appDelegate.loginFailCnt){
        NSLog(@"2. 5번째 실패했을때 시간 저장");
        [prefs setObject:now forKey:@"FAIL_LOGIN_DATE"];
        [prefs synchronize];

        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"login_failed2", @"login_failed2"), [[prefs objectForKey:@"LOGIN_FAILED"] intValue], appDelegate.loginLockTime, appDelegate.loginLockTime];
//        [self showToastView:msg];
        [self showLoginFailAlert:NSLocalizedString(@"login_failed_title2", @"login_failed_title2") message:msg];
        
        NSString *urlString;
        NSData *paramData;
        NSString *paramString;

        NSString *encodingID = [FBEncryptorAES encryptBase64String:userid
                                                         keyString:appDelegate.AES256Key
                                                     separateLines:NO];
        encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSString *dvcid = [MFinityAppDelegate getUUID];

        if (appDelegate.isAES256) {
            urlString = @"https://dev.hhi.co.kr:44175/dataservice41/userAuthLock";
            paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcid=%@&encType=AES256",encodingID, [prefs objectForKey:@"UUID"]];

        }else{
            urlString = @"https://dev.hhi.co.kr:44175/dataservice41/userAuthLock";
            paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcid=%@",encodingID, [prefs objectForKey:@"UUID"]];
        }

        paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSMutableString *str = [NSMutableString stringWithString:urlString];

        NSRange range = [str rangeOfString:@" "];
        while (range.location !=NSNotFound) {
            [str replaceCharactersInRange:range withString:@"%20"];
            range = [str rangeOfString:@" "];
        }
        urlString = str;

        NSLog(@"urlString : %@",urlString);
        NSLog(@"paramString : %@",paramString);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: paramData];
        [request setTimeoutInterval:10.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlCon start];
        
        value = NO;

    } else if([[prefs objectForKey:@"LOGIN_FAILED"] intValue]>appDelegate.loginFailCnt){
        NSLog(@"3. 로그인 성공해도 실패가 5번이라서 10분 기다려야함");
        NSDate *currLoginDate = [prefs objectForKey:@"CURR_LOGIN_DATE"];
        NSDate *failLoginDate = [prefs objectForKey:@"FAIL_LOGIN_DATE"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
        NSString *failStr = [dateFormatter stringFromDate:failLoginDate];
        NSString *currStr = [dateFormatter stringFromDate:currLoginDate];
        NSLog(@"currLoginDate : %@, failLoginDate: %@", currStr, failStr);

        double fail = [failStr doubleValue];
        double curr = [currStr doubleValue];
        NSLog(@"int currLoginDate : %f, failLoginDate: %f", curr, fail);

        int compare = curr - fail;
        NSLog(@"시간차이 : %d",compare);

        if(compare>=appDelegate.loginLockTime){
            NSLog(@"4. 10분이 지나면 FailedCount, FailLoginDate를 초기화 해준다.");
            [prefs setInteger:0 forKey:@"LOGIN_FAILED"];
            [prefs removeObjectForKey:@"FAIL_LOGIN_DATE"];
            [prefs synchronize];

            currFailCnt = 0;
            currFailCnt++;
            [prefs setInteger:currFailCnt forKey:@"LOGIN_FAILED"];
            [prefs synchronize];
            
            if(currFailCnt<appDelegate.loginFailCnt){
//                NSString *msg = [NSString stringWithFormat:@"비밀번호 입력 오류(%d/%d)", currFailCnt, appDelegate.loginFailCnt];
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"login_failed1", @"login_failed1"), currFailCnt, appDelegate.loginFailCnt, appDelegate.loginFailCnt, appDelegate.loginLockTime];
//                [self showToastView:msg];
                [self showLoginFailAlert:NSLocalizedString(@"login_failed_title1", @"login_failed_title1") message:msg];
            }

            value = NO;

        } else if(compare<appDelegate.loginLockTime) {
            NSLog(@"5. %d분 남았습니다.",compare);
//            NSString *msg = [NSString stringWithFormat:@"%d분 뒤 다시 로그인 해주세요.", appDelegate.loginLockTime-compare];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"login_failed2", @"login_failed2"), appDelegate.loginFailCnt, appDelegate.loginLockTime, appDelegate.loginLockTime-compare];
//            [self showToastView:msg];
            [self showLoginFailAlert:NSLocalizedString(@"login_failed_title2", @"login_failed_title2") message:msg];

            value = NO;
        }
    
    } else {
        NSLog(@"6. 일단 5번 채우기 전까지는 여기로?");
        
        if([result isEqualToString:@"FAILED"]){
            value = NO;

        } else if([result isEqualToString:@"SUCCEED"]){
            NSLog(@"8. 로그인 성공 시에는 FailedCount를 초기화 해준다.");
            [prefs setInteger:0 forKey:@"LOGIN_FAILED"];
            [prefs removeObjectForKey:@"FAIL_LOGIN_DATE"];
            [prefs synchronize];
            
            value = YES;
            
        } else {
            value = YES;
        }
    }
    
    return value;
}

- (void)updateApplication{
    NSError *error;
    NSData *login_data = [tabInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *loginDic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
    //NSLog(@"tabDic : %@",loginDic);
    appDelegate.isLogin = YES;
    
    //2018.06 UI개선
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
        if(appDelegate.isMDM) [self enterWorkApp];
        else [appDelegate.window setRootViewController:appDelegate.tabBarController];
        
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
        }else {
            if(appDelegate.isMDM) [self enterWorkApp];
            else [appDelegate.window setRootViewController:appDelegate.tabBarController];
        }
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

-(void)showToastView:(NSString *)msg{
    UIButton *toastBtn = [[UIButton alloc] initWithFrame:CGRectMake(30,30,self.view.frame.size.width-60,30)];
    toastBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    toastBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    toastBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    toastBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont boldSystemFontOfSize:14], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName,
//                                nil];
//    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:title attributes:attributes];
//    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont systemFontOfSize:14], NSFontAttributeName,
//                                [UIColor whiteColor], NSForegroundColorAttributeName,
//                                nil];
//    NSAttributedString *attr2 = [[NSAttributedString alloc] initWithString:msg attributes:attributes2];
//    NSMutableAttributedString *attr3 = [[NSMutableAttributedString alloc] init];
//    [attr3 appendAttributedString:attr1];
//    [attr3 appendAttributedString:attr2];
//    [toastLabel setAttributedTitle:attr3 forState:UIControlStateNormal];
    
    [toastBtn setTitle:msg forState:UIControlStateNormal];
    [toastBtn setTitleEdgeInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
    toastBtn.alpha = 1.0;
    toastBtn.layer.cornerRadius = 18;
    toastBtn.clipsToBounds = YES;
    toastBtn.tag = 99;
    
    [toastBtn sizeToFit];
    
    [toastBtn setFrame:CGRectMake(30, self.view.frame.size.height-toastBtn.frame.size.height-80, self.view.frame.size.width-60, toastBtn.frame.size.height+40)];
    
    if([self.view viewWithTag:99]){
        [[self.view viewWithTag:99] removeFromSuperview];
    }
    
    [self.view addSubview:toastBtn];
    [UIView animateWithDuration:3.0 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toastBtn.alpha = 0.0;
    } completion:^(BOOL finished) {
        [toastBtn removeFromSuperview];
    }];
}

-(void)showLoginFailAlert:(NSString *)title message:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

