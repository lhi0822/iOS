//
//  BeaconManager_Reco.m
//  Anymate_Beacon 16.06.13
//
//  Created by hilee on 2016. 5. 25..
//  Copyright © 2016년 Kyeong In Park. All rights reserved.
//

#import "BeaconManager_Reco.h"
#import <CoreLocation/CoreLocation.h>
#import <Reco/Reco.h>
#import "RecoDefaults.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import "UrlSettingViewController.h"
#define IS_OS_10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
@interface BeaconManager_Reco () <RECOBeaconManagerDelegate>

@end

@implementation BeaconManager_Reco {
    NSMutableArray *_registeredRegions;
    RECOBeaconManager *_recoManager;
    NSMutableDictionary *_rangedRegions;
    NSMutableDictionary *_monitoredRegion;
    NSMutableDictionary *_detectedRegion;

    BOOL isInside;
    BOOL saveflag;
    NSArray *_stateCategory;
}

- (BOOL)beaconSetting {
    NSLog(@"1. %s",__func__);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    _monitoredRegion = [[NSMutableDictionary alloc] init];
    _detectedRegion = [[NSMutableDictionary alloc] init];
    [self checkPermission];
    
    _uuidList = appDelegate.supportedUUIDs;
    _stateCategory = @[@(RECOBeaconRegionUnknown),
                       @(RECOBeaconRegionInside),
                       @(RECOBeaconRegionOutside),
                       @(RECOProximityUnknown),
                       @(RECOProximityImmediate),
                       @(RECOProximityNear),
                       @(RECOProximityFar)];

    for (NSNumber *state in _stateCategory) {
        _detectedRegion[state] = [NSMutableDictionary dictionary];
    }
    _registeredRegions = [[NSMutableArray alloc] init];
    _rangedRegions = [[NSMutableDictionary alloc] init];
    
    _uuidList = [NSArray arrayWithArray: appDelegate.supportedUUIDs];
    
    _recoManager = [[RECOBeaconManager alloc] init];
    _recoManager.delegate = self;
    
    NSSet *monitoredRegion = [_recoManager getMonitoredRegions];
    NSLog(@"monitoredRegion : %@", monitoredRegion.allObjects);
    
    if ([monitoredRegion count] > 0) {
        self.isBackgroundMonitoringOn = YES;
    } else {
        self.isBackgroundMonitoringOn = NO;
    }
    if (_uuidList!=nil) {
        for (int i = 0; i < _uuidList.count; i++) {
            NSUUID *uuid = [_uuidList objectAtIndex:i];
            NSString *identifier = [NSString stringWithFormat:@"[Anymate] RECO BeaconRegion-%d", i];
            [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
        }
        UIApplication *application = [UIApplication sharedApplication];
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
                [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
            }
        }
        [self startMonitoring];
        return YES;
    }else{
        return NO;
    }
}

- (void)checkPermission {
    if ([RECOBeaconManager isMonitoringAvailable]){
        UIApplication *application = [UIApplication sharedApplication];
        if (application.backgroundRefreshStatus != UIBackgroundRefreshStatusAvailable) {
            NSString *title = NSLocalizedString(@"not_auth_background_fetch_title", @"not_auth_background_fetch_title");
            NSString *message = NSLocalizedString(@"not_auth_background_fetch_msg", @"not_auth_background_fetch_msg");
            [self showAlertWithTitle:title andMessage:message];
        }
    }
    
    if([RECOBeaconManager locationServicesEnabled]){
//        NSLog(@"Location Services Enabled");
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            NSString *title = NSLocalizedString(@"not_auth_location_title", @"not_auth_location_title");
            NSString *message = NSLocalizedString(@"not_auth_location_msg", @"not_auth_location_msg");
            [self showAlertWithTitle:title andMessage:message];
        }
    }
}

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    RECOBeaconRegion *region = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    [region setNotifyOnEntry:YES];
    [region setNotifyOnExit:YES];
    
    RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    _rangedRegions[recoRegion] = [NSArray array];
    
    [_monitoredRegion setObject:region forKey:region.identifier];
}

