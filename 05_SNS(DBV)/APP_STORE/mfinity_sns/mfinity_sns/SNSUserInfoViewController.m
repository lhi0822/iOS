//
//  SNSUserInfoViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "SNSUserInfoViewController.h"
#import "MFDBHelper.h"
#import "CustomHeaderViewController.h"
#import "ChatUserListCell.h"
#import "DeptListViewController.h"
#import "UserListViewController.h"
#import "NotiChatViewController.h"

#define REFRESH_HEADER_DEFAULT_HEIGHT   64.f


@interface SNSUserInfoViewController () {
    NSMutableArray *sortDataArr;
    AppDelegate *appDelegate;
//    MFDBHelper *dbHelper;
    NSMutableArray *existUserArr;
    
    BOOL isLoad;
    BOOL isRefresh;
    BOOL isScroll;
    
    int pSize;
    NSString *stSeq;
}
@end

@implementation SNSUserInfoViewController

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *titleStr = [NSString stringWithFormat:@"%@ %@", self.snsName, NSLocalizedString(@"board_userlist_title2", @"board_userlist_title2")];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:titleStr];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_InviteBoardChat:) name:@"noti_InviteBoardChat" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    existUserArr = [NSMutableArray array];
    self.dataSetArray = [NSMutableArray array];
    
    stSeq = @"1";
    isLoad = YES;
    isRefresh = NO;
    isScroll = NO;
    pSize = 30;
    
    [self callGetSNSUserList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callGetSNSUserList{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *paramString = [NSString stringWithFormat:@"snsNo=%@&usrNo=%@&currentUserNos=&pSize=%d&stSeq=%@&dvcId=%@", self.snsNo, myUserNo, pSize, stSeq, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getSNSMemberList"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        self.tableView.scrollEnabled = NO;
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

-(void)noti_InviteBoardChat:(NSNotification *)notification {
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    NSLog(@"userInfo : %@", notification.userInfo);
    
    @try{
        if([self.parentViewController childViewControllers].count == 1){
            NSString *nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
            NSString *nRoomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
            NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
            NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            NSString *resultRoomNm = @"";
            if([[NSString stringWithFormat:@"%@", roomType] isEqualToString:@"3"]) resultRoomNm = nRoomNm;
            else resultRoomNm = [MFUtil createChatRoomName:nRoomNm roomType:roomType];
            
            NSString *sqlStr = [appDelegate.dbHelper getUpdateRoomList:myUserNo roomNo:nRoomNo];
            NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlStr];
            if(roomChatArr.count==0){
                NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:nRoomNo roomName:resultRoomNm roomType:roomType];
                
                for (int i=0; i<users.count; i++) {
                    NSString *userNo = [[users objectAtIndex:i] objectForKey:@"USER_NO"];
                    NSString *userNm = [[users objectAtIndex:i] objectForKey:@"USER_NM"];
                    NSString *decodeUserNm = [NSString urlDecodeString:userNm];
                    NSString *userMsg = [[users objectAtIndex:i] objectForKey:@"USER_MSG"];
                    NSString *decodeUserMsg = [NSString urlDecodeString:userMsg];
                    NSString *userImg = [[users objectAtIndex:i] objectForKey:@"USER_IMG"];
                    NSString *decodeUserImg = [NSString urlDecodeString:userImg];
                    NSString *userId = [[users objectAtIndex:i] objectForKey:@"USER_ID"];
                    NSString *phoneNo = [[users objectAtIndex:i] objectForKey:@"PHONE_NO"];
                    NSString *deptNo = [[users objectAtIndex:i] objectForKey:@"DEPT_NO"];
                    NSString *userBgImg = [[users objectAtIndex:i] objectForKey:@"USER_BG_IMG"];
                    
                    NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DEPT_NM"]];
                    NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
                    NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
                    NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
                    NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
                    NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
                    NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
//                    NSString *levelNo = [[users objectAtIndex:i] objectForKey:@"LEVEL_NO"];
                    NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                    NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                    
                    NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                    NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:nRoomNo userNo:userNo];
                    
                    [appDelegate.dbHelper crudStatement:sqlString2];
                    [appDelegate.dbHelper crudStatement:sqlString3];
                    
                    //프로필 썸네일 로컬저장
                    /*NSString *tmpPath = NSTemporaryDirectory();
                     UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
                     NSData *imageData = UIImagePNGRepresentation(thumbImage);
                     NSString *fileName = [decodeUserImg lastPathComponent];
                     
                     NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                     [imageData writeToFile:thumbImgPath atomically:YES];*/
                }
                
                [appDelegate.dbHelper crudStatement:sqlString1];
                
            }
            
            self.navigationController.navigationBar.topItem.title = @"";
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([[NSString stringWithFormat:@"%@", roomType] isEqualToString:@"0"]){
                NotiChatViewController *destination = [storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.fromSegue = @"BOARD_ADD_USER_MODAL";
                
                destination.roomName = resultRoomNm;
                destination.roomNo = nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = resultRoomNm;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } else {
                ChatViewController *destination = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.fromSegue = @"BOARD_ADD_USER_MODAL";
                destination.snsInfoDic = self.snsInfoDic;
                
                destination.roomName = resultRoomNm;
                destination.roomNo = nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = resultRoomNm;
                rightViewController.roomType = roomType;
                
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    self.tableView.scrollEnabled = YES;
    [SVProgressHUD dismiss];
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    }else{
        @try{
            NSDictionary *dic = session.returnDictionary;
            
            NSMutableArray *dataSets = [dic objectForKey:@"DATASET"];
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            NSUInteger count = dataSets.count;
            
            if(count==0||count<pSize) {
                isLoad = NO;
            }
            else {
                isLoad = YES;
            }
            
            sortDataArr = [NSMutableArray array];
            
            NSDictionary *myInfo = [NSDictionary dictionary];
            NSDictionary *leaderInfo = [NSDictionary dictionary];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            
            for(int i=0; i<dataSets.count; i++){
                NSDictionary *dataSet = [dataSets objectAtIndex:i];
                NSString *userNo = [dataSet objectForKey:@"CUSER_NO"];
                NSString *userId = [NSString urlDecodeString:[dataSet objectForKey:@"CUSER_ID"]];
                NSString *userName = [NSString urlDecodeString:[dataSet objectForKey:@"USER_NM"]];
                NSString *userImg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_IMG"]];
                NSString *userMsg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_MSG"]];
                NSString *phoneNo = [NSString urlDecodeString:[dataSet objectForKey:@"PHONE_NO"]];
                NSString *deptNo = [dataSet objectForKey:@"DEPT_NO"];
                NSString *userBgImg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_BACKGROUND_IMG"]];
                
                NSString *deptName = [NSString urlDecodeString:[dataSet objectForKey:@"DEPT_NM"]];
                NSString *levelNo = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NO"]];
//                NSString *levelNo = [dataSet objectForKey:@"LEVEL_NO"];
                NSString *levelName = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NM"]];
                NSString *dutyNo = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NO"]];
                NSString *dutyName = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NM"]];
                NSString *jobGrpName = [NSString urlDecodeString:[dataSet objectForKey:@"JOB_GRP_NM"]];
                NSString *exCompNo = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY"]];
                NSString *exCompName = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY_NM"]];
                NSString *userType = [dataSet objectForKey:@"SNS_USER_TYPE"];
                
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:userImg userMsg:userMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                [appDelegate.dbHelper crudStatement:sqlString];
                
//                NSString *snsUserType = [[dataSets objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
//                if(![[NSString stringWithFormat:@"%@", snsUserType] isEqualToString:@"1"]){
//                    NSString *userNo = [[dataSets objectAtIndex:i] objectForKey:@"CUSER_NO"];
//
//                    if(![existUserArr containsObject:userNo]){
//                        [indexPaths addObject:[NSIndexPath indexPathForRow:[stSeq integerValue]+i-1 inSection:0]];
//                        [existUserArr addObject:userNo];
//
//                        if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
//                            myInfo = [[NSDictionary alloc] initWithDictionary:[dataSets objectAtIndex:i]];
//
//                        }  else {
//                            if(![[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", [[MFSingleton sharedInstance] adminNo1]]]&&![[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", [[MFSingleton sharedInstance] adminNo2]]]){
//                                if([[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", userNo]]){
//                                    leaderInfo = [[NSDictionary alloc] initWithDictionary:[dataSets objectAtIndex:i]];
//                                } else {
//                                    [sortDataArr addObject:[dataSets objectAtIndex:i]];
//                                }
//                            } else {
//                                [sortDataArr addObject:[dataSets objectAtIndex:i]];
//                            }
//                        }
//                    }
//                }
                
                [indexPaths addObject:[NSIndexPath indexPathForRow:[stSeq integerValue]+i-1 inSection:0]];
                [existUserArr addObject:userNo];
                
                if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                    myInfo = [[NSDictionary alloc] initWithDictionary:[dataSets objectAtIndex:i]];
                    
                }  else {
                    if(![[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", [[MFSingleton sharedInstance] adminNo1]]]&&![[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", [[MFSingleton sharedInstance] adminNo2]]]){
                        if([[NSString stringWithFormat:@"%@", self.snsLeader] isEqualToString:[NSString stringWithFormat:@"%@", userNo]]){
                            leaderInfo = [[NSDictionary alloc] initWithDictionary:[dataSets objectAtIndex:i]];
                        } else {
                            [sortDataArr addObject:[dataSets objectAtIndex:i]];
                        }
                    } else {
                        [sortDataArr addObject:[dataSets objectAtIndex:i]];
                    }
                }
            }
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"USER_NM" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sortDataArr sortUsingDescriptors:sortDescriptors];
            
            if(myInfo.count>0) [sortDataArr insertObject:myInfo atIndex:0];
            if(leaderInfo.count>0) [sortDataArr insertObject:leaderInfo atIndex:1];
            
            //        NSLog(@"sortDataArr : %@", sortDataArr);
            
            //        self.dataSetArray = sortDataArr;
            //        NSLog(@"self.dataSetArray : %@", self.dataSetArray);
            //        [self.tableView reloadData];
            
            if([[NSString stringWithFormat:@"%@", stSeq] isEqualToString:@"1"]){
//                            self.dataSetArray = [NSMutableArray array];
                self.dataSetArray = [NSMutableArray arrayWithArray:sortDataArr];
                //            NSLog(@"self.dataSetArray : %@", self.dataSetArray);
                
                if(isRefresh){
                    isRefresh = NO;
                }
                [self.tableView reloadData];
                
            } else {
                [self.dataSetArray addObjectsFromArray:sortDataArr];
//
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
            
            NSString *seq = [[NSString alloc]init];
            for(int i=1; i<=count; i++){
                seq = [NSString stringWithFormat:@"%d", [stSeq intValue]+i];
            }
            stSeq = seq;
            
            isScroll = YES;
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    self.tableView.scrollEnabled = YES;
    NSLog(@"error : %@", error);
    
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        [self callGetSNSUserList];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSetArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, view.frame.size.height/2-20, 45, 45)];
    UIImage *image = [[UIImage imageNamed:@"btn_adduser.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgView setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
    imgView.image = image;
    imgView.layer.cornerRadius = imgView.frame.size.width/2;
    imgView.clipsToBounds = YES;
    [view addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.size.width+30, 0, self.view.frame.size.width, 60)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    label.backgroundColor = [UIColor whiteColor];
    label.text = NSLocalizedString(@"board_add_member", @"board_add_member");
    label.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    [view addSubview:label];
    
    UITapGestureRecognizer *addUserTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddUser:)];
    [view setUserInteractionEnabled:YES];
    [view addGestureRecognizer:addUserTap];
    
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userImgView.image = nil;
    
    NSDictionary *snsUserDic = [self.dataSetArray objectAtIndex:indexPath.row];
    
    NSString *profileImg = [NSString urlDecodeString:[snsUserDic objectForKey:@"PROFILE_IMG"]];
    NSString *userNo = [snsUserDic objectForKey:@"CUSER_NO"];
    NSString *userName = [NSString urlDecodeString:[snsUserDic objectForKey:@"USER_NM"]];
    //NSString *userMsg = [NSString urlDecodeString:[snsUserDic objectForKey:@"PROFILE_MSG"]];
    //NSString *profileBgImg = [NSString urlDecodeString:[snsUserDic objectForKey:@"PROFILE_BACKGROUND_IMG"]];
    NSString *levelName = [NSString urlDecodeString:[snsUserDic objectForKey:@"LEVEL_NM"]];
    //NSString *deptName = [NSString urlDecodeString:[snsUserDic objectForKey:@"CORP_NM"]];
    NSString *deptName = [NSString urlDecodeString:[snsUserDic objectForKey:@"DEPT_NM"]];
    NSString *exCompName = [NSString urlDecodeString:[snsUserDic objectForKey:@"EX_COMPANY_NM"]];
    
    NSString *userStr;
//    if([userMsg isEqualToString:@""]) userStr = [NSString stringWithFormat:@"%@ (%@)", userName, deptName];
//    else userStr = [NSString stringWithFormat:@"%@ (%@ , %@)", userName, deptName, userMsg];
    
    NSString *levelStr = @"";
    NSString *deptStr = @"";
    if(levelName!=nil&&![levelName isEqualToString:@""]) levelStr = [NSString stringWithFormat:@"%@/", levelName];
    if(deptName!=nil&&![deptName isEqualToString:@""]) deptStr = [NSString stringWithFormat:@"%@/", deptName];
    
    if(levelName.length<1&&deptName.length<1&&exCompName.length<1) userStr = [NSString stringWithFormat:@"%@", userName];
    else userStr = [NSString stringWithFormat:@"%@/%@%@%@", userName, levelStr, deptStr, exCompName];
    
    cell.nodeNameLabel.text = userStr;
    cell.checkButton.hidden = YES;
    
    if([[NSString stringWithFormat:@"%@",userNo] isEqualToString:[NSString stringWithFormat:@"%@",self.snsLeader]]){
        cell.leaderBtn.hidden = NO;
        
        [cell.leaderBtn setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(11, 11) :[UIImage imageNamed:@"icon_crown.png"]] forState:UIControlStateNormal];
        [cell.leaderBtn setBackgroundColor:[UIColor whiteColor]];
        
    } else {
        cell.leaderBtn.hidden = YES;
    }
    
    UIImage *userImg = nil;
    if(![profileImg isEqualToString:@""]){
        userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
        cell.userImgView.image = userImg;
        
    } else {
        userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
        cell.userImgView.image = userImg;
    }
    
    [cell.userImgView setFrame:CGRectMake(20, (cell.frame.size.height/2) - (45/2), 45, 45)];
    [cell.leaderBtn setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width-cell.leaderBtn.frame.size.width, cell.leaderBtn.frame.origin.y, cell.leaderBtn.frame.size.width, cell.leaderBtn.frame.size.height)];
    [cell.nodeNameLabel setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width+10, cell.nodeNameLabel.frame.origin.y, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
    
    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
    cell.userImgView.clipsToBounds = YES;
    cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImgView.layer.borderWidth = 0.3;
    
    cell.leaderBtn.layer.cornerRadius = cell.leaderBtn.frame.size.width/2;
    cell.leaderBtn.clipsToBounds = YES;
    cell.leaderBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.leaderBtn.layer.borderWidth = 0.3;
    
    cell.nodeNameLabel.text = userStr;
    cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self performSegueWithIdentifier:@"BOARD_MEMBER_PROFILE_MODAL" sender:indexPath];
    
    NSDictionary *dic = [self.dataSetArray objectAtIndex:indexPath.row];
    NSString *userNo = [dic objectForKey:@"CUSER_NO"];
    NSString *userType = [dic objectForKey:@"SNS_USER_TYPE"];
    
    CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
    destination.userNo = userNo;
    destination.userType = userType;
    destination.fromSegue = @"BOARD_MEMBER_PROFILE_MODAL";
    
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:destination animated:YES completion:nil];
}

