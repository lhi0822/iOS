//
//  IntroViewController.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 5..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "IntroViewController.h"
#import "iX.h"

@interface IntroViewController (){
    int endCount;
    int count;
    
    /*V-Guard*/
    //백신 객체
    //S* jck;
    //위변조방지 객체
}

@end

@implementation IntroViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
        
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        NSLog(@"orientation : %ld",(long)orientation);
        if (orientation == 1) {
            _imageView.image = [UIImage imageNamed:@"splash_image~ipad.jpg"];
        }else{
            _imageView.image = [UIImage imageNamed:@"intro_landscape.png"];
        }
    }else{
        _imageView.image = [UIImage imageNamed:@"splash_image.jpg"];
    }
    NSLog(@"_imageView.image : %@",_imageView.image);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        //if([[cookie domain] isEqualToString:[AppDelegate getWebURL]]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        //}
    }
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    //개발시에 사용하는 옵션으로 상용 배포시에 필히 삭제하여야 한다.
//    ix_set_debug();
    
    
    //UIActivityIndicatorView
    //43 193 242
    myIndicator.color = [UIColor colorWithRed:43.0/255.0 green:193.0/255.0 blue:242.0/255.0 alpha:1.0];
    [myIndicator startAnimating];

    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        //V-Guard
        [self initApp];
    });
    */
    
    [self startTimer];
}



-(void) startTimer{
    count = 0;
    endCount = 1;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    if (count==endCount) {
        [myIndicator stopAnimating];
        myIndicator.hidesWhenStopped =YES;
        [myIndicator removeFromSuperview];
        
        [self ixShieldSystemCheck];
    }
}

-(void)callWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@",[MFUtil getMainURL]];
    urlString = [urlString stringByAppendingPathComponent:@"dataservice41/MfPubMenu?appNo=1&devOs=I&devTy=P"];
    NSURL *url = [NSURL URLWithString:urlString];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:nil];
    session.delegate =self;
    [session start];
    
}

- (BOOL)webAppCopy:(NSString *)downloadURL{
    //NSLog(@"downloadURL : %@",downloadURL);
    //NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *webAppFolder = [documentFolder stringByAppendingPathComponent:@"webapp"];
    NSString *webAppPath = [webAppFolder stringByAppendingFormat:@"/webapp.zip"];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    [fileManager createDirectoryAtPath:webAppFolder withIntermediateDirectories:NO attributes:nil error:nil];
    NSData *data;
    if ([downloadURL hasPrefix:@"http"]) {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    }else{
        data = [NSData dataWithContentsOfFile:downloadURL];
    }
    
    if (data==nil) {
        return NO;
    }else{
        [data writeToFile:webAppPath atomically:YES];
        ZipArchive *zip = [[ZipArchive alloc]init];
        if ([zip UnzipOpenFile:webAppPath]) {
            [zip UnzipFileTo:webAppFolder overWrite:YES];
        }
        if([zip UnzipCloseFile]){
            [fileManager removeItemAtPath:webAppPath error:nil];
        }
        return YES;
    }
    
}

- (void)webAppTest{
    //NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSString *webAppFolder = [documentFolder stringByAppendingPathComponent:@"webapp"];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"sampleWebapp" ofType:@"zip"];
    if ([manager isReadableFileAtPath:path]) {
        if ([self webAppCopy:path]) {
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *webAppFolder = [documentFolder stringByAppendingPathComponent:@"webapp"];
            NSString *filePath = [webAppFolder stringByAppendingPathComponent:@"Sample.html"];
            NSString *startURL = filePath;

            [self performSegueWithIdentifier:@"PushWebView" sender:startURL];
        }else{
            //NSLog(@"is copy : NO");
        }
    }else{
        //NSLog(@"bundle copy failed : not found [sampleWebapp.zip]");
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==101) {
        exit(0);
    }else{
        [self callWebService];
    }
}
- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            _imageView.image = [UIImage imageNamed:@"intro.p.png"];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            _imageView.image = [UIImage imageNamed:@"intro.l.png"];
            break;
        case UIDeviceOrientationLandscapeRight:
            /* start special animation */
            _imageView.image = [UIImage imageNamed:@"intro.l.png"];
            break;
            
        default:
            break;
    };
}
-(BOOL)shouldAutorotate{
    return YES;
}

