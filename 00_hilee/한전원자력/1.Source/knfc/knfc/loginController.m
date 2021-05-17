//
//  loginController.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "loginController.h"
#import "AppDelegate.h"
#import "MotpMainController.h"
#import "MOTPRegViewController.h"
#import "MOTPCodeViewController.h"
#import "SDKUtils.h"

@interface loginController ()

@end

@implementation loginController

@synthesize btnlogin, txtid, txtpwd, red_view, motp_view, device_btn;

- (void)viewDidLoad {
    savecheck = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"save"] isEqualToString:@"Y"]) {
        savecheck = true;
        [btncheck setImage:[UIImage imageNamed:@"checkbox_member_check"] forState:UIControlStateNormal];
        self.txtid.text = [defaults objectForKey:@"user_id"];
        self.txtpwd.text = [defaults objectForKey:@"password"];
    }
    
    
    [txtid addTarget:self action:@selector(inputID) forControlEvents:UIControlEventTouchDown];
    [txtpwd addTarget:self action:@selector(inputPW) forControlEvents:UIControlEventTouchDown];
    
    self.otpImgView.image = [UIImage imageNamed:@"OTP(회색).png"];
    self.motp_view.backgroundColor = [UIColor clearColor];
    
    self.red_view.layer.borderWidth = 0.5;
    self.red_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.red_view.layer.cornerRadius = 15;
    
    self.mobileImgView.image = [UIImage imageNamed:@"디바이스 아이콘(파란색).png"];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGtest:)];
    singleTap.numberOfTapsRequired = 1;
    [self.red_view addGestureRecognizer:singleTap];

    UITapGestureRecognizer * singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(motptapGtest:)];
    singleTap2.numberOfTapsRequired = 1;
    [self.motp_view addGestureRecognizer:singleTap2];
    
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString *str2_1 = @"※ 담당자 : 디지털융합부 장성호(";
    NSMutableAttributedString *attrStr2_1 = [[NSMutableAttributedString alloc]initWithString:str2_1];
    [attrStr2_1 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} range:NSMakeRange(0, str2_1.length)];
    NSString *str2_2 = @"☎︎ ";
    NSMutableAttributedString *attrStr2_2 = [[NSMutableAttributedString alloc]initWithString:str2_2];
    [attrStr2_2 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, str2_2.length)];
    NSString *str2_3 = @"042-868-1387)";
    NSMutableAttributedString *attrStr2_3 = [[NSMutableAttributedString alloc]initWithString:str2_3];
    [attrStr2_3 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} range:NSMakeRange(0, str2_3.length)];
    [resultStr appendAttributedString:attrStr2_1];
    [resultStr appendAttributedString:attrStr2_2];
    [resultStr appendAttributedString:attrStr2_3];
    self.infoLabel.attributedText = resultStr;
    
    NSString *str2_4 = @"부패행위 익명신고";
    NSMutableAttributedString *attrStr2_4 = [[NSMutableAttributedString alloc]initWithString:str2_4];
    [attrStr2_4 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, str2_4.length)];
    self.linkLabel.attributedText = attrStr2_4;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) tapGtest:(id)sender{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.redwhistle.org/m/report/reportNew.asp?organ=1637"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.redwhistle.org/m/report/reportNew.asp?organ=1637"] options:@{} completionHandler:^(BOOL success) { }];
}

