//
//  ChatListViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatListViewController.h"
#import "SWTableViewCell.h"
#import "RMQServerViewController.h"
#import "RightSideViewController.h"
#import "PostDetailViewController.h"
#import "TaskDetailViewController.h"
#import "DeptListViewController.h"
#import "UserListViewController.h"
#import "MyMessageViewController.h"
#import "NotiChatViewController.h"



#define kCellID @"IMG_CELL_ID"
#define kSupplementaryViewID @"SUP_VIEW_ID"

#define ROW_TAG 1000

#define REFRESH_TABLEVIEW_DEFAULT_ROW               64.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f
#define REFRESH_TITLE_TABLE_PULL                    @"새로고침"
#define REFRESH_TITLE_TABLE_RELEASE                 @"새로고침"
#define REFRESH_TITLE_TABLE_LOAD                    @"새로고치는 중..."
#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"

#define kSupplementaryViewID @"SUP_VIEW_ID"
#define MODEL_NAME [[UIDevice currentDevice] modelName]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface ChatListViewController() {
    NSIndexPath *roomIdx;
    int newChatCnt;
    NSString *thumbImagePath;
    NSString *originImagePath;
    BOOL flag;
    int badgeCnt;
    AppDelegate *appDelegate;
    UITabBarController *rootViewController;
    
    UILabel *emptyLabel;
    
    
    int tCount;
    int endTCount;
    NSTimer *myTimer;
    
    BOOL isLoad;
    BOOL isScroll;
    int pRoomSize;
    NSString *stRoomSeq;
}

@property (nonatomic) BOOL useCustomCells;
@property (strong, nonatomic) NSMutableDictionary *alarmDic;

@property (strong, nonatomic) NSString *pushRoomNm;
@property (strong, nonatomic) NSString *pushMemCnt;

@property (strong, nonatomic) VCFloatingActionButton *addButton;

@end

@implementation ChatListViewController

- (void)initNavigationBar{
    @try{
        NSLog();
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatClassFlag:) name:@"noti_ChatClassFlag" object:nil];
        
        //이 화면에서 새글,댓글,채팅 알림 노티 클릭했을 경우 화면 이동
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
        
        //채팅 수신 시 채팅목록 갱신
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatList:) name:@"noti_ChatList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ApnsChatList:) name:@"noti_ApnsChatList" object:nil];
        
        //채팅 수신 시 탭바 뱃지 카운트 변경
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeChatBadge:) name:@"noti_ChangeChatBadge" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_MoveNewChatRoom:) name:@"noti_MoveNewChatRoom" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SideProfileChat:) name:@"noti_SideProfileChat" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RefreshChatList:) name:@"noti_RefreshChatList" object:nil];
        
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        rootViewController = [MFUtil setDefualtTabBar];
        
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"tab_chat", @"tab_chat")];
        self.navigationItem.hidesBackButton = YES;
        
        if([[MFSingleton sharedInstance] isMDM]){
            UIButton *left1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
            [left1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_off.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
            [left1 addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftBtn1 = [[UIBarButtonItem alloc]initWithCustomView:left1];
            self.navigationItem.leftBarButtonItem = leftBtn1;
        }
        
        UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [right1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_search.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
        [right1 addTarget:self action:@selector(rightSearchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
        
        //NSArray *barButtonArr = [[NSArray alloc]initWithObjects:rightBtn1, rightBtn2, nil];
        self.navigationItem.rightBarButtonItem = rightBtn1;
        
        //플로팅 버튼
        //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, [UIScreen mainScreen].bounds.size.height-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_chat.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
        
        self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
        self.addButton.clipsToBounds = YES;
        self.addButton.contentMode = UIViewContentModeScaleAspectFit;
        
        //[self.addButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        
        self.addButton.imageArray = @[@"floating_chat.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_message", @"new_message")];
        
        self.addButton.hideWhileScrolling = YES;
        self.addButton.delegate = self;
        [self.view addSubview:self.addButton];
        
        emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, self.view.frame.size.width, self.tableView.frame.size.height-self.tabBarController.tabBar.frame.size.height)];
        emptyLabel.textColor = [UIColor blackColor];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.numberOfLines = 0;
        [self.tableView addSubview:emptyLabel];
        emptyLabel.hidden = YES;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try{
        NSLog(@"fromSegue : %@", self.fromSegue);
        [self initNavigationBar];
        
        _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        newChatCnt = 0;
        self.alarmDic = [[NSMutableDictionary alloc]init];
        
        if(appDelegate.inactivePostPushInfo.count>0){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:appDelegate.inactivePostPushInfo];
        }
        if(appDelegate.inactiveChatPushInfo.count>0){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatPush" object:nil userInfo:appDelegate.inactiveChatPushInfo];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s",__func__);
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.tabBarController.tabBar setHidden:NO];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.appPrefs setObject:@"3" forKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]];
    [appDelegate.appPrefs synchronize];
    
    //삭제
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHAT_ROOMS WHERE ROOM_NO IN (1)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHAT_USERS WHERE ROOM_NO = 1"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM USERS WHERE USER_NO IN (120819)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHATS WHERE ROOM_NO IN (1)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM ROOM_IMAGES WHERE ROOM_NO IN (1)"];

//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHAT_ROOMS WHERE ROOM_NO IN (98)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHAT_USERS WHERE ROOM_NO = 98"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM USERS WHERE USER_NO IN (125515)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM CHATS WHERE ROOM_NO IN (98)"];
//    [appDelegate.dbHelper crudStatement:@"DELETE FROM ROOM_IMAGES WHERE ROOM_NO IN (98)"];
    
    
    flag = false;
    stRoomSeq = @"1";
    isLoad = YES;
    isScroll = NO;
    pRoomSize = 30;
    
    @try{
        [self readFromDatabase];
        
        badgeCnt=0;
        for(int i=0; i<self.tempArr.count; i++){
            int notReadCnt = [[[self.tempArr objectAtIndex:i] objectForKey:@"NOT_READ_COUNT"] intValue];
            badgeCnt+=notReadCnt;
        }
        [self.tableView reloadData];

    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)syncChatRoom{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getRoomList"]];
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&stSeq=%@&pSize=%d", _myUserNo, stRoomSeq, pRoomSize];
    
    MFURLSession *session = [[MFURLSession alloc] initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    UIImage *roomImg = [[UIImage alloc] init];
    ChatRoomImgDivision *divide = [[ChatRoomImgDivision alloc]init];
    [divide roomImgSetting:array :memberCnt];
    roomImg = divide.returnImg;
    NSLog(@"Room Img : %@", roomImg);
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/Chat/%@", roomNo];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        
    }else{
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(roomImg);
    NSString *fileName = @"";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    fileName = [NSString stringWithFormat:@"%@(%@).png",roomNo,currentTime];
    
    NSString *imgPath = [saveFolder stringByAppendingPathComponent:fileName];
    [imageData writeToFile:imgPath atomically:YES];
    NSLog(@"Room Img Path : %@", imgPath);
    
    NSString *sqlString;
    NSString *roomImgName = [imgPath lastPathComponent];
    
    NSArray *roomUserKey = [dict allKeys];
    NSArray *roomUserVal = [dict allValues];
    
    NSString *resultKey = [[roomUserKey valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *resultVal = [[roomUserVal valueForKey:@"description"] componentsJoinedByString:@","];
    
//    if([memberCnt isEqualToString:@"1"]){ //200820 기존
    if([[NSString stringWithFormat:@"%@", memberCnt] isEqualToString:@"1"]){
        sqlString = [appDelegate.dbHelper insertRoomImages:roomNo roomImg:roomImgName refNo1:myUserNo];
        
    } else {
        sqlString = [appDelegate.dbHelper insertRoomImages:resultKey roomNo:roomNo roomImg:roomImgName resultVal:resultVal];
    }
    
    [appDelegate.dbHelper crudStatement:sqlString];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect floatFrame = CGRectNull;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        
    } else {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        } else {
            floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-40, 50, 50);
        }
    }
    
    //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
    self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_chat.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
    
    self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
    self.addButton.clipsToBounds = YES;
    self.addButton.contentMode = UIViewContentModeScaleAspectFit;
    
    self.addButton.imageArray = @[@"floating_chat.png"];
    self.addButton.labelArray = @[NSLocalizedString(@"new_message", @"new_message")];
    
    self.addButton.hideWhileScrolling = YES;
    self.addButton.delegate = self;
    
    [self.view addSubview:self.addButton];
}

