//
//  CertViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "CertViewController.h"
#import "RMQServerViewController.h"
#import "IntroViewController.h"

@interface CertViewController (){
    RMQServerViewController *rmq;
    AppDelegate *appDelegate;
    BOOL isTextEnable;
}

@end

@implementation CertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.navigationItem.hidesBackButton = YES;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    isHideKeyboard = YES;
    isTextEnable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    self.compTextField.placeholder = NSLocalizedString(@"msg9", @"msg9");
    [self.compTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    self.authTextField.placeholder = NSLocalizedString(@"msg10", @"msg10");
    
    [self.authButton setTitle:NSLocalizedString(@"msg12", @"msg12") forState:UIControlStateNormal];
    
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title :NSLocalizedString(@"msg12", @"")];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(!isTextEnable){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"auto_cert_msg", @"auto_cert_msg") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
        
    } else {
        return YES;
    }
}


- (IBAction)authenticate:(id)sender {
    if(isTextEnable) [self auth];
    else [self getAuthCode];
    
//    if([self.authTextField.text isEqualToString:@""]){
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg13", @"msg13") message:NSLocalizedString(@"msg14", @"msg14") preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                             [alert dismissViewControllerAnimated:YES completion:nil];
//                                                         }];
//        [alert addAction:okButton];
//        [self presentViewController:alert animated:YES completion:nil];
//
//    } else {
//        [self auth];
//    }
}

-(void)getAuthCode{
    NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&dvcId=%@", self.userID, dvcID];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getAuthCode"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)auth {
    UIDevice *device = [UIDevice currentDevice];
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *ctCarrier = [networkInfo subscriberCellularProvider];
    
    //총 용량
    float totalSpace = 0.0f;
    NSString *totalVolume;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalVolume = [NSString stringWithFormat:@"%0.0f",totalSpace];
        //totalSpace = ((totalSpace/1024)/1024)/1024;
    }
    //사용 용량
    float availableDisk;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[path lastObject] UTF8String], &tStats);
    availableDisk = (float)(tStats.f_bavail * tStats.f_bsize);
    
    NSLog(@"auth !! : %@", [appDelegate.appPrefs objectForKey:@"DVC_ID"]);
    //NSString *dvcID = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]; //@"886165BD-ACCF-498C-BC46-8D0BFDAF1C80-E";
    NSLog(@"dvcidddddd : %@", self.dvcId);
    
    NSString *dvcKind = [device modelName];
    NSString *dvcOS = device.systemName;
    NSString *dvcVer = device.systemVersion;
    NSString *carrier = [ctCarrier carrierName]; if(carrier==nil)carrier = @"-";
    NSString *extRam = @"N";
    NSString *extTotVol = @"0";
    NSString *extUseVol = @"0";
    NSString *useVol = [NSString stringWithFormat:@"%0.0f",availableDisk];

    NSString *pushID1 = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
    NSString *pushID2 = @"-";
    NSString *isRooted = [MFUtil isRooted]?@"Y":@"N";
    NSString *authCode = self.authTextField.text;
#if TARGET_IPHONE_SIMULATOR
    isRooted = @"N";
#endif
    
    //url : http://gw.dbvalley.com, cpncode : CA, dvcId : (null), userId : hilee
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"dvcId=%@&dvcKind=%@&dvcOs=%@&dvcVer=%@&carrier=%@&extRam=%@&extTotVol=%@&extUseVol=%@&useVol=%@&pushId1=%@&pushId2=%@&isRooted=%@&usrId=%@&authCode=%@&appType=%@&dvcType=%@&usrPwd=%@&appVersion=%@&compNo=%@"
                             ,self.dvcId //dvcID
                             ,dvcKind
                             ,dvcOS
                             ,dvcVer
                             ,carrier
                             ,extRam
                             ,extTotVol
                             ,extUseVol
                             ,useVol
                             ,pushID1
                             ,pushID2
                             ,isRooted
                             ,self.userID
                             ,authCode
                             ,[[MFSingleton sharedInstance] appType]
                             ,[[MFSingleton sharedInstance] dvcType]
                             ,self.userPwd
                             ,appVersion
                             ,compNo];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"chkDvcAuth"]];
    MFURLSession *session = [[MFURLSession alloc] initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
    
}

- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error {
    [SVProgressHUD dismiss];
    if(error!=nil){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg13", @"msg13") message:error preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        //NSLog(@"wsName : %@",wsName);
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"chkDvcAuth"]) {
                [appDelegate.appPrefs setObject:self.userID forKey:@"USERID"];
                [appDelegate.appPrefs setObject:self.userPwd forKey:[appDelegate setPreferencesKey:@"USERPWD"]];
                [appDelegate.appPrefs setObject:self.userID forKey:[appDelegate setPreferencesKey:@"DBNAME"]];
                [appDelegate.appPrefs setObject:self.dvcId forKey:@"DVC_ID"];
                [appDelegate.appPrefs synchronize];
                //NSLog(@"Cert returnDictionary : %@", session.returnDictionary);
                
                NSLog(@"chkDvcAuth : %@", [appDelegate.appPrefs objectForKey:@"DVC_ID"]);
                
                [self performSegueWithIdentifier:@"INTRO_VIEW_PUSH" sender:self];
                
            } else if ([wsName isEqualToString:@"getAuthCode"]) {
                NSLog(@"Cert returnDictionary : %@", session.returnDictionary);
                NSDictionary *dataSet = [[session.returnDictionary objectForKey:@"DATASET"] objectAtIndex:0];
                NSString *authCode = [dataSet objectForKey:@"NEW_AUTH_CODE"];
                self.authTextField.text = authCode;
                
                [self auth];
                
            }
        } else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg13", @"msg13") message:[session.returnDictionary objectForKey:@"MESSAGE"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

/*
- (void)certConnectServer :(NSDictionary *)dataSet {
    NSLog(@"%s", __func__);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *compNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"COMP_NO"];
    
    NSArray *snsList = [dataSet objectForKey:@"SNS_LIST"];
    for(int i=0; i<snsList.count; i++){
        NSNumber *snsNo = [[snsList objectAtIndex:i]objectForKey:@"SNS_NO"];
        
        [appDelegate.bindQueueArr addObject:[NSString stringWithFormat:@"BOARD.POST.%@.%@", compNo, snsNo]];
        [appDelegate.bindQueueArr addObject:[NSString stringWithFormat:@"BOARD.COMMENT.%@.%@", compNo, snsNo]];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:appDelegate.bindQueueArr forKey:@"ROUTING_KEY"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RmqConnect" object:nil userInfo:dic];
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        if(isHideKeyboard){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height)];
            isHideKeyboard = NO;
        }
    }else if([notification name]==UIKeyboardWillHideNotification){
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50,self.view.frame.size.width, self.view.frame.size.height)];
        isHideKeyboard = YES;
    }
    [UIView commitAnimations];
}
- (void)_removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