-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [myIndicator stopAnimating];
    [myIndicator setHidden:YES];
    
    if (error==nil) {
        NSString *encString = session.returnDataString;
        NSError *error;
        NSString *decString = [encString AES256DecryptWithKeyString:[MFUtil getAES256Key]];
        decString = [NSString urlDecodeString:decString];
        NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        NSDictionary *dic = [tmpDic objectForKey:@"0"];
        NSLog(@"intro dic : %@", dic);
        
        if (dic!=nil) {
            NSString *startURL = [dic objectForKey:@"V6"];
            //startURL = @"http://ml.korcham.net";
            [self performSegueWithIdentifier:@"PushWebView" sender:startURL];
        }
    }else{
        NSLog(@"error : %@",error);
        if(session.error.code==-1001){
            [self callWebService];
        }
     
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ixShield
-(void)ixShieldSystemCheck{
    // * 시스템 체크 진행
    // 시스템 검사 API의 경우 Objective-C를 타켓으로 하는 Hooking Tool 에 의한 메소드 우회를 방지하기 위해 아래의 사항을 권장합니다.
    // 1. 별도의 Objectivce-C 메소드로 재구현하지 않고 C API 그대로 사용
    // 2. 호출 시점은 비즈니스 로직상 반드시 수행되야하는 위치에서 호출
    //  ( 예, 어플리케이션 실행 초기 서버와의 데이터 통신을 하는 메소드 )
    struct ix_detected_pattern *patternInfo;
    int ret = ix_sysCheckStart(&patternInfo);

    if (ret != 1) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ixShield(AV)"
//                                                        message:[NSString stringWithFormat:@"error code : %d",ret]
//                                                       delegate:@"nil"
//                                              cancelButtonTitle:NSLocalizedString(@"확인", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:[NSString stringWithFormat:NSLocalizedString(@"ixShield_error_msg", @"ixShield_error_msg"), ret] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                                //exit(0);
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];

    }else {
        NSString *jbCode = [NSString stringWithUTF8String:patternInfo->pattern_type_id];

        if ([jbCode isEqualToString:@"0000"]) {
            NSLog(@"[ixShield(AV)] System OK");
            [self callWebService];
        }
        
        else if ([[jbCode substringToIndex:1] isEqualToString:@"H"]) {
            // Hooking Tool이 탐지될 경우 jbCode가 H로 시작합니다.
            // Hooking Tool에 대한 탐지 시 어플리케이션 종료를 권고합니다.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:NSLocalizedString(@"ixShield_alert_msg", @"ixShield_alert_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    //exit(0);
                                                                    [self callWebService];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            // Error code Check and App Exit.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ixShield_error_title",@"ixShield_error_title") message:NSLocalizedString(@"ixShield_alert_msg", @"ixShield_alert_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    //exit(0);
                                                                    [self callWebService];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"[ixShield(AV)] %@", [NSString stringWithFormat:@"Jail break %@",[NSString stringWithUTF8String:patternInfo->pattern_type_id]]);
        }
    }
}

#pragma mark - V-Guard
- (void)initApp{
//    if ([self equalInt] == 504030201 && [self equalInt] == 504030201) {
//        // 탈옥 되지 않았을 경우에 대한 이벤트
//        /** 위변조 방지 루틴**/
//
//        int result = [self getResultAPD];
//        //int result = 0;
//        if (result == 0) {
//            NSLog(@"위변조 방지 성공");
//        }else{
//            NSLog(@"위변조 방지 실패");
//        }
//
//        [self callWebService];
//
//    } else {
//        // 탈옥 되었을 경우에 대한 이벤트
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"탈옥된 기기 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
//        alertView.tag = 101;
//        [alertView show];
//
//    }
}

/*
- (int)getResultAPD{
     int result;
     NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
     NSString *filePath = [[NSBundle mainBundle] pathForResource:appName ofType:@""];
     
     amanager = [[APDApiManager alloc] init];
     [amanager initAPD:LIC_KEY :APD_URL];
     //[amanager setQuitFlag:NO];
     NSString *uuid = [MFUtil getUUID];
     
     NSString *resultString;
     @try {
         resultString = [amanager startAppDefence:uuid :uuid :filePath];
     } @catch (NSException *exception) {
         NSLog(@"### exception : %@",exception);
     } @finally{
         NSLog(@"AppDefence result : %d",resultString.intValue);
         if (resultString==nil) {
             result = -1;
         }else{
             result = resultString.intValue;
         }
     }

     // SUCCESS
     // "00" : "앱위변조 검증 성공"
     
     // FAILURE
     // "01" : "로그인 실패"
     // "02" : "JailBreak 장비, 앱위변조 검증 실패"
     // "04" : "앱위변조 검증 실패"
     // "06" : "앱위변조 검증 실패"
     // "99" : "예외사항 발생"

     return result;
}
 
- (NSInteger) equalInt {
    // 인터페이스 초기화
    jck = [[S alloc]init];
    
    // 리턴값을 받아 처리하는 부분
    NSInteger ck;
    int r = arc4random_uniform(9);
    
    switch (r) {
        case 0:
            ck = [jck toa];
            break;
        case 1:
            ck = [jck tob];
            break;
        case 2:
            ck = [jck toc];
            break;
        case 3:
            ck = [jck tod];
            break;
        case 4:
            ck = [jck toe];
            break;
        case 5:
            ck = [jck tof];
            break;
        case 6:
            ck = [jck tog];
            break;
        case 7:
            ck = [jck toh];
            break;
        case 8:
            ck = [jck toi];
            break;
        case 9:
            ck = [jck toj];
            break;
        default:
            ck = [jck toa];
            break;
    }
    return ck;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"######################## %s",__FUNCTION__);
    WebViewController *vc = [segue destinationViewController];
    vc.startURL = (NSString *)sender;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
}

@end
