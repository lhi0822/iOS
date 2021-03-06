//
//  MyViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MyViewController.h"

#import "MyTableViewCell.h"

#import "PHLibListViewController.h"
#import "PHLibGridViewController.h"
#import "MyMessageViewController.h"
#import "PostDetailViewController.h"
#import "TaskDetailViewController.h"
#import "NotiChatViewController.h"
#import "MediaAccessViewController.h"
#import "SimplePwdViewController.h"


#define HEADER_HEIGHT 45
#define PROFILE_IMG_SIZE 30

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define REFRESH_TABLEVIEW_DEFAULT_ROW               64.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f
#define kSupplementaryViewID @"SUP_VIEW_ID"
#define MODEL_NAME [[UIDevice currentDevice] modelName]

@interface MyViewController () {
    UIImage *userImg;
    NSString *profileThumbImg;
    
    UIImage *bgImg;
    NSString *profileBgImg;
    
    BOOL isProfile;
    
    NSString *userId;
    NSString *exCompNm;
    AppDelegate *appDelegate;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
    NSArray *dataArr;
    
    NSString *authVal;
    NSUserDefaults *prefs;
}

@end

@implementation MyViewController

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    if (@available(iOS 12.0, *)) {
////        if(UIUserInterfaceStyleDark) return UIStatusBarStyleLightContent;
////        else return UIStatusBarStyleDefault;
//        return UIStatusBarStyleLightContent;
//    } else {
//        return UIStatusBarStyleLightContent;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeProfilePush:) name:@"noti_ChangeProfilePush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RefreshProfilePush:) name:@"noti_RefreshProfilePush" object:nil];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    prefs = [NSUserDefaults standardUserDefaults];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
    
    if([self.fromSegue isEqualToString:@"PROFILE_TO_MY_MODAL"]){
        self.tableBottomConstraint.constant = 0;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
        button.adjustsImageWhenDisabled = NO;
        button.frame = CGRectMake(0, 0, 20, 20);
        [button addTarget:self action:@selector(closeModal:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
        self.navigationItem.hidesBackButton = YES;
        
    } else {
        self.tableBottomConstraint.constant = -44;
        self.navigationItem.hidesBackButton = YES;
        
        UIButton *left1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [left1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_off.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
        [left1 addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBtn1 = [[UIBarButtonItem alloc]initWithCustomView:left1];
        self.navigationItem.leftBarButtonItem = leftBtn1;
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.imgView.frame.size.height, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.imgView addSubview:lineView];
    
    self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.width/2;
    self.profileImgView.clipsToBounds = YES;
    self.profileImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImgView.backgroundColor = [UIColor whiteColor];
    self.profileImgView.userInteractionEnabled = YES;
    self.profileImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImgView.layer.borderWidth = 0.3;
    
    self.editImgButton.layer.cornerRadius = self.editImgButton.frame.size.width/2;
    self.editImgButton.clipsToBounds = YES;
    self.editImgButton.contentMode = UIViewContentModeScaleAspectFill;
    self.editImgButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.editImgButton.layer.borderWidth = 0.3;
    [self.editImgButton addTarget:self action:@selector(imageEditClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.profileBgImgView.clipsToBounds = YES;
    self.profileBgImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileBgImgView.backgroundColor = [UIColor whiteColor];
    self.profileBgImgView.userInteractionEnabled = YES;
    
    self.editBgButton.layer.cornerRadius = self.editBgButton.frame.size.width/2;
    self.editBgButton.clipsToBounds = YES;
    self.editBgButton.contentMode = UIViewContentModeScaleAspectFill;
    [self.editBgButton addTarget:self action:@selector(bgImageEditClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.profileKeyArr = [NSMutableArray array];
    [self.profileKeyArr addObject:NSLocalizedString(@"myinfo_name", @"myinfo_name")];
    [self.profileKeyArr addObject:NSLocalizedString(@"myinfo_status", @"myinfo_status")];
    
    self.accountKeyArr = [NSMutableArray array];
    [self.accountKeyArr addObject:NSLocalizedString(@"myinfo_phone", @"myinfo_phone")];
    [self.accountKeyArr addObject:NSLocalizedString(@"myinfo_comp", @"myinfo_comp")];
    [self.accountKeyArr addObject:NSLocalizedString(@"myinfo_dept", @"myinfo_dept")];
    [self.accountKeyArr addObject:NSLocalizedString(@"myinfo_id", @"myinfo_id")];
    
//    self.notiKeyArr = [NSMutableArray array];
//    [self.notiKeyArr addObject:NSLocalizedString(@"myinfo_noti", @"myinfo_noti")];
    
    self.settingKeyArr = [NSMutableArray array];
    //[self.settingKeyArr addObject:NSLocalizedString(@"myinfo_noti", @"myinfo_noti")];
    [self.settingKeyArr addObject:NSLocalizedString(@"myinfo_image_tab_reordering", @"myinfo_image_tab_reordering")];
    if([[MFSingleton sharedInstance] mediaAuthCheck]) [self.settingKeyArr addObject:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")]; //미디어 접근 권한
    if([[MFSingleton sharedInstance] simplePwd]) [self.settingKeyArr addObject:NSLocalizedString(@"myinfo_set_simple_pwd", @"myinfo_set_simple_pwd")]; //간편비밀번호
    //[self.settingKeyArr addObject:@"게시판 형태 변경"];
    
    self.appInfoKeyArr = [NSMutableArray array];
    [self.appInfoKeyArr addObject:NSLocalizedString(@"myinfo_version", @"myinfo_version")];
    
    self.dataManageKeyArr = [NSMutableArray array];
    [self.dataManageKeyArr addObject:NSLocalizedString(@"myinfo_backup_restore", @"myinfo_backup_restore")];
    //[self.dataManageKeyArr addObject:@"캐시 삭제"];
    
    [self callGetProfile];
    
    if(appDelegate.inactivePostPushInfo.count>0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:appDelegate.inactivePostPushInfo];
//        appDelegate.inactivePostPushInfo=nil;
    }
    if(appDelegate.inactiveChatPushInfo.count>0){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatPush" object:nil userInfo:appDelegate.inactiveChatPushInfo];
//        appDelegate.inactiveChatPushInfo=nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.appPrefs setObject:@"4" forKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]];
    [appDelegate.appPrefs synchronize];
    
    profileThumbImg = @"";
    profileBgImg = @"";
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftSideMenuButtonPressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"exit_program", @"exit_program")
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         if([[MFSingleton sharedInstance] isMDM]){
                                                             appDelegate.mdmCallAPI = @"exitWorkApp";
                                                             [appDelegate exitWorkApp];
                                                         } else {
                                                             exit(0);
//                                                             [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                                                         }
                                                     }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)callGetProfile {
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&dvcId=%@", userNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getProfile"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)settingMyInfo :(NSArray *)dataSet{
    @try {
        //NSString *userId = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"]];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        userId = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"]];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
        NSString *phoneNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PHONE_NO"]];
        profileThumbImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
        //NSString *compName = [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"COMPNM"]]];
        NSString *deptName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DEPT_NM"]];
        profileBgImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
        
        exCompNm = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"]];
        
        self.profileValArr = [NSMutableArray array];
        [self.profileValArr addObject:userName];
        [self.profileValArr addObject:profileMsg];
        
        self.accountValArr = [NSMutableArray array];
        [self.accountValArr addObject:phoneNo];
        [self.accountValArr addObject:exCompNm];
        [self.accountValArr addObject:deptName];
        [self.accountValArr addObject:userId];
        
        appDelegate.currChatRoomNo = nil;
        
        userImg = nil;
        bgImg = nil;
        
        if(![profileThumbImg isEqualToString:@""]){
            userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileThumbImg num:userNo]];
        } else {
            userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[UIImage imageNamed:@"profile_default.png"]];
        }
        self.profileImgView.image = userImg;
        
        if(![profileBgImg isEqualToString:@""]){
            bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.profileBgImgView.frame.size.width, self.profileBgImgView.frame.size.height) :[MFUtil saveThumbImage:@"ProfileBg" path:profileBgImg num:userNo]];
        } else {
            bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.profileBgImgView.frame.size.width, self.profileBgImgView.frame.size.height) :[UIImage imageNamed:@"profile_bg_default_hhi.png"]];
        }
        self.profileBgImgView.image = bgImg;
        
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImg:)];
        [self.profileImgView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileBgImg:)];
        [self.profileBgImgView addGestureRecognizer:tap2];
        
        [self.tableView reloadData];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    @try{
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
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactivePostPushInfo=nil;
}

