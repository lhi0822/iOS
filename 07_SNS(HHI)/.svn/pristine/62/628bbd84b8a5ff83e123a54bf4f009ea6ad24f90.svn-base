//
//  MemberManageViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 15..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "MemberManageViewController.h"
#import "ChatUserListCell.h"
#import "MFUtil.h"
#import "MFDBHelper.h"

#define REFRESH_HEADER_DEFAULT_HEIGHT   64.f

@interface MemberManageViewController () {
    NSInteger count;
    NSMutableArray *userArr;
    AppDelegate *appDelegate;
    
    NSString *rejectMsg;
    NSString *rejectJsonStr;
    
    BOOL isLoad;
    BOOL isRefresh;
    BOOL isScroll;
    
    int pSize;
    NSString *stSeq;
    
    NSMutableArray *existUserArr;
}

@property (nonatomic, strong) NSMutableArray *dataSetArray;
@property (nonatomic, strong) NSMutableArray *checkArray;

@property (nonatomic, strong)NSMutableDictionary *rowCheckDictionary;

@end


@implementation MemberManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.checkArray = [NSMutableArray array];
    self.dataSetArray = [NSMutableArray array];
    existUserArr = [NSMutableArray array];
    
    count = 0;
    
    stSeq = @"1";
    isLoad = YES;
    isRefresh = NO;
    isScroll = NO;
    pSize = 30;
    
    if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_info_force_delete_users", @"board_info_force_delete_users")];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"force_secession", @"force_secession")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(rightSideMenuButtonPressed:)];
        
        self.segViewConstraint.constant = 0;
        self.approveSeg.hidden = YES;
        
        [self callWebService:@"getSNSMemberList"];
        
    } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"join_sns_toast11", @"join_sns_toast11")];
        
        self.approveSeg.tintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        
        [self.approveSeg setFrame:CGRectMake(5, 3, self.view.frame.size.width-10, 40)];
        [self.approveSeg addTarget:self action:@selector(segmentedChange:) forControlEvents:UIControlEventValueChanged];
        
        [self.approveSeg setTitle:NSLocalizedString(@"reject_btn_title", @"reject_btn_title") forSegmentAtIndex:0];
        [self.approveSeg setTitle:NSLocalizedString(@"approve_btn_title", @"approve_btn_title") forSegmentAtIndex:1];
        
        self.segViewConstraint.constant = 0;
        self.approveSeg.hidden = YES;
        
        [self callWebService:@"getSNSWaitingMemberList"];
    
    } else if([self.fromSegue isEqualToString:@"TASK_MANAGER"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"수행자 선택", @"수행자 선택")];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete", @"complete")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(rightSideMenuButtonPressed:)];
        
        self.segViewConstraint.constant = 0;
        self.approveSeg.hidden = YES;
        
        [self callWebService:@"getSNSMemberList"];
    
    } else if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"참조자 선택", @"수행자 선택")];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete", @"complete")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(rightSideMenuButtonPressed:)];
        
        self.segViewConstraint.constant = 0;
        self.approveSeg.hidden = YES;
        
        [self callWebService:@"getSNSMemberList"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segmentedChange: (UISegmentedControl *)sender{
    NSInteger checkCnt = self.checkArray.count;
    if(checkCnt>0){
        if(sender.selectedSegmentIndex == 0) {
            rejectMsg = @"";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reject_title", @"reject_title") message:NSLocalizedString(@"reject_msg", @"reject_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            UIAlertAction *rejectBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"reject_btn_title", @"reject_btn_title") style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           rejectMsg = [alert.textFields objectAtIndex:0].text;
                                                           [self resultReqUserAction:@"REJECT"];
                                                       }];
            [alert addAction:cancelBtn];
            [alert addAction:rejectBtn];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"reject_reason_msg", @"reject_reason_msg");
                textField.delegate = self;
            }];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            
        } else if(sender.selectedSegmentIndex == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"approve_title", @"approve_title") message:NSLocalizedString(@"approve_msg", @"approve_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            UIAlertAction *approveBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"approve_btn_title", @"approve_btn_title") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self resultReqUserAction:@"APPROVE"];
                                                           }];
            [alert addAction:cancelBtn];
            [alert addAction:approveBtn];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"check_user_null", @"check_user_null") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
        //거절 사유 100자 제한
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 100) ? NO : YES;
    }
    return YES;
}

