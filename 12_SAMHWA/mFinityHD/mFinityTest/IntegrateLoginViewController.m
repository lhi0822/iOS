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
    NSFileManager *fileManager = [[NSFileManager alloc]init];
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
    NSString *lMainBgFilename=[appDelegate.lBgImagePath lastPathComponent];
    NSString *lSubBgFilename=[appDelegate.lSubBgImagePath lastPathComponent];
    NSString *lIntroBgFilename=[appDelegate.lIntroImagePath lastPathComponent];
    NSString *lLoginImageFilename=[appDelegate.lLoginImagePath lastPathComponent];
    
    NSString *iconBgFilename = [appDelegate.bgIconImagePath lastPathComponent];
    NSString *mainBgFilename = [appDelegate.bgImagePath lastPathComponent];
    NSString *subBgFilename = [appDelegate.subBgImagePath lastPathComponent];
    NSString *subOnButtonImageName = [appDelegate.subOnButtonPath lastPathComponent];
    NSString *subOffButtonImageName = [appDelegate.subOffButtonPath lastPathComponent];
    NSString *introBgFilename = [appDelegate.introImagePath lastPathComponent];
    NSString *loginImageFilename = [appDelegate.loginImagePath lastPathComponent];
    
    
    //NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //documentFolder = [documentFolder stringByAppendingPathComponent:@"icon"];
    NSString *loginBgfilePath = [iconSaveFolder stringByAppendingPathComponent:loginImageFilename];
    NSString *mainBgfilePath = [iconSaveFolder stringByAppendingPathComponent:mainBgFilename];
    NSString *subBgfilePath = [iconSaveFolder stringByAppendingPathComponent:subBgFilename];
    NSString *introfilePath = [iconSaveFolder stringByAppendingPathComponent:introBgFilename];
    NSString *subOnButtonfilePath = [iconSaveFolder stringByAppendingPathComponent:subOnButtonImageName];
    NSString *subOffButtonfilePath = [iconSaveFolder stringByAppendingPathComponent:subOffButtonImageName];
    NSString *iconBgfilePath = [iconSaveFolder stringByAppendingString:iconBgFilename];
    
    NSString *lLoginBgfilePath = [iconSaveFolder stringByAppendingPathComponent:lLoginImageFilename];
    NSString *lMainBgfilePath = [iconSaveFolder stringByAppendingPathComponent:lMainBgFilename];
    NSString *lSubBgfilePath = [iconSaveFolder stringByAppendingPathComponent:lSubBgFilename];
    NSString *lIntrofilePath = [iconSaveFolder stringByAppendingPathComponent:lIntroBgFilename];
    
    
    UIImage *mainBgImage = [UIImage imageWithContentsOfFile:mainBgfilePath];
    
    UIImage *subBgImage = [UIImage imageWithContentsOfFile:subBgfilePath];
    
    UIImage *onButtonImage = [UIImage imageWithContentsOfFile:subOnButtonfilePath];
    
    UIImage *offButtonImage = [UIImage imageWithContentsOfFile:subOffButtonfilePath];
    
    UIImage *introImage = [UIImage imageWithContentsOfFile:introfilePath];
    
    UIImage *loginBgImage = [UIImage imageWithContentsOfFile:loginBgfilePath];
    
    UIImage *iconBgImage = [UIImage imageWithContentsOfFile:iconBgfilePath];
    
    UIImage *lMainBgImage = [UIImage imageWithContentsOfFile:lMainBgfilePath];
    UIImage *lSubBgImage = [UIImage imageWithContentsOfFile:lSubBgfilePath];
    UIImage *lIntroImage = [UIImage imageWithContentsOfFile:lIntrofilePath];
    UIImage *lLoginBgImage = [UIImage imageWithContentsOfFile:lLoginBgfilePath];
    
    NSData *data=nil;
    NSData *encryptData = nil;
    if (![fileManager isReadableFileAtPath:mainBgfilePath] || ![fileManager isReadableFileAtPath:subBgfilePath] || ![fileManager isReadableFileAtPath:subOnButtonfilePath]||
        ![fileManager isReadableFileAtPath:subOffButtonfilePath]||![fileManager isReadableFileAtPath:introfilePath]||![fileManager isReadableFileAtPath:loginBgfilePath]||![fileManager isReadableFileAtPath:iconBgfilePath] || ![fileManager isReadableFileAtPath:lMainBgfilePath] || ![fileManager isReadableFileAtPath:lSubBgfilePath] || ![fileManager isReadableFileAtPath:lIntrofilePath] || ![fileManager isReadableFileAtPath:lLoginBgfilePath]) {
        
        
        NSLog(@"downloading");
        mainBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.bgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(mainBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:mainBgfilePath atomically:YES];
        
        subBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.subBgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(subBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:subBgfilePath atomically:YES];
        
        onButtonImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.subOnButtonPath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(onButtonImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:subOnButtonfilePath atomically:YES];
        
        offButtonImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.subOffButtonPath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(offButtonImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:subOffButtonfilePath atomically:YES];
        
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
        
        lMainBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.lBgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(lMainBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:lMainBgfilePath atomically:YES];
        
        lSubBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.lSubBgImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(lSubBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:lSubBgfilePath atomically:YES];
        
        lIntroImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.lIntroImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(lIntroImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:lIntrofilePath atomically:YES];
        
        lLoginBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.lLoginImagePath]]];
        data = [NSData dataWithData:UIImagePNGRepresentation(lLoginBgImage)];
        encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [encryptData writeToFile:lLoginBgfilePath atomically:YES];
    }
    appDelegate.bgImagePath = mainBgfilePath;
    appDelegate.subBgImagePath = subBgfilePath;
    appDelegate.subOnButtonPath = subOnButtonfilePath;
    appDelegate.subOffButtonPath = subOffButtonfilePath;
    appDelegate.loginImagePath = loginBgfilePath;
    appDelegate.bgIconImagePath = iconBgfilePath;
    
    appDelegate.lBgImagePath = lMainBgfilePath;
    appDelegate.lSubBgImagePath = lSubBgfilePath;
    appDelegate.lIntroImagePath = lIntrofilePath;
    appDelegate.lLoginImagePath = lLoginBgfilePath;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:introfilePath forKey:@"IntroImagePath"];
    [prefs setObject:lIntrofilePath forKey:@"LIntroImagePath"];
    [prefs setObject:mainBgfilePath forKey:@"MainBgFilePath"];
    [prefs setObject:lMainBgfilePath forKey:@"LMainBgFilePath"];
    [prefs setObject:subBgfilePath forKey:@"SubBgFilePath"];
    [prefs setObject:lSubBgfilePath forKey:@"LSubBgFilePath"];
    [prefs setObject:subOnButtonfilePath forKey:@"SubOnButtonFilePath"];
    [prefs setObject:subOffButtonfilePath forKey:@"SubOffButtonFilePath"];
    [prefs setObject:loginBgfilePath forKey:@"LoginImagePath"];
    [prefs setObject:lLoginBgfilePath forKey:@"LLoginImagePath"];
    [prefs setObject:appDelegate.tabBarColor forKey:@"TabBarColor"];
    [prefs synchronize];
    //[prefs setObject:htmlFilePath forKey:@"HtmlFilePath"];
    
    NSError *error;
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
    
    NSPropertyListFormat format;
    NSDictionary *currentWebAppDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    
    NSFileManager *manager =[NSFileManager defaultManager];
    NSData *webApp_data = [appDelegate.htmlPath dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *webAppDic = [NSJSONSerialization JSONObjectWithData:webApp_data options:kNilOptions error:&error];
    
    NSLog(@"error : %@",error);
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
        [prefs synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    
    NSMutableDictionary *dic;
    if (currentWebAppDic==nil) {
        dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[webAppDic objectForKey:@"RES_VER"],@"RES_VER",nil];
        
    }else{
        dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
        [dic setObject:[webAppDic objectForKey:@"RES_VER"] forKey:@"RES_VER"];
        
    }
    [dic writeToFile:filePath atomically:YES];
    [prefs synchronize];
    
    return YES;
}

