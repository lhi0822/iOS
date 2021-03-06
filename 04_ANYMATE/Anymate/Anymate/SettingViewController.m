//
//  PopoverViewController.m
//  Anymate
//
//  Created by Kyeong In Park on 13. 1. 4..
//  Copyright (c) 2013년 Kyeong In Park. All rights reserved.
//

#import "SettingViewController.h"
#import "InfoViewController.h"
#import "WebViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import "SoundSettingViewController.h"
@interface SettingViewController ()

@end

@implementation SettingViewController

-(void)rightBtnClick{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.isSetting = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.preferredContentSize = self.view.frame.size;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.navigationController.navigationBar.topItem.title = @"설정";
//    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:@"#19385b"]];
    self.navigationController.navigationBarHidden = NO;
    
    if (@available(iOS 13.0, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        } else {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:@"19385b"];
        }
    } else {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:@"19385b"];
    }
    
    _tableView.scrollEnabled = NO;
    
    UISegmentedControl *button = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"닫기",nil]]autorelease];
    button.momentary = YES;
    //button.segmentedControlStyle = UISegmentedControlStyleBar;
    [button addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=right;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    tableList = [[NSArray alloc]initWithObjects:@"버전 정보",@"알림 테스트",@"알림음 설정", @"로그아웃",nil];
   
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    [_tableView reloadData];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"기본 정보";
    }else if(section == 1){
        return @"알림 설정";
    }else{
        return @"";
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
		return 1;
	}else if(section == 1){
		return 2;
    }else{
        return 1;
    }
    //return tableList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = [tableList objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = [tableList objectAtIndex:indexPath.row+1];
        if (indexPath.row==1) {
            NSString *soundString = @"";
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSLog(@"sound_number : %ld",(long)[prefs integerForKey:@"SOUND_NUMBER"]);
            switch ([prefs integerForKey:@"SOUND_NUMBER"]) {
                case 0:
                    soundString = @"Anymate";
                    break;
                case 1:
                    soundString = @"기본";
                    break;
                default:
                    break;
            }
            cell.detailTextLabel.text = soundString;
        }
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = [tableList objectAtIndex:indexPath.row+3];
    }
    
    //cell.textLabel.font = [UIFont systemFontOfSize:17];
    //cell.textLabel.text = [tableList objectAtIndex:indexPath.row];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section==0) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"PUSH_VER_INFO" sender:nil];
        }
    }else if(section==1){
        if(row == 0){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"알림 테스트" message:@"서버로 알림테스트를 요청하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
            [alertView show];
            [alertView release];
        }else if(row == 1){
            //SoundSettingViewController *vc = [[SoundSettingViewController alloc]init];
            //[self.navigationController pushViewController:vc animated:YES];
            
            [self performSegueWithIdentifier:@"PUSH_SOUND_SETTING" sender:nil];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그아웃" message:@"로그아웃 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
        [alertView show];
        [alertView release];
        
    }

    [tableView reloadData];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if ([alertView.title isEqualToString:@"알림 테스트"]) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=self_push&device_id=%@",[prefs objectForKey:@"URL"],[self getUUID]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [urlConnection start];
        }else if ([alertView.title isEqualToString:@"로그아웃"]) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            appDelegate.isLogout = YES;
            appDelegate.isLoad = NO;
//            LoginViewController *loginView = [[LoginViewController alloc]init];
//            [self.navigationController pushViewController:loginView animated:YES];
//            [loginView release];
//            [self.navigationController pushViewController:viewController animated:YES];
            
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginView = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            UINavigationController *viewController = [[UINavigationController alloc]initWithRootViewController:loginView];
            viewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:viewController animated:YES completion:nil];
            
        }else if ([alertView.title isEqualToString:@"알림 설정"]) {
            if (buttonIndex==1) {
                NSLog(@"1");
            }else if(buttonIndex==2){
                NSLog(@"2");
            }
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    returnString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"data : %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"returnString : %@", returnString);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    switch ([prefs integerForKey:@"SOUND_NUMBER"]) {
//        case 0:
//            soundId = @"anymate";
//            break;
//        case 1:
//            soundId = @"default";
//        default:
//            break;
//    }
    
    if ([returnString isEqualToString:@"101"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"전송 성공" message:@"알림 요청을 성공하였습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (NSString*) getUUID
{
    // initialize keychaing item for saving UUID.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0)
    {
        // if there is not UUID in keychain, make UUID and save it.
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);
        
        // save UUID in keychain
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }
    
    return uuid;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