- (void)readFromDatabase {
    NSString *sqlString = [appDelegate.dbHelper getRoomList];
    
    self.chatArray = [NSMutableArray array];
    self.tempArr = [NSMutableArray array];
    
    self.chatArray = [appDelegate.dbHelper selectMutableArray:sqlString];
    NSLog(@"앱실행) 사용자 나간 후 채팅방 조회 : %@", self.chatArray);
    
    self.tempArr = [self.chatArray mutableCopy];
    
    if(self.chatArray.count>0){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        emptyLabel.hidden = YES;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        emptyLabel.text = NSLocalizedString(@"no_content_message", @"no_content_message");
        emptyLabel.hidden = NO;
    }
    
    //기존 채팅방목록에 새채팅방번호가 있는지 비교
    self.array = [NSMutableArray array];
    for (int i=0; i<self.chatArray.count; i++) {
        NSDictionary *dic = [self.chatArray objectAtIndex:i];
//        NSLog(@"room info dic : %@", dic);
        NSString *roomNoStr = [dic objectForKey:@"ROOM_NO"];
        NSString *memberCnt = [dic objectForKey:@"MEMBER_COUNT"];
        
        if ([roomNoStr isEqualToString:self.recvRoomNo]) {
            [self.array addObject:self.recvRoomNo];
        }
        
        NSString *roomImage = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomImg:roomNoStr]];
        
        if(roomImage!=nil&&![roomImage isEqualToString:@""]){
            if([roomImage rangeOfString:@"https://"].location != NSNotFound || [roomImage rangeOfString:@"http://"].location != NSNotFound){
                NSLog(@"이미지가 URL임 : %@", roomImage);
                NSMutableArray *imgArr = [[roomImage componentsSeparatedByString:@","] mutableCopy];

                UIImage *roomImg = [[UIImage alloc] init];
                ChatRoomImgDivision *divide = [[ChatRoomImgDivision alloc]init];
                [divide roomImgSetting:imgArr :memberCnt];
                roomImg = divide.returnImg;
                NSLog(@"Room Img : %@", roomImg);
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

                NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/Chat/%@", roomNoStr];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
                if (issue) {

                }else{
                    [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
                }

                NSData *imageData = UIImagePNGRepresentation(roomImg);
                NSString *fileName = @"";
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
                NSString *currentTime = [dateFormatter stringFromDate:today];
                fileName = [NSString stringWithFormat:@"%@(%@).png",roomNoStr,currentTime];

                NSString *imgPath = [saveFolder stringByAppendingPathComponent:fileName];
                [imageData writeToFile:imgPath atomically:YES];
                NSLog(@"Room Img Path : %@", imgPath);

                NSString *roomImgName = [imgPath lastPathComponent];
                NSString *sqlString = [appDelegate.dbHelper updateRoomImage:roomImgName roomNo:roomNoStr];
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }
    }
    
    self.recvRoomNo = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Floating Button Event
-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if(row==0){
        [self createChat:nil];
    }
}

#pragma mark -
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
                                                         }
                                                     }];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)leftNavigationButtonPressed:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated: YES];
    if (!self.tableView.editing) {
        
    }else{
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete", @"complete")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(leftNavigationButtonPressed:)];
    }
}

#pragma mark - Push Notification
- (void)noti_ChangeChatBadge:(NSNotification *)notification {
    @try{
        NSLog(@"왜 호출이 안될까 : %@", notification.userInfo);
        badgeCnt = [[notification.userInfo objectForKey:@"CNT"] intValue];
        NSLog(@"badgeCnt : %d", badgeCnt);
        NSUInteger tabCount = rootViewController.tabBar.items.count;
        
        for(int i=0; i<tabCount; i++){
            if([rootViewController.tabBar.items objectAtIndex:i].tag == 3){
                if(badgeCnt>0 && badgeCnt<100){
                    [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", badgeCnt];
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                    //[[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                } else if(badgeCnt==0){
                    [[self navigationController] tabBarItem].badgeValue = nil;
                } else {
                    [[self navigationController] tabBarItem].badgeValue = @"99+";
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                    //[[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                }
                break;
            }
        }
        
//        NSString *roomNo = [notification.userInfo objectForKey:@"ROOM_NO"];
        NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];

        NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO_LIST"]];
//        NSNumber *unreadCnt = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];

        NSMutableArray *chatNoArr = [NSMutableArray array];
        if([chatNoList rangeOfString:@","].location != NSNotFound){
            chatNoArr = [[chatNoList componentsSeparatedByString:@","] mutableCopy];
        } else {
            [chatNoArr addObject:chatNoList];
        }
        
//        NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
//        [appDelegate.dbHelper crudStatement:sqlString];
        self.tempArr = [self.chatArray mutableCopy];
        
        [self.tableView reloadData];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
   
}

- (void)noti_ChatClassFlag:(NSNotification *)notification {
    flag=true;
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
        NSLog();
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
        
        NSUserDefaults *classPref = [NSUserDefaults standardUserDefaults];
        NSString *classNm = [classPref objectForKey:@"CURR_CLASS"];
        
        if(![classNm isEqualToString:@"TeamListViewController"]){
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
                            
                            if(!flag){
                                [self.navigationController pushViewController:container animated:YES];
                                flag = true;
                            }
                            
                        } else {
                            NSString *strClass = NSStringFromClass([self class]);
                            if([currentClass isEqualToString:strClass]){
                                [self.navigationController pushViewController:container animated:YES];
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
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatDetailView" object:nil userInfo:dict];
                            
                            if(!flag){
                                [self.navigationController pushViewController:container animated:YES];
                                flag = true;
                            }
                        } else {
                            NSString *strClass = NSStringFromClass([self class]);
                            if([currentClass isEqualToString:strClass]){
                                [self.navigationController pushViewController:container animated:YES];
                            }
                        }
                    }
                }
            }
        }
        [classPref setObject:nil forKey:@"CURR_CLASS"];
        [classPref synchronize];
        
        NSLog(@"여기서 삭제");
        appDelegate.inactiveChatPushInfo=nil;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_RefreshChatList:(NSNotification *)notification {
    [self readFromDatabase];
    [self.tableView reloadData];
}

