//
//  MOTPRegViewController.m
//  Example
//
//  Created by GYUYOUNG KANG on 23/08/2018.
//  Copyright © 2018 KCS. All rights reserved.
//

#import "AppDelegate.h"

#import "MOTPRegViewController.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

#import "ETIdentity.h"
#import "ETIdentityProvider.h"
#import "ETSoftTokenSDK.h"

#import "SDKUtils.h"

#import "MOTPCodeViewController.h"


@interface MOTPRegViewController () <QRCodeReaderDelegate, UITextFieldDelegate>
{
    ETIdentity *regIdentity;
}

@property (weak) IBOutlet UIButton *cancelBtn;
@property (weak) IBOutlet UIButton *qrCodeBtn;
@property (weak) IBOutlet UIButton *confirmBtn;

@property (weak) IBOutlet UITextField *serialNumberInput;
@property (weak) IBOutlet UITextField *activationCodeInput;
@property (weak) IBOutlet UIButton *createRegCodeButton;
@property (weak) IBOutlet UILabel *regCodeLabel;

@end

@implementation MOTPRegViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // 취소 버튼 터치 이벤트 설정
    [self.cancelBtn addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    // QR Code 버튼 터치 이벤트 설정
    [self.qrCodeBtn addTarget:self action:@selector(qrCodeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    // 확인 버튼 터치 이벤트 설정
    [self.confirmBtn addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    // 등록코드생성 버튼 이벤트 설정
    [self.createRegCodeButton addTarget:self action:@selector(createRegCodeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.serialNumberInput.delegate = self;
    self.activationCodeInput.delegate = self;
    
    
    self.regCodeLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}


// 키보드 엔트키에 대한 동작
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.serialNumberInput)
    {
        [self.view endEditing:YES];
        
    }else if(textField == self.activationCodeInput){
        [self.view endEditing:YES];
    }
    return YES;
}

// 취소 버튼 터치
- (void)cancelButtonTapped:(UIButton *)sender
{
    [self cancelRegSoftTokenAlert];
}

// QR Code 버튼 터치
- (void)qrCodeButtonTapped:(UIButton *)sender
{
    [self scanQRCode];
}


// 등록코드생성 버튼 터치
- (void)createRegCodeButtonTapped:(id)sender
{
    [self createRegCode];
}


// 확인 버튼 터치
- (void)confirmButtonTapped:(id)sender
{
    if(regIdentity)
    {
        [self confirmRegSoftTokenAlert];
    }
    else
    {
        [self invalidRegCodeAlert];
    }
}




// QR 코드 스캔
- (void)scanQRCode
{
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]])
    {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"취소" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString)
         {
             NSLog(@"QRCode result: %@", resultAsString);
         }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else
    {
        [self notSupportedOnDeviceAlert];
    }
}




- (void)notSupportedOnDeviceAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"에러"
                                message:@"장치가 지원하지 않습니다."
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

- (void)passwordIncorrectAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"에러"
                                message:@"패스워드가 정확하지 않습니다. 다시 시도해 주십시오."
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

- (void)dataIncorrectAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"에러"
                                message:@"입력한 정보가 정확하지 않습니다. 다시 입력한 후 시도해 주십시오."
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


- (void)errorRegAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"에러"
                                message:@"등록을 완료할 수 없습니다. 계속 이 현상이 나타나면 문의처에 문의 바랍니다."
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


- (void)invalidRegCodeAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"에러"
                                message:@"아직 등록코드가 생성되지 않았습니다. 정확한 정보를 입력하여 등록코드를 생성한 후 진행할 수 있습니다."
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



- (void)confirmRegSoftTokenAlert
{
    // 등록완료
    UIAlertController *confirm = [UIAlertController
                                  alertControllerWithTitle:@"등록완료"
                                  message:@"표시된 등록코드를 웹사이트에 등록하였습니까?\n등록을 완료하고 등록 창을 닫으면 이 등록코드는 다시 표시되지 않습니다."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"아니오"
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction * action)
                         {
                             [confirm dismissViewControllerAnimated:YES completion:nil];
                         }];
    [confirm addAction:no];
    
    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:@"예"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self completeRegSoftToken];
                          }];
    
    [confirm addAction:yes];
    
    [self presentViewController:confirm animated:YES completion:nil];
}


