//
//  SNSInfoViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "SNSInfoViewController.h"
#import "SNSInfoTableViewCell.h"
#import "SNSNoticeSetViewController.h"

#import "BoardCreateViewController.h"
#import "MemberManageViewController.h"

#define HEADER_HEIGHT 45

@interface SNSInfoViewController () {
    NSArray *infoKeyArr1;
    NSArray *infoValArr1;
    
    NSArray *infoKeyArr2;
    NSArray *infoValArr2;
    
    NSArray *infoKeyArr3;
    NSArray *infoValArr3;
    
    NSString *myUserNo;
    NSString *snsLeader;
    NSString *snsNo;
    
    AppDelegate *appDelegate;
    NSString *mode;
    
    int currSnsKind;
}

@end

@implementation SNSInfoViewController

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    currSnsKind = 0;
    
    self.tableView.rowHeight = 50;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    [self setTableData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setTableData{
    @try{
        snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
        NSString *snsName = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_NM"]];
        NSString *snsType = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_TY"]];
        NSString *snsKind = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_KIND"]];
        snsLeader = [self.snsInfoDic objectForKey:@"CREATE_USER_NO"];
        NSString *snsLeaderNm = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"CREATE_USER_NM"]];
        NSString *snsMember = [NSString stringWithFormat:@"%@",[self.snsInfoDic objectForKey:@"USER_COUNT"]];
        NSString *needAllow = [NSString stringWithFormat:@"%@",[self.snsInfoDic objectForKey:@"NEED_ALLOW"]];
        NSString *snsDesc = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_DESC"]];
        NSString *createDate = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"CREATE_DATE"]];
        //NSString *itemType = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"ITEM_TYPE"]];
        //NSString *waitingCnt = [NSString stringWithFormat:@"%@",[self.snsInfoDic objectForKey:@"WAITING_USER_COUNT"]];
        
        currSnsKind = [snsKind intValue];
        
        NSString *resultKind;
        NSString *resultType;
        NSString *resultAllow;
        
        if([snsKind isEqualToString:@"Normal"] || [snsKind isEqualToString:@"1"]) resultKind = @"일반형";
        else if([snsKind isEqualToString:@"Project"] || [snsKind isEqualToString:@"2"]) resultKind = @"프로젝트형";
        
        if([snsType isEqualToString:@"Public"] || [snsType isEqualToString:@"3"] ) resultType = @"공개";
        else if([snsType isEqualToString:@"Closed"] || [snsType isEqualToString:@"2"] ) resultType = @"이름 공개";
        else if([snsType isEqualToString:@"Secret"] || [snsType isEqualToString:@"1"] ) resultType = @"비공개";
        
        if([needAllow isEqualToString:@"0"]) resultAllow = @"비승인";
        else if([needAllow isEqualToString:@"1"]) resultAllow = @"승인";
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.sss"];
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        } else {
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.sss"];
        }
        
        NSDate *nsDate = [dateFormat dateFromString:createDate];
        
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
        
        NSString *titleStr = [NSString stringWithFormat:@"%@ 정보", snsName];
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:titleStr];
        
        infoKeyArr1 = @[NSLocalizedString(@"board_info_name", @"board_info_name"),NSLocalizedString(@"board_info_create_user_name", @"board_info_create_user_name"),NSLocalizedString(@"board_info_kind", @"board_info_kind"),NSLocalizedString(@"board_info_member_count", @"board_info_member_count"),NSLocalizedString(@"board_info_visible_type", @"board_info_visible_type"),NSLocalizedString(@"board_info_need_allow", @"board_info_need_allow"),NSLocalizedString(@"board_info_desc", @"board_info_desc"),NSLocalizedString(@"board_info_create_date", @"board_info_create_date")];
        infoValArr1 = @[snsName, snsLeaderNm, resultKind, snsMember, resultType, resultAllow, snsDesc, dateStr];
        
        infoKeyArr2 = @[NSLocalizedString(@"board_info_setting1", @"board_info_setting1"), NSLocalizedString(@"board_info_force_delete_users", @"board_info_force_delete_users"), NSLocalizedString(@"board_info_waiting_users", @"board_info_waiting_users")];
        infoValArr2 = @[];
        
        infoKeyArr3 = @[NSLocalizedString(@"board_info_noti_setting", @"board_info_noti_setting")];
        infoValArr3 = @[];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
        NSString *snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
        
        if([serviceName isEqualToString:@"withdrawSNS"]){
            //isJoin("true":탈퇴 or "false":가입신청취소)
            NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&snsNo=%@&mfpsId=%@&isJoin=true&dvcId=%@", myUserNo, compNo, snsNo, mfpsId, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            
        } else if([serviceName isEqualToString:@"deleteSNS"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&snsNo=%@&dvcId=%@", myUserNo, compNo, snsNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        [session start];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    } else {
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if([wsName isEqualToString:@"withdrawSNS"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"board_info_create_secession4", @"board_info_create_secession4") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
                                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_CloseSNS" object:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else if([wsName isEqualToString:@"deleteSNS"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"board_info_create_secession3", @"board_info_create_secession3") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];

                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
                                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_CloseSNS" object:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [alert dismissViewControllerAnimated:YES completion:nil];
//
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_CloseSNS" object:nil];
//                });
            }
        }
    }
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        return 4;
    } else {
        if(![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo1]] && ![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo2]]){
            return 3;
        } else {
            return 2;
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        if(section == 3) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor whiteColor];
            label.text = NSLocalizedString(@"delete_board", @"delete_board");
            label.textColor = [UIColor redColor];
            
            UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteBoard:)];
            [label setUserInteractionEnabled:YES];
            [label addGestureRecognizer:deleteTap];
            
            return label;
        }
        
    } else {
        if(![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo1]] && ![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo2]]){
            if(section == 2) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:15];
                label.backgroundColor = [UIColor whiteColor];
                label.text = NSLocalizedString(@"board_info_create_secession", @"board_info_create_secession");
                label.textColor = [UIColor redColor];
                
                UITapGestureRecognizer *leaveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeaveBoard:)];
                [label setUserInteractionEnabled:YES];
                [label addGestureRecognizer:leaveTap];
                
                return label;
            }
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        if(section == 0) {
            return NSLocalizedString(@"board_info_title", @"board_info_title");
        } else if(section == 1) {
            return NSLocalizedString(@"board_info_setting", @"board_info_setting");
        } else if(section == 2) {
            return NSLocalizedString(@"board_info_noti_setting", @"board_info_noti_setting");
        }
    } else {
        if(section == 0) {
            return NSLocalizedString(@"board_info_title", @"board_info_title");
        } else if(section == 1) {
            return NSLocalizedString(@"board_info_noti_setting", @"board_info_noti_setting");
        }
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        if(section == 0){
            return infoKeyArr1.count;
            
        } else if (section == 1){
            return infoKeyArr2.count;
            
        } else if (section == 2){
            return infoKeyArr3.count;
        }
        
    } else {
        if(section == 0){
            return infoKeyArr1.count;
            
        } else if (section == 1){
            return infoKeyArr3.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNSInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SNSInfoTableViewCell"];
    
    if(cell == nil){
        cell = [[SNSInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SNSInfoTableViewCell"];
    }
    
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        if(indexPath.section == 0){
            cell.cntLabel.hidden = YES;
            cell.keyLabel.text = [infoKeyArr1 objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(indexPath.row==0) cell.valueLabel.text = [NSString stringWithFormat:@"%@(%@)",[infoValArr1 objectAtIndex:indexPath.row], snsNo];
            else cell.valueLabel.text = [infoValArr1 objectAtIndex:indexPath.row];
            
        } else if(indexPath.section == 1){
            cell.cntLabel.hidden = YES;
            cell.keyLabel.text = [infoKeyArr2 objectAtIndex:indexPath.row];
            cell.valueLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            if(indexPath.row == 2){
                NSString *waitingCnt = [NSString stringWithFormat:@"%@",[self.snsInfoDic objectForKey:@"WAITING_USER_COUNT"]];
                if([waitingCnt intValue]>0){
                    cell.cntLabel.hidden = NO;
                    cell.cntLabel.text = waitingCnt;
                    cell.cntLabel.textAlignment = NSTextAlignmentRight;
                    cell.cntLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                }
            }
            
        } else if(indexPath.section == 2){
            cell.cntLabel.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.keyLabel.text = [infoKeyArr3 objectAtIndex:indexPath.row];
            cell.valueLabel.text = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
        } else if(indexPath.section == 3){
            cell.cntLabel.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.keyLabel.text = nil;
            cell.valueLabel.text = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    } else {
        cell.cntLabel.hidden = YES;
        if(![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo1]] && ![[NSString stringWithFormat:@"%@", snsLeader] isEqualToString:[[MFSingleton sharedInstance] adminNo2]]){
            if(indexPath.section == 0){
                cell.keyLabel.text = [infoKeyArr1 objectAtIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if(indexPath.row==0) cell.valueLabel.text = [NSString stringWithFormat:@"%@(%@)",[infoValArr1 objectAtIndex:indexPath.row], snsNo];
                else cell.valueLabel.text = [infoValArr1 objectAtIndex:indexPath.row];
                
            } else if(indexPath.section == 1){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.keyLabel.text = [infoKeyArr3 objectAtIndex:indexPath.row];
                cell.valueLabel.text = nil;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
            } else if(indexPath.section == 2){
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.keyLabel.text = nil;
                cell.valueLabel.text = nil;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
            }
        } else {
            if(indexPath.section == 0){
                cell.keyLabel.text = [infoKeyArr1 objectAtIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if(indexPath.row==0) cell.valueLabel.text = [NSString stringWithFormat:@"%@(%@)",[infoValArr1 objectAtIndex:indexPath.row], snsNo];
                else cell.valueLabel.text = [infoValArr1 objectAtIndex:indexPath.row];
                
            } else if(indexPath.section == 1){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.keyLabel.text = [infoKeyArr3 objectAtIndex:indexPath.row];
                cell.valueLabel.text = nil;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
            }
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell.keyLabel sizeToFit];
    
    cell.valueLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", snsLeader]]){
        if(indexPath.section==1){
            mode = nil;
            
            if(indexPath.row==0){
                [self performSegueWithIdentifier:@"BOARD_MODIFY_PUSH" sender:nil];
                
            } else if(indexPath.row==1){
                //멤버 관리 (강제탈퇴)
                mode = @"MEMBER_WITHDRAW";
                [self performSegueWithIdentifier:@"BOARD_MEMBER_WITHDRAW_PUSH" sender:nil];
                
            } else if(indexPath.row==2){
                //가입신청 목록
                mode = @"MEMBER_REQUEST";
                [self performSegueWithIdentifier:@"BOARD_MEMBER_WITHDRAW_PUSH" sender:nil];
                
            } else {}
            
        } else if(indexPath.section==2){
            [self performSegueWithIdentifier:@"BOARD_SET_ALARM_PUSH" sender:indexPath];
        }
        
    } else {
        if(indexPath.section==1){
            [self performSegueWithIdentifier:@"BOARD_SET_ALARM_PUSH" sender:indexPath];
        }
    }
}

- (void)tapLeaveBoard:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"board_info_create_secession1", @"board_info_create_secession1") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self callWebService:@"withdrawSNS"];
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tapDeleteBoard:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"board_info_create_secession2", @"board_info_create_secession2") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self callWebService:@"deleteSNS"];
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)noti_ModifyBoard:(NSNotification *)notification{
    NSLog(@"userInfo : %@", notification.userInfo);
    
    self.snsInfoDic = notification.userInfo;
    [self setTableData];
    [self.tableView reloadData];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_ModifyBoard" object:nil];
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"BOARD_MODIFY_PUSH"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ModifyBoard:) name:@"noti_ModifyBoard" object:nil];
  
        BoardCreateViewController *destination = segue.destinationViewController;
        destination.fromSegue = segue.identifier;
        destination.snsInfoDic = self.snsInfoDic;
        destination.currSnsKind = currSnsKind;
        
        self.navigationController.navigationBar.topItem.title = @"";
        
    } else if([segue.identifier isEqualToString:@"BOARD_SET_ALARM_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
        
        SNSNoticeSetViewController *destination = segue.destinationViewController;
        destination.snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
        destination.snsName = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_NM"]];
        
    } else if([segue.identifier isEqualToString:@"BOARD_MEMBER_WITHDRAW_PUSH"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ModifyBoard:) name:@"noti_ModifyBoard" object:nil];
        MemberManageViewController *destination = segue.destinationViewController;
        destination.snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
        destination.snsName = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_NM"]];
        destination.snsKind = [self.snsInfoDic objectForKey:@"SNS_KIND"];
        destination.snsInfoDic = self.snsInfoDic;
        destination.fromSegue = mode;
        self.navigationController.navigationBar.topItem.title = @"";
    }
}
@end
