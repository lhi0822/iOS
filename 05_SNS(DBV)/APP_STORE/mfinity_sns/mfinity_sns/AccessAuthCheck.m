//
//  AccessAuthCheck.m
//  mfinity_sns
//
//  Created by hilee on 2020/05/08.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "AccessAuthCheck.h"

@implementation AccessAuthCheck

+ (UIViewController *)topViewController{
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

#pragma mark - 미디어 접근 권한 여부로 제어

+ (void)cameraAccessCheck:(void (^)(BOOL status))completion{
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        UIViewController *top = [self topViewController];
        
        //현대중공업 - 미디어 접근 권한 없어도 촬영 및 앨범 접근 허용, 실행 전 알림
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
//            미디어 접근 권한 사용 및 권한이 없을 경우
//            권한없음 알림 띄우고 카메라 사용 불가
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //내정보 페이지로 이동?
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [top presentViewController:alert animated:YES completion:nil];
            
            completion(NO);
            
        } else {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(status == AVAuthorizationStatusAuthorized) {
                NSLog(@"카메라 접근 허용일 경우");
                completion(YES);
                
            } else if(status == AVAuthorizationStatusDenied) {
                NSLog(@"카메라 접근 허용되지않았을 경우");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];
                [top presentViewController:alert animated:YES completion:nil];
                
                completion(NO);
                
            } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){ // Access has been granted ..do something
                        completion(YES);
                        
                    } else { // Access denied ..do something
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        [alert addAction:cancelButton];
                        [alert addAction:okButton];

                        [top presentViewController:alert animated:YES completion:NULL];
                        
                        completion(NO);
                    }
                }];
                
            } else {
                completion(NO);
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

+ (void)photoAccessCheck:(void (^)(BOOL status))completion{
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        UIViewController *top = [self topViewController];
        
        //현대중공업 - 미디어 접근 권한 없어도 촬영 및 앨범 접근 허용, 실행 전 알림
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            //미디어 접근 권한 사용 및 권한이 없을 경우
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //내정보 페이지로 이동?
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [top presentViewController:alert animated:YES completion:nil];
            
            completion(NO);
            
        } else {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
            
            if (photoStatus == PHAuthorizationStatusAuthorized) {
                completion(YES);
                
            } else if (photoStatus == PHAuthorizationStatusDenied) {
                NSLog(@"Access has been denied.");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_photo", @"alert_access_photo"),appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];
                [top presentViewController:alert animated:YES completion:NULL];
                
                completion(NO);
                
            } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        NSLog(@"1 StatusNotDetermined Access has been granted.");
                        completion(YES);
                        
                    } else {
                        NSLog(@"2 StatusNotDetermined Access has been granted.");
                        completion(NO);
                    }
                }];
