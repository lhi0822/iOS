//
//  BeaconManager_Minew.m
//  Anymate
//
//  Created by hilee on 2020/11/26.
//  Copyright © 2020 Kyeong In Park. All rights reserved.
//

#import "BeaconManager_Minew.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import "UrlSettingViewController.h"
#define IS_OS_10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@implementation BeaconManager_Minew {
//    MinewBeaconManager *manager;
    int count;
    int scanCount;
    BOOL isScan;
}
- (BOOL)beaconSetting {
    NSLog(@"1. %s",__func__);
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //1. MinewBeaconManager 인스턴스를 가져오고 프록시 객체를 설정합니다.
//    manager = [[MinewBeaconManager alloc] init]; //[MinewBeaconManager sharedInstance];
//    manager.delegate = self;
    
    count = 0;
    _isBeacon = NO;
    isScan = YES;
    scanCount = 0;
    
    UIApplication *application = [UIApplication sharedApplication];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    
    [MinewBeaconManager sharedInstance].delegate = self;
    [[MinewBeaconManager sharedInstance] startScan];
    
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"44425641-4C4C-4559-414E-594D41544533"];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
//    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"Anymate"];
    self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    
    
    
    //2. 스캔 시작
//    [manager startScan];
    
    return YES;
}

//- 모니터링 시작
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion");
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
}

//- 모니터링 실패 시
//error domain 에러 원인 파악하여 처리하시면 됩니다,
//보통 위치서비스 허용과 블루투스 문제로 에러발생합니다
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion : %@",error);
}

//- 비콘에 진입하였을 때
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion");
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

//- 비콘에 멀어져 연결이 종료될 때
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion");
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
}

//- 비콘 상태
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside) {
        NSLog(@"CLRegionStateInside");
    }else if(state == CLRegionStateOutside){
        NSLog(@"CLRegionStateOutside");
    }else{
        NSLog(@"CLRegionStateUnknown");
    }
}

//- 비콘 정보를 읽어오기
-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region {
    NSLog(@"## beacons : %@", beacons);
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) return;
    if([beacons count] == 0) return;

    float arrange = 2.0;

    //Beacon Infomation
    NSNumber *major = [[NSNumber alloc] initWithInt:5];
    NSNumber *minor = [[NSNumber alloc] initWithInt:5000];
    
    for(CLBeacon *beacon in beacons)
    {
        if(beacon.accuracy < arrange && [beacon.major isEqualToNumber:major] && [beacon.minor isEqualToNumber:minor])
        {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"beaconEnterNotify"])
            {
                NSLog(@"Fire Notification");
                NSLog(@"beacon device info[major:%@, minor:%@, accuracy : %.1f]",beacon.major, beacon.minor, beacon.accuracy);
            }
        }
    }
}