- (void)noti_ChatList:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo : %@", userInfo);

    @try{
        [self readFromDatabase];
        [self.tableView reloadData];
        
        NSArray *dataSet = [userInfo objectForKey:@"DATASET"];
        
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *pushType = [userInfo objectForKey:@"TYPE"];
        NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
        NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
        NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"]];
        NSString *fileName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"]];
        NSString *fileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
        NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
        NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        
//        if([contentType isEqualToString:@"INVITE"]){
            content = [NSString urlDecodeString:content];
//        }
        
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
        [userInfoDic setObject:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"] forKey:@"CHAT_NO"];
        //[userInfoDic setObject:content forKey:@"CONTENT"];
        [userInfoDic setObject:contentType forKey:@"CONTENT_TY"];
        [userInfoDic setObject:chatDate forKey:@"LAST_DATE"];
        [userInfoDic setObject:roomNo forKey:@"ROOM_NO"];
        [userInfoDic setObject:pushType forKey:@"TYPE"];
        [userInfoDic setObject:userName forKey:@"USER_NM"];
        [userInfoDic setObject:userNo forKey:@"USER_NO"];
        //[userInfoDic setObject:fileName forKey:@"FILE_NM"];
        //[userInfoDic setObject:fileThumb forKey:@"FILE_THUMB"];
        //[userInfoDic setObject:profileImg forKey:@"USER_IMG"];
        
        if([fileName isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_NM"];
        else [userInfoDic setObject:fileName forKey:@"FILE_NM"];
        
        if([fileThumb isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_THUMB"];
        else [userInfoDic setObject:fileThumb forKey:@"FILE_THUMB"];
        
        if([profileImg isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"USER_IMG"];
        else [userInfoDic setObject:profileImg forKey:@"USER_IMG"];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<self.chatArray.count; i++) {
            NSDictionary *dic = [self.chatArray objectAtIndex:i];
            NSString *roomNoStr = [dic objectForKey:@"ROOM_NO"];
            
            if ([[NSString stringWithFormat:@"%@", roomNoStr] isEqualToString:[NSString stringWithFormat:@"%@", roomNo]]) {
                [array addObject:roomNo];
            }
        }
        
        if(![contentType isEqualToString:@"SYS"]){
            if([contentType isEqualToString:@"IMG"]){
//                NSRange range = [content rangeOfString:@"." options:NSBackwardsSearch];
//                NSString *fileExt = [[content substringFromIndex:range.location+1] lowercaseString];
//                //NSLog(@"fileExt : %@", fileExt);
//
//                if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"heic"]){
//                    [userInfoDic setObject:@"사진" forKey:@"CONTENT"];
//                }
                [userInfoDic setObject:NSLocalizedString(@"chat_receive_image", @"chat_receive_image") forKey:@"CONTENT"];
                
            } else if([contentType isEqualToString:@"VIDEO"]){
                [userInfoDic setObject:NSLocalizedString(@"chat_receive_video", @"chat_receive_video") forKey:@"CONTENT"];
                
            } else if([contentType isEqualToString:@"FILE"]){
                [userInfoDic setObject:NSLocalizedString(@"chat_receive_file", @"chat_receive_file") forKey:@"CONTENT"];
                
            } else if([contentType isEqualToString:@"INVITE"]){
                [userInfoDic setObject:NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite") forKey:@"CONTENT"];
                
            } else if([contentType isEqualToString:@"LONG_TEXT"]){
                [userInfoDic setObject:@"" forKey:@"CONTENT"];
                [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
                
            } else {
                if(content != nil){
                    [userInfoDic setObject:content forKey:@"CONTENT"];
                    [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
                }
            }
            
            if(self.tempArr.count > 0){
                [userInfoDic setObject:[NSString urlDecodeString:[[self.tempArr objectAtIndex:0]objectForKey:@"ROOM_NM"]] forKey:@"ROOM_NM"];
                [userInfoDic setObject:[[self.tempArr objectAtIndex:0]objectForKey:@"MEMBER_COUNT"] forKey:@"MEMBER_COUNT"];
                [userInfoDic setObject:[[self.tempArr objectAtIndex:0]objectForKey:@"ROOM_NOTI"] forKey:@"ROOM_NOTI"];
                //[userInfoDic setObject:[NSString urlDecodeString:[[self.tempArr objectAtIndex:0]objectForKey:@"ROOM_IMG"]] forKey:@"ROOM_IMG"];
                [userInfoDic setObject:[NSString urlDecodeString:[[self.tempArr objectAtIndex:0]objectForKey:@"NEW_CHAT"]] forKey:@"NEW_CHAT"];
                [userInfoDic setObject:[[self.tempArr objectAtIndex:0]objectForKey:@"ROOM_TYPE"] forKey:@"ROOM_TYPE"];
                
                //채팅방 목록에 방번호가 있으면
                if(array.count > 0){
                    //마지막메시지, 날짜 업데이트
                    for (int i=0; i<self.chatArray.count; i++) {
                        NSDictionary *dic = [self.chatArray objectAtIndex:i];
                        NSString *roomNoStr = [dic objectForKey:@"ROOM_NO"];
                        
                        if ([[NSString stringWithFormat:@"%@", roomNoStr] isEqualToString:[NSString stringWithFormat:@"%@", roomNo]]) {
                            [self.chatArray removeObjectAtIndex:i];
                            [self.chatArray insertObject:userInfoDic atIndex:0];
                            [self.tableView reloadData];
                        }
                    }
                } else {
                    [self.chatArray insertObject:userInfoDic atIndex:0];
                    [self.tableView reloadData];
                }
            }
        } else {
            [self readFromDatabase];
            [self.tableView reloadData];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_ApnsChatList:(NSNotification *)notification {
    NSLog();
    [self readFromDatabase];
    [self.tableView reloadData];
}

- (void)noti_NewChatRoom:(NSNotification *)notification {
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    @try{
        NSLog(@"userInfo : %@", notification.userInfo);
        self.nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
        NSString *roomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
        NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
        NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
        
        if([[NSString stringWithFormat:@"%@", roomType] isEqualToString:@"3"]) self.nRoomName = roomNm;
        else self.nRoomName = [MFUtil createChatRoomName:roomNm roomType:roomType];
        
        self.chatArray = [[NSMutableArray alloc]init];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<self.chatArray.count; i++) {
            NSDictionary *dic = [self.chatArray objectAtIndex:i];
            NSString *roomNoStr = [dic objectForKey:@"ROOM_NO"];
            
            if ([[NSString stringWithFormat:@"%@", roomNoStr] isEqualToString:[NSString stringWithFormat:@"%@", self.nRoomNo]]) {
                [array addObject:self.nRoomNo];
            }
        }
        
        NSString *sqlString = [appDelegate.dbHelper getUpdateRoomList:_myUserNo roomNo:_nRoomNo];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlString];
        if(roomChatArr.count==0){
        
            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:_nRoomNo roomName:_nRoomName roomType:roomType];
            
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
                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:_nRoomNo userNo:userNo];
                
                [appDelegate.dbHelper crudStatement:sqlString2];
                [appDelegate.dbHelper crudStatement:sqlString3];
                
                //프로필 썸네일 로컬저장
                //            NSString *tmpPath = NSTemporaryDirectory();
                //            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                //            NSData *imageData = UIImagePNGRepresentation(thumbImage);
                //            NSString *fileName = [decodeUserImg lastPathComponent];
                //
                //            NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                //            [imageData writeToFile:thumbImgPath atomically:YES];
            }
        
        
            [appDelegate.dbHelper crudStatement:sqlString1];
        }
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        if(self.chatArray.count > 0){
            NSString *roomType = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_TYPE"];
            
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_TYPE"];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                
                rightViewController.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_TYPE"];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
            }
            
        } else {
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:self.nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:self.nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
            }
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_NewChatRoom" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_MoveNewChatRoom:(NSNotification *)notification {
    NSLog(@"notification.userInfo : %@", notification.userInfo);
    
    @try{
        self.nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
        NSString *roomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
        NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
        NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
        
        if([roomType isEqualToString:@"3"]) self.nRoomName = roomNm;
        else self.nRoomName = [MFUtil createChatRoomName:roomNm roomType:roomType];
        
        self.chatArray = [[NSMutableArray alloc]init];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<self.chatArray.count; i++) {
            NSDictionary *dic = [self.chatArray objectAtIndex:i];
            NSString *roomNoStr = [dic objectForKey:@"ROOM_NO"];
            
            if ([[NSString stringWithFormat:@"%@", roomNoStr] isEqualToString:[NSString stringWithFormat:@"%@", self.nRoomNo]]) {
                [array addObject:self.nRoomNo];
            }
        }
        
        NSString *sqlString = [appDelegate.dbHelper getUpdateRoomList:_myUserNo roomNo:_nRoomNo];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlString];
        if(roomChatArr.count==0){
            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:_nRoomNo roomName:_nRoomName roomType:roomType];
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
                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:_nRoomNo userNo:userNo];
                
                [appDelegate.dbHelper crudStatement:sqlString2];
                [appDelegate.dbHelper crudStatement:sqlString3];
                
                
                //프로필 썸네일 로컬저장
                //            NSString *tmpPath = NSTemporaryDirectory();
                //            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                //            NSData *imageData = UIImagePNGRepresentation(thumbImage);
                //            NSString *fileName = [decodeUserImg lastPathComponent];
                //
                //            NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                //            [imageData writeToFile:thumbImgPath atomically:YES];
            }
            
            [appDelegate.dbHelper crudStatement:sqlString1];
        }
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        
        rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
        if(self.chatArray.count > 0){
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_TYPE"];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                [self.tabBarController.tabBar setHidden:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:container animated:YES];
                });
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomNo = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_TYPE"];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:0] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                [self.tabBarController.tabBar setHidden:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:container animated:YES];
                });
            }
            
        } else {
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:self.nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                [self.tabBarController.tabBar setHidden:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:container animated:YES];
                });
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:self.nRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                [self.tabBarController.tabBar setHidden:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:container animated:YES];
                });
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_SideProfileChat:(NSNotification *)notification {
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    @try{
        NSLog();
        NSString *nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
        NSString *nRoomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
        NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
        NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = nRoomNm;
        else resultRoomNm = [MFUtil createChatRoomName:nRoomNm roomType:roomType];

        NSString *sqlString = [appDelegate.dbHelper getRoomList];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlString];
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
                //            NSString *tmpPath = NSTemporaryDirectory();
                //            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                //            NSData *imageData = UIImagePNGRepresentation(thumbImage);
                //            NSString *fileName = [decodeUserImg lastPathComponent];
                //
                //            NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                //            [imageData writeToFile:thumbImgPath atomically:YES];
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
            
            NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString2];
            
            [self.tabBarController.tabBar setHidden:YES];
            [self.navigationController pushViewController:container animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                [navigationArray removeObjectAtIndex:1];
                self.navigationController.viewControllers = navigationArray;
            });
            
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
            
            NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString2];
            
            [self.tabBarController.tabBar setHidden:YES];
            [self.navigationController pushViewController:container animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                [navigationArray removeObjectAtIndex:1];
                self.navigationController.viewControllers = navigationArray;
            });
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


