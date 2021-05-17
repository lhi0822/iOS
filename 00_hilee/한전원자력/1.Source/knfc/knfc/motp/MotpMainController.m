//
//  ViewController.m
//  Example
//
//  Created by GYUYOUNG KANG on 22/08/2018.
//  Copyright © 2018 KCS. All rights reserved.
//

#import "AppDelegate.h"

#import "MotpMainController.h"

#import "SDKUtils.h"

#import "MOTPRegViewController.h"
#import "MOTPCodeViewController.h"


@interface MotpMainController ()

@property (weak) IBOutlet UIButton *regBtn;
@property (weak) IBOutlet UIButton *codeBtn;
@property (weak) IBOutlet UIButton *removeBtn;
@property (weak) IBOutlet UIButton *cancelBtn;

@end

@implementation MotpMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 소프트 토큰 등록 버튼 터치 이벤트 설정
    [self.regBtn addTarget:self action:@selector(regButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    // 소프트 토큰 코드 버튼 터치 이벤트 설정
    [self.codeBtn addTarget:self action:@selector(codeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    // 소프트 토큰 제거 버튼 터치 이벤트 설정
    [self.removeBtn addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelBtn addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIThread
    {
        // 소프트 토큰이 등록되어 있으면 초기에 자동으로 토큰값을 표시하도록 한다.
        if(appDelegate.commndLineApp)
        {
            [self codeButtonTapped:nil];
        }
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)cancelButtonTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

 
// 소프트 토큰 등록
- (void)regButtonTapped:(UIButton *)sender
{
    if(appDelegate.commndLineApp.isLoadedIdentity)
    {
        [self alreadyRegedSoftTokenAlert];
    }
    else
    {
        MOTPRegViewController *controller = [[MOTPRegViewController alloc] initWithNibName:@"MOTPRegViewController" bundle:nil];
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

// 소프트 토큰 코드
- (void)codeButtonTapped:(UIButton *)sender
{
    if(!appDelegate.commndLineApp.isLoadedIdentity)
    {
        [self notRegedSoftTokenAlert];
    }
    else
    {
        MOTPCodeViewController *controller = [[MOTPCodeViewController alloc] initWithNibName:@"MOTPCodeViewController" bundle:nil];
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

// 소프트 토큰 제거
- (void)removeButtonTapped:(UIButton *)sender
{
    if(!appDelegate.commndLineApp.isLoadedIdentity)
    {
        [self notRegedSoftTokenAlert];
    }
    else
    {
        [self questionForRemoveSoftToken];
    }
}


- (void)alreadyRegedSoftTokenAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"알림"
                                message:@"이미 소프트 토큰이 등록되었습니다. 재등록 하려면 제거 후 등록하십시오."
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

- (void)notRegedSoftTokenAlert
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"알림"
                                message:@"소프트 토큰이 등록되지 않았습니다. 소프트 토큰을 등록 한 후 수행 할 수 있습니다."
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


- (void)questionForRemoveSoftToken
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"제거"
                                message:@"등록된 소프트 토큰을 제거합니까?"
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
                          }];
    
    [alert addAction:yes];

    [self presentViewController:alert animated:YES completion:nil];
}







@end