#pragma mark Notification
- (void)_sendEnterLocalNotificationWithMessage:(NSString *)message {
    NSLog(@"%s", __func__);
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *today = [date stringFromDate:[NSDate date]];
    [date setDateFormat:@"yyyyMMdd"];
    NSString *today2 = [date stringFromDate:[NSDate date]];
  
    NSError *dicError;
    NSDictionary *dataDiction = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
    NSString *resultCode = [NSString stringWithFormat:@"%@",[dataDiction objectForKey:@"code"]];

    NSString *resultString = @"";
    if ([resultCode isEqualToString:@"990"]) {
        //resultString = NSLocalizedString(@"login_code_990", @"login_code_990");
    }else if ([resultCode isEqualToString:@"991"]) {
        //resultString = NSLocalizedString(@"login_code_991", @"login_code_991");
    }else if ([resultCode isEqualToString:@"992"]) {
        //resultString = NSLocalizedString(@"login_code_992", @"login_code_992");
    }else if ([resultCode isEqualToString:@"100"]) {
        resultString = NSLocalizedString(@"login_code_100", @"login_code_100");
    }else if ([resultCode isEqualToString:@"200"]) {
        resultString = NSLocalizedString(@"login_code_200", @"login_code_200");
    }else if ([resultCode isEqualToString:@"300"]) {
        //resultString = NSLocalizedString(@"login_code_300", @"login_code_300");
    }else if ([resultCode isEqualToString:@"400"]) {
        //resultString = NSLocalizedString(@"login_code_400", @"login_code_400");
    }else if ([resultCode isEqualToString:@"500"]) {
        //resultString = NSLocalizedString(@"login_code_500", @"login_code_500");
    }else if ([resultCode isEqualToString:@"600"]) {
        //resultString = NSLocalizedString(@"login_code_600", @"login_code_600");
    }else if ([resultCode isEqualToString:@"0"]) {
        resultString = NSLocalizedString(@"login_code_0", @"login_code_0");
    }
    if (![resultString isEqualToString:@""]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:today2 forKey:@"LOGIN_DATE"];
        [prefs synchronize];
        
        resultString = [resultString stringByAppendingFormat:@"\n%@",today];
        UIApplication *application = [UIApplication sharedApplication];
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
           
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:resultString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *action) { }]];
            UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
            [rootController presentViewController:alert animated:YES completion:nil];
            
        }else{
            UILocalNotification *notice = [[UILocalNotification alloc] init];
            notice.alertBody = resultString;
            notice.alertTitle = @"Anymate";
            notice.alertAction = @"Open";
            notice.soundName = @"anymate.caf";
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notice];
        }
    }
}

- (void)_sendExitLocalNotificationWithMessage:(NSString *)message {
//     UIApplication *application = [UIApplication sharedApplication];
//     UIApplicationState state = [application applicationState];
//     if (state == UIApplicationStateActive) {
//         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//         AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"알림" message:message delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
//         [alertView show];
//     }else{
//         UILocalNotification *notice = [[UILocalNotification alloc] init];
//         notice.alertBody = message;
//         notice.alertTitle = @"Anymate";
//         notice.alertAction = @"Open";
//         notice.soundName = UILocalNotificationDefaultSoundName;
//         [[UIApplication sharedApplication] scheduleLocalNotification:notice];
//     }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) { }]];
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}

#pragma mark RECOBeaconManager
- (void) recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
    NSLog(@"4. didDetermineState(background) %@, state : %ld", region.identifier, (long)state);
    //0:unknown, 1:inside, 2:outside
    
    switch (state) {
        case RECOBeaconRegionInside:
            _detectedRegion[@(RECOBeaconRegionInside)][region.identifier] = region;
            
            [_detectedRegion[@(RECOBeaconRegionOutside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionUnknown)] removeObjectForKey:region.identifier];
            
            if ([_detectedRegion[@(RECOBeaconRegionUnknown)] count] > 0) {
                NSDictionary *unknownRegions = [_detectedRegion[@(RECOBeaconRegionUnknown)] copy];
                [_detectedRegion[@(RECOBeaconRegionOutside)] addEntriesFromDictionary:unknownRegions];
                [_detectedRegion[@(RECOBeaconRegionUnknown)] removeAllObjects];
            }
            [self startRanging];
            break;
            
        case RECOBeaconRegionOutside:
            _detectedRegion[@(RECOBeaconRegionOutside)][region.identifier] = region;
            
            [_detectedRegion[@(RECOBeaconRegionInside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionUnknown)] removeObjectForKey:region.identifier];
            if ([_detectedRegion[@(RECOBeaconRegionUnknown)] count] > 0) {
                NSDictionary *unknownRegions = [_detectedRegion[@(RECOBeaconRegionUnknown)] copy];
                [_detectedRegion[@(RECOBeaconRegionInside)] addEntriesFromDictionary:unknownRegions];
                [_detectedRegion[@(RECOBeaconRegionUnknown)] removeAllObjects];
            }
            break;
            
        case RECOBeaconRegionUnknown:
            _detectedRegion[@(RECOBeaconRegionUnknown)][region.identifier] = region;
            [_detectedRegion[@(RECOBeaconRegionInside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionOutside)] removeObjectForKey:region.identifier];
            break;
    }
}