#pragma mark - IBAction
- (IBAction)createChat:(id)sender {
    //[self performSegueWithIdentifier:@"CHAT_NEW_USER_PUSH" sender:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([[[MFSingleton sharedInstance] userListSort] isEqualToString:@"DEPT"]){
        DeptListViewController *vc = (DeptListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DeptListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.fromSegue = @"CHAT_NEW_USER_PUSH";
        vc.existUserArr = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatRoom:) name:@"noti_NewChatRoom" object:nil];
        
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        UserListViewController *vc = (UserListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.fromSegue = @"CHAT_NEW_USER_PUSH";
        vc.existUserArr = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatRoom:) name:@"noti_NewChatRoom" object:nil];
        
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)rightSearchButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"SEARCH_CHAT_LIST_MODAL" sender:nil];
}

- (void)callDeleteChat: (NSIndexPath *)indexPath{
    @try{
        //deleteChatUser 파라미터 roomNo, usrNo, queueName, routingKey, usrNM
        //destination.roomNo = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
        NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
        NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];//[MFUtil getUUID];
        //NSString *memberCnt = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"];
        self.deleteRoomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
        NSString *roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];

        //방 나가기 시 채팅 모두 읽은것으로 간주
        NSString *sqlString = [appDelegate.dbHelper getUnreadChatNoRange:self.deleteRoomNo];
        NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString];
        
        NSNumber *firstChat = [[selectArr objectAtIndex:0] objectForKey:@"FIRST_CHAT"];
        NSNumber *lastChat = [[selectArr objectAtIndex:0] objectForKey:@"LAST_CHAT"];
        
        if(![[NSString stringWithFormat:@"%@", firstChat] isEqualToString:@"-1"] && ![[NSString stringWithFormat:@"%@", lastChat] isEqualToString:@"-1"]){
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.currChatRoomNo = self.deleteRoomNo;
            
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatReadStatus"]];
            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&firstChatNo=%@&lastChatNo=%@&dvcId=%@", self.myUserNo, self.deleteRoomNo, firstChat, lastChat, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
            session.delegate = self;
            [session start];
        } else {
            //NSLog(@"FIRST AND LAST CHATS ARE NULL---------");
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.currChatRoomNo = self.deleteRoomNo;
        
        NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:self.deleteRoomNo];
        [appDelegate.dbHelper crudStatement:sqlString2];
        
        //로컬 폴더에 해당 채팅방 번호로 만들어진 폴더 삭제
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@/Chat/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"], self.deleteRoomNo];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:documentFolder];
        if (issue) {
            [fileManager removeItemAtPath:documentFolder error:nil];
        }
        
        NSLog(@"self.deleteRoomNo : %@", self.deleteRoomNo);
        NSLog(@"roomtype : %@", roomType);
        
        //if([memberCnt integerValue] > 2){
        if([roomType isEqualToString:@"2"]){
            NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
            NSString *decodeUserNm = [NSString urlDecodeString:userNm];
            NSString *routingKey = [NSString stringWithFormat:@"%@.CHAT.%@.%@", [[MFSingleton sharedInstance] appType], [appDelegate.appPrefs objectForKey:@"COMP_NO"], self.deleteRoomNo]; //[MFUtil getChatRoutingKey:self.deleteRoomNo];
            
            NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            NSString *paramString = [NSString stringWithFormat:@"roomNo=%@&usrNo=%@&queueName=%@&routingKey=%@&usrNm=%@&dvcId=%@",self.deleteRoomNo, userNo, mfpsId, routingKey, decodeUserNm, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
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
            NSString *selectLastChat = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getChatLastNo:self.deleteRoomNo]];
            NSString *insertChatRoomInfo = [appDelegate.dbHelper insertChatRoomInfo:self.deleteRoomNo roomType:roomType lastChatNo:[NSString stringWithFormat:@"%@", selectLastChat] exitFlag:@"Y"];
            [appDelegate.dbHelper crudStatement:insertChatRoomInfo];
            
            NSString *sqlString1 = [appDelegate.dbHelper deleteMissedChat:self.deleteRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString1];
            NSString *sqlString2 = [appDelegate.dbHelper deleteChats:self.deleteRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString2];
            NSString *sqlString3 = [appDelegate.dbHelper deleteChatUsers:self.deleteRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString3];
            NSString *sqlString4 = [appDelegate.dbHelper deleteChatRooms:self.deleteRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString4];
            
            //채팅방 나가기 시 뱃지 카운트 업데이트
            for(int i=0; i<self.tempArr.count; i++){
                int notReadCnt = [[[self.tempArr objectAtIndex:i] objectForKey:@"NOT_READ_COUNT"] intValue];
                NSString *roomNo = [[self.tempArr objectAtIndex:i] objectForKey:@"ROOM_NO"];
                
                if([[NSString stringWithFormat:@"%@",self.deleteRoomNo] isEqualToString:[NSString stringWithFormat:@"%@",roomNo]]){
                    badgeCnt = badgeCnt-notReadCnt;
                    break;
                }
            }
            
            NSMutableDictionary *badgeDict = [NSMutableDictionary dictionary];
            [badgeDict setObject:[NSString stringWithFormat:@"%d", badgeCnt] forKey:@"CNT"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:badgeDict];
            
            self.deleteRoomNo = nil;
        }
    } @catch (NSException *exception) {
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
                NSString *sqlString1 = [appDelegate.dbHelper deleteMissedChat:self.deleteRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString1];
                NSString *sqlString2 = [appDelegate.dbHelper deleteChats:self.deleteRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                NSString *sqlString3 = [appDelegate.dbHelper deleteChatUsers:self.deleteRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString3];
                NSString *sqlString4 = [appDelegate.dbHelper deleteChatRooms:self.deleteRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString4];
                NSString *sqlString5 = [appDelegate.dbHelper deleteRoomImage:self.deleteRoomNo];
                [appDelegate.dbHelper crudStatement:sqlString5];
                
                //채팅방 나가기 시 뱃지 카운트 업데이트
                for(int i=0; i<self.tempArr.count; i++){
                    int notReadCnt = [[[self.tempArr objectAtIndex:i] objectForKey:@"NOT_READ_COUNT"] intValue];
                    NSString *roomNo = [[self.tempArr objectAtIndex:i] objectForKey:@"ROOM_NO"];
                    
                    if([[NSString stringWithFormat:@"%@",self.deleteRoomNo] isEqualToString:[NSString stringWithFormat:@"%@",roomNo]]){
                        badgeCnt = badgeCnt-notReadCnt;
                        [self.tempArr removeObjectAtIndex:i];
                        break;
                    }
                }
                
                NSMutableDictionary *badgeDict = [NSMutableDictionary dictionary];
                [badgeDict setObject:[NSString stringWithFormat:@"%d", badgeCnt] forKey:@"CNT"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:badgeDict];
                
                self.deleteRoomNo = nil;
            
            } else if([wsName isEqualToString:@"syncChatUsers"]){
                @try{
                    NSLog(@"syncChatUsers !!! : %@", dic);
    //                NSString *ex = @"{\"MESSAGE\":\"-\",\"RESULT\":\"SUCCESS\",\"DATASET\":[{\"UP_NODE_NO\":\"UW093\",\"DEPT_NO\":\"UW093\",\"DEPT_NM\":\"%EB%94%94%EB%B9%84%EB%B0%B8%EB%A6%AC%28%EC%A3%BC%29\",\"SEQ\":0,\"NODE_NM\":\"%EA%B9%80%EC%B0%A8%EC%A2%85%2F%EB%94%94%EB%B9%84%EB%B0%B8%EB%A6%AC%28%EC%A3%BC%29%2F%ED%98%84%EB%8C%80%EC%A4%91%EA%B3%B5%EC%97%85_%ED%98%91%EB%A0%A5%EC%82%AC%28BP%29\",\"IS_FAVORITE_USER\":1,\"ORDERNO\":0,\"NODE_NO\":\"60\",\"PROFILE_MSG\":\"%EB%94%94%EB%B9%84%EB%B0%B8%EB%A6%AC%2FAndroid%20%EB%8B%B4%EB%8B%B9\",\"EX_COMPANY_NM\":\"%ED%98%84%EB%8C%80%EC%A4%91%EA%B3%B5%EC%97%85_%ED%98%91%EB%A0%A5%EC%82%AC%28BP%29\",\"JOB_GRP_NM\":\"\",\"SNS_AUTH_FLAG\":\"TRUE\",\"USER_NM\":\"%EA%B9%80%EC%B0%A8%EC%A2%85\",\"LEVEL_NM\":\"\",\"LEVEL_NO\":\"\",\"PHONE_NO\":\"010-6551-0703\",\"SNS_USER_TYPE\":\"0\",\"EX_COMPANY\":\"\",\"JOB_GRP_CD\":\"\",\"NODE_TY\":\"USER\",\"DUTY_NM\":\"\",\"NODE_IMG\":\"https%3A%2F%2Froms.dbvalley.com%2FsnsService%2FsnsUpload%2Fprofile%2F10%2F60%2F19_boss.png\",\"DUTY_NO\":\"\",\"CUSER_ID\":\"cjkim\",\"NODE_BG_IMG\":\"https%3A%2F%2Ftouch1.hhi.co.kr%2FsnsService%2FsnsUpload%2FprofileBackgound%2F10%2F120819%2Fthumb%2FBP15213%28190403-154705%29.png\"}]}";
    //                NSError *dicError;
    //                dic = [NSJSONSerialization JSONObjectWithData:[ex dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                    
    //                NSArray *dataSet = [dic objectForKey:@"DATASET"];
    //                NSString *userNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"NODE_NO"]];
    //                NSLog(@"userNo : %@", userNo);
                    
                    NSArray *dataSetArr = [dic objectForKey:@"DATASET"];
    //                NSLog(@"dataSetArr : %@", dataSetArr);
                    
    //                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:@"45" userId:@"hilee" userName:@"이혜인" userImg:@"" userMsg:@"" phoneNo:@"" deptNo:@"" userBgImg:@"" deptName:@"" levelNo:@"" levelName:@"" dutyNo:@"" dutyName:@"" jobGrpName:@"" exCompNo:@"UW093" exCompName:@"현대중공업_협력사(BP)" userType:@"0"];
    //                [appDelegate.dbHelper crudStatement:sqlString];
                    
                    for(int i=0; i<dataSetArr.count; i++){
                       NSDictionary *dataSet = [dataSetArr objectAtIndex:i];
                       NSString *userNo = [dataSet objectForKey:@"NODE_NO"];
                       NSString *userId = [NSString urlDecodeString:[dataSet objectForKey:@"CUSER_ID"]];
                       NSString *userName = [NSString urlDecodeString:[dataSet objectForKey:@"USER_NM"]];
                       NSString *userImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_IMG"]];
                       NSString *userMsg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_MSG"]];
                       NSString *phoneNo = [NSString urlDecodeString:[dataSet objectForKey:@"PHONE_NO"]];
                       NSString *deptNo = [dataSet objectForKey:@"DEPT_NO"];
                       NSString *userBgImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_BG_IMG"]];
                       
                       NSString *deptName = [NSString urlDecodeString:[dataSet objectForKey:@"DEPT_NM"]];
                       NSString *levelNo = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NO"]];
                       NSString *levelName = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NM"]];
                       NSString *dutyNo = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NO"]];
                       NSString *dutyName = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NM"]];
                       NSString *jobGrpName = [NSString urlDecodeString:[dataSet objectForKey:@"JOB_GRP_NM"]];
                       NSString *exCompNo = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY"]];
                       NSString *exCompName = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY_NM"]];
                       NSString *userType = [dataSet objectForKey:@"SNS_USER_TYPE"];
                        
                        NSArray *paramArr = [session.decParamStr componentsSeparatedByString:@"&"];
                        for (NSString *str in paramArr) {
                            NSString * key = [[str componentsSeparatedByString:@"="] objectAtIndex:0];
                            NSString * value = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
                            
                            if ([[key lowercaseString] isEqualToString:@"roomno"]) {
                                NSLog(@"roomNo value : %@", value);
    //                            value = @"1632";
                                
                                //목록에 없는 새 채팅방일 경우 CHAT_USERS에 추가
                                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:userImg userMsg:userMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                                [appDelegate.dbHelper crudStatement:sqlString];
                                
                                NSString *sqlString2 = [appDelegate.dbHelper insertChatUsers:value userNo:userNo];
                                [appDelegate.dbHelper crudStatement:sqlString2];
                                
                                //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:value userNo:_myUserNo];
                                [appDelegate.dbHelper crudStatement:sqlString3];
                                
    //                            NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:value userNo:@"45"];
    //                            [appDelegate.dbHelper crudStatement:sqlString3];
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Sync User 끝나면 목록 그리기");
                        [self readFromDatabase];
                        [self.tableView reloadData];
                    });
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            } else if([wsName isEqualToString:@"getRoomList"]){
                @try{
                    NSLog(@"getRoomList : %@", dic);
                    NSArray *dataSet = [dic objectForKey:@"DATASET"];
                    
                    NSUInteger count = dataSet.count;
                    if(count==0){
                        isLoad = NO;
                        
                    } else if(count>0){
                        if(count<pRoomSize){
                            isLoad = NO;
                        } else {
                            isLoad = YES;
                        }
                        
                        if([[NSString stringWithFormat:@"%@", stRoomSeq] isEqualToString:@"1"]){
                            //NSLog(@"새로고침");
                            self.chatArray = [NSMutableArray arrayWithArray:dataSet];
                            
                        } else {
                            [self.chatArray addObjectsFromArray:dataSet];
                        }
                        
                        NSString *seq = [[NSString alloc]init];
                        for(int i=1; i<=count; i++){
                            seq = [NSString stringWithFormat:@"%d", [stRoomSeq intValue]+i];
                        }
                        stRoomSeq = seq;
                        isScroll = YES;
                        
                        
                        //기존 채팅방번호가 있는지 비교
                        NSMutableArray *tempArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getRoomList]];
                        //NSLog(@"tempArr : %@", tempArr);
                        
                        NSMutableArray *currRoomArr = [NSMutableArray array];
                        for (int i=0; i<tempArr.count; i++) {
                            NSDictionary *dictionary = [tempArr objectAtIndex:i];
                            NSString *roomNoStr = [dictionary objectForKey:@"ROOM_NO"];
                            [currRoomArr addObject:roomNoStr];
                        }
//                        NSLog(@"currRoomArr : %@", currRoomArr);
                        
                        NSMutableArray *newRoomArr = [NSMutableArray array];
                        for(int i=0; i<dataSet.count; i++){
                            NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                            NSString *roomNm = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_NM"]];
                            NSString *roomTy = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_TYPE"];
                            NSString *seq = [[dataSet objectAtIndex:i] objectForKey:@"SEQ"];
                            
                            NSString *lastChatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_DATE"]];
                            NSString *lastChatNo = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_NO"];
                            NSString *lastChatUserNo = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CHAT_USER_NO"];
                            NSString *lastContent = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"LAST_CONTENT"]];
                            NSString *lastContentTy = [[dataSet objectAtIndex:i] objectForKey:@"LAST_CONTENT_TY"];
                            NSString *lastUnreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"LAST_UNREAD_COUNT"];
                            NSString *memberCnt = [[dataSet objectAtIndex:i] objectForKey:@"MEMBER_COUNT"];
                            
                            NSString *isRead;
                            if([[NSString stringWithFormat:@"%@", lastUnreadCnt] isEqualToString:@"0"]) isRead = @"1";
                            else isRead = @"0";
                            
                            NSString *aditInfo = @"";
                            if([[NSString stringWithFormat:@"%@", lastChatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                                NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                                [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                                
                                NSError *error;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                                aditInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            }
                            
                            NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
                            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
                            NSDate *date1 = [formatter2 dateFromString:lastChatDate];
                            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                            [formatter3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            NSString *date2 = [formatter3 stringFromDate:date1];
                            
                            NSMutableDictionary *chatDict = [NSMutableDictionary dictionary];
                            [chatDict setObject:date2 forKey:@"LAST_DATE"];
                            [chatDict setObject:roomNo forKey:@"ROOM_NO"];
                            [chatDict setObject:roomNm forKey:@"ROOM_NM"];
                            [chatDict setObject:lastUnreadCnt forKey:@"NOT_READ_COUNT"];
                            [chatDict setObject:roomTy forKey:@"ROOM_TYPE"];
                            [chatDict setObject:lastContentTy forKey:@"CONTENT_TY"];
                            
                            NSError *error;
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[lastContent dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                            NSString *content = [dict objectForKey:@"VALUE"];
                            [chatDict setObject:content forKey:@"CONTENT"];
                            
                            //CHAT_ROOM_INFO (ROOM_NO, ROOM_TPYE, LAST_CHAT_NO, EXIT_FLAG)
                            NSMutableArray *chatInfoArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getChatRoomInfo:roomNo]];
                            if(chatInfoArr.count>0 && [[[chatInfoArr objectAtIndex:0] objectForKey:@"EXIT_FLAG"] isEqualToString:@"Y"]){
                                NSLog(@"1:1이고 나가기 했을 경우 채팅목록에 없어야 함.");
                                //1:1이고 나가기 했을 경우 채팅목록에 없어야 함.
                                //로컬에 저장된 마지막 채팅번호가 웹서비스로 가져온 마지막 번호보다 작으면 표시해야함.
                                //그리고 디비에 엑시트플래그 N으로 변경
                                NSString *dbLastChatNo = [[chatInfoArr objectAtIndex:0] objectForKey:@"LAST_CHAT_NO"];
                                if([lastChatNo intValue] < [dbLastChatNo intValue]){
                                    NSString *insertChatRoomInfo = [appDelegate.dbHelper insertChatRoomInfo:roomNo roomType:roomTy lastChatNo:[NSString stringWithFormat:@"%@", lastChatNo] exitFlag:@"N"];
                                    [appDelegate.dbHelper crudStatement:insertChatRoomInfo];
                                    
                                    [self.chatArray addObject:chatDict];
                                    
                                    NSError *error;
                                    NSArray *roomImgArr = [NSJSONSerialization JSONObjectWithData:[[NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_IMGS"]] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                    
                                    NSMutableArray *roomImg = [[NSMutableArray alloc] init];
                                    NSMutableDictionary *roomUserDict = [[NSMutableDictionary alloc] init];
                                    
                                    for(int j=0; j<roomImgArr.count; j++){
                                        NSString *userNo = [[roomImgArr objectAtIndex:j] objectForKey:@"CUSER_NO"];
                                        NSString *userImg = [NSString urlDecodeString:[[roomImgArr objectAtIndex:j] objectForKey:@"USER_IMG"]];
                                        
                                        [roomUserDict setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d", j+1]];
                                        [roomImg addObject:userImg];
                                    }
                                    
                                    if(currRoomArr.count > 0){
                                        if([currRoomArr containsObject:[NSString stringWithFormat:@"%@", roomNo]]){
//                                            NSLog(@"기존에 있는 방이면 채팅내용만 업데이트");
                                            
                                            NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                            NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                            if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                                NSLog(@"채팅이 없는 경우 인서트");
                                                NSString *sqlString3 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                                [appDelegate.dbHelper crudStatement:sqlString3];
                                            }
                                            
                                        } else {
                                            NSLog(@"방 생성 후 채팅 업데이트 : %@", roomNo);
                                            [newRoomArr addObject:roomNo];
                                            
                                            roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
                                            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
                                            [appDelegate.dbHelper crudStatement:sqlString1];
                                            
                                            NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                            NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                            if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                                NSLog(@"채팅이 없는 경우 인서트");
                                                NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                                [appDelegate.dbHelper crudStatement:sqlString2];
                                            }
                                            
                                            
                                            //유저정보 호출
//                                            NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
//                                            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];
//
//                                            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", self.myUserNo, roomNo, self.myUserNo];
//                                            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//                                            session.delegate = self;
//                                            [session start];
                                            //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                                            NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:_myUserNo];
                                            [appDelegate.dbHelper crudStatement:sqlString3];
                                            
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                                [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
                                                
                                                if(i==dataSet.count-1){
                                                    NSLog(@"새로고침1");
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self readFromDatabase];
                                                        [self.tableView reloadData];
                                                    });
                                                }
                                            });
                                        }
                                        
                                    } else {
                                        NSLog(@"채팅방 없는 경우");
                                        [newRoomArr addObject:roomNo];
                                        
                                        //insert
                                        //채팅방 저장
                                        roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
                                        
                                        NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
                                        [appDelegate.dbHelper crudStatement:sqlString1];
                                        
                                        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                        NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                        if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                            NSLog(@"채팅이 없는 경우 인서트");
                                            NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                            [appDelegate.dbHelper crudStatement:sqlString2];
                                        }
                                        
                                        //유저정보 호출
//                                        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
//                                        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];
//                                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", self.myUserNo, roomNo, self.myUserNo];
//                                        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//                                        session.delegate = self;
//                                        [session start];
                                        //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                                         NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:_myUserNo];
                                         [appDelegate.dbHelper crudStatement:sqlString3];
                                        
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                            [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
                                            
                                            if(i==dataSet.count-1){
                                                NSLog(@"새로고침2");
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self readFromDatabase];
                                                    [self.tableView reloadData];
                                                });
                                            }
                                        });
                                    }
                                    
                                } else {
                                    //마지막 채팅번호가 작거나 같으면 표시 안하면됨.
                                }
                                
                            } else {
                                [self.chatArray addObject:chatDict];
                                
                                NSError *error;
                                NSArray *roomImgArr = [NSJSONSerialization JSONObjectWithData:[[NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"ROOM_IMGS"]] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                
                                NSMutableArray *roomImg = [[NSMutableArray alloc] init];
                                NSMutableDictionary *roomUserDict = [[NSMutableDictionary alloc] init];
                                
                                for(int j=0; j<roomImgArr.count; j++){
                                    NSString *userNo = [[roomImgArr objectAtIndex:j] objectForKey:@"CUSER_NO"];
                                    NSString *userImg = [NSString urlDecodeString:[[roomImgArr objectAtIndex:j] objectForKey:@"USER_IMG"]];
                                    
                                    [roomUserDict setObject:userNo forKey:[NSString stringWithFormat:@"REF_NO%d", j+1]];
                                    [roomImg addObject:userImg];
                                }
                                
                                if(currRoomArr.count > 0){
                                    if([currRoomArr containsObject:[NSString stringWithFormat:@"%@", roomNo]]){
//                                        NSLog(@"기존에 있는 방이면 채팅내용만 업데이트");
                                        
                                        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                        NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                        if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                            NSLog(@"채팅이 없는 경우 인서트");
                                            NSString *sqlString3 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                            [appDelegate.dbHelper crudStatement:sqlString3];
                                        }
                                        
                                    } else {
                                        NSLog(@"방 생성 후 채팅 업데이트 : %@", roomNo);
                                        [newRoomArr addObject:roomNo];
                                        
                                        roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
                                        NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
                                        [appDelegate.dbHelper crudStatement:sqlString1];
                                        
                                        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                        NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                        if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                            NSLog(@"채팅이 없는 경우 인서트");
                                            NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                            [appDelegate.dbHelper crudStatement:sqlString2];
                                        }
                                        
                                        //유저정보 호출
//                                        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
//                                        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];
//                                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", self.myUserNo, roomNo, self.myUserNo];
//                                        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//                                        session.delegate = self;
//                                        [session start];
                                        //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                                         NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:_myUserNo];
                                         [appDelegate.dbHelper crudStatement:sqlString3];
                                        
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                            [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
                                            
                                            if(i==dataSet.count-1){
                                                NSLog(@"새로고침1");
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self readFromDatabase];
                                                    [self.tableView reloadData];
                                                });
                                            }
                                        });
                                    }
                                    
                                } else {
                                    NSLog(@"채팅방이 없는 경우");
                                    [newRoomArr addObject:roomNo];
                                    
                                    //insert
                                    //채팅방 저장
                                    roomNm = [MFUtil createChatRoomName:roomNm roomType:roomTy];
                                    
                                    NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:roomNo roomName:roomNm roomType:roomTy];
                                    [appDelegate.dbHelper crudStatement:sqlString1];
                                    
                                    NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, lastChatNo];
                                    NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                                    if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                                        NSLog(@"채팅이 없는 경우 인서트");
                                        NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateChats2:lastChatNo roomNo:roomNo userNo:lastChatUserNo contentType:lastContentTy content:content localContent:@"" chatDate:lastChatDate fileName:@"" aditInfo:aditInfo isRead:isRead unReadCnt:lastUnreadCnt contentPrev:@""];
                                        [appDelegate.dbHelper crudStatement:sqlString2];
                                    }
                                    
                                    //유저정보 호출