- (void)tapAddUser:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if([[[MFSingleton sharedInstance] userListSort] isEqualToString:@"DEPT"]){
        DeptListViewController *vc = (DeptListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DeptListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.fromSegue = @"BOARD_ADD_USER_MODAL";
        vc.existUserArr = existUserArr;
        
        //noti_InviteBoardChat
        ChatListViewController *vc2 = (ChatListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatListViewController"];
        [[NSNotificationCenter defaultCenter] addObserver:vc2 selector:@selector(noti_NewChatRoom:) name:@"noti_NewChatRoom" object:nil];
        
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        NSLog(@"userListSortUser");
        UserListViewController *vc = (UserListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.fromSegue = @"BOARD_ADD_USER_MODAL";
        vc.existUserArr = existUserArr;
        vc.snsName = self.snsName;
        
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
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
            NSLog(@"새로고침");
            stSeq = @"1";
            isRefresh = YES;
            existUserArr = [NSMutableArray array];
            [self callGetSNSUserList];
        }
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    NSLog(@"scrollView.contentSize.height : %f", scrollView.contentSize.height);
    //    NSLog(@"scrollView.contentOffset.y : %f", scrollView.contentOffset.y);
    //    NSLog(@"self.tableView.frame.size.height : %f", self.tableView.frame.size.height);
    //    NSLog(@"=======================================================");
    
    //스크롤이 하단에 닿을 때 데이터 로드
    //->로우가 추가되는 모양이 부자연스러워서 스크롤이 어느정도 위치에 가면 미리 데이터 로드
    //scrollView.contentSize.height-(self.tableView.frame.size.height/3)
    
    if(scrollView.contentOffset.y>0){
        if (scrollView.contentSize.height-(self.tableView.frame.size.height/1) <= scrollView.contentOffset.y + self.tableView.frame.size.height) {
            if(isLoad==YES && isScroll==YES){
                isScroll = NO;
                [self callGetSNSUserList];
                
            }
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