- (void) recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
//    NSLog(@"didEnterRegion(background) %@", region.identifier);
    NSLog(@"비콘 영역에 들어왔습니다.");
    
    _isBeacon = NO;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
//    NSDateFormatter *date = [[NSDateFormatter alloc]init];
//    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *today = [date stringFromDate:[NSDate date]];
//
//    NSString *msg = [NSString stringWithFormat:@"비콘 영역에 들어왔습니다. %@", today];
//    UIApplication *application = [UIApplication sharedApplication];
//    UIApplicationState state = [application applicationState];
//    if (state == UIApplicationStateActive) {
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"알림" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
//        [alertView show];
//    }else{
//        UILocalNotification *notice = [[UILocalNotification alloc] init];
//        notice.alertBody = msg;
//        notice.alertTitle = @"Anymate";
//        notice.alertAction = @"Open";
//        notice.soundName = UILocalNotificationDefaultSoundName;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
//    }
    
//    [self _sendEnterLocalNotificationWithMessage:msg];
}

- (void) recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region {
//    NSLog(@"didExitRegion(background) %@", region.identifier);
    NSLog(@"비콘 영역을 벗어났습니다.");
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // don't send any notifications
//        NSLog(@"app active: not sending notification");
        return;
    }
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *today = [date stringFromDate:[NSDate date]];

    NSString *msg = [NSString stringWithFormat:@"비콘 영역을 벗어났습니다. %@", today];
    [self _sendExitLocalNotificationWithMessage:msg];
    
}
- (void)recoManager:(RECOBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    NSLog(@"%s",__FUNCTION__);
    
    [_recoManager requestWhenInUseAuthorization];
    [_recoManager requestAlwaysAuthorization];
}
- (void)recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region{
    NSLog(@"didStartMonitoringForRegion: %@", region.identifier);
    [_recoManager requestStateForRegion:region];
}

- (void)recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
    
}

-(void)startRangingBeaconsInRegion:(RECOBeaconRegion *)recoRegion{
    NSLog(@"%s", __func__);
}


- (void) startBackgroundMonitoring {
    NSLog(@"%s", __FUNCTION__);
    if (![RECOBeaconManager isMonitoringAvailable]) {
        return;
    }
    
    for (RECOBeaconRegion *recoRegion in _registeredRegions) {
        [_recoManager startMonitoringForRegion:recoRegion];
    }
}

- (void) stopBackgroundMonitoring {
    NSSet *monitoredRegions = [_recoManager getMonitoredRegions];
    for (RECOBeaconRegion *recoRegion in monitoredRegions) {
        [_recoManager stopMonitoringForRegion:recoRegion];
    }
}
#pragma mark - RECOBeaconManager Monitoring
- (void)startMonitoring {
    NSLog(@"2. %s %d",__FUNCTION__,[RECOBeaconManager isMonitoringAvailable]);
    if (![RECOBeaconManager isMonitoringAvailable]) {
        return;
    }
    
    NSArray *allRegions = [_monitoredRegion allValues];
    [allRegions enumerateObjectsUsingBlock:^(RECOBeaconRegion *region, NSUInteger idx, BOOL *stop) {
        [_recoManager startMonitoringForRegion:region];
        NSLog(@"3. startMonitoringForRegion: %@", region.identifier);

        [_detectedRegion[@(RECOBeaconRegionUnknown)] setObject:region forKey:region.identifier];
    }];
}

