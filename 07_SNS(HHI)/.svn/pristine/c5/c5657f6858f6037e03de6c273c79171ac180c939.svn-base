//
//  SNSNoticeSetViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "SNSNoticeSetViewController.h"
#import "NoticeSetTableViewCell.h"
#import "MFDBHelper.h"
#import "AppDelegate.h"

#define HEADER_HEIGHT 45
#define POST_SWITCH_TAG 1000
#define COMM_SWITCH_TAG 2000

@interface SNSNoticeSetViewController () {
    NSString *postNoti;
    NSString *commNoti;
    AppDelegate *appDelegate;
}

@end

@implementation SNSNoticeSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *titleStr = [NSString stringWithFormat:@"%@ %@", self.snsName, NSLocalizedString(@"notification_setting_title", @"notification_setting_title")];
    
    UIView *statusBar;
    if (@available(iOS 13, *)) {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    } else {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    
//    statusBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
//    self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:titleStr];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:self
//                                                                            action:@selector(rightSideMenuButtonPressed:)];
    
    self.notiPostArr = [NSMutableArray array];
    [self.notiPostArr addObject:NSLocalizedString(@"board_info_push_setting", @"board_info_push_setting")];
    
    self.notiCommArr = [NSMutableArray array];
    [self.notiCommArr addObject:NSLocalizedString(@"board_info_push_setting", @"board_info_push_setting")];
    
    NSString *sql1 = [appDelegate.dbHelper getPostNoti:self.snsNo];
    postNoti = [appDelegate.dbHelper selectString:sql1];
    
    NSString *sql2 = [appDelegate.dbHelper getCommentNoti:self.snsNo];
    commNoti = [appDelegate.dbHelper selectString:sql2];
    
    NSLog(@"11 postNoti : %@, commNoti : %@",postNoti, commNoti);
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"22 postNoti : %@, commNoti : %@", postNoti, commNoti);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
    NSString *sqlString1 = [appDelegate.dbHelper updatePostNoti:postNoti snsNo:self.snsNo];
    [appDelegate.dbHelper crudStatement:sqlString1];
    
    NSString *sqlString2 = [appDelegate.dbHelper updateCommentNoti:commNoti snsNo:self.snsNo];
    [appDelegate.dbHelper crudStatement:sqlString2];
    
    NSMutableDictionary *pDic1 = [NSMutableDictionary dictionary];
    [pDic1 setObject:[NSNumber numberWithBool:[postNoti boolValue]] forKey:@"IS_NOTI"];
    NSData* pData1 = [NSJSONSerialization dataWithJSONObject:pDic1 options:0 error:nil];
    NSString *pJson1 = [[NSString alloc] initWithData:pData1 encoding:NSUTF8StringEncoding];
    NSMutableDictionary *pDic2 = [NSMutableDictionary dictionary];
    [pDic2 setObject:pJson1 forKey:[NSString stringWithFormat:@"%@", self.snsNo]];
    NSData* pData2 = [NSJSONSerialization dataWithJSONObject:pDic2 options:0 error:nil];
    NSString *pJson2 = [[NSString alloc] initWithData:pData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"pJson2 : %@", pJson2);

    NSMutableDictionary *cDic1 = [NSMutableDictionary dictionary];
    [cDic1 setObject:[NSNumber numberWithBool:[commNoti boolValue]] forKey:@"IS_NOTI"];
    NSData* cData1 = [NSJSONSerialization dataWithJSONObject:cDic1 options:0 error:nil];
    NSString *cJson1 = [[NSString alloc] initWithData:cData1 encoding:NSUTF8StringEncoding];
    NSMutableDictionary *cDic2 = [NSMutableDictionary dictionary];
    [cDic2 setObject:cJson1 forKey:[NSString stringWithFormat:@"%@", self.snsNo]];
    NSData* cData2 = [NSJSONSerialization dataWithJSONObject:cDic2 options:0 error:nil];
    NSString *cJson2 = [[NSString alloc] initWithData:cData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"cJson2 : %@", cJson2);
    
    [self notiUpdate:pJson2 :cJson2];
    
}