- (void)noti_NewTaskPush:(NSNotification *)notification {
    @try{
        if(notification.userInfo!=nil){
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
            TaskDetailViewController *vc = (TaskDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            vc.fromSegue = @"NOTI_TASK_DETAIL";
            vc.notiTaskDic = dict;
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


- (void)noti_NewChatPush:(NSNotification *)notification {
    @try{
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
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}

- (void)noti_ChangeProfilePush:(NSNotification *)notification {
    NSLog(@"notification.userInfo : %@", notification.userInfo);

    @try{
        //사진을 썸네일로 해서 많이 깨짐 profileBgImg2 사용하자
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
        NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
        //NSString *profileImg2 = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        //profileThumbImg2 = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_THUMB"]];
        profileThumbImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG_THUMB"]];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        profileBgImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
        //NSString *profileBgThumbImg2 = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BACKGROUND_IMG_THUMB"]];
        
        if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
            
            if(![profileThumbImg isEqualToString:@""]){
                userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileThumbImg num:userNo]];
            } else {
                userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[UIImage imageNamed:@"profile_default.png"]];
            }
            
            if(![profileBgImg isEqualToString:@""]){
                bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.profileBgImgView.frame.size.width, self.profileBgImgView.frame.size.height) :[MFUtil saveThumbImage:@"ProfileBg" path:profileBgImg num:userNo]];
            } else {
                bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.profileBgImgView.frame.size.width, self.profileBgImgView.frame.size.height) :[UIImage imageNamed:@"profile_bg_default_hhi.png"]];
            }
            
            self.profileImgView.image = userImg;
            self.profileBgImgView.image = bgImg;
            
            [self.profileValArr replaceObjectAtIndex:1 withObject:profileMsg];
            [self.tableView reloadData];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_RefreshProfilePush:(NSNotification *)notification {
    NSLog();
    @try{
        [self.tableView reloadData];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapOnProfileImg:(UITapGestureRecognizer*)tap{
    isProfile=true;
    [self imageEditClick];
}

- (void)tapOnProfileBgImg:(UITapGestureRecognizer*)tap{
    isProfile=false;
    [self bgImageEditClick];
}

- (void)imageEditClick {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera1", @"popup_camera1")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
            if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES){
                                UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                                self.picker = [[UIImagePickerController alloc] init];
                                self.picker.delegate = self;
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                
                                self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                [top presentViewController:self.picker animated:YES completion:nil];
                            }
                        });
                    }];
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES){
                            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                            self.picker = [[UIImagePickerController alloc] init];
                            self.picker.delegate = self;
                            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                            self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                            [top presentViewController:self.picker animated:YES completion:nil];
                        }
                    });
                }];
            }
            