-(void)resultReqUserAction:(NSString *)result{
    NSInteger checkCnt = self.checkArray.count;
    
    @try{
        if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
            userArr = [NSMutableArray array];
            for(int i=0; i<checkCnt; i++){
                if(![[self.checkArray objectAtIndex:i] isEqualToString:@"1"]) {
                    NSNumber *userNo = [NSNumber numberWithInteger:[[self.checkArray objectAtIndex:i] intValue]];
                    [userArr addObject:userNo];
                }
            }
            NSLog(@"체크된 사용자들 userArr : %@", userArr);
            if([result isEqualToString:@"REJECT"]){
                NSData *rejectData = [NSJSONSerialization dataWithJSONObject:userArr options:0 error:nil];
                rejectJsonStr = [[NSString alloc] initWithData:rejectData encoding:NSUTF8StringEncoding];
                [self callWebService:@"rejectSNSMember"];
                
            } else if([result isEqualToString:@"APPROVE"]){
                [self callWebService:@"editSNSMember"];
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)rightSideMenuButtonPressed:(id)sender{
    NSInteger checkCnt = self.checkArray.count;
    
    @try{
        if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
           if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                NSDictionary *dic = [NSDictionary dictionary];
                dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TASK_REFERENCE", @"TYPE", self.checkArray, @"CHECK_USER_LIST", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeTaskUser" object:nil userInfo:dic];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            if(checkCnt>0){
                if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                    userArr = [NSMutableArray array];
                    for(int i=0; i<checkCnt; i++){
                        if(![[self.checkArray objectAtIndex:i] isEqualToString:@"1"]) {
                            NSNumber *userNo = [NSNumber numberWithInteger:[[self.checkArray objectAtIndex:i]intValue]];
                            [userArr addObject:userNo];
                        }
                    }
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"force_delete", @"force_delete") message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [self callWebService:@"editSNSMember"];
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    
                    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                    [alert addAction:okButton];
                    [alert addAction:cancelButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                    userArr = [NSMutableArray array];
                    for(int i=0; i<checkCnt; i++){
                        if(![[self.checkArray objectAtIndex:i] isEqualToString:@"1"]) {
                            NSNumber *userNo = [NSNumber numberWithInteger:[[self.checkArray objectAtIndex:i] intValue]];
                            [userArr addObject:userNo];
                        }
                    }
                    [self callWebService:@"editSNSMember"];
                    
                } else if([self.fromSegue isEqualToString:@"TASK_MANAGER"]){
                    NSDictionary *dic = [NSDictionary dictionary];
                    dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TASK_MANAGER", @"TYPE", self.checkArray, @"CHECK_USER_LIST", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeTaskUser" object:nil userInfo:dic];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"check_user_null", @"check_user_null") message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)callWebService:(NSString *)serviceName{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];//appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    NSString *paramString;
    
    @try{
        if([serviceName isEqualToString:@"getSNSMemberList"]){
            paramString = [NSString stringWithFormat:@"snsNo=%@&usrNo=%@&currentUserNos=&pSize=%d&stSeq=%@&dvcId=%@", self.snsNo, myUserNo, pSize, stSeq, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            
        } else if([serviceName isEqualToString:@"editSNSMember"]){
            NSData* data = [NSJSONSerialization dataWithJSONObject:userArr options:NSJSONWritingPrettyPrinted error:nil];
            NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //("APPROVE":가입승인 or "FORCE_DELETE":강제탈퇴)
            NSString *mode = @"";
            if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                mode = @"FORCE_DELETE";
            } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                mode = @"APPROVE";
            }
            NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
            
            paramString = [NSString stringWithFormat:@"mode=%@&compNo=%@&snsNo=%@&snsNm=%@&users=%@&usrNo=%@&snsKind=%@&dvcId=%@",mode, compNo, self.snsNo, self.snsName, jsonData, myUserNo, self.snsKind, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            
        } else if([serviceName isEqualToString:@"getSNSWaitingMemberList"]){
            paramString = [NSString stringWithFormat:@"snsNo=%@&pSize=%d&stSeq=%@&dvcId=%@", self.snsNo, pSize, stSeq, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            
        } else if([serviceName isEqualToString:@"getSNSInfo"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&snsKind=%@&dvcId=%@", myUserNo, self.snsNo, self.snsKind, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        
        } else if([serviceName isEqualToString:@"rejectSNSMember"]){
            if(rejectJsonStr==nil||[rejectJsonStr isEqualToString:@""]){
                paramString = [NSString stringWithFormat:@"snsKind=%@&snsNo=%@&users=%@&usrNo=%@&dvcId=%@", self.snsKind, self.snsNo, rejectJsonStr, myUserNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            } else {
                paramString = [NSString stringWithFormat:@"snsKind=%@&snsNo=%@&users=%@&usrNo=%@&rejectMessage=%@&dvcId=%@", self.snsKind, self.snsNo, rejectJsonStr, myUserNo, rejectMsg, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            }
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if([session start]){
            self.tableView.scrollEnabled = NO;
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    self.tableView.scrollEnabled = YES;
    [SVProgressHUD dismiss];
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    }else{
        NSDictionary *dic = session.returnDictionary;
        
        if([wsName isEqualToString:@"getSNSMemberList"]){
            @try{
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
                count = dataSet.count;
                
                if(count==0||count<pSize) isLoad = NO;
                else isLoad = YES;
                
                NSMutableArray *dataArr = [NSMutableArray array];
                self.rowCheckDictionary = [NSMutableDictionary dictionary];
                
                NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                if([self.fromSegue isEqualToString:@"TASK_MANAGER"] || [self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                    for(int i=0; i<count; i++){
                        NSString *userNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                        [dataArr addObject:[dataSet objectAtIndex:i]];
                        [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"%@", userNo]];
                    }
                    
                    if(self.userListArr.count>0){
                        for(int i=0; i<self.userListArr.count; i++){
                            //NSString *userNo = [[self.userListArr objectAtIndex:i] objectForKey:@"CUSER_NO"];
                            NSString *userNo = [self.userListArr objectAtIndex:i];
                            [self.rowCheckDictionary setObject:@"Y" forKey:[NSString stringWithFormat:@"%@", userNo]];
                        }
                        [self.checkArray addObjectsFromArray:self.userListArr];
                    }
                    
                } else {
                    NSDictionary *upNodeDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"CUSER_NO", NSLocalizedString(@"select_all", @"select_all"),@"USER_NM", nil];
                    [dataArr addObject:upNodeDic];
                    [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"1"]];
                    
                    for(int i=0; i<count; i++){
                        NSString *snsUserType = [[dataSet objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                        if(![[NSString stringWithFormat:@"%@", snsUserType] isEqualToString:@"1"]){
                            NSString *userNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                            
                            if(![existUserArr containsObject:userNo]){
                                [existUserArr addObject:userNo];
                                
                                [indexPaths addObject:[NSIndexPath indexPathForRow:[stSeq integerValue]+i-1 inSection:0]];
                                
                                if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                                    [dataArr addObject:[dataSet objectAtIndex:i]];
                                    [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"%@", userNo]];
                                }
                            }
                        }
                    }
                }
                
//                self.dataSetArray = [[NSMutableArray alloc] init];
//                [self.dataSetArray addObjectsFromArray:dataArr];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //지워야 될 수도 있음, 다시 테스트 해보기
//                    [self.tableView reloadData];
//                });
                
                if([[NSString stringWithFormat:@"%@", stSeq] isEqualToString:@"1"]){
                    self.dataSetArray = [NSMutableArray arrayWithArray:dataArr];
                    
                    if(isRefresh){
                        isRefresh = NO;
                    }
                    [self.tableView reloadData];
                    
                } else {
                    [self.dataSetArray addObjectsFromArray:dataArr];
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
                
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=self.dataSetArray.count; i++){
                    seq = [NSString stringWithFormat:@"%d", [stSeq intValue]+i];
                }
                stSeq = seq;
                
                isScroll = YES;
                
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
            }
            
        } else if([wsName isEqualToString:@"editSNSMember"]){
            @try{
                int affected = [[dic objectForKey:@"AFFECTED"] intValue];
                if(affected>0){
                    self.checkArray = [NSMutableArray array];
                    
                    if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                        stSeq = @"1";
                        [self callWebService:@"getSNSMemberList"];
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil]; //게시판목록갱신
                        
                        //게시판목록, 게시판선택, 게시판정보 갱신필요
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:self.snsInfoDic];
                        
                        
                        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"force_delete_succeed", @"force_delete_succeed"), userArr.count] preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            [self callWebService:@"getSNSInfo"];
                        });

                    } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                        stSeq = @"1";
                        [self callWebService:@"getSNSWaitingMemberList"];
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil]; //게시판목록갱신
                        
                        //게시판목록, 게시판선택, 게시판정보 갱신필요
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:self.snsInfoDic];
                        [self callWebService:@"getSNSInfo"];

                        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"approve_succeed", @"approve_succeed"), userArr.count] preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                } else {
                    
                }
                
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
            }
            
        } else if([wsName isEqualToString:@"getSNSWaitingMemberList"]){
            @try{
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
                count = dataSet.count;
                
                if(count==0||count<pSize) isLoad = NO;
                else isLoad = YES;
                
                if(count>0){
                    self.segViewConstraint.constant = 45;
                    self.approveSeg.hidden = NO;
                } else {
                    self.segViewConstraint.constant = 0;
                    self.approveSeg.hidden = YES;
                }
                
                NSMutableArray *dataArr = [NSMutableArray array];
                self.rowCheckDictionary = [NSMutableDictionary dictionary];
                
                NSDictionary *upNodeDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"CUSER_NO",NSLocalizedString(@"select_all", @"select_all"),@"USER_NM", nil];
                [dataArr addObject:upNodeDic];
                [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"1"]];
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                for(int i=0; i<count; i++){
                    NSString *userNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                    
                    if(![existUserArr containsObject:userNo]){
                        [existUserArr addObject:userNo];
                        
                        [indexPaths addObject:[NSIndexPath indexPathForRow:[stSeq integerValue]+i-1 inSection:0]];
                        
                        [dataArr addObject:[dataSet objectAtIndex:i]];
                        [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"%@", userNo]];
                    }
                }
                