#pragma mark ******************MinewBeaconManager Delegate
- (void)minewBeaconManager:(MinewBeaconManager *)manager didRangeBeacons:(NSArray<MinewBeacon *> *)beacons{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
//    _scannedBeacons = [NSArray array];
    _scannedBeacons = beacons;
//    NSLog(@"beacons[0] : %@", [beacons[0] exportJSON]);
//    NSLog(@"beacons[0].inRange : %@", manager.inRangeBeacons);
//    NSLog(@"beacons.count : %lu", beacons.count);
    
//    _scannedBeacons = [_scannedBeacons sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        NSInteger rssi1 = ((MinewBeacon *)obj1).rssi;
//        NSInteger rssi2 = ((MinewBeacon *)obj2).rssi;
//        return rssi1 > rssi2? NSOrderedAscending: NSOrderedDescending;
//    }];
    
//    NSLog(@"_scannedBeacons : %@", _scannedBeacons);
//    NSLog(@"beacons[0].inRange : %d, %@", beacons[0].inRange, beacons[0].inRange?@"있":@"없");
//    NSLog(@"beacons[0].conn : %d", beacons[0].connectable);
    
    count++;
    if(count==8){
        NSLog(@"끝!(scanCnt : %d) 스캔범위내에 %@",scanCount, isScan?@"있음":@"없음");
        
        if(scanCount==7){
            NSLog(@"스캔 범위 내에 없음!");
        }
        
        count=0;
        scanCount=0;
        
        
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSInteger *prevRssi = [[prefs objectForKey:@"PREV_RSSI"] intValue];
        NSInteger *currRssi = beacons[0].rssi;
        NSLog(@"prev : %ld / curr : %ld", (long)prevRssi, (long)currRssi);
        
        if(prevRssi!=currRssi){
            NSLog(@"같지않음. 스캔 범위 내에 있음");
            isScan = YES;
        
        } else {
            isScan = NO;
            scanCount++;
        }
        
        [prefs setObject:[NSString stringWithFormat:@"%ld", (long)beacons[0].rssi] forKey:@"PREV_RSSI"];
        [prefs synchronize];
    }
    
    if(_scannedBeacons.count>0){
//        MinewBeacon *beacon = _scannedBeacons[0];
//        MinewBeaconConnection *connection = [[MinewBeaconConnection alloc]initWithBeacon:beacon];
//        connection.delegate = self;
//        [connection connect];
        
        /*
//        NSString *supportedUUID = @"44425641-4C4C-4559-414E-594D41544533";
        NSString *beaconName = @"MiniBeacon_42790";
        if (!self.isBeacon) {
            for(int i=0; i<_scannedBeacons.count; i++){
                NSString *getName = beacons[i].name; //beacons[i].uuid;
                if([getName isEqualToString:beaconName]){
                    NSInteger *major = beacons[0].major;
                    appDelegate.beaconMajor = [NSString stringWithFormat:@"%ld",(long)major];
                    NSLog(@"major : %@",appDelegate.beaconMajor);
        
                    NSDateFormatter *date = [[NSDateFormatter alloc]init];
                    [date setDateFormat:@"yyyyMMdd"];
                    NSString *today = [date stringFromDate:[NSDate date]];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        //            NSString *loginDate = [prefs objectForKey:@"LOGIN_DATE"];
                    NSString *loginDate = @"20201126";
                    NSLog(@"today date : %@ / login date : %@",today, loginDate);
                    if (![loginDate isEqualToString:today]) {
                        NSLog(@"로그인 진행!");
//                        MinewBeacon *beacon = _scannedBeacons[0];
//                        MinewBeaconConnection *connection = [[MinewBeaconConnection alloc]initWithBeacon:beacon];
//                        connection.delegate = self;
//                        [connection connect];
                        
        //                [self httpConnect];
                        self.isBeacon = YES;
                    }
                }
            }
        }
         */
    }
}


- (void)minewBeaconManager:(MinewBeaconManager *)manager appearBeacons:(NSArray<MinewBeacon *> *)beacons{
    NSLog(@"===appear beacons:%@", beacons);
    if(beacons.count>0){
        NSLog(@"**************************************");
        UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
        notice.title = @"Anymate";
        notice.body = @"Appear Beacons";
        AudioServicesPlaySystemSound(1007);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Anymate" content:notice trigger:nil];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {}
        }];
    }
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager disappearBeacons:(NSArray<MinewBeacon *> *)beacons{
    NSLog(@"---disappear beacons:%@", beacons);
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    notice.alertBody = @"Disappear Beacons";
    notice.alertTitle = @"Anymate";
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager didUpdateState:(BluetoothState)state{
     NSLog(@"the bluetooth state is %@!", state == BluetoothStatePowerOn? @"power on":( state == BluetoothStatePowerOff? @"power off": @"unknown"));
    
}

//비콘인식하여 로그인 용도로만 사용하므로 굳이 비콘과 연결할 필요 없을듯
#pragma mark **********************Connection Delegate

- (void)beaconConnection:(MinewBeaconConnection *)connection didChangeState:(ConnectionState)state
{
    NSString *string = @"Connection state change to ";
    
    switch (state) {
        case ConnectionStateConnecting:
           string = [string stringByAppendingString:@"Connceting"];
            break;
            
        case ConnectionStateConnected:
            string = [string stringByAppendingString:@"Connected"];
            break;
            
        case ConnectionStateDisconnected:
            string = [string stringByAppendingString:@"Disconnected"];
            break;
            
        case ConnectionStateConnectFailed:
            string = [string stringByAppendingString:@"ConnectFailed"];
            break;
        default:
            break;
    }
    
    
    NSLog(@"conn!!! %@", string);
    
    if ( (state == ConnectionStateConnectFailed || state == ConnectionStateDisconnected ) ){
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Fail to connect this device." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:ok];
    
    } else if(state == ConnectionStateConnected){
        NSLog(@"연결됐으니 스캔 정지");
//        [manager stopScan];
    }

    if (state != ConnectionStateConnected)
        return ;
    
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
    //[self _sendEnterLocalNotificationWithMessage:session.dataStr];
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
