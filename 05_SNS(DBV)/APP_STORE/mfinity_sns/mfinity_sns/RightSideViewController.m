//
//  RightSideViewController
//  mfinity_sns
//
//  Created by hilee on 2017. 5. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "RightSideViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "ChatListViewController.h"
#import "DeptListViewController.h"
#import "UserListViewController.h"
#import "LGSideMenuController.h"
#import <QuartzCore/QuartzCore.h>
#import "RightSideViewCell.h"
#import "NewsFeedViewController.h"
#import "MFDBHelper.h"

#import "CustomHeaderViewController.h"
#import "MyMessageViewController.h"

#define HEADER_HEIGHT 40
#define PROFILE_IMG_SIZE 35

@interface RightSideViewController () {
    NSDictionary *dict;
    UIImage *userImg;
    AppDelegate *appDelegate;
    NSMutableArray *existUserArr;
    
    NSMutableArray *setTitleArr;
}

@property (strong, nonatomic) ChatMessageData *msgData;

@end

@implementation RightSideViewController
static NSString *CellIdentifier = @"Cell";

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_AddAndDelUser:) name:@"noti_AddAndDelUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_AddUserNewChatRoom:) name:@"noti_AddUserNewChatRoom" object:nil];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSLog(@"roomNo : %@", self.roomNo);
    
    self.userArr = [NSMutableArray array];
    existUserArr = [NSMutableArray array];
    
    setTitleArr = [NSMutableArray array];
    [setTitleArr addObject:NSLocalizedString(@"chat_change_room_name", @"chat_change_room_name")];
    [setTitleArr addObject:NSLocalizedString(@"chat_set_alarm", @"chat_set_alarm")];
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"roomNo : %@", self.roomNo);
    NSLog(@"ROOM NAME : %@", self.roomName);
    
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
    self.userArr = [NSMutableArray array];
    self.isSysChat = NO;
   
    [self readFromDatabase];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


#pragma mark - Notifications
- (void)noti_AddUserNewChatRoom:(NSNotification *)notification {
    NSLog();
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_MoveNewChatRoom"
                                                        object:nil
                                                      userInfo:notification.userInfo];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_AddUserNewChatRoom" object:nil];
}

- (void)noti_AddAndDelUser:(NSNotification *)notification {
    NSLog();
    [self readFromDatabase];
}

