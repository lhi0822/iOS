//
//  UserListViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 2. 23..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "UserListViewController.h"
#import "UserListCollectionViewCell.h"
#import "ChatUserListCell.h"
#import "MFDBHelper.h"
#import "CustomHeaderViewController.h"
#import "NotiChatViewController.h"

#define MODEL_NAME [[UIDevice currentDevice] modelName]
#define REFRESH_HEADER_DEFAULT_HEIGHT   64.f

@interface UserListViewController () {
    AppDelegate *appDelegate;
    NSIndexPath *chkIndxPath;
    NSMutableDictionary *checkDict;
    NSString *retVal;
    BOOL isLoad;
    BOOL isFirst;
    BOOL isRefresh;
    BOOL isScroll;
    int pSize;
}

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSLog(@"self.fromSegue : %@", self.fromSegue);
    
    if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_add_member", @"board_add_member")];
    } else {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"dept_user1", @"dept_user1")];
    }
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftSideMenuButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_UserListProfileChat:) name:@"noti_UserListProfileChat" object:nil];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserListCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //self.collectionViewHeight.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height; //44+44, 44+20
    self.collectionViewHeight.constant = 0;
    self.collectionView.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable:)];
    [self.tableView addGestureRecognizer:tap];
    
    self.stSeq = @"1";
    self.dataSetArray = [NSMutableArray array];
    self.checkArray = [NSMutableArray array];
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    checkDict = [NSMutableDictionary dictionary];
    retVal = @"";
    isLoad = YES;
    isFirst = YES;
    isRefresh = NO;
    isScroll = NO;
    pSize = 20;
    
    [self callWebService:@"getUsers2"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSUInteger chkArrCnt = self.checkArray.count;
    
    NSMutableArray *deptArr = [NSMutableArray array];
    NSMutableArray *userArr = [NSMutableArray array];
    
    [userArr addObject:[NSString stringWithFormat:@"%@", myUserNo]];
    
    for(int i=0; i<chkArrCnt; i++){
        NSString *nodeNo = [[self.checkArray objectAtIndex:i] objectForKey:@"NODE_NO"];
        
        if(![[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", nodeNo]]){
            [userArr addObject:nodeNo];
        }
    }
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    [resultDic setObject:deptArr forKey:@"depts"];
    [resultDic setValue:userArr forKey:@"users"];
    
    if(chkArrCnt==0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"check_user_null", @"check_user_null") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
        
        if([self.fromSegue isEqualToString:@"CHAT_SIDE_ADD_USER_PUSH"]){
            [self dismissViewControllerAnimated:YES completion:nil];
            [self saveChatAttn:resultDic];
            
        } else if([self.fromSegue isEqualToString:@"CHAT_SIDE_NEW_ROOM_PUSH"]){
            for(int i=0; i<self.userArr.count; i++){
                NSString *userNo = [[self.userArr objectAtIndex:i] objectForKey:@"USER_NO"];
                if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                    [userArr addObject:userNo];
                }
                [resultDic setValue:userArr forKey:@"users"];
            }
            
            [self callSaveChatInfo:resultDic];
            
        } else if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
            //게시판초대
            [self callSaveChatInfo:resultDic];
            
        } else {
            [self callSaveChatInfo:resultDic];
        }
    }
    
}