- (NSString *)resultUserCheck:(NSDictionary *)loginDic{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result=nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    @try{
        result = [loginDic objectForKey:@"V1"];
        if ([result isEqualToString:@"SUCCEED"]) {
            appDelegate.isLogin = YES;
            appDelegate.passWord = pwd;
            appDelegate.user_id = userid;
            appDelegate.user_no = [loginDic objectForKey:@"V2"];
            appDelegate.comp_no = [loginDic objectForKey:@"V3"];
            [prefs setObject:[appDelegate.comp_no AES256EncryptWithKeyString:appDelegate.AES256Key] forKey:@"COMP_NO"];
            appDelegate.root_menu_no = [loginDic objectForKey:@"V4"];
            appDelegate.app_name = [loginDic objectForKey:@"V5"];
            appDelegate.app_no = [loginDic objectForKey:@"V5_1"];
            appDelegate.app_ci = [loginDic objectForKey:@"V5_2"];
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
            appDelegate.lBgImagePath = [loginDic objectForKey:@"V10_1"];
            
            
            appDelegate.mainFontColor = [loginDic objectForKey:@"V11"];
            appDelegate.mainIsShadow = [loginDic objectForKey:@"V11_1"];
            appDelegate.mainShadowColor = [loginDic objectForKey:@"V11_2"];
            appDelegate.mainShadowOffset = [loginDic objectForKey:@"V11_3"];
            
            [prefs setObject:appDelegate.mainFontColor forKey:@"MAINFONTCOLOR"];
            appDelegate.bgIconImagePath = [loginDic objectForKey:@"V11_4"];
            appDelegate.subBgImagePath = [loginDic objectForKey:@"V12"];
            appDelegate.lSubBgImagePath = [loginDic objectForKey:@"V12_1"];
            appDelegate.subFontColor = [loginDic objectForKey:@"V13"];
            appDelegate.subIsShadow = [loginDic objectForKey:@"V13_1"];
            appDelegate.subShadowColor = [loginDic objectForKey:@"V13_2"];
            appDelegate.subShadowOffset = [loginDic objectForKey:@"V13_3"];
            appDelegate.subOffButtonPath = [loginDic objectForKey:@"V14"];
            appDelegate.subOnButtonPath = [loginDic objectForKey:@"V15"];
            appDelegate.introImagePath = [loginDic objectForKey:@"V16"];
            appDelegate.lIntroImagePath = [loginDic objectForKey:@"V16_2"];
            appDelegate.loginImagePath = [loginDic objectForKey:@"V17"];
            appDelegate.lLoginImagePath = [loginDic objectForKey:@"V17_1"];
            
            NSLog(@"lIntroImagePath :  %@", appDelegate.lIntroImagePath);
            NSLog(@"loginImagePath : %@", appDelegate.loginImagePath);
            NSLog(@"lLoginImagePath : %@", appDelegate.lLoginImagePath);
            
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
            appDelegate.mainType = [loginDic objectForKey:@"V20"];
            appDelegate.htmlPath = [loginDic objectForKey:@"V30"];
            NSString *webAppMenus = [loginDic objectForKey:@"V31"];
            appDelegate.offLineInfo = [loginDic objectForKey:@"V40"];
            appDelegate.serverVersion = [loginDic objectForKey:@"V90"];
            deployURL = [loginDic objectForKey:@"V91"];
            forcedDownFlag =[loginDic objectForKey:@"V92"];
            forcedDownMessage =[loginDic objectForKey:@"V93"];
            tabInfo = [loginDic objectForKey:@"V100"];
            NSString *stoken = [loginDic objectForKey:@"STOKEN"];
            NSString *ipaddr = [loginDic objectForKey:@"IPADDR"];
            [prefs setObject:stoken forKey:@"STOKEN"];
            [prefs setObject:ipaddr forKey:@"IPADDR"];
            NSError * error;
            if (webAppMenus!=nil) {
                NSData *webAppData = [webAppMenus dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *webAppDic = [NSJSONSerialization JSONObjectWithData:webAppData options:kNilOptions error:&error];
                
                
                NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                filePath = [filePath stringByAppendingFormat:@"/%@/webapp/",appDelegate.comp_no];
                
                NSMutableArray * directoryContents = [NSMutableArray arrayWithArray:[manager contentsOfDirectoryAtPath:filePath error:&error]];
                [directoryContents removeObject:@"common"];
                NSLog(@"directory 1 : %@",directoryContents);
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
                save = [save stringByAppendingFormat:@"/ezLoginSHP"];
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
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message6", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
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
            
        }else if([result isEqualToString:@"EXPIRED"]){
            appDelegate.isLogin = NO;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message202", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }else{
            appDelegate.isLogin = NO;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
        }
        
    } @catch(NSException *e){
//        [appDelegate loginErrorToLogFile:@"resultUserCheck" :e];
    }
    
    return result;
}
- (void)updateApplication{
    NSError *error;
    NSData *login_data = [tabInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *loginDic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
    NSLog(@"tabDic : %@",loginDic);
    appDelegate.isLogin = YES;
    [appDelegate setTabBar:loginDic];
    
    if (isSubscriptionSucceed) {
        [self syncAgent];
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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([appDelegate.serverVersion isEqualToString:@"#"]) {
        [appDelegate.window setRootViewController:appDelegate.tabBarController];
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
            }else{
                [appDelegate.window setRootViewController:appDelegate.tabBarController];
            }
            
        }else{
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
            
        }
        
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
        
        [self deleteSubscription];
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
- (void) deleteSubscription{
    NSLog(@"deleteSubscription");
    NSString *urlString = [NSString stringWithFormat:@"%@/deleteSubscription",appDelegate.main_url];
    NSString *paramString = [NSString stringWithFormat:@"cuser_no=%@&encType=AES256",appDelegate.user_no];
    NSData *postData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody: postData];
    [urlRequest setTimeoutInterval:15.0];
    NSLog(@"deleteSubscription urlString : %@",urlString);
    NSLog(@"deleteSubscription paramString : %@",paramString);
    receiveData = [[NSMutableData alloc]init];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
}
#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