-(void)notiUpdate:(NSString *)pJson :(NSString *)cJson{
    NSString *dlqUrl = @"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish";
    NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];

    NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
    [dlqDict setObject:@"1" forKey:@"APP_NO"];
    [dlqDict setObject:[[MFSingleton sharedInstance] appType] forKey:@"APP_TYPE"];
    [dlqDict setObject:@"i" forKey:@"DVC_OS"];
    [dlqDict setObject:[[MFSingleton sharedInstance] dvcType] forKey:@"DVC_TYPE"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] forKey:@"PUSH_ID"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]forKey:@"DVC_ID"];
    [dlqDict setObject:mfpsId forKey:@"QUEUE_NAME"];
    [dlqDict setObject:pJson forKey:@"POST_NOTI_OPTION"];
    [dlqDict setObject:cJson forKey:@"COMMENT_NOTI_OPTION"];
    
    NSString* dlqJson = nil;
    NSData* dlqData = [NSJSONSerialization dataWithJSONObject:dlqDict options:kNilOptions error:nil];
    dlqJson = [[NSString alloc] initWithData:dlqData encoding:NSUTF8StringEncoding];
    dlqJson = [dlqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *dlqDict2 = [NSMutableDictionary dictionary];
    [dlqDict2 setObject:dlqDict forKey:@"properties"];
    [dlqDict2 setObject:@"UPDATE_USER_INFO" forKey:@"routing_key"];
    [dlqDict2 setObject:dlqJson forKey:@"payload"];
    [dlqDict2 setObject:@"string" forKey:@"payload_encoding"];
    NSString* dlqJson2 = nil;
    NSData* dlqData2 = [NSJSONSerialization dataWithJSONObject:dlqDict2 options:kNilOptions error:nil];
    dlqJson2 = [[NSString alloc] initWithData:dlqData2 encoding:NSUTF8StringEncoding];

    MFURLSession *dlqSession = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:dlqUrl] option:dlqJson2];
    [dlqSession start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}

//-(void)rightSideMenuButtonPressed:(id)sender{
//    NSString *sqlString1 = [appDelegate.dbHelper updatePostNoti:postNoti snsNo:self.snsNo];
//    [appDelegate.dbHelper crudStatement:sqlString1];
//
//    NSString *sqlString2 = [appDelegate.dbHelper updateCommentNoti:commNoti snsNo:self.snsNo];
//    [appDelegate.dbHelper crudStatement:sqlString2];
//
//    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"저장되었습니다.", @"저장되었습니다.") preferredStyle:UIAlertControllerStyleAlert];
//    [self presentViewController:alert animated:YES completion:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [alert dismissViewControllerAnimated:YES completion:nil];
//    });
//}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0){
        return NSLocalizedString(@"board_info_noti_setting_post", @"board_info_noti_setting_post");
    } else if(section==1){
        return NSLocalizedString(@"board_info_noti_setting_comment", @"board_info_noti_setting_comment");
    } else {
        return nil;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return self.notiPostArr.count;
    } else if(section==1){
        return self.notiCommArr.count;
    } else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoticeSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoticeSetTableViewCell"];
    
    if(cell == nil){
        cell = [[NoticeSetTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NoticeSetTableViewCell"];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section==0){
        int sectionTag=POST_SWITCH_TAG;
        cell.keyLabel.text = [self.notiPostArr objectAtIndex:indexPath.row];
        
        cell.noticeSwitch.tag = sectionTag+indexPath.row;
        [cell.noticeSwitch setOnTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
        
        if(indexPath.row==0){
            if([postNoti isEqualToString:@"1"]){
                [cell.noticeSwitch setOn:YES animated:NO];
            } else {
                [cell.noticeSwitch setOn:NO animated:NO];
            }
        }
        
    } else if(indexPath.section==1){
        int sectionTag=COMM_SWITCH_TAG;
        cell.keyLabel.text = [self.notiCommArr objectAtIndex:indexPath.row];
        
        cell.noticeSwitch.tag = sectionTag+indexPath.row;
        [cell.noticeSwitch setOnTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
        
        if(indexPath.row==0){
            if([commNoti isEqualToString:@"1"]){
                [cell.noticeSwitch setOn:YES animated:NO];
            } else {
                [cell.noticeSwitch setOn:NO animated:NO];
            }
        }
    }
    
    [cell.noticeSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell.keyLabel sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if(![mySwitch isOn]){
        if(mySwitch.tag==POST_SWITCH_TAG){
            postNoti=@"0";
        } else if(mySwitch.tag==COMM_SWITCH_TAG){
            commNoti=@"0";
        }
    } else {
        if(mySwitch.tag==POST_SWITCH_TAG){
            postNoti=@"1";
        } else if(mySwitch.tag==COMM_SWITCH_TAG){
            commNoti=@"1";
        }
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSDictionary *dic = session.returnDictionary;
        if ([[dic objectForKey:@"RESULT"]isEqualToString:@"SUCCESS"]) {
            
        }
    } else {
        
    }
}

@end