- (void)callSaveChatInfo: (NSMutableDictionary *)dictionary {
    //saveChatInfo - usrId, attendants:{"depts":"[부서]","users":"[사용자]"}
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *inviteMode;
    NSString *inviteRef1;
    if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
        inviteMode = @"INVITE_SNS";
        inviteRef1 = _snsName;
    } else {
        inviteMode = @"INVITE_CHAT";
        inviteRef1 = @"";
    }
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&attendants=%@&inviteMode=%@&inviteRef1=%@&dvcId=%@", userID, userNo, jsonData, inviteMode, inviteRef1, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatInfo"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)saveChatAttn: (NSMutableDictionary *)dictionary {
    NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
    NSString *decodeUserNm = [NSString urlDecodeString:userNm];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
    
    NSString *inviteMode;
    NSString *inviteRef1;
    if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
        inviteMode = @"INVITE_SNS";
        inviteRef1 = _snsName;
    } else {
        inviteMode = @"INVITE_CHAT";
        inviteRef1 = @"";
    }
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNm=%@&roomNo=%@&attendants=%@&inviteMode=%@&inviteRef1=%@&dvcId=%@", userID, decodeUserNm, self.roomNo, jsonData, inviteMode, inviteRef1, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatAttn"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString;
        
        NSString* jsonData = nil;
        if(self.existUserArr!=nil){
            NSData* data = [NSJSONSerialization dataWithJSONObject:self.existUserArr options:NSJSONWritingPrettyPrinted error:nil];
            jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            jsonData = @"";
        }
        
        if([serviceName isEqualToString:@"getUsers2"]){
            NSString *deptNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DEPTNO"]];
            NSString *legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
            NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
            NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
//            if(retVal==nil || [retVal isEqualToString:@""]){
//                paramString = [NSString stringWithFormat:@"deptNo=%@&legacyNm=%@&retVal=&stSeq=1&currentUserNos=%@&compNo=%@&dvcId=%@&pSize=%d&usrNo=%@", deptNo, legacyNm, jsonData, compNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]], pSize, userNo];
//            } else {
                paramString = [NSString stringWithFormat:@"deptNo=%@&legacyNm=%@&retVal=%@&stSeq=%@&currentUserNos=%@&compNo=%@&dvcId=%@&pSize=%d&usrNo=%@", deptNo, legacyNm, retVal, self.stSeq, jsonData, compNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"], pSize, userNo];
//            }
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        [session start];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    self.tableView.scrollEnabled = YES;
    [SVProgressHUD dismiss];
    
    //NSLog(@"reteurnDataString : %@",session.returnDataString);
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    }else{
        NSDictionary *dic = session.returnDictionary;
        if([wsName isEqualToString:@"getUsers2"]){
            @try{
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
                NSUInteger count = dataSet.count;
                
                NSLog(@"count : %lu", (unsigned long)count);
                NSLog(@"pSize : %d", pSize);
                
                if(count==0||count<pSize) isLoad = NO;
                else isLoad = YES;
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                for(int i=0; i<count; i++){
                    NSString *nodeNo = [[dataSet objectAtIndex:i] objectForKey:@"NODE_NO"];
                    
                    if(isFirst){
                        [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"%@", nodeNo]];
                        isFirst = NO;
                    }
                    [indexPaths addObject:[NSIndexPath indexPathForRow:[self.stSeq integerValue]+i-1 inSection:0]];
                }
                
                if([[NSString stringWithFormat:@"%@", self.stSeq] isEqualToString:@"1"]){
//                    NSLog(@"새로고침");
                    self.dataSetArray = [NSMutableArray array];
                    self.dataSetArray = [NSMutableArray arrayWithArray:dataSet];
                    
                    if(isRefresh){
                        isRefresh = NO;
                        self.checkArray = [NSMutableArray array];
                        self.rowCheckDictionary = [NSMutableDictionary dictionary];
                        [self.collectionView reloadData];
                    }
                    [self.tableView reloadData];
                    
                } else {
                    [self.dataSetArray addObjectsFromArray:dataSet];
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    
                }
                
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=count; i++){
                    seq = [NSString stringWithFormat:@"%d", [self.stSeq intValue]+i];
                }
                self.stSeq = seq;
//                if(retVal!=nil&&![retVal isEqualToString:@""]){
//                    self.stSeq = @"1";
//                    if(count==0) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//                }
                isScroll = YES;
                
                
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
            }
            
        } else if ([wsName isEqualToString:@"saveChatInfo"]) {
            NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
            NSString *roomName = [dataSet objectForKey:@"ROOM_NM"];
            //NSString *decodeRoomName = [NSString urlDecodeString:roomName];
            NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
            NSString *roomType = [dataSet objectForKey:@"ROOM_TYPE"];
            NSArray *users = [dataSet objectForKey:@"USERS"];
            
            NSMutableDictionary *newChatDic = [[NSMutableDictionary alloc]init];
            [newChatDic setObject:@"NEW_CHAT" forKey:@"TYPE"];
            [newChatDic setObject:roomNo forKey:@"NEW_ROOM_NO"];
            [newChatDic setObject:roomName forKey:@"NEW_ROOM_NM"];
            [newChatDic setObject:roomType forKey:@"NEW_ROOM_TY"];
            [newChatDic setObject:users forKey:@"NEW_USERS"];
            
            if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
                [self dismissViewControllerAnimated:YES completion:^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_InviteBoardChat" object:nil userInfo:newChatDic];
                }];
                
            } else if([self.fromSegue isEqualToString:@"CHAT_SIDE_NEW_ROOM_PUSH"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddUserNewChatRoom" object:nil userInfo:newChatDic];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                [self dismissViewControllerAnimated:YES completion:^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatRoom" object:nil userInfo:newChatDic];
                }];
            }
            
        } else if ([wsName isEqualToString:@"saveChatAttn"]) {
            NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
            NSString *roomName = [dataSet objectForKey:@"ROOM_NM"];
            NSString *decodeRoomName = [NSString urlDecodeString:roomName];
            
            NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
            NSString *decodeUserNm = [NSString urlDecodeString:userNm];
            
            if([decodeRoomName rangeOfString:decodeUserNm].location != NSNotFound){
                decodeRoomName = [decodeRoomName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", decodeUserNm] withString:@""];
            }
            
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        [self callWebService:@"getUsers2"];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 컬렉션과 컬렉션 width 간격
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 80);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.checkArray.count>0){
        return self.checkArray.count; //선택한 사람 수
    } else {
        self.collectionView.hidden = YES;
        //self.collectionViewHeight.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.collectionViewHeight.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserListCollectionViewCell *cell = (UserListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UserListCollectionViewCell" forIndexPath:indexPath];
    
    NSString *userNo = [[self.checkArray objectAtIndex:indexPath.item] objectForKey:@"NODE_NO"];
    NSString *profileImg = [NSString urlDecodeString:[[self.checkArray objectAtIndex:indexPath.item] objectForKey:@"NODE_IMG"]];
    if(![profileImg isEqualToString:@""]){
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
        cell.userImgView.image = userImg;
    } else {
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
        cell.userImgView.image = userImg;
    }
    cell.userNmLabel.text = [NSString urlDecodeString:[[self.checkArray objectAtIndex:indexPath.item] objectForKey:@"USER_NM"]];
    
    UIImage *deleteImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:10.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.deleteButton setTintColor:[UIColor lightGrayColor]];
    [cell.deleteButton setImage:deleteImg forState:UIControlStateNormal];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UIButton *button = [[UIButton alloc]init];
    NSString *checkNodeNo = [[self.checkArray objectAtIndex:indexPath.item] objectForKey:@"NODE_NO"];
    button.tag = [checkNodeNo intValue];
    
    [self checkAction:button];
}