//            if([AccessAuthCheck cameraAccessCheckNotAuth]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    self.picker = [[UIImagePickerController alloc] init];
//                    self.picker.delegate = self;
//                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                    [top presentViewController:self.picker animated:YES completion:nil];
//                });
//            }
        }else{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera2", @"popup_camera2")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
                });
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
//        }
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //if(![profileThumbImg isEqualToString:@""]&&![profileThumbImg2 isEqualToString:@""]){
    if(![profileThumbImg isEqualToString:@""]){
        UIAlertAction *defaultImageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"myinfo_image_null", @"myinfo_image_null")
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_image_null_msg", @"myinfo_image_null_msg") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self callWebService];
            }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        [actionSheet addAction:defaultImageAction];
    }
    
    [actionSheet addAction:takePictureAction];
    [actionSheet addAction:selectPhotoAction];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
        
        [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
        CGRect rect = self.view.frame;
        rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
        rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = rect;
    } else {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)bgImageEditClick {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera1", @"popup_camera1")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
            if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES){
                                UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                                self.picker = [[UIImagePickerController alloc] init];
                                self.picker.delegate = self;
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                
                                self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                [top presentViewController:self.picker animated:YES completion:nil];
                            }
                        });
                    }];
                    
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES){
                            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                            self.picker = [[UIImagePickerController alloc] init];
                            self.picker.delegate = self;
                            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                            self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                            [top presentViewController:self.picker animated:YES completion:nil];
                        }
                    });
                }];
            }
            