//                                    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
//                                    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];
//                                    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", self.myUserNo, roomNo, self.myUserNo];
//                                    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//                                    session.delegate = self;
//                                    [session start];
                                    //CHAT_USERS에 내번호를 입력하는게 맞는건가 왜냐면 내 번호는 당연히 들어있지 않을까 아닌가
                                     NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:roomNo userNo:_myUserNo];
                                     [appDelegate.dbHelper crudStatement:sqlString3];
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                        [self createChatRoomImg:roomUserDict :roomImg :memberCnt :roomNo];
                                        
                                        if(i==dataSet.count-1){
                                            NSLog(@"새로고침2");
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self readFromDatabase];
                                                [self.tableView reloadData];
                                            });
                                        }
                                    });
                                }
                            }
                            
                            if(i==dataSet.count-1){
                                NSLog(@"새로고침3");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self readFromDatabase];
                                    [self.tableView reloadData];
                                });
                            }
                        }
                    }
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        if (self.chatArray.count>0) {
            @try{
                NSLog(@"chatArray ~~~  : %@", self.chatArray);
                //내가 보낸 메시지에 대해서는 뱃지 처리 안해주면 됨
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                
                NSString *lastDate = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"LAST_DATE"];
                NSString *roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                NSString *roomNm = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                NSString *notReadCount = [[self.tempArr objectAtIndex:indexPath.row] objectForKey:@"NOT_READ_COUNT"];
                NSString *roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
                NSString *contentType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT_TY"];
//                NSString *content = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"]];
                NSString *content = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];
                
                NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
