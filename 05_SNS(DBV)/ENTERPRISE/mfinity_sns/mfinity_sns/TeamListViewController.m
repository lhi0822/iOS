//
//  TeamListViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "TeamListViewController.h"
#import "HDNotificationView.h"

#import "TeamSelectController.h"
#import "PostDetailViewController.h"
#import "TaskDetailViewController.h"
#import "BoardCreateViewController.h"
#import "TaskWriteViewController.h"
#import "NotiChatViewController.h"

#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f


@interface TeamListViewController (){
    int badgeCnt;
    
    NSString *cancelSNSNo;
    int notMemberCnt;
    
    UIImage *postCover;
    AppDelegate *appDelegate;
    
    SDImageCache *imgCache;
    
    BOOL isFirst;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
    UILabel *emptyLabel;
}

@property (strong, nonatomic) VCFloatingActionButton *addButton;

@end

@implementation TeamListViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [appDelegate.appPrefs setObject:@"2" forKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]];
    [appDelegate.appPrefs synchronize];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title :NSLocalizedString(@"tab_home", @"tab_home")];
    self.navigationItem.hidesBackButton = YES;
    
    if (self.isEdit) {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title :NSLocalizedString(@"newpost_feed", @"newpost_feed")];
        
        self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(50, 8, self.navigationController.navigationBar.frame.size.width-97, 30)];
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(leftSideMenuButtonPressed:)];
    } else {
        if([[MFSingleton sharedInstance] isMDM]){
            UIButton *left1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
            [left1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_off.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
            [left1 addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftBtn1 = [[UIBarButtonItem alloc]initWithCustomView:left1];
            self.navigationItem.leftBarButtonItem = leftBtn1;
        }
    }
    
    UIButton *right2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [right2 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_search.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
    [right2 addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc]initWithCustomView:right2];
    
    //NSArray *barButtonArr = [[NSArray alloc]initWithObjects:rightBtn1, rightBtn2, nil];
    self.navigationItem.rightBarButtonItem = rightBtn2;
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    NSArray *subViews = [self.navigationController.navigationBar subviews];
    
    for (UIView *subview in subViews) {
        NSString *viewName = [NSString stringWithFormat:@"%@",[subview class]];
        if ([viewName isEqualToString:@"UITextField"]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ModifyBoard:) name:@"noti_ModifyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ForceDeleteSNS:) name:@"noti_ForceDeleteSNS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RefreshTeamList:) name:@"noti_RefreshTeamList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_DismissTeamList:) name:@"noti_DismissTeamList" object:nil];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    isFirst = YES;
    
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, self.view.frame.size.width, self.tableView.frame.size.height-self.tabBarController.tabBar.frame.size.height)];
    emptyLabel.textColor = [UIColor blackColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.numberOfLines = 0;
    [self.tableView addSubview:emptyLabel];
    emptyLabel.hidden = YES;
    
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
        backgroundSupported = device.multitaskingSupported;
    }
    // background 작업을 지원하면
    if(backgroundSupported){
        // System 에 background 작업이 필요함을 알림. 작업의 id 반환
        taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
             NSLog(@"Backgrouund task ran out of time and was terminated");
             [[UIApplication sharedApplication] endBackgroundTask:taskId];
        }];
    }
    
    if([[MFSingleton sharedInstance] useTask]){
        self.segContainer.hidden = NO;
        
        [self.segContainer setFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        self.boardSegment.tintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        
        self.boardSegment.selectedSegmentIndex = 0;
        [self.boardSegment setFrame:CGRectMake(self.boardSegment.frame.origin.x, self.boardSegment.frame.origin.y, self.boardSegment.frame.size.width, 35)];
        [self.boardSegment addTarget:self action:@selector(segmentedChange:) forControlEvents:UIControlEventValueChanged];
        
        self.normalDataArray = [NSMutableArray array];
        self.projectDataArray = [NSMutableArray array];
        
        if([[[MFSingleton sharedInstance] defaultBoard] isEqualToString:@"NORMAL"]){
            [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_normal", @"board_info_kind_normal") forSegmentAtIndex:0];
            [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_project", @"board_info_kind_project") forSegmentAtIndex:1];
            
            //플로팅 버튼
            CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        
            self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
            self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
            self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
            self.addButton.clipsToBounds = YES;
            self.addButton.contentMode = UIViewContentModeScaleAspectFit;
            self.addButton.tag = 100;
            
            self.addButton.imageArray = @[@"floating_board.png",@"floating_write.png"];
            self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_post", @"new_post")];
            
            self.addButton.hideWhileScrolling = YES;
            self.addButton.delegate = self;
            
            self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:self.addButton];
            
            self.selectBoardKind=1;
            [self callWebService:@"getUserSNSLists" :1];
            
        } else {
            [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_normal", @"board_info_kind_normal") forSegmentAtIndex:1];
            [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_project", @"board_info_kind_project") forSegmentAtIndex:0];
            
            //플로팅 버튼
            CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
            self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
            
            self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
            self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
            self.addButton.clipsToBounds = YES;
            self.addButton.contentMode = UIViewContentModeScaleAspectFit;
            
            self.addButton.imageArray = @[@"floating_board.png",@"floating_newproject.png"];
            self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_task", @"new_task")];
            
            self.addButton.hideWhileScrolling = YES;
            self.addButton.delegate = self;
            
            [self.view addSubview:self.addButton];
            
            self.selectBoardKind=2;
            [self callWebService:@"getUserSNSLists" :2];
        }
        
    } else {
        self.segContainer.hidden = YES;
        self.tableViewTopConstraint.constant = 0;
        
        [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_normal", @"board_info_kind_normal") forSegmentAtIndex:0];
        [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_project", @"board_info_kind_project") forSegmentAtIndex:1];
        
        //플로팅 버튼
        CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
        
        self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
        self.addButton.clipsToBounds = YES;
        self.addButton.contentMode = UIViewContentModeScaleAspectFit;
        
        self.addButton.imageArray = @[@"floating_board.png",@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_post", @"new_post")];
        
        self.addButton.hideWhileScrolling = YES;
        self.addButton.delegate = self;
        
        [self.view addSubview:self.addButton];
        
        self.normalDataArray = [NSMutableArray array];
        self.selectBoardKind=1;
        
        [self callWebService:@"getUserSNSLists" :1];
//        [self setSnsListData];
    }
    
    if(appDelegate.inactivePostPushInfo.count>0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:appDelegate.inactivePostPushInfo];
    }
    if(appDelegate.inactiveChatPushInfo.count>0){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatPush" object:nil userInfo:appDelegate.inactiveChatPushInfo];
    }
    appDelegate.currChatRoomNo = nil;
}

-(void)setSnsListData{
    NSString *sqlString = [appDelegate.dbHelper getSnsList:@"1"];
    
    NSMutableArray *snsListArr = [appDelegate.dbHelper selectMutableArray:sqlString];
    NSLog(@"snsListArr : %@", snsListArr);
    self.normalDataArray = snsListArr;
    
    notMemberCnt = 0;
    if(snsListArr.count>0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        emptyLabel.hidden = YES;
        
        for(int i=0; i<snsListArr.count; i++){
            NSDictionary *dataSet = [snsListArr objectAtIndex:i];
            NSString *itemType = [dataSet objectForKey:@"ITEM_TYPE"];
            if(![itemType isEqualToString:@"MEMBER"]){
                notMemberCnt++;
            }
        }
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        emptyLabel.text = NSLocalizedString(@"no_content_normal_board", @"no_content_normal_board");
        emptyLabel.hidden = NO;
    }
//    [self.tableView reloadData];
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
    
    self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
    self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
    self.addButton.clipsToBounds = YES;
    self.addButton.contentMode = UIViewContentModeScaleAspectFit;
    
    if(self.selectBoardKind==1){
        self.addButton.imageArray = @[@"floating_board.png",@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_post", @"new_post")];
        
    } else if(self.selectBoardKind==2){
        self.addButton.imageArray = @[@"floating_board.png",@"floating_newproject.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_task", @"new_task")];
    }
    
    self.addButton.hideWhileScrolling = YES;
    self.addButton.delegate = self;
    
    [self.view addSubview:self.addButton];
}

-(void)createBoard{
    //[self performSegueWithIdentifier:@"BOARD_CREATE_MODAL" sender:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveBoard:) name:@"noti_SaveBoard" object:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BoardCreateViewController *destination = (BoardCreateViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BoardCreateViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
    
    //TASK_CREATE_MODAL
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    TaskWriteViewController *destination = (TaskWriteViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskWriteViewController"];
    //    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    //
    //    navController.modalTransitionStyle = UIModalPresentationNone;
    //    [self presentViewController:navController animated:YES completion:nil];
}

-(void)segmentedChange: (UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 0) {
//        NSLog(@"일반");
        
        //플로팅 버튼 변경
        self.addButton.imageArray = @[@"floating_board.png",@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_post", @"new_post")];
        self.addButton.hideWhileScrolling = YES;
        self.addButton.delegate = self;
        
        if([[[MFSingleton sharedInstance] defaultBoard] isEqualToString:@"NORMAL"]) {
            self.selectBoardKind = 1;
            
            if(isFirst) {
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
                [SVProgressHUD show];
                [self callWebService:@"getUserSNSLists" :1];
                isFirst = NO;
            }
            
        }
        else self.selectBoardKind = 2;
        [self.tableView reloadData];
        
    } else if(sender.selectedSegmentIndex == 1) {
//        NSLog(@"프로젝트");
        
        //플로팅 버튼 변경
        self.addButton.imageArray = @[@"floating_board.png",@"floating_newproject.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_board", @"new_board"),NSLocalizedString(@"new_task", @"new_task")];
        self.addButton.hideWhileScrolling = YES;
        self.addButton.delegate = self;
        
        if([[[MFSingleton sharedInstance] defaultBoard] isEqualToString:@"NORMAL"]) {
            self.selectBoardKind = 2;
            
            if(isFirst) {
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
                [SVProgressHUD show];
                [self callWebService:@"getUserSNSLists" :2];
                isFirst = NO;
            }
        }
        else self.selectBoardKind = 1;
        [self.tableView reloadData];
    }
}

- (void)rightSideMenuButtonPressed:(id)sender {
    if([self.fromSegue isEqualToString:@"POST_SELECT_GROUP_MODAL"]){
        //[self performSegueWithIdentifier:@"POST_BOARD_SEARCH_MODAL" sender:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchViewController *destination = (SearchViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fromSegue = @"POST_BOARD_SEARCH_MODAL";
        
        navController.modalTransitionStyle = UIModalPresentationNone;
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
        
    } else {
        //[self performSegueWithIdentifier:@"BOARD_SEARCH_MODAL" sender:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchViewController *destination = (SearchViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fromSegue = @"BOARD_SEARCH_MODAL";
        
        navController.modalTransitionStyle = UIModalPresentationNone;
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)leftSideMenuButtonPressed:(id)sender {
    if (self.isEdit) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Floating Button Event
-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if(row==0){
        [self createBoard];
        
    } else if(row==1){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TeamListViewController *destination = (TeamListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TeamListViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fromSegue = @"POST_SELECT_GROUP_MODAL";
        destination.isEdit = YES;
        
        navController.modalTransitionStyle = UIModalPresentationNone;
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Push Notification
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
            
            NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
            NSString *postDetailClass = NSStringFromClass([vc class]);
            
            vc.fromSegue = @"NOTI_POST_DETAIL";
            vc.notiPostDic = dict;
            
            if([currentClass isEqualToString:postDetailClass]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostDetailView" object:nil userInfo:dict];
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactivePostPushInfo=nil;
}

-(void)noti_NewTaskPush:(NSNotification *)notification {
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
            
            NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
            NSString *taskDetailClass = NSStringFromClass([vc class]);
            
            vc.fromSegue = @"NOTI_TASK_DETAIL";
            vc.notiTaskDic = dict;
            
            if([currentClass isEqualToString:taskDetailClass]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TaskDetailView" object:nil userInfo:dict];
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_NewChatPush:(NSNotification *)notification {
    @try{
        if(notification.userInfo!=nil){
            appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
            
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

- (void)noti_ModifyBoard:(NSNotification *)notification{
    [self callWebService:@"getUserSNSLists" :1];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_ModifyBoard" object:nil];
}

- (void)noti_ForceDeleteSNS:(NSNotification *)notification{
    [self callWebService:@"getUserSNSLists" :1];
}

- (void)noti_RefreshTeamList:(NSNotification *)notification{
    [self callWebService:@"getUserSNSLists" :1];
}

//- (void)noti_SavePost:(NSNotification *)notification{
//    if([self.fromSegue isEqualToString:@"POST_SELECT_GROUP_MODAL"]){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

//- (void)noti_SaveTask:(NSNotification *)notification{
//    if([self.fromSegue isEqualToString:@"POST_SELECT_GROUP_MODAL"]){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

- (void)noti_SaveBoard:(NSNotification *)notification{
    self.selectBoardKind = [[notification.userInfo objectForKey:@"SNS_KIND"] intValue];
    [self startLoading];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SaveBoard" object:nil];
}

- (void)noti_DismissTeamList:(NSNotification *)notification{
    NSLog(@"selectBoardKind : %d", self.selectBoardKind);
    [self callWebService:@"getUserSNSLists" :self.selectBoardKind];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.selectBoardKind==1){
        if([self.fromSegue isEqualToString:@"POST_SELECT_GROUP_MODAL"]){
            return self.normalDataArray.count-notMemberCnt;
        } else {
            return self.normalDataArray.count;
        }
        
    } else if(self.selectBoardKind==2){
        return self.projectDataArray.count;
    }
    
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectBoardKind==1){
        return 80;
        
    } else if(self.selectBoardKind==2){
        return 80;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectBoardKind==1){
        MFGroupCell *cell = (MFGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"MFGroupCell"];
        
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MFGroupCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[MFGroupCell class]]) {
                    cell = (MFGroupCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        NSDictionary *sns = [self.normalDataArray objectAtIndex:indexPath.row];
        NSString *snsStatus = [sns objectForKey:@"ITEM_TYPE"];
        
        if([self.fromSegue isEqualToString:@"POST_SELECT_GROUP_MODAL"]&&[snsStatus isEqualToString:@"MEMBER"]){
            [self setUpCell:cell atIndexPath:indexPath];
        } else {
            [self setUpCell:cell atIndexPath:indexPath];
        }
        
        cell.gestureRecognizers = nil;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(boardLongClick:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [cell addGestureRecognizer:longPress];
        
        return cell;
        
    } else if(self.selectBoardKind==2){
        MFGroupCell *cell = (MFGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"MFGroupCell"];
        
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MFGroupCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[MFGroupCell class]]) {
                    cell = (MFGroupCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        [self setUpProjectCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (void)setUpCell:(MFGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        cell.label3.hidden = YES;
        cell.requestBtn.hidden = YES;
        
        [cell.inviteBtn setFrame:CGRectMake(cell.inviteBtn.frame.origin.x, cell.inviteBtn.frame.origin.y, cell.inviteBtn.frame.size.width, cell.inviteBtn.frame.size.height)];
        [cell.requestBtn setFrame:CGRectMake(cell.requestBtn.frame.origin.x, cell.requestBtn.frame.origin.y, cell.requestBtn.frame.size.width, cell.requestBtn.frame.size.height)];
        
        NSDictionary *sns = [self.normalDataArray objectAtIndex:indexPath.row];
        
        NSString *coverImg = [NSString urlDecodeString:[sns objectForKey:@"COVER_IMG"]];
        NSString *snsName = [NSString urlDecodeString:[sns objectForKey:@"SNS_NM"]];
        NSString *snsDesc = [NSString urlDecodeString:[sns objectForKey:@"SNS_DESC"]];
        NSString *createUser = [NSString urlDecodeString:[sns objectForKey:@"CREATE_USER_NM"]];
        NSString *userCnt = [sns objectForKey:@"USER_COUNT"];
        NSString *waitingCnt = [sns objectForKey:@"WAITING_USER_COUNT"];
        NSString *snsStatus = [sns objectForKey:@"ITEM_TYPE"];
        
        if([snsDesc isEqualToString:@""]){
            cell.nameTopConstraint.constant = 10;
            cell.descHeightConstraint.constant = 0;
        } else {
            cell.nameTopConstraint.constant = 0;
            cell.descHeightConstraint.constant = 18;
        }
        
        postCover = nil;
        if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&![coverImg isEqualToString:@"(null)"]&&coverImg!=nil){
            [cell.snsImageView sd_setImageWithURL:[NSURL URLWithString:coverImg] placeholderImage:nil options:SDWebImageRefreshCached];
            
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[UIImage imageNamed:@"cover3-2.png"]];
            cell.snsImageView.image = postCover;
        }
        
        cell.snsName.text = snsName;
        cell.snsDesc.text = snsDesc;
        
        if([[MFSingleton sharedInstance] boardInfoIcon]){
            [cell.leaderBtn setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(11, 11) :[UIImage imageNamed:@"icon_crown.png"]] forState:UIControlStateNormal];
            [cell.leaderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)];
        } else {
            [cell.leaderBtn setImage:nil forState:UIControlStateNormal];
            [cell.leaderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        [cell.leaderBtn setBackgroundColor:[UIColor clearColor]];
        
        [cell.leaderBtn setTitle:createUser forState:UIControlStateNormal];
        if([createUser isEqualToString:@"관리자"]){
            [cell.leaderBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [cell.leaderBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        [cell.memberBtn setBackgroundColor:[UIColor clearColor]];
        if([[MFSingleton sharedInstance] boardInfoIcon]){
            [cell.memberBtn setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(11, 11) :[UIImage imageNamed:@"icon_member.png"]] forState:UIControlStateNormal];
            [cell.memberBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)];
        } else {
            [cell.memberBtn setImage:nil forState:UIControlStateNormal];
            [cell.memberBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        [cell.memberBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_member_count1", @"board_info_member_count1"), userCnt] forState:UIControlStateNormal]; //멤버
        
        if([waitingCnt intValue]>0){
            cell.label2.hidden = NO;
            cell.inviteBtn.hidden = NO;
            [cell.inviteBtn setBackgroundColor:[UIColor clearColor]];
            if([[MFSingleton sharedInstance] boardInfoIcon]){
                [cell.inviteBtn setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(11, 11) :[UIImage imageNamed:@"icon_mail.png"]] forState:UIControlStateNormal];
                [cell.inviteBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)];
            } else {
                [cell.inviteBtn setImage:nil forState:UIControlStateNormal];
                [cell.inviteBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
            [cell.inviteBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_invite_count", @"board_info_invite_count"), waitingCnt] forState:UIControlStateNormal]; //신청
            
        } else {
            cell.label2.hidden = YES;
            cell.inviteBtn.hidden = YES;
        }
        
        cell.statusBtn.image = nil;
        cell.statusBtn.contentMode = UIViewContentModeScaleAspectFit;
        if([snsStatus isEqualToString:@"MEMBER"]){
            cell.statusBtn.hidden = NO;
        } else if([snsStatus isEqualToString:@"JOIN_STANDBY"]){
            [cell.statusBtn setImage:[UIImage imageNamed:@"icon_standby.png"]];
            cell.statusBtn.hidden = NO;
        } else if([snsStatus isEqualToString:@"NOMEMBER"]){
            [cell.statusBtn setImage:[UIImage imageNamed:@"icon_nonmember.png"]];
            cell.statusBtn.hidden = NO;
        } else {
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setUpProjectCell:(MFGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        [cell.inviteBtn setFrame:CGRectMake(cell.inviteBtn.frame.origin.x, cell.inviteBtn.frame.origin.y, cell.inviteBtn.frame.size.width, cell.inviteBtn.frame.size.height)];
        [cell.inviteBtn setBackgroundColor:[UIColor yellowColor]];
        
        [cell.requestBtn setFrame:CGRectMake(cell.requestBtn.frame.origin.x, cell.requestBtn.frame.origin.y, cell.requestBtn.frame.size.width, cell.requestBtn.frame.size.height)];

        NSDictionary *sns = [self.projectDataArray objectAtIndex:indexPath.row];
        NSString *coverImg = [NSString urlDecodeString:[sns objectForKey:@"COVER_IMG"]];
        NSString *snsName = [NSString urlDecodeString:[sns objectForKey:@"SNS_NM"]];
        NSString *snsDesc = [NSString urlDecodeString:[sns objectForKey:@"SNS_DESC"]];
        NSString *createUser = [NSString urlDecodeString:[sns objectForKey:@"CREATE_USER_NM"]];
        NSString *userCnt = [sns objectForKey:@"USER_COUNT"];
        NSString *snsStatus = [sns objectForKey:@"ITEM_TYPE"];
//        NSString *waitingCnt = [sns objectForKey:@"WAITING_USER_COUNT"];
        NSString *startTask = [sns objectForKey:@"START_TASK"];
//        NSString *endTask = [sns objectForKey:@"END_TASK"];
//        NSString *holdTask = [sns objectForKey:@"HOLD_TASK"];
        NSString *reqTask = [sns objectForKey:@"REQUEST_TASK"];
//        NSString *totTaskCnt = [sns objectForKey:@"TOTAL_TASK_COUNT"];
        
        if([snsDesc isEqualToString:@""]){
            cell.nameTopConstraint.constant = 10;
            cell.descHeightConstraint.constant = 0;
        } else {
            cell.nameTopConstraint.constant = 0;
            cell.descHeightConstraint.constant = 18;
        }
        
        cell.label3.hidden = YES;
        cell.requestBtn.hidden = YES;
        
        postCover = nil;
        
        if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
            [cell.snsImageView sd_setImageWithURL:[NSURL URLWithString:coverImg] placeholderImage:nil options:0];
            
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[UIImage imageNamed:@"cover3-2.png"]];
            cell.snsImageView.image = postCover;
        }
        
        cell.snsName.text = snsName;
        cell.snsDesc.text = snsDesc;
        
        [cell.leaderBtn setBackgroundColor:[UIColor clearColor]];
        [cell.leaderBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.leaderBtn setTitle:createUser forState:UIControlStateNormal];
        if([createUser isEqualToString:@"관리자"]){
            [cell.leaderBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [cell.leaderBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        [cell.memberBtn setBackgroundColor:[UIColor clearColor]];
        [cell.memberBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.memberBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_member_count1", @"board_info_member_count1"), userCnt] forState:UIControlStateNormal]; //멤버
        
        UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:13];
        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        CGSize textSize = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"task_status2", @"task_status2"), startTask] sizeWithAttributes:attributes]; //진행
        CGFloat strikeWidth = textSize.width;
        
        if([startTask intValue]>0){
            cell.label2.hidden = NO;
            cell.inviteBtn.hidden = NO;
            [cell.inviteBtn setBackgroundColor:[UIColor clearColor]];
            [cell.inviteBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [cell.inviteBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"task_status2", @"task_status2"), startTask] forState:UIControlStateNormal]; //진행
            cell.requestBtnLeftConstraint.constant = strikeWidth+5;
        } else {
            cell.label2.hidden = YES;
            cell.inviteBtn.hidden = YES;
            cell.requestBtnLeftConstraint.constant = -5;
        }
        
        if([reqTask intValue]>0){
            cell.label3.hidden = NO;
            cell.requestBtn.hidden = NO;
            [cell.requestBtn setBackgroundColor:[UIColor clearColor]];
            [cell.requestBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [cell.requestBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"task_status1", @"task_status1"), reqTask] forState:UIControlStateNormal]; //요청
        } else {
            cell.label3.hidden = YES;
            cell.requestBtn.hidden = YES;
        }
        
        cell.statusBtn.image = nil;
        cell.statusBtn.contentMode = UIViewContentModeScaleAspectFit;
        if([snsStatus isEqualToString:@"MEMBER"]){
            cell.statusBtn.hidden = NO;
        } else if([snsStatus isEqualToString:@"JOIN_STANDBY"]){
            [cell.statusBtn setImage:[UIImage imageNamed:@"icon_standby.png"]];
            cell.statusBtn.hidden = NO;
        } else if([snsStatus isEqualToString:@"NOMEMBER"]){
            [cell.statusBtn setImage:[UIImage imageNamed:@"icon_nonmember.png"]];
            cell.statusBtn.hidden = NO;
        } else {
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        NSString *snsNo;
        NSString *snsName;
        NSString *itemType;
        NSDictionary *snsInfoDic = [NSDictionary dictionary];
        
        if(self.selectBoardKind==1){
            snsNo = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
            snsName = [NSString urlDecodeString:[[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
            itemType = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"ITEM_TYPE"];
            snsInfoDic = [self.normalDataArray objectAtIndex:indexPath.row];
            
        } else if(self.selectBoardKind==2){
            snsNo = [[self.projectDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
            snsName = [NSString urlDecodeString:[[self.projectDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
            itemType = [[self.projectDataArray objectAtIndex:indexPath.row] objectForKey:@"ITEM_TYPE"];
            snsInfoDic = [self.projectDataArray objectAtIndex:indexPath.row];
        }
        
        dispatch_async (dispatch_get_main_queue (), ^ {
            if (self.isEdit) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                if(self.selectBoardKind==1){
                    PostWriteTableViewController *vc = (PostWriteTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostWriteTableViewController"];
//                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    
                    vc.snsNo = snsNo;
                    vc.snsName = snsName;
                    vc.fromSegue = @"POST_WRITE_PUSH";
                    
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SavePost:) name:@"noti_SavePost" object:nil];
                    
                    self.navigationController.navigationBar.topItem.title = @"";
//                    [self presentViewController:nav animated:YES completion:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    
                } else if(self.selectBoardKind==2){
                    TaskWriteViewController *vc = (TaskWriteViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskWriteViewController"];
//                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    
                    vc.snsNo = snsNo;
                    vc.snsName = snsName;
                    vc.fromSegue = @"TASK_WRITE_PUSH";
                    
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveTask:) name:@"noti_SaveTask" object:nil];
                    
                    self.navigationController.navigationBar.topItem.title = @"";
//                    [self presentViewController:nav animated:YES completion:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            } else {
                if([itemType isEqualToString:@"MEMBER"]){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    TeamSelectController *vc = (TeamSelectController *)[storyboard instantiateViewControllerWithIdentifier:@"TeamSelectController"];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    
                    vc.snsNo = snsNo;
                    vc.snsName = snsName;
                    //vc.snsInfoDic = snsInfoDic;
                    vc.fromSegue = @"BOARD_SELECT_TEAM";
                    vc.selectBoardKind = self.selectBoardKind;
                    
                    self.navigationController.navigationBar.topItem.title = @"";
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:nav animated:YES completion:nil];
                    
                } else if([itemType isEqualToString:@"NOMEMBER"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast7", @"join_sns_toast7") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else if([itemType isEqualToString:@"JOIN_STANDBY"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast6", @"join_sns_toast6") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        });
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)boardLongClick:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        NSString *itemType = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"ITEM_TYPE"];
        if([itemType isEqualToString:@"JOIN_STANDBY"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast8", @"join_sns_toast8") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 cancelSNSNo = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 [self callWebService:@"withdrawSNS" :0];
                                                             }];
            UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action){
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            
            [alert addAction:okButton];
            [alert addAction:cancelButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        
    }
}

- (void)callWebService:(NSString *)serviceName :(int)snsKind{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; 
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    NSString *paramString = nil;
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    if([serviceName isEqualToString:@"getUserSNSLists"]){
        paramString = [NSString stringWithFormat:@"compNo=%@&usrId=%@&snsKind=%d&searchNm=""&dvcId=%@",compNo, [appDelegate.appPrefs objectForKey:@"USERID"], snsKind, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        
    } else if([serviceName isEqualToString:@"withdrawSNS"]){
        //isJoin("true":탈퇴 or "false":가입신청취소) 이 화면에서는 가입신청취소의 경우만.
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&snsNo=%@&mfpsId=%@&isJoin=false&dvcId=%@", myUserNo, compNo, cancelSNSNo, mfpsId,[appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        cancelSNSNo = nil;
    }
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if([session start]){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
    
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    }else{
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSDictionary *dic = session.returnDictionary;
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getUserSNSLists"]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    //Run your loop here
//                    dispatch_async(dispatch_get_main_queue(), ^(void) {
//                         //stop your HUD here
//                         //This is run on the main thread
                        if(self.selectBoardKind==1){
                            notMemberCnt=0;
                            
                            self.normalDataArray = [dic objectForKey:@"DATASET"];
                            if(self.normalDataArray.count>0) {
                                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                emptyLabel.hidden = YES;
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                if(!appDelegate.teamListRefresh){
                                    for(int i=0; i<self.normalDataArray.count; i++){
                                        NSDictionary *dataSet = [self.normalDataArray objectAtIndex:i];
                                        NSString *snsType = [dataSet objectForKey:@"SNS_TY"];
                                        NSString *snsNo = [dataSet objectForKey:@"SNS_NO"];
                                        NSString *snsName = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_NM"]];
                                        NSString *needAllow = [dataSet objectForKey:@"NEED_ALLOW"];
                                        NSString *snsDesc = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_DESC"]];
                                        NSString *coverImg = [NSString urlDecodeString:[dataSet objectForKey:@"COVER_IMG"]];
                                        NSString *createUserNo = [dataSet objectForKey:@"CREATE_USER_NO"];
                                        NSString *createDate = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_DATE"]];
                                        NSString *compNo = [dataSet objectForKey:@"COMP_NO"];
                                        NSString *snsKind = [dataSet objectForKey:@"SNS_KIND"];
                                        NSString *itemType = [dataSet objectForKey:@"ITEM_TYPE"];
                                        NSString *createUserNm = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_USER_NM"]];
            //                            NSString *userCount = [dataSet objectForKey:@"USER_COUNT"];
            //                            NSString *waitingCount = [dataSet objectForKey:@"WAITING_USER_COUNT"];
                                        
                                        NSString *userList = [NSString urlDecodeString:[dataSet objectForKey:@"USER_LIST"]];
                                        
                                        NSData *jsonData = [userList dataUsingEncoding:NSUTF8StringEncoding];
                                        NSError *error;
                                        NSArray *userArr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                                        
                                        for(int i=0; i<userArr.count; i++){
                                            NSString *sqlStr = [appDelegate.dbHelper insertSnsUser:snsNo userNo:[userArr objectAtIndex:i]];
                                            [appDelegate.dbHelper crudStatement:sqlStr];
                                        }
                                        
                                        //이미지캐싱
                                        //normalImgCache = [SDImageCache sharedImageCache];
                                        //NSString *tmpPath = NSTemporaryDirectory();
                                        //NSString *imgPath = [tmpPath stringByAppendingPathComponent:@"cache"];
                                        //[normalImgCache makeDiskCachePath:imgPath];
                                        
                                        if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
                                            UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
                                            if(image!=nil){
                                                postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :image];
                                                [imgCache storeImage:postCover forKey:coverImg toDisk:YES];
                                            }
                                        }
                                        
                                        if([snsKind isEqualToString:@"Normal"]) snsKind = @"1";
                                        else snsKind = @"2";
                                        
                                        if(![itemType isEqualToString:@"MEMBER"]){
                                            notMemberCnt++;
                                        }
                                        
                                        NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getSnsNo:snsNo]];
        //                                NSLog(@"TeamList SelectArr ; %@", selectArr);
                                        if(selectArr.count>0){
                                            //POST_NOTI INTEGER DEFAULT 1, COMMENT_NOTI
                                            NSString *sqlString = [appDelegate.dbHelper updateSnsInfo:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg snsNo:snsNo];
                                            [appDelegate.dbHelper crudStatement:sqlString];

                                            NSString *sqlString2 = [appDelegate.dbHelper updateSnsMemberInfo:createUserNo createUserNm:createUserNm snsNo:snsNo];
                                            [appDelegate.dbHelper crudStatement:sqlString2];

                                        } else {
                                            NSString *sqlString = [appDelegate.dbHelper insertOrUpdateSns:snsNo snsName:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg createUserNo:createUserNo createUserNm:createUserNm createDate:createDate compNo:compNo snsKind:snsKind];
                                            [appDelegate.dbHelper crudStatement:sqlString];
                                        }
                                    }
                                    
                                } else {
                                    appDelegate.teamListRefresh = NO;
                                }
                                });
                                
                            } else {
                                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                emptyLabel.text = NSLocalizedString(@"no_content_normal_board", @"no_content_normal_board");
                                emptyLabel.hidden = NO;
                            }
                            
                        } else if(self.selectBoardKind==2){
                            notMemberCnt=0;
                            
                            self.projectDataArray = [dic objectForKey:@"DATASET"];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            if(self.projectDataArray.count>0) {
                                for(int i=0; i<self.projectDataArray.count; i++){
                                    NSDictionary *dataSet = [self.projectDataArray objectAtIndex:i];
                                    NSString *snsType = [dataSet objectForKey:@"SNS_TY"];
                                    NSString *snsNo = [dataSet objectForKey:@"SNS_NO"];
                                    NSString *snsName = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_NM"]];
                                    NSString *needAllow = [dataSet objectForKey:@"NEED_ALLOW"];
                                    NSString *snsDesc = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_DESC"]];
                                    NSString *coverImg = [NSString urlDecodeString:[dataSet objectForKey:@"COVER_IMG"]];
                                    NSString *createUserNo = [dataSet objectForKey:@"CREATE_USER_NO"];
                                    NSString *createDate = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_DATE"]];
                                    NSString *compNo = [dataSet objectForKey:@"COMP_NO"];
                                    NSString *snsKind = [dataSet objectForKey:@"SNS_KIND"];
                                    NSString *itemType = [dataSet objectForKey:@"ITEM_TYPE"];
                                    NSString *createUserNm = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_USER_NM"]];
//                                    NSString *userCount = [dataSet objectForKey:@"USER_COUNT"];
//                                    NSString *waitingCount = [dataSet objectForKey:@"WAITING_USER_COUNT"];
                                    
                                    //이미지캐싱
                                    if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
                                        UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
                                        if(image!=nil){
                                            postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :image];
                                            [imgCache storeImage:postCover forKey:coverImg toDisk:YES];
                                        }
                                    }
                                    
                                    if([snsKind isEqualToString:@"Normal"]) snsKind = @"1";
                                    else snsKind = @"2";
                                    
                                    if(![itemType isEqualToString:@"MEMBER"]){
                                        notMemberCnt++;
                                    }
                                    
                                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateSns:snsNo snsName:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg createUserNo:createUserNo createUserNm:createUserNm createDate:createDate compNo:compNo snsKind:snsKind];
                                    [appDelegate.dbHelper crudStatement:sqlString];
                                }
                            } else {
                                
                            }
                            });
                        }
                
                        // background 작업의 종료를 알린다.
                        NSLog(@"background 작업의 종료를 알린다.");
                        [[UIApplication sharedApplication] endBackgroundTask:taskId];
                
                        //                if([AppDelegate isProject]){
                        //                    if(self.boardSegment.selectedSegmentIndex==0){
                        //                        [self segmentedChange:self.boardSegment];
                        //                    }
                        //                } else {
                        [self.tableView reloadData];
                        //                }
                
//                    });
//                });
                
            } else if([wsName isEqualToString:@"withdrawSNS"]){
                [self callWebService:@"getUserSNSLists" :1];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast9", @"join_sns_toast9") message:nil preferredStyle:UIAlertControllerStyleAlert];
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

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
    
    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
//        [self callWebService:@"getUserSNSLists" :1];
    }
    [self reconnectFromError];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    if ([[segue identifier] isEqualToString:@"POST_WRITE_PUSH"]) {
        PostWriteTableViewController *destination = segue.destinationViewController;
        destination.snsNo = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
        destination.snsName = [NSString urlDecodeString:[[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
        destination.fromSegue = segue.identifier;
        self.navigationController.navigationBar.topItem.title = @"";
        
    } else if ([[segue identifier] isEqualToString:@"BOARD_SEARCH_MODAL"]) {
        UINavigationController *nav = segue.destinationViewController;
        SearchViewController *destination = [nav.childViewControllers objectAtIndex:0];
        destination.fromSegue = segue.identifier;
        
    } else if ([[segue identifier] isEqualToString:@"POST_BOARD_SEARCH_MODAL"]) {
        UINavigationController *nav = segue.destinationViewController;
        SearchViewController *destination = [nav.childViewControllers objectAtIndex:0];
        destination.fromSegue = segue.identifier;
        
    } /*else if([[segue identifier] isEqualToString:@"BOARD_SELECT_TEAM"]){
       UINavigationController *nav = segue.destinationViewController;
       TeamSelectController *destination = [nav.childViewControllers objectAtIndex:0];
       //TeamSelectController *destination = segue.destinationViewController;
       destination.snsNo = [[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
       destination.snsName = [NSString urlDecodeString:[[self.normalDataArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
       destination.snsInfoDic = [self.normalDataArray objectAtIndex:indexPath.row];
       destination.fromSegue = segue.identifier;
       self.navigationController.navigationBar.topItem.title = @"";
       //self.navigationController.navigationBar.backgroundColor = [UIColor yellowColor];
       
       }*/ else if([[segue identifier] isEqualToString:@"BOARD_CREATE_MODAL"]){
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveBoard:) name:@"noti_SaveBoard" object:nil];
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

        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.tableView.frame.size.height) {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 10;
            if(y > h + reload_distance) {
                //데이터로드
            }
        }
        [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT){
        [self startLoading];
    }
}
- (void)startLoading {
    NSLog();
    @try {
        //데이터새로고침
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
        
        if(self.selectBoardKind==1){
            [self callWebService:@"getUserSNSLists" :1];
        } else if(self.selectBoardKind==2){
            [self callWebService:@"getUserSNSLists" :2];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //
    //    if(scrollOffsetY > 0) {
    //        self.tableView.contentInset = UIEdgeInsetsZero;
    //    } else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT) {
    //        self.tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
    //    }
}

-(void)setTimer{
    timerCount = 0;
    timerEndCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
-(void)handleTimer:(NSTimer *)timer {
    timerCount++;
    if (timerCount==timerEndCount) {
        [self callWebService:@"getUserSNSLists" :1];
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

@end