//                self.dataSetArray = [[NSMutableArray alloc] init];
//                [self.dataSetArray addObjectsFromArray:dataArr];
//                [self.tableView reloadData];
                
                if([[NSString stringWithFormat:@"%@", stSeq] isEqualToString:@"1"]){
                    self.dataSetArray = [NSMutableArray arrayWithArray:dataArr];
                    
                    if(isRefresh){
                        isRefresh = NO;
                    }
                    [self.tableView reloadData];
                    
                } else {
                    [self.dataSetArray addObjectsFromArray:dataArr];
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
                
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=self.dataSetArray.count; i++){
                    seq = [NSString stringWithFormat:@"%d", [stSeq intValue]+i];
                }
                stSeq = seq;
                
                isScroll = YES;
                
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
            }
        
        } else if([wsName isEqualToString:@"getSNSInfo"]){
            NSArray *dataSet = [dic objectForKey:@"DATASET"];
            
            self.snsInfoDic = [dataSet objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:self.snsInfoDic];
        
        } else if([wsName isEqualToString:@"rejectSNSMember"]){
            @try{
                int affected = [[dic objectForKey:@"AFFECTED"] intValue];
                if(affected>0){
                    [self callWebService:@"getSNSWaitingMemberList"];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil]; //게시판목록갱신
                    
                    //게시판목록, 게시판선택, 게시판정보 갱신필요
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:self.snsInfoDic];
                    [self callWebService:@"getSNSInfo"];
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"reject_succeed", @"reject_succeed"), userArr.count] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    });
                }
            
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    self.tableView.scrollEnabled = YES;
    NSLog(@"error : %@", error);
    
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
}


