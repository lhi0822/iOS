//
//  MOTPCodeViewController.m
//  Example
//
//  Created by GYUYOUNG KANG on 23/08/2018.
//  Copyright © 2018 KCS. All rights reserved.
//

#import "AppDelegate.h"

#import "MOTPCodeViewController.h"
#import "OJFSegmentedProgressView.h"


@interface MOTPCodeViewController () <UITextFieldDelegate>
{
    
}

@property (weak) IBOutlet UIButton *closeBtn;

@property (weak) IBOutlet UILabel *codeLabel1;
@property (weak) IBOutlet UILabel *codeLabel2;
@property (weak) IBOutlet UILabel *codeLabel3;
@property (weak) IBOutlet UILabel *codeLabel4;
@property (weak) IBOutlet UILabel *codeLabel5;
@property (weak) IBOutlet UILabel *codeLabel6;
@property (weak) IBOutlet UILabel *codeLabel7;
@property (weak) IBOutlet UILabel *codeLabel8;

@property (weak) IBOutlet OJFSegmentedProgressView *lifeTimeMeter;
@property (weak) IBOutlet UILabel *lifeTimeLabel;


@property (weak) IBOutlet UITextField *autoLoginAddressTextField;
@property (weak) IBOutlet UITextField *autoLoginIdTextField;
@property (weak) IBOutlet UIButton *autoLoginButton;

@property (strong) NSArray *codeLabels;
@property (strong) NSTimer *codeGenTimer;

@property (strong, nonatomic) UIWindow *window;

@end

@implementation MOTPCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 닫기 버튼 터치 이벤트 설정
    [self.closeBtn addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    // 자동로그인 버튼 터치 이벤트 설정
    [self.autoLoginButton addTarget:self action:@selector(autologinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    self.codeLabels = [NSArray arrayWithObjects:
                       self.codeLabel1,
                       self.codeLabel2,
                       self.codeLabel3,
                       self.codeLabel4,
                       self.codeLabel5,
                       self.codeLabel6,
                       self.codeLabel7,
                       self.codeLabel8,
                       nil];
    for(UILabel *codeLabel in self.codeLabels)
    {
        [self codeLabelStyle:codeLabel];
    }

    [self alignCodeLabelPositions];
    [self showSecureCode];

    self.autoLoginAddressTextField.delegate = self;
    self.autoLoginIdTextField.delegate = self;

    [self loadAutologinTextField];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// 닫기 버튼 터치
- (void)closeButtonTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateOTP
{
    [appDelegate.commndLineApp.identity setOtpLength:8];
    NSString *otpString = [appDelegate.commndLineApp.identity getOTP:[NSDate new]];
    for(int i=0;i<8;i++)
    {
        UILabel *label = [self.codeLabels objectAtIndex:i];
        label.text = [NSString stringWithFormat:@"%C",[otpString characterAtIndex:i]];
        label.alpha = 1.0f;
    }
}


- (void)showSecureCode
{
    @synchronized (self)
    {
        [self updateOTP];
        
        self.lifeTimeMeter.alpha = 1.0f;
        if(self.codeGenTimer==nil)
        {
            [self startCodeGenTimer];
        }
    }
}


- (void)codeGenTimerProc:(NSTimer *)timer
{
    time_t currentTime = time(NULL);
    struct tm timeStruct;
    localtime_r(&currentTime, &timeStruct);
    
    int lifeTime = 30 - (timeStruct.tm_sec % 30);
    NSLog(@"codeGenTimerProc %d", lifeTime);
    
    UIThread
    {
        if(lifeTime==30)
        {
            [self updateOTP];
        }
        [self.lifeTimeMeter setProgress:(float)lifeTime / 30.f];
        self.lifeTimeLabel.text = [NSString stringWithFormat:@"잔여시간 %02d 초", lifeTime];
        self.lifeTimeLabel.alpha = 1.0f;
    });
}
- (void)startCodeGenTimer
{
    @synchronized (self)
    {
        [self stopCodeGenTimer];
        
        self.codeGenTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(codeGenTimerProc:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.codeGenTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopCodeGenTimer
{
    @synchronized (self)
    {
        if(self.codeGenTimer)
        {
            [self.codeGenTimer invalidate];
            self.codeGenTimer = nil;
        }
    }
}



- (void)viewDidDisappear:(BOOL)animated
{
    [self stopCodeGenTimer];
}





- (void)buttonStyle:(UIButton *)button borderColor:(UIColor *)borderColor
{
    button.layer.borderColor = [borderColor CGColor];
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 8.f;
}

- (void)codeLabelStyle:(UILabel *)codeLabel
{
    codeLabel.layer.borderColor = [UIColor grayColor].CGColor;
    codeLabel.layer.borderWidth = 1.0f;
    codeLabel.layer.cornerRadius = 6.f;
}
- (void)alignCodeLabelPositions
{
    CGFloat labelWidth = self.codeLabel1.frame.size.width;
    CGFloat labelSpace = 4.f;
    CGFloat centerSpace = 10.f;
    CGFloat centerX = self.view.bounds.size.width / 2;
    CGFloat startX = centerX - ((labelWidth + labelSpace) * (self.codeLabels.count / 2));
    startX -= (centerSpace / 2) - (labelSpace / 2);
    
    CGFloat posX = startX;
    for(int i=0;i<self.codeLabels.count;i++)
    {
        UILabel *codeLabel = [self.codeLabels objectAtIndex:i];
        CGRect r = self.codeLabel1.frame;
        
        r.origin.x = posX;
        
        if(i==3)
        {
            posX += labelWidth + centerSpace;
        }
        else
        {
            posX += labelWidth + labelSpace;
        }
        
        codeLabel.frame = r;
    }
    
    CGRect r = self.lifeTimeMeter.frame;
    r.origin.x = startX;
    r.size.width = posX - labelSpace - startX;
    self.lifeTimeMeter.frame = r;
    
    self.lifeTimeMeter.numberOfSegments = 30;
    self.lifeTimeMeter.segmentSeparatorSize = 3.0f;
}


- (void)saveAutologinTextField
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.autoLoginAddressTextField.text forKey:@"autoLoginAddressTextField"];
    [defaults setObject:self.autoLoginIdTextField.text forKey:@"autoLoginIdTextField"];
    [defaults synchronize];
}
- (void)loadAutologinTextField
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *address = [defaults objectForKey:@"autoLoginAddressTextField"];
    if(address==nil || address.length==0)
    {
        address = @"https://entrust.kcert.co.kr/autoLoginBridge.jsp";
    }
    if(address)
    {
        self.autoLoginAddressTextField.text = address;
    }
    
    NSString *userid = [defaults objectForKey:@"autoLoginIdTextField"];
    if(userid)
    {
        self.autoLoginIdTextField.text = userid;
    }
}





- (void)saveLastAutologinOtpCode:(NSString *)otpcode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:otpcode forKey:@"lastAutologinOtpCode"];
    [defaults synchronize];
}
- (NSString *)readLastAutologinOtpCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *otpCode = [defaults objectForKey:@"lastAutologinOtpCode"];
    return otpCode;
}

- (void)alreadyRequestedOtpCodeAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"알림"
                                message:@"이미 자동로그인을 요청한 상태입니다. 재요청이 필요하면 보안코드가 갱신된 후 시도하시기 바랍니다."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"확인"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}





// 키보드 엔트키에 대한 동작
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.autoLoginAddressTextField)
    {
        [self saveAutologinTextField];
        [self.view endEditing:YES];
        
    }else if(textField == self.autoLoginIdTextField){
        [self saveAutologinTextField];
        [self.view endEditing:YES];
    }
    
    return YES;
}

// 자동로그인 버튼 터치
- (void)autologinButtonTapped:(UIButton *)sender
{
    NSString *otpString = [appDelegate.commndLineApp.identity getOTP:[NSDate new]];
    NSString *lastSentOtpString = [self readLastAutologinOtpCode];
    if([otpString isEqualToString:lastSentOtpString])
    {
        [self alreadyRequestedOtpCodeAlert];
        return;
    }
    
    
    NSString *autoLoginUrl = [NSString stringWithFormat:@"http://motp.knfc.co.kr/otp_server/server.jsp?command=startAutoLoginTry&userid=%@&otpNumber=%@", self.autoLoginIdTextField.text, otpString];
    
    NSLog(@"url : %@", autoLoginUrl);
    
    NSURL *url = [NSURL URLWithString:autoLoginUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"res : %@", ret);
    [self saveLastAutologinOtpCode:otpString];
    
    //로그인 성공시
    if([ret isEqualToString:@"({\"result\":[\"Y\"]})"]){
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"알림"
                                    message:@"OTP 로그인 완료"
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"확인"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"알림"
                                    message:@"OTP 로그인에 실패했습니다."
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"확인"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];

    }
    
    
}
@end
