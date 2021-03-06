//
//  MFUtil.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFUtil.h"
#import "AppDelegate.h"

@implementation MFUtil

#pragma mark - UI
//네비게이션 타이틀(White)
+(UILabel *)navigationTitleStyle:(UIColor *)color title:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = color;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    
    return titleLabel;
}

+(UITabBarController *)setDefualtTabBar{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    
    //탭바 아이콘 설정
    int tabCnt=0;
    if([legacyNm isEqualToString:@"NONE"]) {
        tabCnt = 4;
        
        NSMutableArray *tbViewControllers = [NSMutableArray arrayWithArray:[tabBarController viewControllers]];
        [tbViewControllers removeObjectAtIndex:3];
        [tabBarController setViewControllers:tbViewControllers];
        
    } else if([legacyNm isEqualToString:@"ANYMATE"]) {
        tabCnt = 5;
        
    } else if([legacyNm isEqualToString:@"HHI"]) {
        tabCnt = 4;
        //        tabCnt = 5;
        
        NSMutableArray *tbViewControllers = [NSMutableArray arrayWithArray:[tabBarController viewControllers]];
        [tbViewControllers removeObjectAtIndex:3];
        [tabBarController setViewControllers:tbViewControllers];
        
        //        UINavigationController *nav = [[UINavigationController alloc] init];
        //        [tbViewControllers addObject:nav];
        //        [tabBarController setViewControllers:tbViewControllers];
    }
    
    for(int i=0; i<tabCnt; i++){
        UITabBarItem *item = [tabBarController.tabBar.items objectAtIndex:i];
        item.title = nil;
        //item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] } forState:UIControlStateNormal];
    }
    
    UITabBarItem *item1 = [tabBarController.tabBar.items objectAtIndex:0];
    item1.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *feedSelectImg;
    if (@available(iOS 13.0, *)) {
        feedSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        feedSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    item1.selectedImage = feedSelectImg;
//    item1.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.tag = 1;
    item1.title = NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed");
    
    UITabBarItem *item2 = [tabBarController.tabBar.items objectAtIndex:1];
    item2.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *homeSelectImg;
    if (@available(iOS 13.0, *)) {
        homeSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        homeSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    item2.selectedImage = homeSelectImg;
//    item2.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.tag = 2;
    item2.title = NSLocalizedString(@"tab_home", @"tab_home");
    
    UITabBarItem *item3 = [tabBarController.tabBar.items objectAtIndex:2];
    item3.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *chatSelectImg;
    if (@available(iOS 13.0, *)) {
        chatSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        chatSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    item3.selectedImage = chatSelectImg;
//    item3.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.tag = 3;
    item3.title = NSLocalizedString(@"tab_chat", @"tab_chat");
    
    if([legacyNm isEqualToString:@"NONE"]){
        UITabBarItem *item5 = [tabBarController.tabBar.items objectAtIndex:3];
        item5.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *profileSelectImg;
        if (@available(iOS 13.0, *)) {
            profileSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            profileSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        item5.selectedImage = profileSelectImg;
//        item5.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item5.tag = 4;
        item5.title = NSLocalizedString(@"tab_myinfo", @"tab_myinfo");
    }
    else if([legacyNm isEqualToString:@"ANYMATE"]){
        UITabBarItem *item4 = [tabBarController.tabBar.items objectAtIndex:3];
        item4.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_anymate.png"] scaledToMaxWidth:27.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        UIImage *anymateSelectImg;
//        if (@available(iOS 13.0, *)) {
//            anymateSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_anymate_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
//        } else {
//            anymateSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_anymate_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        }
//        item4.selectedImage = anymateSelectImg;
        item4.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_anymate_over.png"] scaledToMaxWidth:27.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item4.tag = 4;
        item4.title = @"Anymate";
        
        UITabBarItem *item5 = [tabBarController.tabBar.items objectAtIndex:4];
        item5.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *profileSelectImg;
        if (@available(iOS 13.0, *)) {
            profileSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            profileSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        item5.selectedImage = profileSelectImg;
//        item5.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item5.tag = 5;
        item5.title = NSLocalizedString(@"tab_myinfo", @"tab_myinfo");
    }
    else if([legacyNm isEqualToString:@"HHI"]){
        UITabBarItem *item5 = [tabBarController.tabBar.items objectAtIndex:3];
        item5.image = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *profileSelectImg;
        if (@available(iOS 13.0, *)) {
            profileSelectImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            profileSelectImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        item5.selectedImage = profileSelectImg;
//        item5.selectedImage = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:24.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item5.tag = 4;
        item5.title = NSLocalizedString(@"tab_myinfo", @"tab_myinfo");
    }
    
    NSString *userId = [prefs objectForKey:@"USERID"];
    NSArray *tabArr = [prefs objectForKey:[NSString stringWithFormat:@"%@_TABITEM",userId]];
    NSMutableArray *tmpArray = [NSMutableArray array];
//    NSLog(@"tabArr : %@",tabArr);
    if(tabArr != nil){
        for(int i=0; i<tabArr.count; i++){
            NSString *item = [tabArr objectAtIndex:i];
            int key = [item intValue]-1;
//            NSLog(@"tab key : %d",key);
            UINavigationController *tmp = [tabBarController.viewControllers objectAtIndex:key];
            [tmpArray addObject:tmp];
        }
        [tabBarController setViewControllers:tmpArray];
    }
    
    return tabBarController;
}

+ (UIColor *) myRGBfromHex: (NSString *) code{
    NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
        return [UIColor blackColor];
    
    // 0x로 시작하면 0x를 지워준다.
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    
    // #으로 시작해도 #을 지워준다.
    
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
        return [UIColor blackColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rcolorString = [str substringWithRange:range];
    range.location = 2;
    NSString *gcolorString = [str substringWithRange:range];
    range.location = 4;
    NSString *bcolorString = [str substringWithRange:range];
    unsigned int red, green, blue;
    [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
    [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
    [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
    
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];

}

//그라데이션 레이어 생성
+(CAGradientLayer *)setImageGradient:(CGRect)frame startPoint:(CGPoint)st endPoint:(CGPoint)ed colors:(NSArray *)colors{
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = frame;
    gradientMask.startPoint = st;
    gradientMask.endPoint = ed;
    gradientMask.colors = colors;
    return gradientMask;
}

+(UIImage *)changeImgColor:(UIImage *)img{
    UIColor *color = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, img.size.width, img.size.height));

    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;;
}

//최상위 뷰
+(UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}
+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }

  if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }

  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
}

#pragma mark - Information
+ (BOOL)isRooted{
#if (TARGET_OS_SIMULATOR)
    return NO;
#else
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: @"/Applications/Cydia.app"]||
        [fileManager fileExistsAtPath: @"/Applications/RockApp.app"]||
        [fileManager fileExistsAtPath: @"/Applications/Icy.app"]||
        [fileManager fileExistsAtPath: @"/Applications/FakeCrrier.app"]||
        [fileManager fileExistsAtPath: @"/Applications/WinterBoard.app"]||
        [fileManager fileExistsAtPath: @"/Applications/SBSettings.app"]||
        [fileManager fileExistsAtPath: @"/Applications/MxTube.app"]||
        [fileManager fileExistsAtPath: @"/Applications/InteliScreen.app"]||
        [fileManager fileExistsAtPath: @"/Applications/blackra1n.app"]||
        [fileManager fileExistsAtPath: @"/Applications/.app"]||
        [fileManager fileExistsAtPath: @"/usr/sbin/sshd"]||
        [fileManager fileExistsAtPath: @"/usr/bin/sshd"]||
        [fileManager fileExistsAtPath: @"/usr/libexec/sftp-server"]||
        [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist"]||
        [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist"]||
        [fileManager fileExistsAtPath: @"/private/var/lib/apt"]||
        [fileManager fileExistsAtPath: @"/private/var/stash"]||
        [fileManager fileExistsAtPath: @"/private/var/mobile/Library/SBSettings/Themes"]||
        [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.ikey.bbot.plist"]||
        [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"]||
        [fileManager fileExistsAtPath: @"/private/var/tmp/cydia.log"]||
        [fileManager fileExistsAtPath: @"/private/var/lib/cydia"]) {
        return YES;
    }else{
        return NO;
    }
#endif
}

+ (BOOL) retinaDisplayCapable
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    
    if(scale == 2.0f) return YES;
    else return NO;
}
+ (NSString *) getUUID
{
    // initialize keychaing item for saving UUID.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0)
    {
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

+(NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
//                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                NSLog(@"IP ADDRESS : %@", address);
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+(NSString *)getDevPlatformNumber{
    NSString *modelStr = [[[UIDevice currentDevice] modelIdentifier] stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
    NSArray *modelIdArr = [modelStr componentsSeparatedByString:@","];
//    NSLog(@"modelStr : %@", modelStr);
    
    NSString *platformNumber = [modelIdArr objectAtIndex:0];
    int modelNum = [platformNumber intValue];
    if(modelNum <= 6){
        //5s 이하
    } else if(modelNum > 6 && modelNum < 10){
        //6~7
        if([modelStr isEqualToString:@"8,4"]){ //SE
            platformNumber = @"5";
        }
        if([modelStr isEqualToString:@"7,1"]||[modelStr isEqualToString:@"8,2"]||[modelStr isEqualToString:@"9,2"]||[modelStr isEqualToString:@"9,4"]){ //6,7 plus
            platformNumber = @"10";
        }
    } else {
        //8시리즈이상
        if([modelStr isEqualToString:@"10,1"]||[modelStr isEqualToString:@"10,4"]){ //8
            platformNumber = @"9";
        }
        if([modelStr isEqualToString:@"12,8"]){ //SE2
            platformNumber = @"9";
        }
    }
    return platformNumber;
}

+(NSString *)getMfpsId{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId = [prefs objectForKey:@"USERID"];
    
    NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[prefs objectForKey:@"COMP_NO"], [prefs objectForKey:@"USERID"], [prefs objectForKey:[prefs objectForKey:[NSString stringWithFormat:@"%@_DVCID",userId]]]];
    return mfpsId;
}

+(NSString *)getChatRoutingKey:(NSString *)roomNo{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *routingKey = [NSString stringWithFormat:@"%@.CHAT.%@.%@", [[MFSingleton sharedInstance] appType], [prefs objectForKey:@"COMP_NO"], roomNo];
    return routingKey;
}

#pragma mark - Local
+(NSString *)getFolderName:(NSString *)type{
    NSString *folder = @"";
    if([type isEqualToString:@"IMG"]) folder = @"Image";
    else if([type isEqualToString:@"VIDEO"]) folder = @"Video";
    else if([type isEqualToString:@"VIDEO_THUMB"]) folder = @"Video";
    else if([type isEqualToString:@"FILE"]) folder = @"File";
    
    else if([type isEqualToString:@"CHAT"]) folder = @"Chat";
    else if([type isEqualToString:@"POST"]) folder = @"Post";
    else if([type isEqualToString:@"COMMENT"]) folder = @"Comment";
    
    return folder;
}
//+(UIImage *)saveThumbImage :(NSString *)folder :(NSString *)thumbFilePath{
+(UIImage *)saveThumbImage:(NSString *)folder path:(NSString *)thumbFilePath num:(NSString *)paramNo{
    //이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
    //NSString *savePath = [NSString stringWithFormat:@"%@/%@/",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], folder];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *savePath = nil;
    if(paramNo!=nil){
        savePath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [prefs objectForKey:@"COMP_NO"], folder, paramNo];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isReadable = [fileManager isReadableFileAtPath:savePath];
        if (!isReadable) {
            [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    } else {
        savePath = [NSString stringWithFormat:@"%@/%@/%@/%@/", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [prefs objectForKey:@"COMP_NO"], folder];
    }
//    NSLog(@"savePath : %@", savePath);
    
    NSString *fileName = [thumbFilePath lastPathComponent];
    NSString *chkFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@", fileName]];
    UIImage *image = nil;
    
    if([thumbFilePath rangeOfString:@"https://"].location != NSNotFound || [thumbFilePath rangeOfString:@"http://"].location != NSNotFound){
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:chkFile];
        if(!fileExists){
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[thumbFilePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            NSData *imageData = UIImagePNGRepresentation(thumbImage);
            [imageData writeToFile:chkFile atomically:YES];
        }
        
        NSData *data = [NSData dataWithContentsOfFile:chkFile];
        image = [UIImage imageWithData:data];
        
    } else {
        image = nil;
    }
    
    return image;
}

#pragma mark - Controller
+(NSString *)createChatRoomName:(NSString *)roomName roomType:(NSString *)roomType{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId = [prefs objectForKey:@"USERID"];
    NSString *myUserNm = [NSString urlDecodeString:[prefs objectForKey:[NSString stringWithFormat:@"%@_USERNM",userId]]];
    
    NSArray *roomNmArr = [NSArray array];
    if([roomName rangeOfString:@","].location != NSNotFound){
        roomNmArr = [roomName componentsSeparatedByString:@","];
    }
    
    NSString *resultRoomNm = @"";
    NSMutableArray *resultRoomArr = [NSMutableArray array];
    BOOL isMyName = NO;
    if(roomNmArr.count>0){
        for(int i=0; i<roomNmArr.count; i++){
            NSString *arrUserNm = [roomNmArr objectAtIndex:i];
            
            if(!isMyName&&[arrUserNm isEqualToString:myUserNm]){
                isMyName = YES;
                
            } else{
                [resultRoomArr addObject:arrUserNm];
            }
        }
        resultRoomNm = [[resultRoomArr valueForKey:@"description"] componentsJoinedByString:@","];
    }
//    NSLog(@"룸타입!! : %@", roomType);
    if(resultRoomNm==nil || [resultRoomNm isEqualToString:@""]){
        if([roomType isEqualToString:@"3"]) resultRoomNm = myUserNm;
        else resultRoomNm = NSLocalizedString(@"chat_roomname_null", @"chat_roomname_null");
    }
    
    return resultRoomNm;
}

+(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSLog(@"dict : %@ / array : %@ / memberCnt : %@", dict, array, memberCnt);
//    dict : { "REF_NO1" = 120819; } / array : ( "https://touch1.hhi.co.kr/snsService/snsUpload/profile/10/120819/thumb/20200410-102010004.png" ) / memberCnt : 2
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    UIImage *roomImg = [[UIImage alloc] init];
    ChatRoomImgDivision *divide = [[ChatRoomImgDivision alloc]init];
    [divide roomImgSetting:array :memberCnt];
    roomImg = divide.returnImg;
    NSLog(@"Room Img : %@", roomImg);
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/Chat/%@", roomNo];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        
    }else{
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(roomImg);
    NSString *fileName = @"";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    fileName = [NSString stringWithFormat:@"%@(%@).png",roomNo,currentTime];
    
    NSString *imgPath = [saveFolder stringByAppendingPathComponent:fileName];
    [imageData writeToFile:imgPath atomically:YES];
    NSLog(@"Room Img Path : %@", imgPath);
    
    NSString *sqlString;
    NSString *roomImgName = [imgPath lastPathComponent];
    
    NSArray *roomUserKey = [dict allKeys];
    NSArray *roomUserVal = [dict allValues];
    
    NSString *resultKey = [[roomUserKey valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *resultVal = [[roomUserVal valueForKey:@"description"] componentsJoinedByString:@","];
    
//    if([memberCnt isEqualToString:@"1"]){ //200820 기존
    if([memberCnt isEqual:@"1"]){
        sqlString = [appDelegate.dbHelper insertRoomImages:roomNo roomImg:roomImgName refNo1:myUserNo];
        
    } else {
        sqlString = [appDelegate.dbHelper insertRoomImages:resultKey roomNo:roomNo roomImg:roomImgName resultVal:resultVal];
    }
    
    [appDelegate.dbHelper crudStatement:sqlString];
    
    return imgPath;
}

+ (UINavigationController *)showToShareView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    return navController;
}

#pragma mark - Date
+ (NSString *)getTimeIntervalFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate{
    
    NSTimeInterval theTimeInterval = [toDate timeIntervalSinceDate:fromDate];
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    NSString *returnString = @"";
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    int minute = (int)[conversionInfo minute];
    int hour = (int)[conversionInfo hour];
    int month = (int)[conversionInfo month];
    int year = (int)[conversionInfo year];
    if (year>0) {
        returnString = [NSString stringWithFormat:@"%d년 전",year];
    }else{
        if (month>0) {
            returnString = [NSString stringWithFormat:@"%d달 전",month];
        }else{
            if (hour>0) {
                returnString = [NSString stringWithFormat:@"%d시간 전",hour];
            }else{
                if (minute>0) {
                    returnString = [NSString stringWithFormat:@"%d분 전",minute];
                }else{
                    returnString = @"지금";
                }
            }
        }
    }
    return returnString;
}

#pragma mark - Json
+ (NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - String
+ (NSDictionary *)getParametersByString:(NSString *)query{
    NSArray *params = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[params count]; i++) {
        NSArray *tmpArr = [[params objectAtIndex:i] componentsSeparatedByString:@"="];
        NSString *keyString = [NSString urlDecodeString:[tmpArr objectAtIndex:0]];
        NSString *valueString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
        [returnDic setObject:valueString forKey:keyString];
    }
    
    return returnDic;
}

+(NSString *)webServiceParamEncrypt :(NSString*)paramStr{
    NSArray *paramArr= [paramStr componentsSeparatedByString: @"&"];
    NSString *resultStr = @"";
    
    for(int i=0;i<paramArr.count;i++){
        NSString *paramStr = [paramArr objectAtIndex:i];
        
        NSString *paramKey;
        NSString *paramVal;
        NSString *encodedKey;
        NSString *encodedVal;
        
        NSRange subRange;
        subRange = [paramStr rangeOfString : @"="];
        if (subRange.location == NSNotFound){
            //NSLog(@"String not found");
        } else {
            paramKey = [paramStr substringToIndex:subRange.location];
            paramVal = [paramStr substringFromIndex:subRange.location+1];
            
            if([[MFSingleton sharedInstance] wsEncrypt]){
                paramVal = [FBEncryptorAES encryptBase64String:[paramStr substringFromIndex:subRange.location+1] keyString:[[MFSingleton sharedInstance] aes256key] separateLines:NO];
                encodedVal = [paramVal urlEncodeUsingEncoding:NSUTF8StringEncoding];
                
                if(i==0){
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@", paramKey, encodedVal]];
                } else {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", paramKey, encodedVal]];
                }
            } else {
                encodedKey = [paramKey urlEncodeUsingEncoding:NSUTF8StringEncoding];
                encodedVal = [paramVal urlEncodeUsingEncoding:NSUTF8StringEncoding];
                
                if(i==0){
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@", paramKey, encodedVal]];
                } else {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", paramKey, encodedVal]];
                }
            }
        }
    }
    
    //NSLog(@"resultStr : %@", resultStr);
    return resultStr;
}

+(NSString *)paramEncryptAndEncode :(NSString*)paramStr{
    NSString *resultStr = @"";
    paramStr = [FBEncryptorAES encryptBase64String:paramStr keyString:[[MFSingleton sharedInstance] aes256key] separateLines:NO];
    resultStr = [paramStr urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"paramStr : %@", resultStr);
    return resultStr;
}

+ (NSString *)replaceEncodeToChar:(NSString*)str{
    if([str rangeOfString:@"%"].location != NSNotFound){
        str = [str stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    }
    if([str rangeOfString:@"&"].location != NSNotFound){
        str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    }
    if([str rangeOfString:@"+"].location != NSNotFound){
        str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    }
    return str;
}

# pragma mark - Image Size
+ (UIImage *)getScaledLowImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    scaleFactor = width / oldWidth;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    //Chat, RMQServer, PushReceive 에서는 이걸 사용
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
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

+ (UIImage *)getScaledImage:(UIImage *)image scaledToMaxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    scaleFactor = height / oldHeight; //높이고정
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    if (oldWidth < width && oldHeight < height)
        return image;
    
    CGFloat scaleFactorW =1;
    CGFloat scaleFactorH =1;
    
    if (oldWidth > width)
        scaleFactorW = width / oldWidth;
    if(oldHeight > height)
        scaleFactorH = height / oldHeight;
    
    CGFloat scaleFactor = (scaleFactorW<scaleFactorH)?scaleFactorW:scaleFactorH;
    
    
    CGFloat newHeight = oldHeight * scaleFactor;
    //CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(width, newHeight);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getScaledImage:(UIImage *)image scaledToFixLongSide:(CGFloat)fixedValue {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    if(oldWidth<=oldHeight){
        scaleFactor = fixedValue / oldHeight; //높이고정
    } else {
        scaleFactor = fixedValue / oldWidth; //높이고정
    }
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageByScalingAndCroppingForSize2:(CGSize)targetSize :(UIImage *)image :(CGFloat)width{
//    CGFloat oldWidth = image.size.width;
//    CGFloat oldHeight = image.size.height;
//
//    CGFloat scaleFactor=1;
//
//    scaleFactor = width / oldWidth;
//
//    CGFloat newHeight = oldHeight * scaleFactor;
//    CGFloat newWidth = oldWidth * scaleFactor;
//    CGSize newSize = CGSizeMake(newWidth, newHeight);
//
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
//    [image drawInRect:CGPointMake(<#CGFloat x#>, <#CGFloat y#>)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = image.size;
    CGFloat scaledWidth = image.size.width;
    CGFloat scaledHeight = image.size.height;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    CGSize newSize;
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat scaleFactor=1;
    
        scaleFactor = width / scaledWidth;
    
        CGFloat newHeight = scaledHeight * scaleFactor;
        CGFloat newWidth = scaledWidth * scaleFactor;
        newSize = CGSizeMake(newWidth, newHeight);
    }
    
    //UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    
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

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize :(UIImage *)image{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
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
    
    //UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    
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

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
+ (UIImage *)rotateImage90:(UIImage *)img {
    //NSLog(@"rotateImage90:");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    
    CGContextRotateCTM (context, DEGREES_TO_RADIANS(270));
    CGContextTranslateCTM (context, -width, 0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}

+ (UIImage *)rotateImageReverse90:(UIImage *)img{
    NSLog(@"rotateImageReverse90:");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRotateCTM (context, DEGREES_TO_RADIANS(90));
    CGContextTranslateCTM (context, 0, -height);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
+ (UIImage *)rotateImage:(UIImage *)img byOrientationFlag:(UIImageOrientation)orient{
    NSLog(@"ImageProcessUtil rotateImage");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    NSLog(@"rotate image size width=%f, height=%f, orientation=%ld", width, height, (long)orient);
    
    switch(orient) {
            
        case UIImageOrientationUp:
            break;
            
        case UIImageOrientationDown:
            break;
            
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        default:
            break;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    if (orient == UIImageOrientationRight) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(270));
        CGContextTranslateCTM (context, -width, 0);
    }
    else if (orient == UIImageOrientationLeft) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(90));
        CGContextTranslateCTM (context, 0, -height);
    }
    else if (orient == UIImageOrientationDown) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(180));
        CGContextTranslateCTM (context, -width, -height);
    }
    else if (orient == UIImageOrientationUp) {
        // NOTHING
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}

+ (UIImage *)getResizeImageRatio:(UIImage *)img{
    UIImage *resizedImg = [[UIImage alloc] init];
    NSString *resultRatio = @"";
    
    int originWidth = (int)img.size.width;
    int originHeight = (int)img.size.height;
    
    int ratio1 = 1, ratio2 = 1;
    int tempWidth = 0;
    int tempResult = 100;
    
    if(originWidth != originHeight){
        BOOL isNext = true;
        for(int i=1; i<=20; i++){
            if(isNext){
                tempWidth = originWidth/i;
                for(int j=1; j<=20; j++){
                    int absValue = abs(tempWidth - originHeight/j);
                    if(absValue < tempResult){
                        tempResult = absValue;
                        ratio1 = i;
                        ratio2 = j;
                        
                        if(tempResult == 0){
                            isNext = false;
                            break;
                        }
                    }
                }
            }
            else{
                break;
            }
        }
    }
    
    resultRatio = [NSString stringWithFormat:@"%d_%d", ratio1, ratio2];
    NSLog(@"resultRatio : %@", resultRatio);
    if(ratio1 < ratio2){
        resizedImg = [self imageNeedToResize:img longSide:originHeight ratio:resultRatio];
        
    } else if(ratio1 == ratio2){
        resizedImg = [self imageNeedToResize:img longSide:originHeight ratio:resultRatio];
        
    } else {
        resizedImg = [self imageNeedToResize:img longSide:originWidth ratio:resultRatio];
    }
    
    return resizedImg;
}


#define NORMAL_IMAGE_RATIO_4_3 [NSMutableArray arrayWithObjects:@1024, @768, nil]
#define NORMAL_IMAGE_RATIO_16_9 [NSMutableArray arrayWithObjects:@1280, @720, nil]
#define HIGH_IMAGE_RATIO_4_3 [NSMutableArray arrayWithObjects:@2048, @1536, nil]
#define HIGH_IMAGE_RATIO_16_9 [NSMutableArray arrayWithObjects:@2560, @1440, nil]
+ (UIImage *)imageNeedToResize:(UIImage *)image longSide:(int)longSide ratio:(NSString *)ratio{
    NSLog(@"원본 w : %f, h : %f", image.size.width, image.size.height);
    
    UIImage *resizedImg = [[UIImage alloc] init];
    NSString *imgQuality = [[MFSingleton sharedInstance] imgQuality];
    
    if([ratio isEqualToString:@"4_3"]||[ratio isEqualToString:@"3_4"]){
        if([imgQuality isEqualToString:@"NORMAL"]){
            int normal_lognSide_4_3 = [[NORMAL_IMAGE_RATIO_4_3 objectAtIndex:0] intValue];
            if(longSide > normal_lognSide_4_3) {
                resizedImg = [self getScaledImage:image scaledToFixLongSide:normal_lognSide_4_3];
            }
            else {
                resizedImg = image;
            }
            
            
        } else if([imgQuality isEqualToString:@"HIGH"]){
            int high_lognSide_4_3 = [[HIGH_IMAGE_RATIO_4_3 objectAtIndex:0] intValue];
            if(longSide > high_lognSide_4_3) {
                resizedImg = [self getScaledImage:image scaledToFixLongSide:high_lognSide_4_3];
            }
            else {
                resizedImg = image;
            }
            
        }
        
    } else if([ratio isEqualToString:@"16_9"]||[ratio isEqualToString:@"9_16"]){
        if([imgQuality isEqualToString:@"NORMAL"]){
            int normal_lognSide_16_9 = [[NORMAL_IMAGE_RATIO_16_9 objectAtIndex:0] intValue];
            if(longSide > normal_lognSide_16_9) {
                resizedImg = [self getScaledImage:image scaledToFixLongSide:normal_lognSide_16_9];
            }
            else {
                resizedImg = image;
            }
            
        } else if([imgQuality isEqualToString:@"HIGH"]){
            int high_lognSide_16_9 = [[HIGH_IMAGE_RATIO_16_9 objectAtIndex:0] intValue];
            if(longSide > high_lognSide_16_9) {
                resizedImg = [self getScaledImage:image scaledToFixLongSide:high_lognSide_16_9];
            }
            else {
                resizedImg = image;
            }
        }
        
    } else {
        //1:1 또는 그 외 비율은 화면사이즈에 맞게 조정 (이미지 가로를 변경)
        //CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        CGFloat screenWidth = [UIScreen mainScreen].nativeBounds.size.width; //pixel
        //NSLog(@"screenWidth : %f", screenWidth);
        
        if([imgQuality isEqualToString:@"NORMAL"]){
            if(longSide >= 2000) {
                resizedImg = [self getScaledImage:image scaledToMaxWidth:screenWidth];
            }
            else {
                resizedImg = image;
            }
            
        } else if([imgQuality isEqualToString:@"HIGH"]){
            if(longSide >= 3000) {
                resizedImg = [self getScaledImage:image scaledToMaxWidth:screenWidth];
            }
            else {
                resizedImg = image;
            }
        }
    }
    
    NSLog(@"resizedImg w : %f, h : %f", resizedImg.size.width, resizedImg.size.height);
    
    return resizedImg;
}


+ (CGSize)getResizeVideoRatio:(CGSize)videoSize{
    NSString *videoQuality = [[MFSingleton sharedInstance] vdoQuality];
    int normalSize = 480; //720;
    int highSize = 1080; //1980;
    
    CGFloat oldWidth = fabs(videoSize.width);
    CGFloat oldHeight = fabs(videoSize.height);
    
    CGFloat scaleFactor=1;
    
//    긴쪽기준
//    float longSide = 0;
//    if(oldWidth > oldHeight) longSide = oldWidth;
//    if(oldWidth <= oldHeight) longSide = oldHeight;
//
//    if([videoQuality isEqualToString:@"NORMAL"]){
//        if(longSide >= 1000) {
//            scaleFactor = normalSize / longSide;
//        }
//
//    } else if([videoQuality isEqualToString:@"HIGH"]){
//        if(longSide >= 2000) {
//            scaleFactor = highSize / longSide;
//        }
//    }
    
//    짧은쪽기준
    float shortSide = 0;
    if(oldWidth > oldHeight) shortSide = oldHeight;
    if(oldWidth <= oldHeight) shortSide = oldWidth;
    
    if([videoQuality isEqualToString:@"NORMAL"]){
        if(shortSide > normalSize) {
            scaleFactor = normalSize / shortSide;
        }
        
    } else if([videoQuality isEqualToString:@"HIGH"]){
        if(shortSide > highSize) {
            scaleFactor = highSize / shortSide;
        }
    }

    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return newSize;
}



@end


#pragma mark - AES256
@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    NSString *returnString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
    
    return returnString;
}

+ (NSString *)urlDecodeString:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)temp,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}

- (NSString *)AES256EncryptWithKeyString:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES256DecryptWithKeyString:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES256DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

@end

@implementation NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}
@end