//            if([AccessAuthCheck cameraAccessCheckNotAuth]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    self.picker = [[UIImagePickerController alloc] init];
//                    self.picker.delegate = self;
//                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                    [top presentViewController:self.picker animated:YES completion:nil];
//                });
//            }
            
        }else{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera2", @"popup_camera2")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
                });
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"MY_PHLIB_MODAL" sender:@"PHOTO"];
//        }
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    //if(![profileBgImg isEqualToString:@""] && ![profileBgImg2 isEqualToString:@""]){
    if(![profileBgImg isEqualToString:@""]){
        UIAlertAction *defaultImageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"myinfo_image_null", @"myinfo_image_null")
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"myinfo_image_null_msg", @"myinfo_image_null_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self callWebService];
            }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [actionSheet addAction:defaultImageAction];
    }
    
    [actionSheet addAction:takePictureAction];
    [actionSheet addAction:selectPhotoAction];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
        
        [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
        CGRect rect = self.view.frame;
        rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
        rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = rect;
    } else {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 5) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        button.backgroundColor = [UIColor whiteColor];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(20, 20) :[UIImage imageNamed:@"icon_exit.png"]] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"myinfo_logout", @"myinfo_logout") forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(1.0, 20.0, .0, 0.0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 0.0)];
        [button addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return NSLocalizedString(@"myinfo_profile", @"myinfo_profile");
    } else if(section == 1) {
        return NSLocalizedString(@"myinfo_account", @"myinfo_account");
    } else if(section == 2) {
        return NSLocalizedString(@"myinfo_system_title", @"myinfo_system_title");
    } else if(section == 3){
        return NSLocalizedString(@"myinfo_backup_restore_title", @"myinfo_backup_restore_title");
    } else if(section == 4){
        return NSLocalizedString(@"myinfo_version_title", @"myinfo_version_title");
    }else{
        return nil;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.profileKeyArr.count;
        
    } else if (section == 1){
        return self.accountKeyArr.count;
        
    } else if (section == 2){
        return self.settingKeyArr.count;
        
    } else if (section == 3){
        return self.dataManageKeyArr.count;
        
    } else if (section == 4){
        return self.appInfoKeyArr.count;
        
    }else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell"];
    
    if(cell == nil){
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyTableViewCell"];
    }
    
    @try{
        if(indexPath.section == 0){
            if(indexPath.row==1){
                cell.editWidthConstraint.constant = 20;
                cell.editSpaceConstraint.constant = 30;
                [cell.editIcon setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(20, 20) :[UIImage imageNamed:@"btn_edit.png"]] forState:UIControlStateNormal];
                
            } else {
                cell.editWidthConstraint.constant = 0;
                cell.editSpaceConstraint.constant = 0;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.keyLabel.text = [self.profileKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = [self.profileValArr objectAtIndex:indexPath.row];
            cell.valueLabel.numberOfLines = 1;
            
        } else if (indexPath.section == 1) {
            cell.keyLabel.text = [self.accountKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = [self.accountValArr objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
            
        } else if (indexPath.section == 2) {
            cell.keyLabel.text = [self.settingKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
            
            if(indexPath.row==1&&[[MFSingleton sharedInstance] mediaAuthCheck]){
//            if(indexPath.row==2&&[[MFSingleton sharedInstance] mediaAuthCheck]){
                cell.editWidthConstraint.constant = 40;
                cell.editSpaceConstraint.constant = 20;
                
                NSString *authText = @"";
                authVal = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]];
                if([authVal isEqualToString:@"1"]) {
                    authText = @"승인";
                    [cell.editIcon setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
                } else {
                    authText = @"미승인";
                    [cell.editIcon setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                
                [cell.editIcon setImage:nil forState:UIControlStateNormal];
                [cell.editIcon setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 4.0, 0.0)];
                [cell.editIcon setTitle:authText forState:UIControlStateNormal];
            }
            
        } else if (indexPath.section == 3) {
            cell.keyLabel.text = [self.dataManageKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
            
        } else if (indexPath.section == 4) {
            cell.keyLabel.text = NSLocalizedString(@"myinfo_version", @"myinfo_version");
            cell.valueLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
            
        } /*else if (indexPath.section == 5) {
            cell.keyLabel.text = NSLocalizedString(@"myinfo_mdm_off", @"myinfo_mdm_off");
            cell.valueLabel.text = nil;
        } */else {
            cell.keyLabel.text = NSLocalizedString(@"myinfo_logout", @"myinfo_logout");
            cell.valueLabel.text = nil;
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        [cell.keyLabel sizeToFit];
        //[cell.valueLabel sizeToFit];
        
        return cell;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 1){
        [self performSegueWithIdentifier:@"MY_MSG_CHANGE_PUSH" sender:nil];
    } /*else if(indexPath.section == 2 && indexPath.row == 0){
       //NSLog(@"로그아웃");
       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"로그아웃하시면 앱이 종료됩니다." delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
       alert.tag = 1;
       [alert show];
       }*/
    else if(indexPath.section == 2){
        if(indexPath.row == 0) {
            [self performSegueWithIdentifier:@"MY_TAB_CHANGE_PUSH" sender:nil];
            
        } else if(indexPath.row == 1) {
            if([[MFSingleton sharedInstance] mediaAuthCheck]){
                MediaAccessViewController *vc = [[MediaAccessViewController alloc] init];
                vc.dataArr = dataArr;
                vc.authVal = authVal;
                vc.exCompNm = exCompNm;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                if([[MFSingleton sharedInstance] simplePwd]){
                    SimplePwdViewController *vc = [[SimplePwdViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                } else {
                    
                }
            }
            
        } else if(indexPath.row == 2) {
            if([[MFSingleton sharedInstance] simplePwd]){
                SimplePwdViewController *vc = [[SimplePwdViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
            }  
        }
//        if(indexPath.row == 0) {
//            [self performSegueWithIdentifier:@"NOTI_SET_PUSH" sender:nil];
//
//        } else if(indexPath.row == 1) {
//            [self performSegueWithIdentifier:@"MY_TAB_CHANGE_PUSH" sender:nil];
//
//        } else if(indexPath.row == 2) {
//            if([[MFSingleton sharedInstance] mediaAuthCheck]){
//                MediaAccessViewController *vc = [[MediaAccessViewController alloc] init];
//                vc.dataArr = dataArr;
//                vc.authVal = authVal;
//                vc.exCompNm = exCompNm;
//                [self.navigationController pushViewController:vc animated:YES];
//
//            } else {
//                if([[MFSingleton sharedInstance] simplePwd]){
//                    SimplePwdViewController *vc = [[SimplePwdViewController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
//
//                } else {
//
//                }
//            }
//
//        } else if(indexPath.row == 3) {
//            if([[MFSingleton sharedInstance] simplePwd]){
//                SimplePwdViewController *vc = [[SimplePwdViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
//
//            } else {
//
//            }
//        }
        
    } else if(indexPath.section == 3){
        [self performSegueWithIdentifier:@"DATA_BACKUP_PUSH" sender:nil];
        
    } else if(indexPath.section == 4){
        [self performSegueWithIdentifier:@"MY_APP_VER_PUSH" sender:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//-(void)MDMOff{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:NSLocalizedString(@"myinfo_mdm_off_message", @"myinfo_mdm_off_message") preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                             [alert dismissViewControllerAnimated:YES completion:nil];
//                                                         }];
//    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction * action) {
//                                                         [alert dismissViewControllerAnimated:YES completion:nil];
//                                                         appDelegate.mdmCallAPI = @"exitWorkApp";
//                                                         [appDelegate exitWorkApp];
//                                                         exit(0);
//                                                     }];
//
//    [alert addAction:cancelButton];
//    [alert addAction:okButton];
//    [self presentViewController:alert animated:YES completion:nil];
//}
-(void)Logout{
    NSLog();
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"notification_setting_title", @"notification_setting_title") message:NSLocalizedString(@"myinfo_logout_message", @"myinfo_logout_message") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                         [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"USERPWD"]];
                                                         [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                         [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                         [appDelegate.appPrefs removeObjectForKey:@"URL"];
                                                         [appDelegate.appPrefs removeObjectForKey:@"CPN_CODE"];
                                                         [appDelegate.appPrefs synchronize];
                                                         
//                                                         appDelegate.mdmCallAPI = @"exitWorkApp";
//                                                         [appDelegate exitWorkApp];
                                                         
                                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                         IntroViewController *vc = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
                                                         UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                                         nav.modalPresentationStyle = UIModalPresentationFullScreen;
                                                         [self presentViewController:nav animated:YES completion:nil];
                                                         
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *messageText;
    messageText = [[NSMutableAttributedString alloc]
                   initWithString:alert.message
                   attributes:@{
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSFontAttributeName : [UIFont systemFontOfSize:15],
                                NSForegroundColorAttributeName : [UIColor blackColor]
                                }
                   ];
    [alert setValue:messageText forKey:@"attributedMessage"];
    
    [self presentViewController:alert animated:YES completion:nil];
     
    
//    if([MFMailComposeViewController canSendMail]) {
//        NSLog(@"YES????");
//        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
//        mailCont.mailComposeDelegate = self;
//
//        [mailCont setSubject:@"yo!"];
//        [mailCont setToRecipients:[NSArray arrayWithObject:@"hilee@dbvalley.com"]];
//        [mailCont setMessageBody:@"Don't ever want to give you up" isHTML:NO];
//        //[mcvc addAttachmentData:ifAny mimeType:@"application/pdf" fileName:fileName];
//
//        [self presentViewController:mailCont animated:YES completion:nil];
//
//    } else {
//        NSLog(@"NO????");
//
//        NSString *recipients = @"mailto:?cc=&subject=";
//        NSString *body = @"&body=";
//        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//        email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options:@{} completionHandler:nil];
//    }
    
}

- (void)tapLogout:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"myinfo_logout_message", @"myinfo_logout_message") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                         [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                         [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                         [appDelegate.appPrefs removeObjectForKey:@"URL"];
                                                         [appDelegate.appPrefs removeObjectForKey:@"CPN_CODE"];
                                                         [appDelegate.appPrefs synchronize];
                                                         
                                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                         IntroViewController *vc = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
                                                         UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                                         [self presentViewController:nav animated:YES completion:nil];
                                                         
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *messageText;
    messageText = [[NSMutableAttributedString alloc]
                   initWithString:alert.message
                   attributes:@{
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSFontAttributeName : [UIFont systemFontOfSize:15],
                                NSForegroundColorAttributeName : [UIColor blackColor]
                                }
                   ];
    [alert setValue:messageText forKey:@"attributedMessage"];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if(alertView.tag == 1 && buttonIndex == 1){
//        //userid, devid삭제 후 앱종료
//        [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
//        [appDelegate.appPrefs removeObjectForKey:@"USERID"];
//        [appDelegate.appPrefs removeObjectForKey:@"URL"];
//        [appDelegate.appPrefs removeObjectForKey:@"CPN_CODE"];
//        [appDelegate.appPrefs synchronize];
//        
//        exit(0);
//        
//    }
//}

- (void)callWebService{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    //KEY : refTy VALUE : "2"(프로필이미지) or "3"(프로필배경이미지)
    NSString *refTy;
    if(isProfile){
        refTy=@"2";
    } else {
        refTy=@"3";
    }
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&refTy=%@&compNo=%@&dvcId=%@", userNo, refTy, compNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"deleteProfileImage"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSDictionary *dic = session.returnDictionary;
        if ([[dic objectForKey:@"RESULT"]isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getProfile"]) {
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
//                NSLog(@"dataSet : %@", dataSet);
                dataArr = [[NSArray alloc] initWithArray:dataSet];
                
                [self settingMyInfo :dataSet];
            }
        }
    }
}
-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        //[self callGetProfile];
    }
}
-(void)setTimer{
    timerCount = 0;
    timerEndCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
-(void)handleTimer:(NSTimer *)timer {
    timerCount++;
    if (timerCount==timerEndCount) {
        [self callGetProfile];
        [myTimer invalidate];
    }
}

-(void)reconnectFromError{
    if(appDelegate.errorExecCnt<[[MFSingleton sharedInstance] errorMaxCnt]){
        [self setTimer];
    } else {
        appDelegate.errorExecCnt = 0;
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    appDelegate.errorExecCnt++;
}

/*
- (void)saveAttachedFile:(NSDictionary *)userInfo{
    @try{
        self.assetArray = [userInfo objectForKey:@"ASSET_LIST"];
        
        //사진앨범에서 선택
        if(self.assetArray.count > 0){
            for (int i=0; i<self.imageArray.count; i++) {
                self.asset = [[userInfo objectForKey:@"ASSET_LIST"] objectAtIndex:i];
                
                NSString *fileName = [self createFileName];
                
                UIImage *image =[self.imageArray objectAtIndex:i];
                NSData * data = UIImageJPEGRepresentation(image, 0.3);
                
                [self saveAttachedFile:data AndFileName:fileName];
            }
        } else {
            //사진촬영
            NSString *aditInfo = [userInfo objectForKey:@"ADIT_INFO"];
            NSString *fileName =  [userInfo objectForKey:@"FILE_NM"];
            
            NSData* imgData = [[NSFileManager defaultManager] contentsAtPath:aditInfo];
            UIImage *image = [UIImage imageWithData:imgData];
            NSData * data = UIImageJPEGRepresentation(image, 0.3);
            
            [self saveAttachedFile:data AndFileName:fileName];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
*/
- (void)saveAttachedFile:(UIImage *)image{
    @try{
        NSString *fileName = [self createFileName];
        NSData * data = UIImageJPEGRepresentation(image, 0.3);
        [self saveAttachedFile:data AndFileName:fileName];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


- (void)saveAttachedFile:(NSData *)data AndFileName:(NSString *)fileName{
    @try{
        //프로필변경 웹서비스
        //ADIT_INFO : {"TMP_NO":Long,"LOCAL_CONTENT":String}
        NSString *dvcID = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];//[MFUtil getUUID];
        NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
        [aditDic setObject:@1 forKey:@"TMP_NO"];
        [aditDic setObject:dvcID forKey:@"DEVICE_ID"];
        
        NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
        NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
        //[sendFileParam setObject:self.roomNo forKey:@"roomNo"];
        [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
        [sendFileParam setObject:userNo forKey:@"usrNo"];
        //[sendFileParam setObject:@"4" forKey:@"refTy"];
        [sendFileParam setObject:userNo forKey:@"refNo"];
        [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
        [sendFileParam setObject:@"false" forKey:@"isShared"];
        [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
        
        //프로필이미지의 경우에는 REF_TY을 "4"로 보내는데 프로필배경이미지의 경우 REF_TY를 "5"로 보내야함
        if(isProfile){
            [sendFileParam setObject:@"4" forKey:@"refTy"];
        } else {
            [sendFileParam setObject:@"5" forKey:@"refTy"];
        }
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
        urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
        
        MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
        sessionUpload.delegate = self;
        
        if ([sessionUpload start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (NSString *)createFileName{
    @try{
        NSString *fileName = nil;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        fileName = [NSString stringWithFormat:@"%@.png",currentTime];
        return fileName;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionUpload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    if (error != nil) {
        
    }else{
        NSLog(@"dictionary : %@", dictionary);
        if(dictionary != nil){
            [self.imageFileNameArray addObject:[dictionary objectForKey:@"FILE_URL"]];
            
            if ([dictionary objectForKey:@"FILE_URL"]==nil) {

            } else{
                [SVProgressHUD dismiss];
            }
        } else {
            //데이터,와이파이 둘 다 꺼져있을경우
            NSLog(@"인터넷 연결이 오프라인으로 나타납니다.");
        }
    }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"%@", error);
}

- (void)getImageNotification:(NSNotification *)notification {
    self.imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
    
    UIImage *image = [self.imageArray objectAtIndex:0];
    self.croppingStyle = TOCropViewCroppingStyleDefault;
    
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
    cropController.delegate = self;
    self.image = image;
    [self presentViewController:cropController animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self video:mediaUrl.absoluteString didFinishSavingWithError:nil contextInfo:nil];
        }
        
    }else{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self image:image didFinishSavingWithError:nil contextInfo:nil];
        }
        
        
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        UIImage *rotateImg = nil;
        if(image.size.width>image.size.height){
            rotateImg = [MFUtil rotateImage:image byOrientationFlag:image.imageOrientation];
        } else {
            rotateImg = [MFUtil rotateImage90:image];
        }
        
        self.croppingStyle = TOCropViewCroppingStyleDefault;
        
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:rotateImg];
        cropController.delegate = self;
        self.image = rotateImg;
        [self presentViewController:cropController animated:YES completion:nil];
        
        
//        NSString *getFileName = [self createFileName];
//        NSData *imageData = UIImageJPEGRepresentation(rotateImg, 0.1);
//
//        NSString *tmpPath = NSTemporaryDirectory();
//        NSString *imagePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",getFileName]];
//        //NSLog(@"imagePath : %@", imagePath);
//        [imageData writeToFile:imagePath atomically:YES];
//        NSLog(@"사진촬영 원본이미지 : %@", imagePath);
//
//        //썸네일이미지 로컬 tmp경로에 저장
//        NSData *imageThumbData = UIImagePNGRepresentation([MFUtil imageByScalingAndCroppingForSize:CGSizeMake(225, 300) :rotateImg]);
//        NSString *imageThumbPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",getFileName]];
//        [imageThumbData writeToFile:imageThumbPath atomically:YES];
//        NSLog(@"사진촬영 썸네일이미지 : %@", imageThumbPath);
//
//        NSMutableDictionary *imageInfoDic = [NSMutableDictionary dictionary];
//        [imageInfoDic setObject:imagePath forKey:@"ADIT_INFO"];
//        [imageInfoDic setObject:getFileName forKey:@"FILE_NM"];
//
//        [self saveAttachedFile:imageInfoDic];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
//        NSLog(@"saved video videoPath");
    }
}

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    if (image!=nil) {
        
        if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
            [cropViewController dismissAnimatedFromParentViewController:self
                                                       withCroppedImage:image
                                                                 toView:nil
                                                                toFrame:CGRectZero
                                                                  setup:^{}
                                                             completion:^{
                                                                 [self saveAttachedFile:image];
                                                             }];
        }
        
    }
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"MY_PHLIB_MODAL"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:@"getImageNotification" object:nil];
        
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fromSegue = segue.identifier;
        vc.listType = sender;
        
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
    } else if([[segue identifier] isEqualToString:@"MY_MSG_CHANGE_PUSH"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:@"getImageNotification" object:nil];
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        MyMessageViewController *destination = segue.destinationViewController;
        destination.statusMsg = [self.profileValArr objectAtIndex:1];
        destination.fromSegue = segue.identifier;
        
    } else if([[segue identifier] isEqualToString:@"MY_TAB_CHANGE_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
        
    } else if([[segue identifier] isEqualToString:@"MY_APP_VER_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
       
    } else if([[segue identifier] isEqualToString:@"NOTI_SET_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
        
    } else if([[segue identifier] isEqualToString:@"DATA_BACKUP_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
    }
}




// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