//                formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss.s";
                NSDate *date1 = [formatter2 dateFromString:lastDate];
                NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                [formatter3 setDateFormat:@"yyyy-MM-dd a hh:mm"];
                NSString *date2 = [formatter3 stringFromDate:date1];
//                NSLog(@"date2 : %@", date2);
                
                NSInteger compDate = [self formattedDateCompareToNow:date1];
                NSString *lastDateString = [[NSString alloc]init];
                if(compDate==0) {
                    date2 = [date2 substringFromIndex:lastDate.length-8];
                } else {
//                    date2 = [date2 substringToIndex:lastDate.length-9]; //200820 기존
                    date2 = [date2 substringToIndex:lastDate.length-10];
                }
                lastDateString = date2;
                
                self.chatListCell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatListViewCell" forIndexPath:indexPath];
                
                NSString *roomImage = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomImg:roomNo]];
//                NSLog(@"roomIMGGGGg : %@", roomImage);
                if(roomImage!=nil&&![roomImage isEqualToString:@""]){
                    if([roomImage rangeOfString:@"https://"].location != NSNotFound || [roomImage rangeOfString:@"http://"].location != NSNotFound){
                        NSLog(@"이미지가 URL임");
                        
                    } else {
                        NSString *roomImgPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@", roomNo, roomImage];
                        UIImage *roomImg = [UIImage imageWithContentsOfFile:roomImgPath];
                        if(roomImg){
                            self.chatListCell.chatImage.image = roomImg;
                        } else {
                            NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserNoAndUserImg:roomNo]];
                            
                            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
                            NSMutableArray *roomImgArr = [NSMutableArray array];
                            NSMutableArray *myRoomImgArr = [NSMutableArray array];
                            int roomImgCount = 1;
                            
                            for(int i=0; i<selectArr.count; i++){
                                NSString *chatUserNo = [[selectArr objectAtIndex:i] objectForKey:@"USER_NO"];
                                NSString *chatUserImg = [[selectArr objectAtIndex:i] objectForKey:@"USER_IMG"];
                                
                                if(![[NSString stringWithFormat:@"%@", chatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                                    if(roomImgCount<=4){
                                        if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [roomImgArr addObject:chatUserImg];
                                        [roomUsers setObject:chatUserNo forKey:[NSString stringWithFormat:@"REF_NO%d",roomImgCount]];
                                        roomImgCount++;
                                    }
                                } else {
                                    if(chatUserImg!=nil&&![chatUserImg isEqualToString:@""]) [myRoomImgArr addObject:chatUserImg];
                                }
                            }
                            
                            if(roomUsers.count>0){
//                                NSString *roomImgPath = [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                NSString *roomImgPath = [MFUtil createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                self.chatListCell.chatImage.image = [UIImage imageWithContentsOfFile:roomImgPath];
                                
                            } else {
//                                NSString *roomImgPath = [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                NSString *roomImgPath = [MFUtil createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                self.chatListCell.chatImage.image = [UIImage imageWithContentsOfFile:roomImgPath];
                            }
                        }
                    }
                    
                } else {
                    self.chatListCell.chatImage.image = [UIImage imageNamed:@"profile_default.png"];
                }
               
                if([roomType intValue]==3) {
                    self.chatListCell.myLabel.text = NSLocalizedString(@"me", @"me");
                    self.chatListCell.myLabel.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                    if([self.chatListCell.myLabel.text isEqualToString:@"me"]){
                        self.chatListCell.myLabel.font = [UIFont systemFontOfSize:10];
                    } else {
                        self.chatListCell.myLabel.font = [UIFont systemFontOfSize:12];
                    }
                    self.chatListCell.myLabel.hidden = NO;
                }
                else self.chatListCell.myLabel.hidden = YES;
                
                self.chatListCell.chatName.text = roomNm;
                
                NSError *error;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                
                if([contentType isEqualToString:@"LONG_TEXT"]){
                    self.chatListCell.chatContent.text = content; //200821 기존
//                    self.chatListCell.chatContent.text = [dic objectForKey:@"VALUE"];
                    
                } else if([contentType isEqualToString:@"INVITE"]){
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite")]];
                    
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"icon_mail.png"];
                    textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [attributedString appendAttributedString:attrStringWithImage];
                    [attributedString appendAttributedString:attributedString2];
                    
                    self.chatListCell.chatContent.attributedText = attributedString;
                    
                } else if([contentType isEqualToString:@"TEXT"]){
                    self.chatListCell.chatContent.text = content; //200821 기존
//                    self.chatListCell.chatContent.text = [dic objectForKey:@"VALUE"];
                    
                } else if([contentType isEqualToString:@"IMG"]){
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_image", @"chat_receive_image")]];
                    
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"icon_photo.png"];
                    textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [attributedString appendAttributedString:attrStringWithImage];
                    [attributedString appendAttributedString:attributedString2];
                    
                    self.chatListCell.chatContent.attributedText = attributedString;
                    
                }  else if([contentType isEqualToString:@"VIDEO"]){
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_video", @"chat_receive_video")]];
                    
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"icon_photo.png"];
                    textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [attributedString appendAttributedString:attrStringWithImage];
                    [attributedString appendAttributedString:attributedString2];
                    
                    self.chatListCell.chatContent.attributedText = attributedString;
                    
                } else if([contentType isEqualToString:@"FILE"]){
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_file", @"chat_receive_file")]];
                    
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"file_zip.png"];
                    textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [attributedString appendAttributedString:attrStringWithImage];
                    [attributedString appendAttributedString:attributedString2];
                    
                    self.chatListCell.chatContent.attributedText = attributedString;
                    
                }else {
                    self.chatListCell.chatContent.text = content; //200821 기존
//                    self.chatListCell.chatContent.text = [dic objectForKey:@"VALUE"];
                }
                
                self.chatListCell.chatDate.text = lastDateString;
                
                if([[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"] intValue] <= 2){
                    self.chatListCell.userCountWidth.constant=0;
                    
                } else {
                    self.chatListCell.userCount.text = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"]; //원래 사용하던것 200819
//                    self.chatListCell.userCount.text = [NSString stringWithFormat:@"%@",[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"]];
                    self.chatListCell.userCountWidth.constant=15;
                }
                
                if([notReadCount intValue]>0){
                    self.chatListCell.nChatLabel.hidden = NO;
                    
                    if([notReadCount intValue]>99) {
                        notReadCount = [NSString stringWithFormat:@"99+"];
                        self.chatListCell.nChatWidth.constant = 35;
                    } else {
                        self.chatListCell.nChatWidth.constant = 21;
                    }
                    self.chatListCell.nChatLabel.text = [NSString stringWithFormat:@"%@", notReadCount];
                    newChatCnt = 1;
                    
                } else {
                    self.chatListCell.nChatLabel.hidden = YES;
                }
                
                NSString *roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                
                if([roomNoti isEqualToString:@"1"]){ //on
                    self.chatListCell.chatAlarm.hidden = YES;
                } else {
                    [self.chatListCell.chatAlarm setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"icon_alarm_off2.png"] scaledToMaxWidth:12.0f]];
                    self.chatListCell.chatAlarm.hidden = NO;
                }
                
                NSDictionary *attributes = @{NSFontAttributeName: [self.chatListCell.chatName font]};
                CGSize textSize = [[self.chatListCell.chatName text] sizeWithAttributes:attributes];
                CGFloat strikeWidth = textSize.width;
                
                if(strikeWidth >= 150.0f){
                    self.chatListCell.chatNameWidth.constant = 177;
                    self.chatListCell.chatName.textAlignment = NSTextAlignmentLeft;
                } else{
                    self.chatListCell.chatNameWidth.constant = strikeWidth+3;
                    self.chatListCell.chatName.textAlignment = NSTextAlignmentLeft;
                }
                
                self.chatListCell.leftUtilityButtons = [self leftButtons];
                self.chatListCell.rightUtilityButtons = [self rightButtons:roomNoti :indexPath];
                self.chatListCell.delegate = self;
                
                tableView.scrollEnabled = YES;
                
                NSUInteger tabCount = rootViewController.tabBar.items.count;
                for(int i=0; i<tabCount; i++){
                    if([rootViewController.tabBar.items objectAtIndex:i].tag == 3){
                        if(badgeCnt>0 && badgeCnt<100){
                            [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", badgeCnt];
                            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                        } else if(badgeCnt==0){
                            [[self navigationController] tabBarItem].badgeValue = nil;
                        } else {
                            [[self navigationController] tabBarItem].badgeValue = @"99+";
                            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [[self navigationController] tabBarItem].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                        }
                        break;
                    }
                }
                
                return self.chatListCell;
                
            } @catch(NSException *exception){
                NSLog(@"Exception : %@", exception);
                return self.chatListCell;
            }
        }
        
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
            tableView.scrollEnabled = YES;
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        
        return nil;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
        self.navigationController.navigationBar.topItem.title = @"";
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
        NSLog(@"[채팅목록] ROOM_TYPE : %@", roomType);
        
        if(self.chatArray.count > 0){
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                
                rightViewController.roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                destination.roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                
                rightViewController.roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                rightViewController.roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                rightViewController.roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
            }
            
        } else {
            RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
            CGRect screen = [[UIScreen mainScreen]bounds];
            CGFloat screenWidth = screen.size.width;
            CGFloat screenHeight = screen.size.height;
            rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } else {
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
                destination.roomNoti = @"1";
                rightViewController.roomNo = self.nRoomNo;
                rightViewController.roomNoti = @"1";
                rightViewController.roomName = self.nRoomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                newChatCnt = 0;
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (NSInteger)formattedDateCompareToNow:(NSDate *)date
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
    NSInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
    return dayDiff;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    @try {
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT) {
            //채팅방목록은 새로고침 안함
        }
    } @catch (NSException *exception) {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //스크롤이 하단에 닿을 때 데이터 로드
    //->로우가 추가되는 모양이 부자연스러워서 스크롤이 어느정도 위치에 가면 미리 데이터 로드
    //scrollView.contentSize.height-(self.tableView.frame.size.height/3)
    
    if(scrollView.contentOffset.y>0){
        if (scrollView.contentSize.height-(self.tableView.frame.size.height/1) <= scrollView.contentOffset.y + self.tableView.frame.size.height) {
            if(isLoad && isScroll){
                isScroll = NO;
                
                //싱크 채팅룸 호출
                [self syncChatRoom];
                
            }
        }
    }
}