- (void)cancelRegSoftTokenAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"등록취소"
                                message:@"등록을 취소하고 창을 닫습니까?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"아니오"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                         }];
    [alert addAction:no];
    
    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:@"예"
                          style:UIAlertActionStyleDestructive
                          handler:^(UIAlertAction * action)
                          {
                              [self hideKeyboard];
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }];
    
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
}








// QRCODE ==================================================================

- (void)qrcodePasswordCheck:(NSString *)linkString
{
    NSURL *launchUrl = [NSURL URLWithString:linkString];
    ETLaunchUrlParams *launchParms = [ETSoftTokenSDK parseLaunchUrl:launchUrl];
    if (launchParms && [launchParms isKindOfClass:[ETSecureOfflineActivationLaunchUrlParams class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"QR 패스워드" message:@"QR 패스워드를 입력하세요." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
         {
             textField.placeholder = @"QR 패스워드";
             textField.secureTextEntry = NO;
             textField.keyboardType = UIKeyboardTypeASCIICapable;
         }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            NSString *password = [[alertController textFields][0] text];
                                            
                                            NSLog(@"Password %@", password);
                                            
                                            NSLog(@"launchParms is ETSecureOfflineActivationLaunchUrlParams");
                                            ETSecureOfflineActivationLaunchUrlParams *offlineActivationUrlParam = (ETSecureOfflineActivationLaunchUrlParams *)launchParms;
                                            
                                            ETOfflineActivationLaunchUrlParams *offlineActivationUrlParamDecrypted = [offlineActivationUrlParam decryptUsingPassword:(NSString *)password];
                                            
                                            NSString *serialNumber = offlineActivationUrlParamDecrypted.serialNumber;
                                            NSString *activationCode = offlineActivationUrlParamDecrypted.activationCode;
                                            
                                            NSLog(@"serialNumber : %@", serialNumber);
                                            NSLog(@"activationCode : %@", activationCode);
                                            
                                            if(serialNumber && activationCode)
                                            {
                                                self.serialNumberInput.text = serialNumber;
                                                self.activationCodeInput.text = activationCode;
                                                UIThread
                                                {
                                                    [self createRegCode];
                                                });
                                            }
                                            else
                                            {
                                                self.serialNumberInput.text = @"";
                                                self.activationCodeInput.text = @"";
                                                [self invalidRegCode];
                                                
                                                UIThread
                                                {
                                                    [self passwordIncorrectAlert];
                                                });
                                            }
                                        }];
        [alertController addAction:confirmAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           NSLog(@"Canelled");
                                           self.serialNumberInput.text = @"";
                                           self.activationCodeInput.text = @"";
                                           [self invalidRegCode];
                                       }];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)createRegCode
{
    UIThread
    {
        [self hideKeyboard];
    });
    
    
    NSString *serialNumber = self.serialNumberInput.text;
    NSString *activationCode = self.activationCodeInput.text;

    ETIdentity *tmpIdentity = nil;

    @try
    {
        tmpIdentity = [ETIdentityProvider generate:nil // Not registering online during this step so don't provide a device ID.
                                      serialNumber:serialNumber
                                    activationCode:activationCode];
    }
    @catch (NSException *exception)
    {
        tmpIdentity = nil;
    }

    NSLog(@"registrationCode : %@", tmpIdentity.registrationCode);

    if(tmpIdentity==nil || tmpIdentity.registrationCode==nil)
    {
        [self invalidRegCode];

        UIThread
        {
            self.regCodeLabel.hidden = YES;
            [self dataIncorrectAlert];
        });
    }
    else
    {
        self.regCodeLabel.text = tmpIdentity.registrationCode;
        [self.regCodeLabel setTextColor:[UIColor blueColor]];
        regIdentity = tmpIdentity;

        UIThread
        {
            self.regCodeLabel.hidden = NO;
        });
    }
}
- (void)invalidRegCode
{
    self.regCodeLabel.text = @"xxxxx-xxxxx";
    [self.regCodeLabel setTextColor:UIColorFromRGB(0xe0e0e0)];    
    regIdentity = nil;
}

- (void)completeRegSoftToken
{
    if([SDKUtils saveIdentity:regIdentity])
    {
        appDelegate.commndLineApp.identity = regIdentity;
        
        [self hideKeyboard];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [SDKUtils deleteIdentityFile];
        [self errorRegAlert];
    }
}









#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    __block NSString *linkString = result;
    
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         UIThread
         {
             [self qrcodePasswordCheck:linkString];
         });
     }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