- (void)readFromDatabase {
    @try{
        existUserArr = [NSMutableArray array];
        
        NSString *sqlString = [appDelegate.dbHelper getRoomUserInfo:self.roomNo];
        NSMutableDictionary *resultDic = [appDelegate.dbHelper selectMutableDictionary:sqlString :existUserArr];
        NSLog(@"resultDict : %@", resultDic);
//        resultDict : {
//            "EXIST_USER_ARR" =     (
//                120818,
//                125515
//            );
//            "USER_ARR" =     (
//                        {
//                    "DEPT_NM" = "\Ub514\Ube44\Ubc38\Ub9ac(\Uc8fc)";
//                    "DEPT_NO" = UW093;
//                    "DUTY_NM" = "";
//                    "DUTY_NO" = "";
//                    "EX_COMPANY_NM" = "\Ud604\Ub300\Uc911\Uacf5\Uc5c5_\Ud611\Ub825\Uc0ac(BP)";
//                    "EX_COMPANY_NO" = BP;
//                    "JOB_GRP_NM" = "";
//                    "LEVEL_NM" = "";
//                    "LEVEL_NO" = "";
//                    "SNS_USER_TYPE" = 0;
//                    "USER_BG_IMG" = "";
//                    "USER_ID" = "(null)";
//                    "USER_IMG" = "https://touch1.hhi.co.kr/snsService/snsUpload/profile/10/120818/20191015-024316852.png";
//                    "USER_MSG" = "\Uc548\Ub155\Ud558\Uc138\Uc694.";
//                    "USER_NM" = "\Uc774\Ud61c\Uc778";
//                    "USER_NO" = 120818;
//                    "USER_PHONE" = "010-9391-7822";
//                },
//                        {
//                    "DEPT_NM" = "";
//                    "DEPT_NO" = "";
//                    "DUTY_NM" = "";
//                    "DUTY_NO" = "";
//                    "EX_COMPANY_NM" = "\Ud604\Ub300\Uc911\Uacf5\Uc5c5_\Ud611\Ub825\Uc0ac(BP)";
//                    "EX_COMPANY_NO" = "";
//                    "JOB_GRP_NM" = "";
//                    "LEVEL_NM" = "";
//                    "LEVEL_NO" = "";
//                    "SNS_USER_TYPE" = 1;
//                    "USER_BG_IMG" = "";
//                    "USER_ID" = "HHI_ALERT";
//                    "USER_IMG" = "";
//                    "USER_MSG" = "HHI \Uc54c\Ub78c\Ud1a1 \Uc0ac\Uc6a9\Uc790\Uc785\Ub2c8\Ub2e4.";
//                    "USER_NM" = "HHI \Uc54c\Ub9bc\Ud1a1";
//                    "USER_NO" = 125515;
//                    "USER_PHONE" = "";
//                }
//            );
//        }
        
        self.userArr = [NSMutableArray array];
        self.userArr = [resultDic objectForKey:@"USER_ARR"];
        for(int i=0; i<_userArr.count; i++){
            NSString *userType = [[_userArr objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
            if([userType isEqualToString:@"1"]){
                self.isSysChat = YES;
                break;
            }
        }
        
        existUserArr = [resultDic objectForKey:@"EXIST_USER_ARR"];
        
        [self.tableView reloadData];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableView Delegate & Datasrouce -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"chat_slidingmenu_title1", @"chat_slidingmenu_title1"), (unsigned long)self.userArr.count];
    } else if(section == 1) {
        return nil;
    } else if(section == 2){
        return NSLocalizedString(@"chat_room_setting", @"chat_room_setting");
    } else{
        return NSLocalizedString(@"popup_room_exit1", @"popup_room_exit1");
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return HEADER_HEIGHT;
    } else if (section == 1){
        return 0;
    } else if (section == 2){
        return HEADER_HEIGHT;
    } else {
        return HEADER_HEIGHT;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    } else if (section == 1){
        return 5;
    } else if (section == 2){
        return 5;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        if(self.userArr.count>0) return self.userArr.count;
        else return 1;
        
    } else if (section == 1){
        @try{
            //0:일반유저, 1:API, SYSTEM
//            NSLog(@"userArr : %@", self.userArr);
            
            if(self.userArr.count > 0){
                if(self.userArr.count==1){
                    NSString *userNo = [[self.userArr objectAtIndex:0] objectForKey:@"USER_NO"];
                    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];

                    if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]) return 0;
                    else return 1;

                } else {
                    if(self.isSysChat) return 0;
                    else return 1;
                }
                
            } else {
                return 0;
            }
            
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
        return 1;
        
    } else if (section == 2){
        return setTitleArr.count;
        
    } else {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, header.frame.size.height, header.frame.size.width, 1)];
    lineView.backgroundColor = [MFUtil myRGBfromHex:@"F1F2F3"];
    [header addSubview:lineView];
    
    if(section==0){
        header.tintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        header.textLabel.textColor = [UIColor whiteColor];
    } else {
        header.tintColor = [UIColor whiteColor];
        header.textLabel.textColor = [UIColor blackColor];
    }
    
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        RightSideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightSideViewCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[RightSideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RightSideViewCell"];
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.userImgView.image = nil;
        cell.userImgView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.notiSwitch setOnTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
        
        if(self.userArr.count > 0){
            if(indexPath.section == 0){
                NSDictionary *userDict = [self.userArr objectAtIndex:indexPath.row];
                
                NSString *userNo = [userDict objectForKey:@"USER_NO"];
                NSString *userName = [userDict objectForKey:@"USER_NM"];
                NSString *profileImg = [userDict objectForKey:@"USER_IMG"];
                NSString *profileMsg = [userDict objectForKey:@"USER_MSG"];
                NSString *deptName = [userDict objectForKey:@"DEPT_NM"];
                
                if(![profileImg isEqualToString:@""]){
                    userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
                    
                } else {
                    userImg = [UIImage imageNamed:@"profile_default.png"];
                }
                
                NSString *userStr;
                if([profileMsg isEqualToString:@""]) userStr = [NSString stringWithFormat:@"%@ (%@)", userName, deptName];
                else userStr = [NSString stringWithFormat:@"%@ (%@ , %@)", userName, deptName, profileMsg];
                
                cell.notiSwitch.hidden = YES;
                cell.userNmLabel.text = userStr;
                cell.userImgView.image = userImg;
                
                cell.userImgView.tag = indexPath.row;
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
                cell.userImgView.clipsToBounds = YES;
                cell.userImgView.backgroundColor = [UIColor clearColor];
                cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                cell.userImgView.layer.borderWidth = 0.3;
                
            } else if (indexPath.section == 1) {
                cell.notiSwitch.hidden = YES;
                cell.userImgView.image = [[UIImage imageNamed:@"btn_adduser.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.userImgView setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
                cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
                cell.userImgView.clipsToBounds = YES;
                cell.userImgView.backgroundColor = [UIColor clearColor];
                
                cell.userNmLabel.text = NSLocalizedString(@"chat_slidingmenu_adduser", @"chat_slidingmenu_adduser");
                
            } else if (indexPath.section == 2){
                 if(indexPath.row==0){
                    cell.notiSwitch.hidden = YES;
                    [cell.userImgView setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_edit.png"] scaledToMaxWidth:15]];
                    cell.userImgView.layer.cornerRadius = 0;
                    cell.userImgView.clipsToBounds = NO;
                    cell.userNmLabel.text = [setTitleArr objectAtIndex:indexPath.row];
                    
                 } else if(indexPath.row==1){
                     cell.notiSwitch.hidden = NO;
                     [cell.userImgView setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"icon_alarm.png"] scaledToMaxWidth:15]];
                     cell.userImgView.layer.cornerRadius = 0;
                     cell.userImgView.clipsToBounds = NO;
                     cell.userNmLabel.text = [setTitleArr objectAtIndex:indexPath.row];
                     
                     if([self.roomNoti isEqualToString:@"1"]){
                         [cell.notiSwitch setOn:YES animated:NO];
                     } else {
                         [cell.notiSwitch setOn:NO animated:NO];
                     }
                     [cell.notiSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
                 }
                
            } else {
                cell.notiSwitch.hidden = YES;
                [cell.userImgView setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"icon_exit.png"] scaledToMaxWidth:15]];
                cell.userImgView.layer.cornerRadius = 0;
                cell.userImgView.clipsToBounds = NO;
                cell.userNmLabel.text = NSLocalizedString(@"chat_leave_room", @"chat_leave_room");
            }
            
            return cell;
            
        } else {
            NSLog(@"userArr is Nil");
            return cell;
        }
        return nil;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    NSString *json;
    if ([mySwitch isOn]) {
        NSString *sqlString = [appDelegate.dbHelper updateRoomNoti:1 roomNo:self.roomNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        [dic1 setObject:@YES forKey:@"IS_NOTI"];
        NSData* data1 = [NSJSONSerialization dataWithJSONObject:dic1 options:0 error:nil];
        NSString *json1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        [dic2 setObject:json1 forKey:[NSString stringWithFormat:@"%@", self.roomNo]];
        NSData* data2 = [NSJSONSerialization dataWithJSONObject:dic2 options:0 error:nil];
        json = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
        
        
    } else {
        NSString *sqlString = [appDelegate.dbHelper updateRoomNoti:0 roomNo:self.roomNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        [dic1 setObject:@NO forKey:@"IS_NOTI"];
        NSData* data1 = [NSJSONSerialization dataWithJSONObject:dic1 options:0 error:nil];
        NSString *json1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        [dic2 setObject:json1 forKey:[NSString stringWithFormat:@"%@", self.roomNo]];
        NSData* data2 = [NSJSONSerialization dataWithJSONObject:dic2 options:0 error:nil];
        json = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"json : %@", json);
    [self notiUpdate:json];
}

-(void)notiUpdate:(NSString *)json{
    NSString *dlqUrl = [NSString stringWithFormat:@"http://%@:15672/api/exchanges/snsHost/mfps.dlq.function/publish", [[MFSingleton sharedInstance] rmq_host]];
    NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];

    NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
    [dlqDict setObject:@"1" forKey:@"APP_NO"];
    [dlqDict setObject:[[MFSingleton sharedInstance] appType] forKey:@"APP_TYPE"];
    [dlqDict setObject:@"i" forKey:@"DVC_OS"];
    [dlqDict setObject:[[MFSingleton sharedInstance] dvcType] forKey:@"DVC_TYPE"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] forKey:@"PUSH_ID"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
    [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"DVC_ID"]forKey:@"DVC_ID"];
    [dlqDict setObject:mfpsId forKey:@"QUEUE_NAME"];
    [dlqDict setObject:json forKey:@"CHAT_NOTI_OPTION"];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @try{
        if(indexPath.section == 0){
            NSString *sqlString = [appDelegate.dbHelper getRoomType:self.roomNo];
            NSString *roomType = [appDelegate.dbHelper selectString:sqlString];
            
            NSDictionary *dic = [self.userArr objectAtIndex:indexPath.row];
            NSString *userNo = [dic objectForKey:@"USER_NO"];
            NSString *userType = [dic objectForKey:@"SNS_USER_TYPE"];
            
            CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
            destination.userNo = userNo;
            destination.fromSegue = @"CHAT_SIDE_PROFILE_MODAL";
            destination.chatRoomTy = roomType;
            destination.userType = userType;
            
            destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:destination animated:YES completion:nil];
            
            
        } else if(indexPath.section == 1){
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            if([self.roomType isEqualToString:@"1"]){
                if([[[MFSingleton sharedInstance] userListSort] isEqualToString:@"DEPT"]){
                    DeptListViewController *destination = (DeptListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DeptListViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                    
                    destination.fromSegue = @"CHAT_SIDE_NEW_ROOM_PUSH";
                    destination.userArr = self.userArr;
                    destination.roomNo = self.roomNo;
                    destination.existUserArr = existUserArr;
                    
                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:navController animated:YES completion:nil];
                    
                } else {
                    UserListViewController *destination = (UserListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                    
                    destination.fromSegue = @"CHAT_SIDE_NEW_ROOM_PUSH";
                    destination.userArr = self.userArr;
                    destination.roomNo = self.roomNo;
                    destination.existUserArr = existUserArr;
                    
                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:navController animated:YES completion:nil];
                }
                
            } else if([self.roomType isEqualToString:@"2"]){
                if([[[MFSingleton sharedInstance] userListSort] isEqualToString:@"DEPT"]){
                    DeptListViewController *destination = (DeptListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DeptListViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                    
                    destination.fromSegue = @"CHAT_SIDE_ADD_USER_PUSH";
                    destination.roomNo = self.roomNo;
                    destination.existUserArr = existUserArr;
                    
                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:navController animated:YES completion:nil];
                    
                } else {
                    UserListViewController *destination = (UserListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                    
                    destination.fromSegue = @"CHAT_SIDE_ADD_USER_PUSH";
                    destination.roomNo = self.roomNo;
                    destination.existUserArr = existUserArr;
                    
                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:navController animated:YES completion:nil];
                }
            }
            
        } else if(indexPath.section == 2){
            if(indexPath.row==0){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MyMessageViewController *destination = (MyMessageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MyMessageViewController"];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                
                destination.statusMsg = self.roomName;
                destination.changeRoomNo = self.roomNo;
                destination.fromSegue = @"CHAT_SET_ROOM_NAME_MODAL";
                
                navController.modalTransitionStyle = UIModalPresentationNone;
                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self presentViewController:navController animated:YES completion:nil];
            }
            
        } else if(indexPath.section == 3){
            NSLog(@"exit select");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"chat_leave_room_message", @"chat_leave_room_message") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 [self callDeleteChat];
                                                             }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)callDeleteChat{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
        NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
        NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
    //    NSUInteger memberCnt = self.userArr.count;
        
    //    if(memberCnt > 2){
        if([self.roomType isEqualToString:@"2"]){
            NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
            NSString *decodeUserNm = [NSString urlDecodeString:userNm];
            NSString *routingKey = [NSString stringWithFormat:@"%@.CHAT.%@.%@", [[MFSingleton sharedInstance] appType], [appDelegate.appPrefs objectForKey:@"COMP_NO"], self.roomNo];//[MFUtil getChatRoutingKey:self.roomNo];

            NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            NSString *paramString = [NSString stringWithFormat:@"roomNo=%@&usrNo=%@&queueName=%@&routingKey=%@&usrNm=%@&dvcId=%@",self.roomNo, userNo, mfpsId, routingKey, decodeUserNm, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"deleteChatUser"]];
            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
            session.delegate = self;
            if ([session start]) {
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
                [SVProgressHUD show];
            }
        } else {
            //1:1채팅방일 경우 방정보 저장(0:알림톡, 1:일대일, 2:그룹채팅, 3:나와의채팅)
            NSString *selectLastChat = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getChatLastNo:self.roomNo]];
            NSString *insertChatRoomInfo = [appDelegate.dbHelper insertChatRoomInfo:self.roomNo roomType:self.roomType lastChatNo:[NSString stringWithFormat:@"%@", selectLastChat] exitFlag:@"Y"];
            [appDelegate.dbHelper crudStatement:insertChatRoomInfo];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            NSString *sqlString1 = [appDelegate.dbHelper deleteMissedChat:self.roomNo];
            [appDelegate.dbHelper crudStatement:sqlString1];
            NSString *sqlString2 = [appDelegate.dbHelper deleteChats:self.roomNo];
            [appDelegate.dbHelper crudStatement:sqlString2];
            NSString *sqlString3 = [appDelegate.dbHelper deleteChatUsers:self.roomNo];
            [appDelegate.dbHelper crudStatement:sqlString3];
            NSString *sqlString4 = [appDelegate.dbHelper deleteChatRooms:self.roomNo];
            [appDelegate.dbHelper crudStatement:sqlString4];
            NSString *sqlString5 = [appDelegate.dbHelper deleteRoomImage:self.roomNo];
            [appDelegate.dbHelper crudStatement:sqlString5];
            
            self.roomNo = nil;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    
    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSDictionary *dic = session.returnDictionary;
        if ([[dic objectForKey:@"RESULT"]isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"deleteChatUser"]) {
                [self.navigationController popViewControllerAnimated:YES];
                
                NSString *sqlString1 = [appDelegate.dbHelper deleteMissedChat:self.roomNo];
                [appDelegate.dbHelper crudStatement:sqlString1];
                NSString *sqlString2 = [appDelegate.dbHelper deleteChats:self.roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                NSString *sqlString3 = [appDelegate.dbHelper deleteChatUsers:self.roomNo];
                [appDelegate.dbHelper crudStatement:sqlString3];
                NSString *sqlString4 = [appDelegate.dbHelper deleteChatRooms:self.roomNo];
                [appDelegate.dbHelper crudStatement:sqlString4];
            }
        }
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
}

@end