#pragma mark - SWTableViewDelegate
- (NSArray *)leftButtons{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    //하늘색 125,180,238
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:125.0f/255.0f green:180.0f/255.0f blue:238.0f/255.0f alpha:1.0f] title:@"채팅방이름설정"];
    return leftUtilityButtons;
}
- (NSArray *)rightButtons:(NSString *)roomNoti :(NSIndexPath *)indexPath
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    NSString *noti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
    
    //어두운회색 100,107,115
    if([noti isEqualToString:@"1"]){
        [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:100.0f/255.0f green:107.0f/255.0f blue:115.0f/255.0f alpha:1.0] title:NSLocalizedString(@"popup_room_noti_off", @"popup_room_noti_off")];
    } else {
        [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:100.0f/255.0f green:107.0f/255.0f blue:115.0f/255.0f alpha:1.0] title:NSLocalizedString(@"popup_room_noti_on", @"popup_room_noti_on")];
    }
    
    //빨간색?다홍색? 254,87,37
    [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:254.0f/255.0f green:87.0f/255.0f blue:37.0f/255.0f alpha:1.0f] title:NSLocalizedString(@"popup_room_exit1", @"popup_room_exit1")];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            //NSLog(@"utility buttons closed");
            break;
        case 1:
            //NSLog(@"left utility buttons open");
            break;
        case 2:
            //NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)roomNoti:(NSString *)roomNoti indexPath:(NSIndexPath *)indexPath{
    @try{
        NSString *roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
        
        if([roomNoti isEqualToString:@"1"]){ //on
            self.chatListCell.chatAlarm.hidden = YES;
            [[self.chatArray objectAtIndex:indexPath.row] setObject:@"0" forKey:@"ROOM_NOTI"];
            
//            NSString *urlString = appDelegate.main_url;
//            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&notiFlag=0&refTy=3&refNo=%@&dvcId=%@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]], roomNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
//            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveNotification"]];
//            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//            session.delegate = self;
//            [session start];
            
            NSString *sqlString = [appDelegate.dbHelper updateRoomNoti:0 roomNo:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString];
            
            self.roomNoti = @"0";
            self.chatListCell.rightUtilityButtons = [self rightButtons:self.roomNoti :indexPath];
            [self.tableView reloadData];
            
        } else {
            self.chatListCell.chatAlarm.hidden = NO;
            [[self.chatArray objectAtIndex:indexPath.row] setObject:@"1" forKey:@"ROOM_NOTI"];
            
//            NSString *urlString = appDelegate.main_url;
//            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&notiFlag=1&refTy=3&refNo=%@&dvcId=%@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]], roomNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
//            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveNotification"]];
//            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//            session.delegate = self;
//            [session start];
            
            NSString *sqlString = [appDelegate.dbHelper updateRoomNoti:1 roomNo:roomNo];
            [appDelegate.dbHelper crudStatement:sqlString];
            
            self.roomNoti = @"1";
            self.chatListCell.rightUtilityButtons = [self rightButtons:self.roomNoti :indexPath];
            [self.tableView reloadData];
            
        }
        
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        [dic1 setObject:[NSNumber numberWithBool:[self.roomNoti boolValue]] forKey:@"IS_NOTI"];
        NSData* data1 = [NSJSONSerialization dataWithJSONObject:dic1 options:0 error:nil];
        NSString *json1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        [dic2 setObject:json1 forKey:[NSString stringWithFormat:@"%@", roomNo]];
        NSData* data2 = [NSJSONSerialization dataWithJSONObject:dic2 options:0 error:nil];
        NSString *json2 = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
        NSLog(@"json2 : %@", json2);
        [self notiUpdate:json2];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
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

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {
            [cell hideUtilityButtonsAnimated:YES];
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            NSString *roomName = [[self.chatArray objectAtIndex:cellIndexPath.row] objectForKey:@"ROOM_NM"];
            NSString *roomNo = [[self.chatArray objectAtIndex:cellIndexPath.row] objectForKey:@"ROOM_NO"];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyMessageViewController *destination = (MyMessageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MyMessageViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];

            destination.statusMsg = roomName;
            destination.fromSegue = @"CHAT_SET_ROOM_NAME_MODAL";
            destination.changeRoomNo = roomNo;

            navController.modalTransitionStyle = UIModalPresentationNone;
            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:navController animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {
            [cell hideUtilityButtonsAnimated:YES];
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            NSString *roomNoti = [[self.chatArray objectAtIndex:cellIndexPath.row] objectForKey:@"ROOM_NOTI"];
            [self roomNoti:roomNoti indexPath:cellIndexPath];
            
            break;
        }
        case 1:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            roomIdx = cellIndexPath;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"chat_leave_room_message", @"chat_leave_room_message") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 
                                                                 [self callDeleteChat:roomIdx];
                                                                 [self.chatArray removeObjectAtIndex:roomIdx.row];
                                                                 [self.tempArr removeObjectAtIndex:roomIdx.row];
                                                                 
                                                                 if(roomIdx.row > 0){
                                                                     [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:roomIdx] withRowAnimation:UITableViewRowAnimationFade];
                                                                 } else {
                                                                     [self.tableView reloadData];
                                                                 }
                                                             }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CHAT_DETAIL_PUSH"]) {
        self.navigationController.navigationBar.topItem.title = @"";
        
        ChatViewController *destination = segue.destinationViewController;
  
        if(self.notiClick){
            if(self.chatArray.count > 0){
                NSArray *dataSet = [sender objectForKey:@"DATASET"];
                destination.roomName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"]];
            } else {
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
            }
            self.notiClick = false;
            
        } else {
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            if(self.chatArray.count > 0){
                destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                destination.roomNo = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
            } else {
                destination.roomName = self.nRoomName;
                destination.roomNo = self.nRoomNo;
            }
            self.notiClick = false;
        }
        
    } else if ([[segue identifier] isEqualToString:@"CHAT_NEW_USER_PUSH"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatRoom:) name:@"noti_NewChatRoom" object:nil];
        
    } else if([[segue identifier] isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        UINavigationController *nav = segue.destinationViewController;
        SearchViewController *destination = [nav.childViewControllers objectAtIndex:0];
        destination.fromSegue = segue.identifier;
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
}

@end
