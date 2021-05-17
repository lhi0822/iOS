
#import "loginController.h"
#import "AppDelegate.h"
//#import "MotpMainController.h"
//#import "MOTPRegViewController.h"
//#import "MOTPCodeViewController.h"
//#import "SDKUtils.h"

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
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGtest:)];
    singleTap.numberOfTapsRequired = 1;
    [self.red_view addGestureRecognizer:singleTap];

    UITapGestureRecognizer * singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(motptapGtest:)];
    singleTap2.numberOfTapsRequired = 1;
    [self.motp_view addGestureRecognizer:singleTap2];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void) tapGtest:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.redwhistle.org/m/report/reportNew.asp?organ=1637"]];
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
//    if(!appDelegate.commndLineApp.isLoadedIdentity)
//    {
//        //토큰 등록이 필요한 경우
//        MOTPRegViewController * motpregview = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
//        [self presentViewController:motpregview animated:YES completion:NULL];
//
//    }
//    else
//    {
//        //토큰이 이미 등록된 경우
//        MOTPCodeViewController *controller = [[MOTPCodeViewController alloc] initWithNibName:@"MOTPCodeViewController" bundle:nil];
//        [self presentViewController:controller animated:YES completion:NULL];
//    }

    
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

//- (IBAction)btnAddPress:(id)sender{
//    //motp 체크
//    if(!appDelegate.commndLineApp.isLoadedIdentity)
//    {
//        //토큰 등록이 필요한 경우
//        MOTPRegViewController * motpregview = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
//        [self presentViewController:motpregview animated:YES completion:NULL];
//
//    }
//    else
//    {
//        //토큰이 이미 등록된 경우
//        UIAlertController *alert = [UIAlertController
//                                    alertControllerWithTitle:@"기기등록"
//                                    message:@"이미 등록된 OTP토큰이 존재합니다.\n기존 토큰을 제거하고 새로 등록하시겠습니까?"
//                                    preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction *no = [UIAlertAction
//                             actionWithTitle:@"아니오"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                             }];
//        [alert addAction:no];
//
//        UIAlertAction *yes = [UIAlertAction
//                              actionWithTitle:@"예"
//                              style:UIAlertActionStyleDestructive
//                              handler:^(UIAlertAction * action)
//                              {
//
//                                  [SDKUtils deleteIdentityFile];
//                                  [appDelegate.commndLineApp loadIdentity];
//
//                                  [alert dismissViewControllerAnimated:YES completion:nil];
//
//                                  UIAlertController *alert2 = [UIAlertController
//                                                               alertControllerWithTitle:@"알림"
//                                                               message:@"포털에서 기존 토큰을 삭제 후 다시 생성하세요."
//                                                               preferredStyle:UIAlertControllerStyleAlert];
//
//                                  UIAlertAction *ok = [UIAlertAction
//                                                       actionWithTitle:@"확인"
//                                                       style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action)
//                                                       {
//                                                           [alert2 dismissViewControllerAnimated:YES completion:nil];
//                                                       }];
//
//                                  [alert2 addAction:ok];
//                                  [self presentViewController:alert2 animated:YES completion:nil];
//
//                              }];
//
//        [alert addAction:yes];
//        [self presentViewController:alert animated:YES completion:nil];
//
//    }
//}

- (IBAction)btnloginPress:(id)sender {
//    NSLog(@"aiddI1627l : %@", [self createSHA256:@"aiddl1627!"]);
//    NSLog(@"knfc141545@ : %@", [self createSHA256:@"knfc141545@"]);
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[app loadmain];
   
    
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
    
    //비밀번호 SHA256암호화
    NSString *pwd = [self createSHA256:self.txtpwd.text];
    NSLog(@"pwd : %@", pwd);
    
//    NSString *strurl = [NSString stringWithFormat:@"%@XXX/m_login.jsp?sid=%@&pwd=%@&device_id=%@",host,self.txtid.text,pwd, app.deviceID];
//
//    NSLog(@"%@", strurl);
//    NSData *returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
//
//    NSString *stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",stStr);
//    //[returnData release];
//    //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
//    stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//    returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
//    if ([returnData length] == 0) {
//        return;
//    }
//    //jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict;
//    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
//    if (!jsonSerializationClass) {
//        //iOS < 5 didn't have the JSON serialization class
//        dict = [returnData objectFromJSONData]; //JSONKit
//    }
//    else {
//        NSError *jsonParsingError = nil;
//        dict = [NSJSONSerialization JSONObjectWithData:returnData options:0   error:&jsonParsingError];
//
//    }
//
//    NSLog(@"%@",[dict description]);
//
//    if ([[dict objectForKey:@"searchResult"] isKindOfClass:[NSArray class]]) {
//        NSDictionary *dt = [[dict objectForKey:@"searchResult"] objectAtIndex:0];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:@"Y" forKey:@"auto"];
//        [defaults setObject:[dt objectForKey:@"user_id"] forKey:@"user_id"];
//        [defaults setObject:[dt objectForKey:@"user_sabun"] forKey:@"user_sabun"];
//        [defaults setObject:[dt objectForKey:@"user_name"] forKey:@"user_name"];
//        [defaults setObject:[dt objectForKey:@"user_department"] forKey:@"user_department"];
//        [defaults setObject:[dt objectForKey:@"user_positon"] forKey:@"user_positon"];
//        if (savecheck) {
//            [defaults setObject:self.txtpwd.text forKey:@"password"];
//            [defaults setObject:@"Y" forKey:@"save"];
//        }
//        [defaults synchronize];
//        [app loadmain];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"로그인에 실패했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
//        [alert show];
//    }
    
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
    
//    NSLog(@"output : %@", hash);
    return hash;
}
@end