- (void)stopMonitoring {
    NSArray *allRegions = [_monitoredRegion allValues];
    [allRegions enumerateObjectsUsingBlock:^(RECOBeaconRegion *region, NSUInteger idx, BOOL *stop) {
        [_recoManager stopMonitoringForRegion:region];
        [_monitoredRegion removeObjectForKey:region.identifier];
    }];
}
#pragma mark - RECOBeaconManager Ranging
- (void) startRanging {
    if (![RECOBeaconManager isRangingAvailable]) {
        return;
    }
    
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager startRangingBeaconsInRegion:recoRegion];
    }];
}

- (void) stopRanging; {
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager stopRangingBeaconsInRegion:recoRegion];
    }];
}


- (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region {
//    NSLog(@"didRangeBeaconsInRegion: %@, ranged %lu beacons", region.identifier, (unsigned long)[beacons count]);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _rangedRegions[region] = beacons;
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    NSArray *arrayOfBeaconsInRange = [_rangedRegions allValues];
    [arrayOfBeaconsInRange enumerateObjectsUsingBlock:^(NSArray *beaconsInRange, NSUInteger idx, BOOL *stop){
        [allBeacons addObjectsFromArray:beaconsInRange];
    }];
    
    if ([beacons count] > 0) {
        if (!self.isBeacon) {
            NSNumber *major = [[beacons objectAtIndex:0] major];
            NSNumber *minor = [[beacons objectAtIndex:0] minor];
            appDelegate.beaconMajor = [NSString stringWithFormat:@"%@",major];
            appDelegate.beaconMinor = [NSString stringWithFormat:@"%@",minor];
            //NSLog(@"major : %@",major);
            //NSLog(@"minor : %@",minor);
            NSDateFormatter *date = [[NSDateFormatter alloc]init];
            [date setDateFormat:@"yyyyMMdd"];
            NSString *today = [date stringFromDate:[NSDate date]];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *loginDate = [prefs objectForKey:@"LOGIN_DATE"];
//            NSLog(@"today date : %@ / login date : %@",today, loginDate);
            if (![loginDate isEqualToString:today]) {
                [self httpConnect];
                self.isBeacon = YES;
            }
            
        }
    }
}

- (void)recoManager:(RECOBeaconManager *)manager rangingDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
}


#pragma mark SessionHttp
- (void) httpConnect{
    NSLog(@"%s",__FUNCTION__);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [prefs objectForKey:@"URL"];
    if (urlStr!=nil) {
        NSString *deviceID = [prefs objectForKey:@"DEVICE_ID"];
        
        NSUserDefaults *prefsToken = [NSUserDefaults standardUserDefaults];
        NSString *deviceToken = [prefsToken objectForKey:@"DEVICE_TOKEN"];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        NSString *supportedUUID = [appDelegate.supportedUUIDs componentsJoinedByString:@" "];
        NSArray *uuidArr = [supportedUUID componentsSeparatedByString:@" "];
        NSString *uuidStr = nil;
        
        
        if (IS_OS_10_OR_LATER) {
            uuidStr = [uuidArr objectAtIndex:0];
        }else{
            if (uuidArr.count>1) {
                uuidStr = [uuidArr objectAtIndex:2];
            }else{
                uuidStr = [uuidArr objectAtIndex:0];
            }
        }
        NSString *urlString = [NSString stringWithFormat:@"%@/m/main/?event=set_beacon&device_id=%@&token=%@&uuid=%@&major=%@&minor=%@",urlStr,deviceID,deviceToken,
                               uuidStr,appDelegate.beaconMajor,appDelegate.beaconMinor];
        NSLog(@"httpConnect urlString : %@",urlString);
        NSURL *url = [[NSURL alloc]initWithString:urlString];
        
        _isBeacon = NO;
        SessionHTTP *session = [[SessionHTTP alloc] init];
        session.delegate = self;
        [session URL:url parameter:nil];
    }
    
}

-(void)returnData:(SessionHTTP *)session{
    NSLog(@"SessionHTTP dataStr : %@", session.dataStr);
    [self _sendEnterLocalNotificationWithMessage:session.dataStr];
}

-(void)returnData:(SessionHTTP *)SessionHTTP withErrorMessage:(NSString *)errorMessage error:(NSError *)error{
    NSLog(@"[%s] error : %@", __func__, error);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) { }]];
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}
@end