#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataSetArray.count>0){
        return self.dataSetArray.count;
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //임의 셀
    ChatUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.checkButton setFrame:CGRectMake(cell.checkButton.frame.origin.x, cell.frame.size.height-(cell.frame.size.height/2)-(30/2), cell.checkButton.frame.size.width, 30)];
    
    cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
    
    //cell.checkButton.layer.cornerRadius = cell.checkButton.frame.size.width/10;
    //cell.checkButton.clipsToBounds = YES;
    //[cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.userImgView.image = nil;
    cell.userImgView.hidden = NO;
    cell.favoriteBtn.hidden = YES;
    
    NSDictionary *dataDict = [self.dataSetArray objectAtIndex:indexPath.row];
    //NSString *userId = [NSString urlDecodeString:[dataDict objectForKey:@"CUSER_ID"]];
    NSString *nodeNo = [dataDict objectForKey:@"NODE_NO"];
    NSString *nodeName = [NSString urlDecodeString:[dataDict objectForKey:@"NODE_NM"]];
    NSString *profileImg = [NSString urlDecodeString:[dataDict objectForKey:@"NODE_IMG"]];
    NSString *profileMsg = [dataDict objectForKey:@"PROFILE_MSG"];
    BOOL authFlag = [[dataDict objectForKey:@"SNS_AUTH_FLAG"] boolValue];
    NSString *favoriteUser = [dataDict objectForKey:@"IS_FAVORITE_USER"];
    
    if([[NSString stringWithFormat:@"%@", favoriteUser] isEqualToString:@"1"]){
        cell.favoriteBtn.hidden = NO;
        [cell.favoriteBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"bookmark_on.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
    } else {
        cell.favoriteBtn.hidden = YES;
    }
    
    if(profileMsg.length==0){
        NSRange range = [nodeName rangeOfString:@"," options:NSBackwardsSearch];
        
        if(range.location != NSNotFound){
            nodeName = [nodeName stringByReplacingOccurrencesOfString:@" , " withString:@""];
        }
    }
    
    if ([[self.rowCheckDictionary objectForKey:[NSString stringWithFormat:@"%@",nodeNo]] isEqualToString:@"Y"]) {
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
    cell.userImgView.tag = indexPath.row;
    
    [cell.unInstallLbl setFrame:CGRectMake(20, (cell.frame.size.height/2) - (45/2), 45, 45)];
    
    cell.checkButton.tag = [nodeNo integerValue];
    //cell.checkButton.tag = indexPath.row;
    
    cell.leaderBtn.hidden = YES;
    
    if(![profileImg isEqualToString:@""]){
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:nodeNo]];
        cell.userImgView.image = userImg;
    } else {
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
        cell.userImgView.image = userImg;
    }
    
    cell.nodeNameLabel.text = nodeName;
    
    UITapGestureRecognizer *userImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImgTapDetected:)];
    if(authFlag){
        cell.unInstallLbl.hidden = YES;
        cell.userImgView.alpha = 1.0;
        cell.nodeNameLabel.alpha = 1.0;
        cell.checkButton.alpha = 1.0;
        [cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell.userImgView setUserInteractionEnabled:YES];
        [cell.userImgView addGestureRecognizer:userImgTap];

    } else {
        cell.unInstallLbl.hidden = NO;
        cell.userImgView.alpha = 0.5;
        cell.nodeNameLabel.alpha = 0.5;
        cell.checkButton.alpha = 0.5;
        [cell.checkButton removeTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.userImgView setUserInteractionEnabled:NO];
        [cell.userImgView removeGestureRecognizer:userImgTap];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)checkAction:(UIButton *)sender{
    @try{
        UIButton *button = sender;
        NSInteger buttonTag = button.tag;
        
        NSIndexPath *selectIdxPath = [[NSIndexPath alloc] init];
        NSDictionary *selectDict = [NSDictionary dictionary];
        
        for(int i=0; i<self.dataSetArray.count; i++){
            NSString *nodeNo2 = [[self.dataSetArray objectAtIndex:i] objectForKey:@"NODE_NO"];
            if([[NSString stringWithFormat:@"%@", nodeNo2] isEqualToString:[NSString stringWithFormat:@"%ld", (long)buttonTag]]){
                selectDict = [self.dataSetArray objectAtIndex:i];
                selectIdxPath = [NSIndexPath indexPathForItem:i inSection:0];
                break;
            }
        }
        
        BOOL isAlready = NO;
        for (int i=0; i<self.checkArray.count; i++) {
            if ([[[self.checkArray objectAtIndex:i] objectForKey:@"NODE_NO"] isEqualToString:[NSString stringWithFormat:@"%ld", (long)buttonTag]]) {
                chkIndxPath = [[NSIndexPath alloc] init];
                chkIndxPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self.checkArray removeObjectAtIndex:i];
                isAlready = YES;
                break;
            }
        }
        
        if (!isAlready) {
            [self.rowCheckDictionary setObject:@"Y" forKey:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
            [self.checkArray addObject:selectDict];
            
        } else{
            [self.rowCheckDictionary setObject:@"N" forKey:[NSString stringWithFormat:@"%ld", (long)buttonTag]];
        }
        
        NSUInteger path = [[NSString stringWithFormat:@"%lu",(unsigned long)[selectIdxPath indexAtPosition:[selectIdxPath length]-1]] length];
        //path가 없을 경우 9223372036854775807
        if(path<19){
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[selectIdxPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        
        [self addUserAction:isAlready];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addUserAction:(BOOL)isAlready{
    @try {
        NSArray *uArr = [self.rowCheckDictionary allValues];
        NSMutableArray *Yflag = [NSMutableArray array];
        NSUInteger count = uArr.count;
        for(int i=0; i<count; i++){
            if([[uArr objectAtIndex:i] isEqualToString:@"Y"]){
                [Yflag addObject:[uArr objectAtIndex:i]];
            }
        }
        
        NSUInteger itemCount = [self.checkArray count];
        NSUInteger YFlagCnt = Yflag.count;
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        if(self.checkArray.count>0){
            [indexPaths addObject:[NSIndexPath indexPathForItem:self.checkArray.count-1 inSection:0]];
        }
        
        if(YFlagCnt>0){
            self.collectionView.hidden = NO;
            self.collectionViewHeight.constant = 106;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.collectionView.collectionViewLayout invalidateLayout];
            }];
            
        } else {
            self.collectionView.hidden = YES;
            self.collectionViewHeight.constant = 0;
            [UIView animateWithDuration:0.3 animations:^{
                [self.collectionView.collectionViewLayout invalidateLayout];
            }];
        }
        if(isAlready){
            if(itemCount>0){
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:chkIndxPath]];
                } completion:nil];
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.checkArray.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
                
            } else {
                [self.collectionView reloadData];
            }
        } else {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:nil];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.checkArray.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tapOnTable:(UITapGestureRecognizer*)tap{
    [self.searchBar resignFirstResponder];
}