#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @try{
        if(self.dataSetArray.count>1){
            return self.dataSetArray.count;
        } else {
            return 0;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        ChatUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if(self.dataSetArray.count>1){
            [cell.checkButton setFrame:CGRectMake(cell.checkButton.frame.origin.x, cell.frame.size.height-(cell.frame.size.height/2)-(30/2), cell.checkButton.frame.size.width, 30)];
            
            cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
            
            cell.checkButton.clipsToBounds = YES;
            [cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if(![self.fromSegue isEqualToString:@"TASK_MANAGER"] && ![self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                if(indexPath.row==0){//(indexPath.section==0){
                    cell.userImgView.hidden = YES;
                    [cell.nodeNameLabel setFrame:CGRectMake(20, cell.nodeNameLabel.frame.origin.y, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
                    cell.checkButton.tag = [[NSString stringWithFormat:@"1"] integerValue];
                    
                    if ([[self.rowCheckDictionary objectForKey:[NSString stringWithFormat:@"1"]] isEqualToString:@"Y"]) {
                        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                    }else{
                        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_false.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                    }
                    
                    NSDictionary *dataDict = [self.dataSetArray objectAtIndex:indexPath.row];
                    NSString *userName = [NSString urlDecodeString:[dataDict objectForKey:@"USER_NM"]];
                    cell.nodeNameLabel.text = userName;
                    
                } else {
                    cell.userImgView.image = nil;
                    cell.userImgView.hidden = NO;
                    
                    NSDictionary *dataDict = [self.dataSetArray objectAtIndex:indexPath.row];
                    //NSString *userId = [NSString urlDecodeString:[dataDict objectForKey:@"CUSER_ID"]];
                    NSString *userNo = [dataDict objectForKey:@"CUSER_NO"];
                    NSString *userName = [NSString urlDecodeString:[dataDict objectForKey:@"USER_NM"]];
                    NSString *profileImg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_IMG"]];
                    //NSString *profileMsg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_MSG"]];
                    
                    NSString *levelName = [NSString urlDecodeString:[dataDict objectForKey:@"LEVEL_NM"]];
                    //NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"CORP_NM"]];
                    NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"DEPT_NM"]];
                    NSString *exCompName = [NSString urlDecodeString:[dataDict objectForKey:@"EX_COMPANY_NM"]];
                    
                    if ([[self.rowCheckDictionary objectForKey:[NSString stringWithFormat:@"%@",userNo]] isEqualToString:@"Y"]) {
                        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                    }else{
                        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_false.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                    }
                    
                    [cell.userImgView setFrame:CGRectMake(20, (cell.frame.size.height/2) - (45/2), 45, 45)];
                    [cell.nodeNameLabel setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width+10, cell.nodeNameLabel.frame.origin.y, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
                    
                    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
                    cell.userImgView.clipsToBounds = YES;
                    cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                    cell.userImgView.layer.borderWidth = 0.3;
                    
                    cell.checkButton.tag = [userNo integerValue];
                    
                    cell.leaderBtn.hidden = YES;
                    
                    if(![profileImg isEqualToString:@""]){
                        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
                        cell.userImgView.image = userImg;
                    } else {
                        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
                        cell.userImgView.image = userImg;
                    }
                    
                    NSString *userStr;
                    NSString *levelStr = @"";
                    NSString *deptStr = @"";
                    if(levelName!=nil&&![levelName isEqualToString:@""]) levelStr = [NSString stringWithFormat:@"%@/", levelName];
                    if(deptName!=nil&&![deptName isEqualToString:@""]) deptStr = [NSString stringWithFormat:@"%@/", deptName];
                    
                    if(levelName.length<1&&deptName.length<1&&exCompName.length<1) userStr = [NSString stringWithFormat:@"%@", userName];
                    else userStr = [NSString stringWithFormat:@"%@/%@%@%@", userName, levelStr, deptStr, exCompName];
                    
                    cell.nodeNameLabel.text = userStr;
                }
            } else {
                cell.userImgView.image = nil;
                cell.userImgView.hidden = NO;
                
                NSDictionary *dataDict = [self.dataSetArray objectAtIndex:indexPath.row];
                //NSString *userId = [NSString urlDecodeString:[dataDict objectForKey:@"CUSER_ID"]];
                NSString *userNo = [dataDict objectForKey:@"CUSER_NO"];
                NSString *userName = [NSString urlDecodeString:[dataDict objectForKey:@"USER_NM"]];
                NSString *profileImg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_IMG"]];
                //NSString *profileMsg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_MSG"]];
                
                NSString *levelName = [NSString urlDecodeString:[dataDict objectForKey:@"LEVEL_NM"]];
                //NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"CORP_NM"]];
                NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"DEPT_NM"]];
                NSString *exCompName = [NSString urlDecodeString:[dataDict objectForKey:@"EX_COMPANY_NM"]];
                
                if ([[self.rowCheckDictionary objectForKey:[NSString stringWithFormat:@"%@",userNo]] isEqualToString:@"Y"]) {
                    [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                }else{
                    [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_false.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
                }
                
                [cell.userImgView setFrame:CGRectMake(20, (cell.frame.size.height/2) - (45/2), 45, 45)];
                [cell.nodeNameLabel setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width+10, cell.nodeNameLabel.frame.origin.y, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
                
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
                cell.userImgView.clipsToBounds = YES;
                cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                cell.userImgView.layer.borderWidth = 0.3;
                
                cell.checkButton.tag = [userNo integerValue];
                
                cell.leaderBtn.hidden = YES;
                
                if(![profileImg isEqualToString:@""]){
                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
                    cell.userImgView.image = userImg;
                } else {
                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
                    cell.userImgView.image = userImg;
                }
                
                NSString *userStr;
                NSString *levelStr = @"";
                NSString *deptStr = @"";
                if(levelName!=nil&&![levelName isEqualToString:@""]) levelStr = [NSString stringWithFormat:@"%@/", levelName];
                if(deptName!=nil&&![deptName isEqualToString:@""]) deptStr = [NSString stringWithFormat:@"%@/", deptName];
                
                if(levelName.length<1&&deptName.length<1&&exCompName.length<1) userStr = [NSString stringWithFormat:@"%@", userName];
                else userStr = [NSString stringWithFormat:@"%@/%@%@%@", userName, levelStr, deptStr, exCompName];
                
                cell.nodeNameLabel.text = userStr;
            }
            return cell;
            
        } else {
            return cell;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)checkAction:(UIButton *)sender{
    @try{
        UIButton *button = sender;
        NSString *buttonTag = [NSString stringWithFormat:@"%ld", (long)button.tag];
        
        BOOL isAlready = NO;
        for (int i=0; i<self.checkArray.count; i++) {
            if([self.fromSegue isEqualToString:@"TASK_MANAGER"] || [self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
//                NSString *userNo = [[self.checkArray objectAtIndex:i] objectForKey:@"CUSER_NO"];
//                if ([[NSString stringWithFormat:@"%@", userNo] isEqualToString:buttonTag]) {
//                    [self.checkArray removeObjectAtIndex:i];
//                    isAlready = YES;
//                }
                if ([[NSString stringWithFormat:@"%@",[self.checkArray objectAtIndex:i]] isEqualToString:buttonTag]) {
                    //[self.checkArray removeObject:buttonTag];
                    [self.checkArray removeObjectAtIndex:i];
                    isAlready = YES;
                }
            } else {
                if ([[self.checkArray objectAtIndex:i] isEqualToString:buttonTag]) {
                    [self.checkArray removeObject:buttonTag];
                    isAlready = YES;
                }
            }
            
        }
        
        if (!isAlready) {
            if([buttonTag isEqualToString:@"1"]){
                NSArray *uArr = [self.rowCheckDictionary allKeys];
                for(int i=0; i<uArr.count; i++){
                    [self.rowCheckDictionary setObject:@"Y" forKey:uArr[i]];
                    [self.checkArray addObject:uArr[i]];
                }
            } else {
                [self.rowCheckDictionary setObject:@"Y" forKey:buttonTag];
                //[self.checkArray addObject:buttonTag];
                
                if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                    [self.checkArray addObject:buttonTag];
                    if(self.checkArray.count==count-1){
                        [self.rowCheckDictionary setObject:@"Y" forKey:@"1"];
                        [self.checkArray addObject:@"1"];
                    }
                } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                    [self.checkArray addObject:buttonTag];
                    if(self.checkArray.count==count){
                        [self.rowCheckDictionary setObject:@"Y" forKey:@"1"];
                        [self.checkArray addObject:@"1"];
                    }
                } else if([self.fromSegue isEqualToString:@"TASK_MANAGER"]){
                    //[self.checkArray addObject:selectDict];
                    [self.checkArray addObject:buttonTag];
                    
                } else if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                    //[self.checkArray addObject:selectDict];
                    [self.checkArray addObject:buttonTag];
                }
            }
            
        } else{
            if([buttonTag isEqualToString:@"1"]){
                [self.checkArray removeAllObjects];
                
                NSArray *uArr = [self.rowCheckDictionary allKeys];
                for(int i=0; i<uArr.count; i++){
                    //if(![uArr[i] isEqualToString:@"1"])
                    [self.rowCheckDictionary setObject:@"N" forKey:uArr[i]];
                }
                
            } else {
                [self.rowCheckDictionary setObject:@"N" forKey:buttonTag];
                
                if([[self.rowCheckDictionary objectForKey:@"1"] isEqualToString:@"Y"]){
                    [self.rowCheckDictionary setObject:@"N" forKey:@"1"];
                    [self.checkArray removeObject:@"1"];
                }
            }
        }
        
        [self.tableView reloadData];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    @try {
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        if ([MFUtil retinaDisplayCapable]) {
            screenHeight = screenHeight*2;
            screenWidth = screenWidth*2;
        }
        
        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.view.frame.size.height) {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 10;
            if(y > h + reload_distance) {
                //데이터로드
                //[self callWebService:@"getUsers2"];
            }
        }
        
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT) {
            //NSLog(@"새로고침");
            stSeq = @"1";
            isRefresh = YES;
            existUserArr = [NSMutableArray array];
            
            if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                [self callWebService:@"getSNSMemberList"];
                
            } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                [self callWebService:@"getSNSWaitingMemberList"];
                
            } else if([self.fromSegue isEqualToString:@"TASK_MANAGER"]){
                [self callWebService:@"getSNSMemberList"];
                
            } else if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                [self callWebService:@"getSNSMemberList"];
            }
        }
    } @catch (NSException *exception) {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y>0){
        if (scrollView.contentSize.height-(self.tableView.frame.size.height/1) <= scrollView.contentOffset.y + self.tableView.frame.size.height) {
            if(isLoad && isScroll){
                isScroll = NO;
                
                if([self.fromSegue isEqualToString:@"MEMBER_WITHDRAW"]){
                    [self callWebService:@"getSNSMemberList"];
                    
                } else if([self.fromSegue isEqualToString:@"MEMBER_REQUEST"]){
                    [self callWebService:@"getSNSWaitingMemberList"];
                    
                } else if([self.fromSegue isEqualToString:@"TASK_MANAGER"]){
                    [self callWebService:@"getSNSMemberList"];
                    
                } else if([self.fromSegue isEqualToString:@"TASK_REFERENCE"]){
                    [self callWebService:@"getSNSMemberList"];
                }
            }
        }
    }
}

@end