//                return NO;
                
            } else if (photoStatus == PHAuthorizationStatusRestricted) {
                NSLog(@"Restricted access - normally won't happen.");
                completion(NO);
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

/*
+(BOOL)cameraAccessCheck {
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        UIViewController *top = [self topViewController];
        
        //현대중공업 - 미디어 접근 권한 없어도 촬영 및 앨범 접근 허용, 실행 전 알림
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
//            미디어 접근 권한 사용 및 권한이 없을 경우
            
//            권한없음 알림 띄우고 카메라 사용 불가
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //내정보 페이지로 이동?
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [top presentViewController:alert animated:YES completion:nil];

            return NO;
            
        } else {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(status == AVAuthorizationStatusAuthorized) {
                NSLog(@"카메라 접근 허용일 경우");
                return YES;
                
            } else if(status == AVAuthorizationStatusDenied) {
                NSLog(@"카메라 접근 허용되지않았을 경우");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];
                
                [top presentViewController:alert animated:YES completion:nil];
                
                return NO;
                
            } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){ // Access has been granted ..do something
                        
                    } else { // Access denied ..do something
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        [alert addAction:cancelButton];
                        [alert addAction:okButton];

                        [top presentViewController:alert animated:YES completion:NULL];
                    }
                }];
                
                return NO;
                
            } else {
               return NO;
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

+(BOOL)photoAccessCheck{
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        UIViewController *top = [self topViewController];
        
        //현대중공업 - 미디어 접근 권한 없어도 촬영 및 앨범 접근 허용, 실행 전 알림
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            //미디어 접근 권한 사용 및 권한이 없을 경우
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //내정보 페이지로 이동?
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            
            [top presentViewController:alert animated:YES completion:nil];
            
            return NO;
            
        } else {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
            
            if (photoStatus == PHAuthorizationStatusAuthorized) {
                return YES;
                
            } else if (photoStatus == PHAuthorizationStatusDenied) {
                NSLog(@"Access has been denied.");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_photo", @"alert_access_photo"),appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];

                [top presentViewController:alert animated:YES completion:NULL];
                
                return NO;
                
            } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        NSLog(@"1 StatusNotDetermined Access has been granted.");
                    
                        
                    } else {
                        NSLog(@"2 StatusNotDetermined Access has been granted.");
                    }
                }];
                
                return NO;
                
            } else if (photoStatus == PHAuthorizationStatusRestricted) {
                NSLog(@"Restricted access - normally won't happen.");
                return NO;
            }
            
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
*/

#pragma mark - 미디어 접근 권한과 관계없이 사용
/*
+(BOOL)cameraAccessCheckNotAuth {
    @try{
        UIViewController *top = [self topViewController];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            NSLog(@"카메라 접근 허용일 경우");
            return YES;
            
        } else if(status == AVAuthorizationStatusDenied) {
            NSLog(@"카메라 접근 허용되지않았을 경우");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            
            [top presentViewController:alert animated:YES completion:nil];
            
            return NO;
            
        } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    
                } else { // Access denied ..do something
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                         
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:cancelButton];
                    [alert addAction:okButton];

                    [top presentViewController:alert animated:YES completion:NULL];
                }
            }];
            
            return NO;
            
        } else {
           return NO;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

+(BOOL)photoAccessCheckNotAuth{
    @try{
        UIViewController *top = [self topViewController];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoStatus == PHAuthorizationStatusAuthorized) {
            return YES;
            
        } else if (photoStatus == PHAuthorizationStatusDenied) {
            NSLog(@"Access has been denied.");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_photo", @"alert_access_photo"),appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            
            [top presentViewController:alert animated:YES completion:NULL];
            
            return NO;
            
        } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
            NSLog(@"Restricted access"); //처음 권한없을때 여기로
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"1 StatusNotDetermined Access has been granted."); //그리고 확인 시 여기로
                    
                } else {
                    NSLog(@"2 StatusNotDetermined Access has been granted."); //허용안함하면 여기로
                }
            }];
            //return NO;
            
        } else if (photoStatus == PHAuthorizationStatusRestricted) {
            NSLog(@"Restricted access - normally won't happen.");
            return NO;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
*/


+ (void)cameraAccessCheckNotAuth:(void (^)(BOOL status))completion{
    @try{
        UIViewController *top = [self topViewController];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            NSLog(@"카메라 접근 허용일 경우");
            completion(YES);
            
        } else if(status == AVAuthorizationStatusDenied) {
            NSLog(@"카메라 접근 허용되지않았을 경우");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [top presentViewController:alert animated:YES completion:nil];
            
            completion(NO);
            
        } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    completion(YES);
                    
                } else { // Access denied ..do something
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_camera", @"alert_access_camera"), appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                         
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:cancelButton];
                    [alert addAction:okButton];

                    [top presentViewController:alert animated:YES completion:NULL];
                    
                    completion(NO);
                }
            }];
            
//            return NO;
            
        } else {
            completion(NO);
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}


+ (void)photoAccessCheckNotAuth:(void (^)(BOOL status))completion{
    @try{
        UIViewController *top = [self topViewController];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoStatus == PHAuthorizationStatusAuthorized) {
            completion(YES);
            
        } else if (photoStatus == PHAuthorizationStatusDenied) {
            NSLog(@"Access has been denied.");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_access_photo", @"alert_access_photo"),appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            
            [top presentViewController:alert animated:YES completion:NULL];
            
            completion(NO);
            
        } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
            NSLog(@"Restricted access"); //처음 권한없을때 여기로
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"1 StatusNotDetermined Access has been granted."); //그리고 확인 시 여기로
                    completion(YES);
                    
                } else {
                    NSLog(@"2 StatusNotDetermined Access has been granted."); //허용안함하면 여기로
                    completion(NO);
                }
            }];
            //return NO;
            
        } else if (photoStatus == PHAuthorizationStatusRestricted) {
            NSLog(@"Restricted access - normally won't happen.");
            completion(NO);
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

@end