- (void)userImgTapDetected:(UITapGestureRecognizer*)tap{
    NSInteger index = tap.view.tag;
    
    NSString *userNo = [[self.dataSetArray objectAtIndex:index] objectForKey:@"NODE_NO"];
    NSString *userType = [[self.dataSetArray objectAtIndex:index] objectForKey:@"SNS_USER_TYPE"];

    CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
    destination.userNo = userNo;
    destination.userType = userType;
    destination.fromSegue = @"USER_LIST_PROFILE_MODAL";

    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:destination animated:YES completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.stSeq = @"1";
    retVal = searchBar.text;
    
    //getUser에 검색파라미터 추가하여 호출
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    [self callWebService:@"getUsers2"];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog();
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if([searchText isEqualToString:@""]){
        self.stSeq = @"1";
        retVal = searchText;
        
        //getUser에 검색파라미터 추가하여 호출
        [self callWebService:@"getUsers2"];
    }
}

- (void)noti_UserListProfileChat:(NSNotification *)notification {
    NSLog(@"userinfo : %@", notification.userInfo);

    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    @try{
        //글목록에서 푸시받았을경우
        if([self.parentViewController childViewControllers].count == 1){
            NSString *nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
            NSString *nRoomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
            NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
            NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
            NSString *resultRoomNm = @"";
            if([roomType isEqualToString:@"3"]) resultRoomNm = nRoomNm;
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
                    NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                    NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                    
                    NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                    NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:nRoomNo userNo:userNo];
                    
                    [appDelegate.dbHelper crudStatement:sqlString2];
                    [appDelegate.dbHelper crudStatement:sqlString3];
                    
                    //프로필 썸네일 로컬저장
                    //                NSString *tmpPath = NSTemporaryDirectory();
                    //                UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
                    //                NSData *imageData = UIImagePNGRepresentation(thumbImage);
                    //                NSString *fileName = [decodeUserImg lastPathComponent];
                    //
                    //                NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                    //                [imageData writeToFile:thumbImgPath atomically:YES];
                }
                
                [appDelegate.dbHelper crudStatement:sqlString1];
            }
            self.navigationController.navigationBar.topItem.title = @"";
            
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
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
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
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
            self.stSeq = @"1";
            isRefresh = YES;
            [SVProgressHUD show];
            self.tableView.scrollEnabled = NO;
            [self callWebService:@"getUsers2"];
        }
    } @catch (NSException *exception) {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//        NSLog(@"scrollView.contentSize.height : %f", scrollView.contentSize.height);
//        NSLog(@"scrollView.contentOffset.y : %f", scrollView.contentOffset.y);
//        NSLog(@"self.tableView.frame.size.height : %f", self.tableView.frame.size.height);
//        NSLog(@"=======================================================");
    
    //스크롤이 하단에 닿을 때 데이터 로드
    //->로우가 추가되는 모양이 부자연스러워서 스크롤이 어느정도 위치에 가면 미리 데이터 로드
    //scrollView.contentSize.height-(self.tableView.frame.size.height/3)
    
    if(scrollView.contentOffset.y>0){
        if (scrollView.contentSize.height-(self.tableView.frame.size.height/1) <= scrollView.contentOffset.y + self.tableView.frame.size.height) {
            if(isLoad && isScroll){
                isScroll = NO;
//                if(retVal!=nil && ![retVal isEqualToString:@""]) [self callWebService:@"getUsers2"];
                [self callWebService:@"getUsers2"];
            }
        }
    }
}

@end
