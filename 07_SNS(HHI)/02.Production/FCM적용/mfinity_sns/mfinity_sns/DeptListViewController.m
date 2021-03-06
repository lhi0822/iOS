//
//  DeptListViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "DeptListViewController.h"
#import "PostDetailViewController.h"
#import "NotiChatViewController.h"

@interface DeptListViewController () {
    UIImage *userImg;
    NSMutableArray *tempArray;
    BOOL mfURLSessionFlag;
    NSInteger sectionTag;
    
    NSMutableArray *flagSectionNoArr;
    NSMutableArray *flagRowNoArr;
    NSMutableArray *highSectionArray;
    NSMutableArray *equalSectionArr;
    NSMutableArray *equalRowArr;
    
    NSMutableDictionary *rowCheckDic1;
    NSMutableDictionary *rowCheckDic2;
    
    AppDelegate *appDelegate;
}

@end

@implementation DeptListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"fromSegue : %@", self.fromSegue);
   
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    
    self.deptNo = @"0";
    self.searchText = @"null";
    self.dataSetArray = [NSMutableArray array];
    self.arrowArray = [NSMutableArray array];
    self.checkArray = [NSMutableArray array];
    self.dataSetDictionary = [NSMutableDictionary dictionary];
    self.rowDictionary = [NSMutableDictionary dictionary];
    self.rowCheckDictionary = [NSMutableDictionary dictionary];
    self.sectionCheckDictionary = [NSMutableDictionary dictionary];
    
    self.testDic = [NSMutableDictionary dictionary];
    self.testDic2 = [NSMutableDictionary dictionary];
    self.testRowDic = [NSMutableDictionary dictionary];
    
    rowCheckDic1 = [NSMutableDictionary dictionary];
    rowCheckDic2 = [NSMutableDictionary dictionary];
    
    [self callWebService];
    
    self.exclusiveSections = YES;
    self.shouldHandleHeadersTap = YES;
    self.sectionsStates = [[NSMutableArray alloc] init];
    
    [self setExclusiveSections:!self.exclusiveSections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    if(notification.userInfo!=nil){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
        NSDictionary *dict = [NSDictionary dictionary];
        if(message!=nil){
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            dict = notification.userInfo;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        vc.fromSegue = @"NOTI_POST_DETAIL";
        vc.notiPostDic = dict;
        [self presentViewController:nav animated:YES completion:nil];
    }
    appDelegate.inactivePostPushInfo=nil;
}

- (void)noti_NewChatPush:(NSNotification *)notification {
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    if(notification.userInfo!=nil){
        NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
        NSString *noti = [notification.userInfo objectForKey:@"NOTI"];
        NSDictionary *dict = [NSDictionary dictionary];
        if(noti==nil){
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            dict = notification.userInfo;
        }
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        
        NSString *sqlString = [appDelegate.dbHelper getRoomInfo:roomNo];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlString];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
        
        if(roomChatArr.count>0){
            NSString *roomNoti = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NOTI"];
            NSString *roomName = [NSString urlDecodeString:[[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NM"]];
            NSString *roomType = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_TYPE"];
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *vc = (NotiChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                vc.roomNo = roomNo;
                vc.roomNoti = roomNoti;
                vc.roomName = roomName;
                rightViewController.roomNo = roomNo;
                rightViewController.roomNoti = roomNoti;
                rightViewController.roomName = roomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];
                
                self.navigationController.navigationBar.topItem.title = @"";
                
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *chatDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_CHAT_DETAIL";
                
                if([currentClass isEqualToString:chatDetailClass]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatDetailView" object:nil userInfo:dict];
                } else {
                    NSString *strClass = NSStringFromClass([self class]);
                    if([currentClass isEqualToString:strClass]){
                        CATransition* transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                        [self.navigationController pushViewController:container animated:NO];
                    }
                }
                
            } else {
                ChatViewController *vc = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                vc.roomNo = roomNo;
                vc.roomNoti = roomNoti;
                vc.roomName = roomName;
                rightViewController.roomNo = roomNo;
                rightViewController.roomNoti = roomNoti;
                rightViewController.roomName = roomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];
                
                self.navigationController.navigationBar.topItem.title = @"";
                
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *chatDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_CHAT_DETAIL";
                vc.notiChatDic = dict;
                
                if([currentClass isEqualToString:chatDetailClass]){
                    //send notification to postdetail and if noti postno equal current postno, not open modal
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatDetailView" object:nil userInfo:dict];
                } else {
                    NSString *strClass = NSStringFromClass([self class]);
                    if([currentClass isEqualToString:strClass]){
                        CATransition* transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                        [self.navigationController pushViewController:container animated:NO];
                    }
                }
            }
        }
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}

- (void)callWebService{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString* jsonData = nil;
    if(self.existUserArr!=nil){
        NSData* data = [NSJSONSerialization dataWithJSONObject:self.existUserArr options:NSJSONWritingPrettyPrinted error:nil];
        jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    } else {
        jsonData = @"[]";
    }
    
    if([self.fromSegue isEqualToString:@"CHAT_SIDE_ADD_USER_PUSH"] || [self.fromSegue isEqualToString:@"CHAT_SIDE_NEW_ROOM_PUSH"]){
        NSString *paramString = [NSString stringWithFormat:@"compNo=%@&deptNo=%@&retVal=""&currentUserNos=%@&dvcId=%@", compNo, self.deptNo, jsonData, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getOrganization"]];
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if([session start]){
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } else {
        NSString *paramString = [NSString stringWithFormat:@"compNo=%@&deptNo=%@&retVal=""&currentUserNos=%@&dvcId=%@", compNo, self.deptNo, jsonData, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getOrganization"]];
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if([session start]){
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
    }
}

#pragma mark - UINavigationBar Button Action
- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    //value(flag)=Y 인 DeptNo 또는 UserNo를 가져옴
    NSMutableArray *userArr = [NSMutableArray array];
    NSMutableArray *deptArr = [NSMutableArray array];
    
    [userArr addObject:[NSString stringWithFormat:@"%@", myUserNo]];
    
    BOOL flag=NO;
    
    NSArray *dArr = [self.sectionCheckDictionary allKeys];
    for (int i=0; i<dArr.count; i++) {
        NSDictionary *dic = [self.sectionCheckDictionary objectForKey:dArr[i]];
        NSString *str = [dic objectForKey:@"FLAG"];
        if ([str isEqualToString:@"Y"]) {
            [deptArr addObject:dArr[i]];
            flag=YES;
        }
    }
    
    NSInteger deptCnt = deptArr.count;
    NSArray *uArr = [self.rowCheckDictionary allKeys];
    for(int i=0; i<uArr.count; i++){
        NSString *str = [self.rowCheckDictionary objectForKey:uArr[i]];
        
        if([uArr[i] intValue]>2){
            if([str isEqualToString:@"Y"]) {
                flag=YES;
                if(![[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", uArr[i]]]){
                    
                    NSDictionary *dict = [rowCheckDic2 objectForKey:uArr[i]];
                    NSString *upNode = [dict objectForKey:@"UP_NODE_NO"];
                    
                    if(deptCnt>0){
                        for(int k=0; k<deptCnt; k++){
                            if(![[deptArr objectAtIndex:k] isEqualToString:[NSString stringWithFormat:@"%@", upNode]]){
                                [userArr addObject:uArr[i]];
                            }
                        }
                    } else {
                        [userArr addObject:uArr[i]];
                    }
                    
                }
            }
        }
    }
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    [resultDic setObject:deptArr forKey:@"depts"];
    [resultDic setValue:userArr forKey:@"users"];
    
    if(!flag){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"check_user_null", @"check_user_null") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        if([self.fromSegue isEqualToString:@"CHAT_SIDE_ADD_USER_PUSH"]){
            [self dismissViewControllerAnimated:YES completion:nil];
            [self saveChatAttn:resultDic];
            
        } else if([self.fromSegue isEqualToString:@"CHAT_SIDE_NEW_ROOM_PUSH"]){
            for(int i=0; i<self.userArr.count; i++){
                NSString *userNo = [[self.userArr objectAtIndex:i]objectForKey:@"USER_NO"];
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
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&attendants=%@&inviteMode=%@&inviteRef1=%@&dvcId=%@", userID, userNo, jsonData,inviteMode, inviteRef1, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
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
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
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
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNm=%@&roomNo=%@&attendants=%@&inviteMode=%@&inviteRef1=%@&dvcId=%@", userID, decodeUserNm, self.roomNo, jsonData, inviteMode, inviteRef1, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatAttn"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    mfURLSessionFlag = NO;
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSDictionary *dic = session.returnDictionary;
        
        if ([[dic objectForKey:@"RESULT"]isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"saveChatInfo"]) {
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
                    
                } else {
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatRoom" object:nil userInfo:newChatDic];
                    }];
                }
                
                if([self.fromSegue isEqualToString:@"CHAT_SIDE_NEW_ROOM_PUSH"]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_AddUserNewChatRoom" object:nil userInfo:newChatDic];
                }
                
            } else if ([wsName isEqualToString:@"saveChatAttn"]) {
                NSDictionary *dataSet = [dic objectForKey:@"DATASET"];
                NSString *roomName = [dataSet objectForKey:@"ROOM_NM"];
                NSString *decodeRoomName = [NSString urlDecodeString:roomName];
                //NSString *roomNo = [dataSet objectForKey:@"ROOM_NO"];
                //NSArray *users = [dataSet objectForKey:@"USERS"];
                
                NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
                NSString *decodeUserNm = [NSString urlDecodeString:userNm];
                
                if([decodeRoomName rangeOfString:decodeUserNm].location != NSNotFound){
                    decodeRoomName = [decodeRoomName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", decodeUserNm] withString:@""];
                }
                
            } else if ([wsName isEqualToString:@"getOrganization"]) {
                if ([self.deptNo isEqualToString:@"0"]) {
                    NSArray *array = [dic objectForKey:@"DATASET"];
                    
                    self.sectionArray = [NSMutableArray array];
                    for (int i=0; i<array.count; i++) {
                        NSMutableDictionary *dataSet = [array[i] mutableCopy];
                        [dataSet setObject:@"Y" forKey:@"IS_VIEW"];
                        [dataSet setObject:@"N" forKey:@"IS_OPEN"];
                        [dataSet setObject:@"N" forKey:@"IS_CHECK"];
                        [dataSet setObject:[NSNumber numberWithInt:0] forKey:@"LEVEL"];
                        [self.sectionArray addObject:dataSet];
                        
                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                        [tmpDic setObject:@"N" forKey:@"FLAG"];
                        [tmpDic setObject:[dataSet objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                        [tmpDic setObject:[dataSet objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                        [tmpDic setObject:[dataSet objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                        [tmpDic setObject:[dataSet objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                        
                        [self.sectionCheckDictionary setObject:tmpDic forKey:[dataSet objectForKey:@"NODE_NO"]];
                        [self.sectionsStates addObject:@NO];
                        [self.tableView reloadData];
                    }
                    
                }else{
                    NSMutableArray *newArray = [NSMutableArray arrayWithArray:[dic objectForKey:@"DATASET"]];
                    for(int i=0; i<newArray.count; i++){
                        NSString *profileImg = [NSString urlDecodeString:[[newArray objectAtIndex:i]objectForKey:@"NODE_IMG"]];
                        if(![profileImg isEqualToString:@""]){
                            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[profileImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
                            NSData *imageData = UIImagePNGRepresentation(thumbImage);
                            
                            NSRange range = [profileImg rangeOfString:@"/" options:NSBackwardsSearch];
                            NSString *thumbfileName = [profileImg substringFromIndex:range.location+1];
                            
                            NSString *tmpPath = NSTemporaryDirectory();
                            NSString *imagePath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",thumbfileName]];
                            [imageData writeToFile:imagePath atomically:YES];
                        }
                    }
                    
                    if (newArray.count>0) {
                        NSDictionary *newDic = [newArray objectAtIndex:0];
                        int startIndex = 0;
                        
                        NSNumber *upNodeLevel;
                        for (int i=0; i<self.sectionArray.count; i++) {
                            NSDictionary *dataSet = [self.sectionArray objectAtIndex:i];
                            if ([[dataSet objectForKey:@"NODE_NO"] isEqual:[newDic objectForKey:@"UP_NODE_NO"]]) {
                                startIndex = i;
                                upNodeLevel = [dataSet objectForKey:@"LEVEL"];
                                break;
                            }
                        }
                        
                        int insertStartIndext = startIndex;
                        //NSInteger sectionIndex = startIndex;
                        NSString *key = [NSString stringWithFormat:@"%d",startIndex];
                        NSNumber *currentLevel = [NSNumber numberWithInt:[upNodeLevel intValue]+1];
                        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
                        NSMutableArray *tmpArray = [NSMutableArray array];
                        NSMutableArray *insertArray = [NSMutableArray array];
                        
                        int sectionCount = 0;
                        NSMutableArray *sectionInsertArray = [NSMutableArray array];
                        
                        for (int i=1; i<=newArray.count; i++) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[newArray objectAtIndex:i-1]];
                            
                            self.testDic = [[NSMutableDictionary alloc]init];
                            [self.testDic setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                            [self.testDic setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                            
                            if ([[dic objectForKey:@"NODE_TY"] isEqualToString:@"USER"]) {
                                [dic setObject:@"N" forKey:@"IS_OPEN"];
                                [dic setObject:@"N" forKey:@"IS_CHECK"];
                                [dic setObject:currentLevel forKey:@"LEVEL"];
                                [dic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                
                                if ([self.rowCheckDictionary objectForKey:[dic objectForKey:@"NODE_NO"]]==nil) {
                                    NSDictionary *tmp = [self.sectionCheckDictionary objectForKey:[NSNumber numberWithInteger:[self.deptNo integerValue]]];
                                    
                                    if([[tmp objectForKey:@"FLAG"] boolValue]){
                                        [self.rowCheckDictionary setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                        [dic setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        rowCheckDic1 = [NSMutableDictionary dictionary];
                                        [rowCheckDic1 setObject:@"Y" forKey:@"FLAG"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [rowCheckDic2 setObject:rowCheckDic1 forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                    }else{
                                        [self.rowCheckDictionary setObject:@"N" forKey:[dic objectForKey:@"NODE_NO"]];
                                        [dic setObject:@"N" forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        rowCheckDic1 = [NSMutableDictionary dictionary];
                                        [rowCheckDic1 setObject:@"N" forKey:@"FLAG"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [rowCheckDic2 setObject:rowCheckDic1 forKey:[dic objectForKey:@"NODE_NO"]];
                                    }
                                } else {
                                    NSDictionary *tmp = [self.sectionCheckDictionary objectForKey:[NSNumber numberWithInteger:[self.deptNo integerValue]]];
                                    if([[tmp objectForKey:@"FLAG"] boolValue]){
                                        [self.rowCheckDictionary setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                        [dic setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        rowCheckDic1 = [NSMutableDictionary dictionary];
                                        [rowCheckDic1 setObject:@"Y" forKey:@"FLAG"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [rowCheckDic1 setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [rowCheckDic2 setObject:rowCheckDic1 forKey:[dic objectForKey:@"NODE_NO"]];
                                    }
                                }
                                [insertArray addObject:dic];
                                
                                [self.testDic2 setObject:self.testDic forKey:[dic objectForKey:@"NODE_NO"]];
                                
                            } else if ([[dic objectForKey:@"NODE_TY"] isEqualToString:@"DEPT"]) {
                                sectionCount++;
                                [sectionInsertArray addObject:@NO];
                                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:newArray[i-1]];
                                [dic setObject:@"Y" forKey:@"IS_VIEW"];
                                [dic setObject:@"N" forKey:@"IS_OPEN"];
                                [dic setObject:@"N" forKey:@"IS_CHECK"];
                                [dic setObject:currentLevel forKey:@"LEVEL"];
                                [dic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                
                                [tmpArray addObject:dic];
                                [indexes addIndex:++startIndex];
                                if ([self.sectionCheckDictionary objectForKey:[dic objectForKey:@"NODE_NO"]]==nil) {
                                    NSDictionary *tmp = [self.sectionCheckDictionary objectForKey:[NSNumber numberWithInteger:[self.deptNo integerValue]]];
                                    if([[tmp objectForKey:@"FLAG"] boolValue]){
                                        
                                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                                        [tmpDic setObject:@"Y" forKey:@"FLAG"];
                                        [tmpDic setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                                        [self.sectionCheckDictionary setObject:tmpDic forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        [dic setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                        [dic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                        
                                    }else{
                                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                                        [tmpDic setObject:@"N" forKey:@"FLAG"];
                                        [tmpDic setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                                        [self.sectionCheckDictionary setObject:tmpDic forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        [dic setObject:@"N" forKey:[dic objectForKey:@"NODE_NO"]];
                                    }
                                }else{
                                    //already
                                    NSDictionary *tmp = [self.sectionCheckDictionary objectForKey:[NSNumber numberWithInteger:[self.deptNo integerValue]]];
                                    if([[tmp objectForKey:@"FLAG"] boolValue]){
                                        
                                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                                        [tmpDic setObject:@"Y" forKey:@"FLAG"];
                                        [tmpDic setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                                        [tmpDic setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                                        [tmpDic setObject:[dic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                                        [self.sectionCheckDictionary setObject:tmpDic forKey:[dic objectForKey:@"NODE_NO"]];
                                        
                                        [dic setObject:@"Y" forKey:[dic objectForKey:@"NODE_NO"]];
                                    }
                                }
                            }
                        }
                        
                        if(sectionCount>0){
                            NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(insertStartIndext+1, sectionCount)];
                            [self.sectionsStates insertObjects:sectionInsertArray atIndexes:indexSet];
                        }
                        
                        if (insertArray.count>0) {
                            [self.rowDictionary setObject:insertArray forKey:key];
                        }
                        // 섹션이 추가 되면 추가된 만큼 self.rowDictionary에 있는 키값을 증가 시켜줘야됨
                        if (tmpArray.count>0) {
                            NSArray *allKeys = [self.rowDictionary allKeys];
                            for(int i=0; i<allKeys.count; i++){
                                NSNumber *key = [allKeys objectAtIndex:i];
                                if(indexes.firstIndex <= key.intValue){
                                    //indexes.count
                                    NSArray *arr = [NSArray arrayWithArray:[self.rowDictionary objectForKey:key]];
                                    //int indexCount = indexes.count;
                                    NSNumber *indexCount = [NSNumber numberWithUnsignedInteger:indexes.count];
                                    NSString *newKey = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:key.intValue+indexCount.intValue]];
                                    [self.rowDictionary setObject:arr forKey:newKey];
                                    [self.rowDictionary removeObjectForKey:key];
                                }
                            }
                            [self.sectionArray insertObjects:tmpArray atIndexes:indexes];
                            
                        }
                        
                        [self.tableView reloadData];
                    }
                }
            }
            
        } else {
            if ([wsName isEqualToString:@"saveChatInfo"] || [wsName isEqualToString:@"saveChatAttn"]) {
                NSString *message = [dic objectForKey:@"MESSAGE"];
                if([message isEqualToString:@"NO_CHAT_TARGET"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"check_user_null", @"check_user_null") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}

- (int)getRowCount:(NSInteger)section{
    int count=0;
    @try {
        count = (int)[[self.rowDictionary objectForKey:[NSString stringWithFormat:@"%ld",section]] count];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    } @finally{
        return count;
    }
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int nbSection = 0;
    for (int i=0; i<self.sectionArray.count; i++) {
        NSDictionary *dic = self.sectionArray[i];
        if ([[dic objectForKey:@"IS_VIEW"] boolValue]) {
            nbSection++;
        }
    }
    return nbSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[self.sectionsStates objectAtIndex:section] boolValue]){
        int rowCount = [self getRowCount:section];
        return rowCount;
        
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr = [self.rowDictionary objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]];
    NSDictionary *dic = [arr objectAtIndex:indexPath.row];
    
    NSString *nodeNm =[NSString urlDecodeString:[dic objectForKey:@"NODE_NM"]];
    NSNumber *level = [dic objectForKey:@"LEVEL"];
    
    NSString *attatchString = @"";
    
    ChatUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell" forIndexPath:indexPath];
    cell.userImgView.image = nil;
    NSString *profileImg = [NSString urlDecodeString:[[arr objectAtIndex:indexPath.row]objectForKey:@"NODE_IMG"]];
    if(![profileImg isEqualToString:@""]){
        //썸네일 로컬저장
        //        UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString urlDecodeString:profileImg]]]];
        //        NSData *imageData = UIImagePNGRepresentation(thumbImage);
        //
        //        NSRange range = [profileImg rangeOfString:@"/" options:NSBackwardsSearch];
        //        NSString *thumbfileName = [profileImg substringFromIndex:range.location+1];
        //
        //        NSString *tmpPath = NSTemporaryDirectory();
        //        NSString *imagePath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",thumbfileName]];
        //        [imageData writeToFile:imagePath atomically:YES];
        
        NSRange range = [profileImg rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *profileName = [profileImg substringFromIndex:range.location+1];
        
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *imagePath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",profileName]];
        
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:data];
        
        userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :image];
        
    } else {
        userImg = [UIImage imageNamed:@"profile_default.png"];
    }
    
    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
    cell.userImgView.clipsToBounds = YES;
    cell.userImgView.backgroundColor = [UIColor clearColor];
    cell.userImgView.image = userImg;
    cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImgView.layer.borderWidth = 0.3;
    
    cell.nodeNameLabel.text = [NSString stringWithFormat:@"%@%@",attatchString,nodeNm];
    cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
    
    //위치초기화
    [cell.arrowButton setFrame:CGRectMake(8.0, cell.frame.size.height/2 - cell.arrowButton.frame.size.height/2, cell.arrowButton.frame.size.width, cell.arrowButton.frame.size.height)];
    [cell.userImgView setFrame:CGRectMake(cell.arrowButton.frame.size.width*[level intValue] + 20, cell.frame.size.height/2 - cell.userImgView.frame.size.height/2, cell.userImgView.frame.size.width, cell.userImgView.frame.size.height)];
    [cell.nodeNameLabel setFrame:CGRectMake(cell.arrowButton.frame.origin.x + cell.userImgView.frame.size.width + cell.userImgView.frame.size.width, cell.frame.size.height/2 - cell.nodeNameLabel.frame.size.height/2, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
    
    //레벨에 따라 위치변경
    for (int i=0; i<[level intValue]; i++) {
        [cell.arrowButton setFrame:CGRectMake(cell.arrowButton.frame.size.width*[level intValue], cell.frame.size.height/2 - cell.arrowButton.frame.size.height/2, cell.arrowButton.frame.size.width, cell.arrowButton.frame.size.height)];
        
        [cell.userImgView setFrame:CGRectMake(cell.arrowButton.frame.size.width*[level intValue] + 20, cell.frame.size.height/2 - cell.userImgView.frame.size.height/2, cell.userImgView.frame.size.width, cell.userImgView.frame.size.height)];
        
        [cell.nodeNameLabel setFrame:CGRectMake(cell.arrowButton.frame.origin.x + cell.userImgView.frame.size.width + cell.userImgView.frame.size.width, cell.frame.size.height/2 - cell.nodeNameLabel.frame.size.height/2, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
    }
    
    cell.checkButton.tag = [[dic objectForKey:@"NODE_NO"] intValue];
    cell.arrowButton.tag = indexPath.row;
    [cell.checkButton addTarget:self action:@selector(touchedRowCheckButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([[self.rowCheckDictionary objectForKey:[dic objectForKey:@"NODE_NO"]] boolValue]) {
        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
    }else{
        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_false.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic = [self.sectionArray objectAtIndex:section];
    
    NSString *nodeNm =[NSString urlDecodeString:[dic objectForKey:@"NODE_NM"]];
    NSNumber *level = [dic objectForKey:@"LEVEL"];
    
    NSString *attatchString = @"";
    
    ChatUserListCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell"];
    [cell.arrowButton setFrame:CGRectMake(8.0, cell.frame.size.height/2 - cell.arrowButton.frame.size.height/2, cell.arrowButton.frame.size.width, cell.arrowButton.frame.size.height)];
    [cell.nodeNameLabel setFrame:CGRectMake(cell.arrowButton.frame.origin.x + cell.arrowButton.frame.size.width + 10, cell.frame.size.height/2 - cell.nodeNameLabel.frame.size.height/2, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
    
    [cell.userImgView setFrame:CGRectMake(cell.arrowButton.frame.size.width*[level intValue], cell.frame.size.height/2 - cell.arrowButton.frame.size.height/2, 0.0, 0.0)];
    
    for (int i=0; i<[level intValue]; i++) {
        [cell.arrowButton setFrame:CGRectMake(cell.arrowButton.frame.size.width*[level intValue] + 10, cell.frame.size.height/2 - cell.arrowButton.frame.size.height/2, cell.arrowButton.frame.size.width, cell.arrowButton.frame.size.height)];
        
        [cell.nodeNameLabel setFrame:CGRectMake(cell.arrowButton.frame.origin.x + cell.arrowButton.frame.size.width + 10, cell.frame.size.height/2 - cell.nodeNameLabel.frame.size.height/2, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
    }
    
    cell.nodeNameLabel.text = [NSString stringWithFormat:@"%@%@",attatchString,nodeNm];
    cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
    cell.checkButton.tag = section;
    cell.arrowButton.tag = section;
    [cell.checkButton addTarget:self action:@selector(touchedSectionCheckButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[dic objectForKey:@"IS_OPEN"] boolValue]) {
        [cell.arrowButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_open.png"] scaledToMaxWidth:15]];
    }else{
        if(level > 0){
            [cell.arrowButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:15]];
        } else {
            [cell.arrowButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:15]];
            
        }
    }
    
    NSDictionary *tmpDic = [self.sectionCheckDictionary objectForKey:[dic objectForKey:@"NODE_NO"]];
    
    if ([[tmpDic objectForKey:@"FLAG"] boolValue]) {
        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
    }else{
        [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_false.png"] scaledToMaxWidth:24.0f] forState:UIControlStateNormal];
    }
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    UIView *view = cell.contentView;
    if (self.shouldHandleHeadersTap)
    {
        NSArray* gestures = view.gestureRecognizers;
        BOOL tapGestureFound = NO;
        for (UIGestureRecognizer* gesture in gestures)
        {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            {
                tapGestureFound = YES;
                break;
            }
        }
        
        if (!tapGestureFound)
        {
            [view setTag:section];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        }
    }
    return view;
}

#pragma mark - IBAction
-(void)touchedRowCheckButton:(UIButton *)sender{
    NSString *nodeNo = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    NSNumber *upNodeNo = [[self.testDic2 objectForKey:nodeNo] objectForKey:@"UP_NODE_NO"];
    BOOL flag = [[self.rowCheckDictionary objectForKey:nodeNo] boolValue];
    
    if(upNodeNo!=nil){
        [self.rowCheckDictionary setObject:flag?@"N":@"Y" forKey:nodeNo];
        [rowCheckDic1 setObject:flag?@"N":@"Y" forKey:@"FLAG"];
        [rowCheckDic1 setObject:nodeNo forKey:@"NODE_NO"];
        [rowCheckDic1 setObject:upNodeNo forKey:@"UP_NODE_NO"];
        [rowCheckDic2 setObject:rowCheckDic1 forKey:nodeNo];
        
        //로우선택 시 섹션이 선택되어있을경우 상위체크해제
        if(self.sectionCheckDictionary.count>0){
            //상위섹션찾기
            [self findHighSection:upNodeNo];
            
            NSDictionary *sectionDic = [NSDictionary dictionary];
            for(int i=0; i<highSectionArray.count; i++){
                sectionDic = [self.sectionCheckDictionary objectForKey:[highSectionArray objectAtIndex:i]];
                if(sectionDic!=nil){
                    //섹션선택해제
                    NSMutableDictionary *sectionCheckTmp = [NSMutableDictionary dictionary];
                    [sectionCheckTmp setObject:@"N" forKey:@"FLAG"];
                    [sectionCheckTmp setObject:[sectionDic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                    [sectionCheckTmp setObject:[sectionDic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                    [sectionCheckTmp setObject:[sectionDic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                    [sectionCheckTmp setObject:[sectionDic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                    
                    [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:[highSectionArray objectAtIndex:i]];
                }
            }
        }
        
        [self levelRowExistCheck:upNodeNo];
        [self levelSectionExistCheck:upNodeNo];
        
        if(flagRowNoArr.count < 1 && flagSectionNoArr.count < 1){
            //로우 모두체크되었으면 섹션체크
            for(int i=(int)self.sectionArray.count-1; i>=0; i--){
                NSDictionary *section = [self.sectionArray objectAtIndex:i];
                NSNumber *sectionNodeNo = [section objectForKey:@"NODE_NO"];
                
                //선택한로우의 상위섹션들 모두 찾아서 레벨 1이상인 섹션의 값이 모두 y이면 레벨0인 섹션체크
                for(int j=0; j<highSectionArray.count; j++){
                    if([[highSectionArray objectAtIndex:j] intValue] == [sectionNodeNo intValue]){
                        [self levelRowExistCheck:sectionNodeNo];
                        [self levelSectionExistCheck:sectionNodeNo];
                        
                        if(flagRowNoArr.count < 1 && flagSectionNoArr.count < 1 ){
                            [self sectionCheckFlagY:section];
                        }
                    }
                }
            }
        }
        [self.tableView reloadData];
    }
}

-(void)sectionCheckFlagY :(NSDictionary *)section{
    NSMutableDictionary *sectionCheckTmp = [NSMutableDictionary dictionary];
    [sectionCheckTmp setObject:@"Y" forKey:@"FLAG"];
    [sectionCheckTmp setObject:[section objectForKey:@"UP_NODE_NO"]  forKey:@"UP_NODE_NO"];
    [sectionCheckTmp setObject:[section objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
    [sectionCheckTmp setObject:[section objectForKey:@"LEVEL"] forKey:@"LEVEL"];
    [sectionCheckTmp setObject:[section objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
    
    [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:[section objectForKey:@"NODE_NO"]];
}

-(int)getTotalLevel{
    int maxLevel=0;
    NSArray *arr = [self.sectionCheckDictionary allValues];
    for(int i=0; i<arr.count; i++){
        NSDictionary *sectionDic = [arr objectAtIndex:i];
        NSNumber *sectionLevel = [sectionDic objectForKey:@"LEVEL"];
        
        if (sectionLevel.intValue>maxLevel) {
            maxLevel = sectionLevel.intValue;
        }
    }
    return maxLevel;
}
-(NSArray *)getLowNodeNoArray:(NSNumber *)nodeNo{
    int count = [self getTotalLevel];
    NSMutableArray *lowNodeNoArray = [NSMutableArray arrayWithArray:[self recursionNodeNoArray:nodeNo]];
    for(int i=1; i<count; i++){
        for(int j=0; j<lowNodeNoArray.count; j++){
            [lowNodeNoArray addObjectsFromArray:[self recursionNodeNoArray:[lowNodeNoArray objectAtIndex:j]]];
        }
    }
    return lowNodeNoArray;
}
- (NSArray *)recursionNodeNoArray:(NSNumber *)nodeNo{
    NSMutableArray *lowNodeNoArray = [NSMutableArray array];
    NSArray *arr = [self.sectionCheckDictionary allValues];
    
    for(int i=0; i<arr.count; i++){
        NSDictionary *section = [arr objectAtIndex:i];
        NSNumber *upNodeNo = [section objectForKey:@"UP_NODE_NO"];
        NSNumber *tmpNodeNo = [section objectForKey:@"NODE_NO"];
        if(nodeNo.intValue == upNodeNo.intValue){
            [lowNodeNoArray addObject:tmpNodeNo];
        }
    }
    return lowNodeNoArray;
}

-(void)touchedSectionCheckButton:(UIButton *)sender{
    NSDictionary *dic = [self.sectionArray objectAtIndex:sender.tag];
    NSNumber *nodeNo = [dic objectForKey:@"NODE_NO"];
    NSNumber *upNodeNo = [dic objectForKey:@"UP_NODE_NO"];
    NSMutableDictionary *tmpDic = [[self.sectionCheckDictionary objectForKey:nodeNo] mutableCopy];
    BOOL flag = [[tmpDic objectForKey:@"FLAG"] boolValue];
    
    NSMutableDictionary *sectionCheckTmp = [NSMutableDictionary dictionary];
    [sectionCheckTmp setObject:flag?@"N":@"Y" forKey:@"FLAG"];
    [sectionCheckTmp setObject:[dic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
    [sectionCheckTmp setObject:[dic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
    [sectionCheckTmp setObject:[dic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
    [sectionCheckTmp setObject:[dic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
    [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:[dic objectForKey:@"NODE_NO"]];
    
    NSNumber *nodeLevel = [dic objectForKey:@"LEVEL"];
    NSMutableArray *lowNodeNoArray = [NSMutableArray array];
    
    //현재 존재하는 하위 섹션의 체크 설정
    for (int index=0; index<self.sectionArray.count; index++) {
        NSDictionary *lowSection = [self.sectionArray objectAtIndex:index];
        NSNumber *lowNodeNo = [lowSection objectForKey:@"NODE_NO"];
        NSNumber *lowUpNodeNo = [lowSection objectForKey:@"UP_NODE_NO"];
        NSNumber *lowNodeLevel = [lowSection objectForKey:@"LEVEL"];
        
        NSMutableDictionary *sectionCheckTmp = [NSMutableDictionary dictionary];
        [sectionCheckTmp setObject:flag?@"N":@"Y" forKey:@"FLAG"];
        [sectionCheckTmp setObject:[lowSection objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
        [sectionCheckTmp setObject:[lowSection objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
        [sectionCheckTmp setObject:[lowSection objectForKey:@"LEVEL"] forKey:@"LEVEL"];
        [sectionCheckTmp setObject:[lowSection objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
        
        if (lowNodeLevel.intValue>nodeLevel.intValue){
            if ([nodeNo intValue] == [lowUpNodeNo intValue]) {
                [lowNodeNoArray addObject:lowNodeNo];
                [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:lowNodeNo];
                
            } else{
                for(int i=0; i<lowNodeNoArray.count; i++){
                    if ([[lowNodeNoArray objectAtIndex:i] intValue] == [lowUpNodeNo intValue]) {
                        [lowNodeNoArray addObject:lowNodeNo];
                        [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:lowNodeNo];
                    }
                }
            }
        }
    }
    
    //현재 보이는 하위 로우의 체크 설정
    NSArray *rowVal = [self.rowDictionary allValues];
    NSMutableArray *rowArr = [NSMutableArray array];
    NSMutableArray *checkArray = [NSMutableArray array];
    for(int i=0; i<rowVal.count; i++){
        NSArray *rowVal2 = [rowVal objectAtIndex:i];
        
        for(int j=0; j<rowVal2.count; j++){
            [rowArr addObject:[rowVal2 objectAtIndex:j]];
        }
    }
    for(int index=0; index<rowArr.count; index++){
        NSDictionary *lowSection = [rowArr objectAtIndex:index];
        //NSLog(@"lowSection : %@", lowSection);
        NSNumber *lowNodeNo = [lowSection objectForKey:@"NODE_NO"];
        NSNumber *lowUpNodeNo = [lowSection objectForKey:@"UP_NODE_NO"];
        NSNumber *lowNodeLevel = [lowSection objectForKey:@"LEVEL"];
        
        if (lowNodeLevel.intValue>nodeLevel.intValue){
            if ([nodeNo intValue] == [lowUpNodeNo intValue]) {
                [self.rowCheckDictionary setObject:flag?@"N":@"Y" forKey:lowNodeNo];
                [rowCheckDic1 setObject:flag?@"N":@"Y" forKey:@"FLAG"];
                [rowCheckDic1 setObject:lowNodeNo forKey:@"NODE_NO"];
                [rowCheckDic1 setObject:lowUpNodeNo forKey:@"UP_NODE_NO"];
                [rowCheckDic2 setObject:rowCheckDic1 forKey:lowNodeNo];
                
            } else {
                //하위로우의 업노드넘버가 lowNodeNoArray의 섹션넘버와 같으면
                for(int i=0; i<lowNodeNoArray.count; i++){
                    if ([[lowNodeNoArray objectAtIndex:i] intValue] == [lowUpNodeNo intValue]) {
                        [checkArray addObject:lowNodeNo];
                    }
                }
            }
        }
    }
    for (NSNumber *number in checkArray) {
        [self.rowCheckDictionary setObject:flag?@"N":@"Y" forKey:number];
        
        [rowCheckDic1 setObject:flag?@"N":@"Y" forKey:@"FLAG"];
        [rowCheckDic1 setObject:number forKey:@"NODE_NO"];
        [rowCheckDic1 setObject:upNodeNo forKey:@"UP_NODE_NO"];
        [rowCheckDic2 setObject:rowCheckDic1 forKey:number];
    }
    
    
    [self getLowNodeNoArray:nodeNo];
    
    //현재 안보이는 하위 섹션의 체크 설정
    NSMutableArray *lowNodeNoArray2 = [NSMutableArray arrayWithArray:[self getLowNodeNoArray:nodeNo]];
    NSMutableArray *checkArray2 = [NSMutableArray arrayWithArray:[self getLowNodeNoArray:nodeNo]];
    
    for (NSNumber *number in checkArray2) {
        NSMutableDictionary *tmp = [self.sectionCheckDictionary objectForKey:number];
        [tmp setObject:flag?@"N":@"Y" forKey:@"FLAG"];
    }
    
    //현재 안보이는 하위 로우의 체크 설정
    NSMutableDictionary *tmpRowDic = [self.rowCheckDictionary mutableCopy];
    for(int i=0; i<[tmpRowDic allKeys].count; i++){
        NSDictionary *dict = [self.testDic2 objectForKey:[[tmpRowDic allKeys] objectAtIndex:i]];
        
        if([[dict objectForKey:@"UP_NODE_NO"] isEqual:nodeNo]){
            [self.rowCheckDictionary setObject:flag?@"N":@"Y" forKey:[dict objectForKey:@"NODE_NO"]];
            
            [rowCheckDic1 setObject:flag?@"N":@"Y" forKey:@"FLAG"];
            [rowCheckDic1 setObject:[dict objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
            [rowCheckDic1 setObject:upNodeNo forKey:@"UP_NODE_NO"];
            [rowCheckDic2 setObject:rowCheckDic1 forKey:[dict objectForKey:@"NODE_NO"]];
            
        } else {
            for(int i=0; i<lowNodeNoArray2.count; i++){
                if ([[lowNodeNoArray2 objectAtIndex:i] intValue] == [[dict objectForKey:@"UP_NODE_NO"] intValue]) {
                    [self.rowCheckDictionary setObject:flag?@"N":@"Y" forKey:[dict objectForKey:@"NODE_NO"]];
                    
                    [rowCheckDic1 setObject:flag?@"N":@"Y" forKey:@"FLAG"];
                    [rowCheckDic1 setObject:[dict objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                    [rowCheckDic1 setObject:upNodeNo forKey:@"UP_NODE_NO"];
                    [rowCheckDic2 setObject:rowCheckDic1 forKey:[dict objectForKey:@"NODE_NO"]];
                }
            }
        }
    }
    
    
    //섹션선택 시 상위섹션이 선택되어있을경우 상위체크해제
    //상위섹션찾기
    [self findHighSection:upNodeNo];
    
    if(self.sectionCheckDictionary.count>0){
        NSDictionary *sectionDic = [NSDictionary dictionary];
        for(int i=0; i<highSectionArray.count; i++){
            sectionDic = [self.sectionCheckDictionary objectForKey:[highSectionArray objectAtIndex:i]];
            if(sectionDic!=nil){
                //섹션선택해제
                NSMutableDictionary *sectionCheckTmp = [NSMutableDictionary dictionary];
                [sectionCheckTmp setObject:@"N" forKey:@"FLAG"];
                [sectionCheckTmp setObject:[sectionDic objectForKey:@"UP_NODE_NO"] forKey:@"UP_NODE_NO"];
                [sectionCheckTmp setObject:[sectionDic objectForKey:@"NODE_NM"] forKey:@"NODE_NM"];
                [sectionCheckTmp setObject:[sectionDic objectForKey:@"LEVEL"] forKey:@"LEVEL"];
                [sectionCheckTmp setObject:[sectionDic objectForKey:@"NODE_NO"] forKey:@"NODE_NO"];
                
                [self.sectionCheckDictionary setObject:sectionCheckTmp forKey:[highSectionArray objectAtIndex:i]];
            }
        }
    }
    
    //하위섹션/로우 모두체크 시 상위섹션체크
    [self levelRowExistCheck:upNodeNo];
    [self levelSectionExistCheck:upNodeNo];
    
    if(flagRowNoArr.count < 1 && flagSectionNoArr.count < 1){
        //로우 모두체크되었으면 섹션체크
        for(int i=(int)self.sectionArray.count-1; i>=0; i--){
            NSDictionary *section = [self.sectionArray objectAtIndex:i];
            NSNumber *sectionNodeNo = [section objectForKey:@"NODE_NO"];
            
            for(int j=0; j<highSectionArray.count; j++){
                if([[highSectionArray objectAtIndex:j] intValue] == [sectionNodeNo intValue]){
                    [self levelRowExistCheck:sectionNodeNo];
                    [self levelSectionExistCheck:sectionNodeNo];
                    
                    if(flagRowNoArr.count < 1 && flagSectionNoArr.count < 1 ){
                        [self sectionCheckFlagY:section];
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void)findHighSection :(NSNumber *)upNodeNo{
    //상위섹션찾기
    highSectionArray = [NSMutableArray array];
    NSArray *highArr = [self.sectionCheckDictionary allValues];
    for (int i=0; i<highArr.count; i++) {
        NSDictionary *highSection = [highArr objectAtIndex:i];
        NSNumber *highNodeNo = [highSection objectForKey:@"NODE_NO"];
        NSNumber *highUpNodeNo = [highSection objectForKey:@"UP_NODE_NO"];
        
        if([upNodeNo intValue] == [highNodeNo intValue]){
            [highSectionArray addObject:highUpNodeNo];
            [highSectionArray addObject:upNodeNo];
        } else {
            for(int i=0; i<highSectionArray.count; i++){
                if([[highSectionArray objectAtIndex:i] intValue] == [highNodeNo intValue]){
                    [highSectionArray addObject:highUpNodeNo];
                }
            }
        }
    }
    return;
}

- (void)levelRowExistCheck :(NSNumber *)upNodeNo{
    //같은레벨에 있는 로우찾기
    NSArray *rowDicArr = [self.rowDictionary allValues];
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for(int i=0; i<rowDicArr.count; i++){
        NSArray *rowVal = [rowDicArr objectAtIndex:i];
        
        for(int j=0; j<rowVal.count; j++){
            [tmpArray addObject:[rowVal objectAtIndex:j]];
        }
    }
    
    equalRowArr = [NSMutableArray array];
    for(int index=0; index<tmpArray.count; index++){
        NSDictionary *section = [tmpArray objectAtIndex:index];
        NSNumber *sectionNodeNo = [section objectForKey:@"NODE_NO"];
        NSNumber *sectionUpNodeNo = [section objectForKey:@"UP_NODE_NO"];
        
        if([upNodeNo intValue] == [sectionNodeNo intValue]){
            
        } else {
            if([upNodeNo intValue] == [sectionUpNodeNo intValue]){
                [equalRowArr addObject:sectionNodeNo];
            }
        }
    }
    
    flagRowNoArr = [NSMutableArray array];
    for(int i=0; i<equalRowArr.count; i++){
        NSNumber *rowNo = [equalRowArr objectAtIndex:i];
        if([[self.rowCheckDictionary objectForKey:rowNo] isEqualToString:@"N"]){
            [flagRowNoArr addObject:rowNo];
        }
    }
    
    return;
}

- (void)levelSectionExistCheck :(NSNumber *)upNodeNo{
    //같은레벨에 있는 섹션찾기
    equalSectionArr = [NSMutableArray array];
    for(int i=0; i<self.sectionArray.count; i++){
        NSDictionary *section = [self.sectionArray objectAtIndex:i];
        NSNumber *sectionNodeNo = [section objectForKey:@"NODE_NO"];
        NSNumber *sectionUpNodeNo = [section objectForKey:@"UP_NODE_NO"];
        
        if([upNodeNo intValue] == [sectionNodeNo intValue]){
            
        } else {
            //로우와 같은레벨에 있는 섹션
            if([upNodeNo intValue] == [sectionUpNodeNo intValue]){
                [equalSectionArr addObject:sectionNodeNo];
            }
        }
    }
    //NSLog(@"equalSectionArr : %@", equalSectionArr); //선택한로우와 같은레벨에 있는 섹션
    
    flagSectionNoArr = [NSMutableArray array];
    NSArray *arr2 = [self.sectionCheckDictionary allValues];
    for (int i=0; i<arr2.count; i++) {
        NSDictionary *section = [arr2 objectAtIndex:i];
        NSNumber *sectionUpNo = [section objectForKey:@"UP_NODE_NO"];
        NSNumber *sectionNo = [section objectForKey:@"NODE_NO"];
        
        if([upNodeNo intValue] == [sectionUpNo intValue]){
            
            if([[section objectForKey:@"FLAG"] isEqualToString:@"N"]){
                [flagSectionNoArr addObject:sectionNo];
            }
        }
    }
    //NSLog(@"flagSectionNoArr : %@", flagSectionNoArr); //선택한로우와 같은레벨에 있는 섹션 중 체크되지않은 섹션
    
    return;
}

#pragma mark - CollapseTableView
- (void)openSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    if (sectionIndex >= [self.sectionsStates count])
    {
        return;
    }
    
    if ([[self.sectionsStates objectAtIndex:sectionIndex] boolValue])
    {
        return;
    }
    
    if (self.exclusiveSections)
    {
        NSUInteger openedSection = [self openedSection];
        
        [self setSectionAtIndex:sectionIndex open:YES];
        [self setSectionAtIndex:openedSection open:NO];
        
        if(animated)
        {
            NSArray* indexPathsToInsert = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
            NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:openedSection];
            
            UITableViewRowAnimation insertAnimation;
            UITableViewRowAnimation deleteAnimation;
            
            if (openedSection == NSNotFound || sectionIndex < openedSection)
            {
                insertAnimation = UITableViewRowAnimationTop;
                deleteAnimation = UITableViewRowAnimationBottom;
            }
            else
            {
                insertAnimation = UITableViewRowAnimationBottom;
                deleteAnimation = UITableViewRowAnimationTop;
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
            [self.tableView endUpdates];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
    else
    {
        [self setSectionAtIndex:sectionIndex open:YES];
        
        if (animated)
        {
            NSArray* indexPathsToInsert = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
            [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}

- (void)closeSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    [self.tableView beginUpdates];
    
    //////////////////////////////////////////////////
    //섹션 닫기
    //////////////////////////////////////////////////
    NSDictionary *dic = [self.sectionArray objectAtIndex:sectionIndex];
    NSNumber *currNodeNo = [dic objectForKey:@"NODE_NO"];
    NSNumber *currNodeLevel = [dic objectForKey:@"LEVEL"];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.sectionArray];
    NSMutableArray *nodeNoArray = [NSMutableArray array];
    NSMutableArray *removeIndexArray = [NSMutableArray array];
    
    for (int index=0; index<self.sectionArray.count; index++) {
        NSDictionary *lowSection = [self.sectionArray objectAtIndex:index];
        NSNumber *nodeNo = [lowSection objectForKey:@"NODE_NO"];
        NSNumber *upNodeNo = [lowSection objectForKey:@"UP_NODE_NO"];
        NSNumber *nodeLevel = [lowSection objectForKey:@"LEVEL"];
        if (nodeLevel.intValue>currNodeLevel.intValue){
            if ([currNodeNo intValue] == [upNodeNo intValue]) {
                [nodeNoArray addObject:nodeNo];
                [tmpArray removeObject:lowSection];
                [self setSectionAtIndex:index open:NO];
                [removeIndexArray addObject:[NSNumber numberWithInt:index]];
                
            }else{
                for(int i=0; i<nodeNoArray.count; i++){
                    if ([[nodeNoArray objectAtIndex:i] intValue] == [upNodeNo intValue]) {
                        [nodeNoArray addObject:nodeNo];
                        [tmpArray removeObject:lowSection];
                        [self setSectionAtIndex:index open:NO];
                        [removeIndexArray addObject:[NSNumber numberWithInt:index]];
                        
                    }
                }
            }
        }
    }
    
    self.sectionArray = tmpArray;
    
    if (removeIndexArray.count > 0) {
        NSRange range = NSMakeRange([[removeIndexArray objectAtIndex:0] intValue], removeIndexArray.count);
        NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:range];
        //self.rowDictionary 옮겨진 위치로 키값 변경해줘야됨
        /*
         printf("\n==================================================\n");
         printf("closeSection sectionStates : %lu\n",self.sectionsStates.count);
         for (int i=0; i<self.sectionsStates.count; i++) {
         printf(" %d",[[self.sectionsStates objectAtIndex:i] boolValue]);
         }
         printf("\n==================================================\n");
         NSLog(@"self.rowDictionary : %@",self.rowDictionary);
         */
        for(int i=[[removeIndexArray objectAtIndex:0] intValue]; i<self.sectionsStates.count; i++){
            if ([[self.sectionsStates objectAtIndex:i] boolValue]) {
                NSArray *tmpArr = [NSArray arrayWithArray:[self.rowDictionary objectForKey:[NSString stringWithFormat:@"%d",i]]];
                if (tmpArr!=nil) {
                    [self.rowDictionary setObject:tmpArr forKey:[NSString stringWithFormat:@"%lu",i-removeIndexArray.count]];
                    [self.rowDictionary removeObjectForKey:[NSString stringWithFormat:@"%d",i]];
                }
            }
        }
        
        [self.sectionsStates removeObjectsAtIndexes:indexSet];
        for (int i=0; i<removeIndexArray.count; i++) {
            int index = [[removeIndexArray objectAtIndex:i] intValue];
            NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    //////////////////////////////////////////////////
    //로우 닫기
    //////////////////////////////////////////////////
    [self setSectionAtIndex:sectionIndex open:NO];
    
    NSArray* indexPathsToDelete = [self indexPathsForRowsInSectionAtIndex:sectionIndex];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    [self.rowDictionary removeObjectForKey:[NSString stringWithFormat:@"%lu",sectionIndex]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)toggleSection:(NSUInteger)sectionIndex animated:(BOOL)animated
{
    if (sectionIndex >= [self.sectionsStates count])
    {
        return;
    }
    
    BOOL sectionIsOpen = [[self.sectionsStates objectAtIndex:sectionIndex] boolValue];
    NSDictionary *dic = [self.sectionArray objectAtIndex:sectionIndex];
    
    
    if (sectionIsOpen)
    {
        [dic setValue:@"N" forKey:@"IS_OPEN"];
        [self closeSection:sectionIndex animated:YES];
    }
    else
    {
        [dic setValue:@"Y" forKey:@"IS_OPEN"];
        
        [self setSectionAtIndex:sectionIndex open:YES];
        self.deptNo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"NODE_NO"]];
        [self callWebService];
        //[self openSection:sectionIndex animated:animated];
    }
    //[self.tableView reloadData];
}

- (BOOL)isOpenSection:(NSUInteger)sectionIndex
{
    if (sectionIndex >= [self.sectionsStates count])
    {
        return NO;
    }
    return [[self.sectionsStates objectAtIndex:sectionIndex] boolValue];
}

- (void)setExclusiveSections:(BOOL)exclusiveSections
{
    _exclusiveSections = exclusiveSections;
    
    if (self.exclusiveSections)
    {
        NSInteger firstSection = NSNotFound;
        
        for (NSUInteger index = 0 ; index < [self.sectionsStates count] ; index++)
        {
            if ([[self.sectionsStates objectAtIndex:index] boolValue])
            {
                if (firstSection == NSNotFound)
                {
                    firstSection = index;
                }
                else
                {
                    [self closeSection:index animated:YES];
                }
            }
        }
    }
}

#pragma mark - Private methods
- (void)handleTapGesture:(UITapGestureRecognizer*)tap
{
    NSInteger index = tap.view.tag;
    if (index >= 0)
    {
        [self toggleSection:(NSUInteger)index animated:YES];
    }
}

- (NSArray*)indexPathsForRowsInSectionAtIndex:(NSUInteger)sectionIndex
{
    if (sectionIndex >= [self.sectionsStates count])
    {
        return nil;
    }
    
    NSInteger numberOfRows = [self getRowCount:sectionIndex];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < numberOfRows ; i++)
    {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
    }
    
    return array;
}

- (void)setSectionAtIndex:(NSUInteger)sectionIndex open:(BOOL)open
{
    
    if (sectionIndex >= [self.sectionsStates count])
    {
        return;
    }
    [self.sectionsStates replaceObjectAtIndex:sectionIndex withObject:@(open)];
}

- (NSUInteger)openedSection
{
    if (!self.exclusiveSections)
    {
        return NSNotFound;
    }
    
    for (NSUInteger index = 0 ; index < [self.sectionsStates count] ; index++)
    {
        if ([[self.sectionsStates objectAtIndex:index] boolValue])
        {
            return index;
        }
    }
    
    return NSNotFound;
}

@end