- (void) motptapGtest:(id)sender{
    
    //스토리보드에서 뷰컨트롤로 가져오기
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MotpMain" bundle:nil];
    MotpMainController *motpmainvc = [storyboard instantiateViewControllerWithIdentifier:@"MotpMainController"];
    //MotpMainController *motpmainvc = [[MotpMainController alloc] initWithNibName:@"" bundle:nil];
    [self presentViewController:motpmainvc animated:YES completion:NULL];
    */
    
    /*
    MOTPRegViewController * motpregview = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
    [self presentViewController:motpregview animated:YES completion:NULL];
    */
    
    //motp 체크
    if(!appDelegate.commndLineApp.isLoadedIdentity)
    {
        //토큰 등록이 필요한 경우
        MOTPRegViewController * motpregview = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
        
        motpregview.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:motpregview animated:YES completion:NULL];

    }
    else
    {
        //토큰이 이미 등록된 경우
        MOTPCodeViewController *controller = [[MOTPCodeViewController alloc] initWithNibName:@"MOTPCodeViewController" bundle:nil];
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controller animated:YES completion:NULL];
    }

    /*
    self.naviController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    if ([self.naviController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self.naviController setNavigationBarHidden:YES];
    self.window.rootViewController = self.naviController;
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnAddPress:(id)sender{
    
    //motp 체크
    if(!appDelegate.commndLineApp.isLoadedIdentity)
    {
        //토큰 등록이 필요한 경우
        MOTPRegViewController * motpregview = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
        motpregview.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:motpregview animated:YES completion:NULL];
        
    }
    else
    {
        //토큰이 이미 등록된 경우
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"기기등록"
                                    message:@"이미 등록된 OTP토큰이 존재합니다.\n기존 토큰을 제거하고 새로 등록하시겠습니까?"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *no = [UIAlertAction
                             actionWithTitle:@"아니오"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:no];
        
        UIAlertAction *yes = [UIAlertAction
                              actionWithTitle:@"예"
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  [SDKUtils deleteIdentityFile];
                                  [appDelegate.commndLineApp loadIdentity];
                                  
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  UIAlertController *alert2 = [UIAlertController
                                                               alertControllerWithTitle:@"알림"
                                                               message:@"포털에서 기존 토큰을 삭제 후 다시 생성하세요."
                                                               preferredStyle:UIAlertControllerStyleAlert];
                                  
                                  UIAlertAction *ok = [UIAlertAction
                                                       actionWithTitle:@"확인"
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                                       {
                                                           [alert2 dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                                  
                                  [alert2 addAction:ok];
                                  [self presentViewController:alert2 animated:YES completion:nil];
                                  
                              }];
        
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

    
}

- (IBAction)btnloginPress:(id)sender {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([self.txtid.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"아이디를 입력하세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if ([self.txtpwd.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"비밀번호를 입력하세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    CUSTOM------------------------------------------------------
    //비밀번호 SHA256암호화
    NSString *pwd = [self createSHA256:self.txtpwd.text];
    pwd = [pwd urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *userId = [self.txtid.text urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *dvcId = [app.deviceID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *strurl = [NSString stringWithFormat:@"%@api/m_login.jsp?sid=%@&pwd=%@&device_id=%@", host, userId, pwd, dvcId];
//    CUSTOM------------------------------------------------------

    
//    NSString *strurl = [NSString stringWithFormat:@"%@api/m_login.jsp?sid=%@&pwd=%@&device_id=%@",host,self.txtid.text,self.txtpwd.text, app.deviceID];
    NSLog(@"strurl : %@", strurl);
    NSData *returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];

    NSString *stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"login stStr : %@",stStr);
    //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
    stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
    if ([returnData length] == 0) {
        return;
    }
    //jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass) {
        //iOS < 5 didn't have the JSON serialization class
        dict = [returnData objectFromJSONData]; //JSONKit
    }
    else {
        NSError *jsonParsingError = nil;
        dict = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];

    }

    NSLog(@"login Dict : %@",[dict description]);
//    savecheck = false;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([[defaults objectForKey:@"save"] isEqualToString:@"Y"]) {
//        savecheck = true;
//        [btncheck setImage:[UIImage imageNamed:@"checkbox_member_check"] forState:UIControlStateNormal];
//        self.txtid.text = [defaults objectForKey:@"user_id"];
//        self.txtpwd.text = [defaults objectForKey:@"password"];
//    }

    if ([[dict objectForKey:@"searchResult"] isKindOfClass:[NSArray class]]) {
        NSDictionary *dt = [[dict objectForKey:@"searchResult"] objectAtIndex:0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Y" forKey:@"auto"];
//        [defaults setObject:[dt objectForKey:@"user_id"] forKey:@"user_id"];
        [defaults setObject:[dt objectForKey:@"user_sabun"] forKey:@"user_sabun"];
        [defaults setObject:[dt objectForKey:@"user_name"] forKey:@"user_name"];
        [defaults setObject:[dt objectForKey:@"user_department"] forKey:@"user_department"];
        [defaults setObject:[dt objectForKey:@"user_positon"] forKey:@"user_positon"];
        if (savecheck) {
            //[defaults setObject:@"Y" forKey:@"auto"];
            [defaults setObject:[dt objectForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:self.txtpwd.text forKey:@"password"];
            [defaults setObject:@"Y" forKey:@"save"];
        } else {
            //체크해제 했을 경우 처리가 없어서 추가함
            [defaults removeObjectForKey:@"user_id"];
            [defaults removeObjectForKey:@"password"];
            [defaults setObject:@"N" forKey:@"save"];
        }
        [defaults synchronize];
        [app loadmain];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"로그인에 실패했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alert show];
//        [app loadmain];
    }
    
}

- (IBAction)btncheckPress:(id)sender {
    savecheck = !savecheck;
    if (savecheck) {
        [btncheck setImage:[UIImage imageNamed:@"checkbox_member_check"] forState:UIControlStateNormal];
    } else {
        [btncheck setImage:[UIImage imageNamed:@"checkbox_member"] forState:UIControlStateNormal];
    }
}

- (void) inputID {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"아이디 입력" message:@"아이디를 입력하세요"
                                                    delegate:self
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles:@"취소", nil
                           ];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.text = txtid.text;
    [alert show];

    
}

- (void) inputPW {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"비밀번호 입력" message:@"비밀번호를 입력하세요"
                                                    delegate:self
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles:@"취소", nil
                           ];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.text = txtpwd.text;
    [alert show];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView.title isEqualToString:@"아이디 입력"]){
        if(buttonIndex == 0){
            txtid.text = [[alertView textFieldAtIndex:0] text];
        }
    }
    else if([alertView.title isEqualToString:@"비밀번호 입력"]){
        if(buttonIndex == 0){
            txtpwd.text = [[alertView textFieldAtIndex:0] text];
        }
    }
    
}

#pragma mark - Encrypt SHA256
- (NSString*)createSHA256:(NSString *)string{
    const char *s=[string cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    NSString *hash = [out base64Encoding];
    
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"output : %@", hash);
    return hash;
}


@end


@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
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

@end
