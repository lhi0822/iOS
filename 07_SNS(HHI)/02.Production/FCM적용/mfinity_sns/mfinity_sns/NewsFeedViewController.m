//
//  NewsFeedViewController.m
//  mfinity_sns
//
//  Created by hilee on 31/01/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "PostDetailViewController.h"

#import "ProjectCollectionViewCell.h"
#import "TaskDetailViewController.h"
#import "TaskWriteViewController.h"

#import "CustomHeaderViewController.h"
#import "TutorialViewController.h"

#import "UIImageView+AFNetworking.h"
#import "AFHTTPSessionManager.h"

#import "SDWebImagePrefetcher.h"
#import "NotiChatViewController.h"

#define REFRESH_TABLEVIEW_DEFAULT_ROW               64.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f

#define MODEL_NAME [[UIDevice currentDevice] modelName]

@interface NewsFeedViewController () {
    BOOL isError;
    AppDelegate *appDelegate;
    int initKind;
    SDImageCache *imgCache;
    SDWebImageManager *imageManager;
    
    int datasetCnt;
    int cachingCnt;
    int dataCnt;
    
    BOOL isLoad;
    int firstImgCnt;
    int allDataCnt;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
    BOOL isAutoLoad;
    BOOL isManualLoad;
    
    NSMutableArray *tmpDataArr;
    
    UILabel *emptyLabel;
}

@property (strong, nonatomic) VCFloatingActionButton *addButton;


@end

@implementation NewsFeedViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_FeedProfileChat:) name:@"noti_FeedProfileChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ForceDeleteSNS:) name:@"noti_ForceDeleteSNS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RefreshFeed:) name:@"noti_RefreshFeed" object:nil];
    
    
//    [self callWebService:@"deletePost"];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    imageManager = [SDWebImageManager sharedManager];
    
    //캐시삭제
//    [[SDImageCache sharedImageCache] clearMemory];
//    [[SDImageCache sharedImageCache] clearDisk];
    
    isError = NO;
    isLoad = NO;
    
    isAutoLoad = NO;
    isManualLoad = NO;
    
    firstImgCnt=0;
    allDataCnt=0;
    
    tmpDataArr = [NSMutableArray array];
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.prefetchDataSource = self;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIButton *left1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [left1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_off.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
    [left1 addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn1 = [[UIBarButtonItem alloc]initWithCustomView:left1];
    self.navigationItem.leftBarButtonItem = leftBtn1;
    
    UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [right1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_search.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
    [right1 addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
    
    self.navigationItem.rightBarButtonItem = rightBtn1;
    
    appDelegate.currChatRoomNo = nil;
    
    self.profileImgArray = [NSMutableArray array];
    self.contentsImgArray = [NSMutableArray array];
    self.timeArray = [NSMutableArray array];
    self.writerNameArray = [NSMutableArray array];
    self.descriptionArray = [NSMutableArray array];
    self.cardSizeArray = [NSMutableArray array];
    self.snsNameArray = [NSMutableArray array];
    
    self.lastPostNo = @"1";
    self.lastTaskNo = @"1";
    cachingCnt = 0;
    datasetCnt = 0;
    dataCnt = 0;
    
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
            taskId = UIBackgroundTaskInvalid;
        }];
    }
    
    if([[MFSingleton sharedInstance] useTask]){
        self.segContainer.hidden=NO;
        
        [self.segContainer setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, 60)];
        self.boardSegment.tintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_normal", @"board_info_kind_normal") forSegmentAtIndex:0];
        [self.boardSegment setTitle:NSLocalizedString(@"board_info_kind_project", @"board_info_kind_project") forSegmentAtIndex:1];
        
        self.boardSegment.selectedSegmentIndex=0;
        [self.boardSegment setFrame:CGRectMake(self.boardSegment.frame.origin.x, self.boardSegment.frame.origin.y, self.boardSegment.frame.size.width, 35)];
        [self.boardSegment addTarget:self action:@selector(segmentedChange:) forControlEvents:UIControlEventValueChanged];
        
        self.normalDataArray = [NSMutableArray array];
        self.projectDataArray = [NSMutableArray array];
        
        if([[[MFSingleton sharedInstance] defaultBoard] isEqualToString:@"NORMAL"]){
            //플로팅 버튼
            //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, [UIScreen mainScreen].bounds.size.height-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
            CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
            self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
            
            self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
            self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
            self.addButton.clipsToBounds = YES;
            self.addButton.contentMode = UIViewContentModeScaleAspectFit;
            
            //[self.addButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            
            self.addButton.imageArray = @[@"floating_write.png"];
            self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
            
            self.addButton.hideWhileScrolling = YES;
            self.addButton.delegate = self;
            
            [self.view addSubview:self.addButton];
        }
        
        self.selectBoardKind=1;
        [self callWebService:@"getPostLists"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.selectBoardKind=2;
            [self callWebService:@"getTaskLists"];
        });
        
    } else {
        //플로팅 버튼
        //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, [UIScreen mainScreen].bounds.size.height-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.tabBarController.tabBar.frame.origin.y-self.tabBarController.tabBar.frame.size.height-70, 50, 50);
        self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
        
        self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
        self.addButton.clipsToBounds = YES;
        self.addButton.contentMode = UIViewContentModeScaleAspectFit;
        
        //[self.addButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        
        self.addButton.imageArray = @[@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
        
        self.addButton.hideWhileScrolling = YES;
        self.addButton.delegate = self;
        
        [self.view addSubview:self.addButton];
        
        self.segContainer.hidden=YES;
        self.tableViewTopConstraint.constant=0;
        
        self.normalDataArray = [NSMutableArray array];
        self.selectBoardKind=1;
        [self callWebService:@"getPostLists"];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            //Run your loop here
//            NSLog(@"여기서 호출");
//            [self callWebService:@"getPostLists"];
////            dispatch_async(dispatch_get_main_queue(), ^(void) {
////                 //stop your HUD here
////                 //This is run on the main thread
////                NSLog(@"여기서 호출");
////                [self callWebService:@"getPostLists"];
////            });
//        });
    }
    
    if(appDelegate.inactivePostPushInfo.count>0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewPostPush" object:nil userInfo:appDelegate.inactivePostPushInfo];
//        appDelegate.inactivePostPushInfo=nil;
    }
    if(appDelegate.inactiveChatPushInfo.count>0){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewChatPush" object:nil userInfo:appDelegate.inactiveChatPushInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    self.navigationController.navigationBar.translucent = NO;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.appPrefs setObject:@"1" forKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]];
    [appDelegate.appPrefs synchronize];
    
    if(appDelegate.canFeedRefresh){
        self.lastPostNo = @"1";
        appDelegate.canFeedRefresh = NO;
        [self refreshCallGetPostList];
    }
    
    if(isError){
        [self callWebService:@"getPostLists"];
        isError=NO;
    }
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.isBoard) {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.snsName];
        
    } else {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
    }
    
    if([[appDelegate.appPrefs objectForKey:@"IS_TUTORIAL"] isEqual:@"YES"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TutorialViewController *destination = (TutorialViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        navController.modalTransitionStyle = UIModalPresentationNone;
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_home.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:YES];
    self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
    self.addButton.clipsToBounds = YES;
    self.addButton.contentMode = UIViewContentModeScaleAspectFit;
    
    if(self.selectBoardKind==1){
        self.addButton.imageArray = @[@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
        
    } /*else if(self.selectBoardKind==2){
       
       }*/
    
    self.addButton.hideWhileScrolling = YES;
    self.addButton.delegate = self;
    
    [self.view addSubview:self.addButton];
}

-(void)segmentedChange: (UISegmentedControl *)sender{
    @try{
        if(sender.selectedSegmentIndex == 0) {
            //            NSLog(@"일반");
            self.selectBoardKind = 1;
            
            //플로팅 버튼 변경
            self.addButton.imageArray = @[@"floating_write.png"];
            self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
            self.addButton.hideWhileScrolling = YES;
            self.addButton.delegate = self;
            
            [self.tableView reloadData];
            
        } else if(sender.selectedSegmentIndex == 1) {
            //            NSLog(@"프로젝트");
            self.selectBoardKind = 2;
            
            //플로팅 버튼 변경
            self.addButton.imageArray = @[@"floating_write.png"];
            self.addButton.labelArray = @[NSLocalizedString(@"new_task", @"new_task")];
            self.addButton.hideWhileScrolling = YES;
            self.addButton.delegate = self;
            
            [self.tableView reloadData];
        }
    } @catch(NSException *exception){
        
    }
}

#pragma mark - Floating Button Event
-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if(row==0){
        if([MFUtil isWorkingTime]){
            if(self.selectBoardKind==1){
                [self createPost:nil];
            } else if(self.selectBoardKind==2){
                [self createTask];
            }
        }
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
//                                                             [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                                                         }
                                                     }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)rightSideMenuButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *destination = (SearchViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    destination.fromSegue = @"POST_SEARCH_MODAL";
    destination.snsNo = self.snsNo;
    
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)rightSideCancelPressed:(id)sender {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg17", @"")
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    
    
    if(self.isBoard) {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.snsName];
    } else {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
    }
}

- (IBAction)createPost:(id)sender {
    if (self.snsNo != nil) {
        
        [self performSegueWithIdentifier:@"POST_WRITE_MODAL" sender:nil];
    }else{
        [self performSegueWithIdentifier:@"POST_SELECT_GROUP_MODAL" sender:nil];
    }
}

-(void)createTask{
    if (self.snsNo != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TaskWriteViewController *destination = (TaskWriteViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskWriteViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fromSegue = @"TASK_WRITE_MODAL";
        destination.snsNo = self.snsNo;
        destination.snsName = self.snsName;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noti_SaveTask:)
                                                     name:@"noti_SaveTask"
                                                   object:nil];
        
        [self presentViewController:navController animated:YES completion:nil];
        
    }else{
        [self performSegueWithIdentifier:@"POST_SELECT_GROUP_MODAL" sender:nil];
    }
}

- (void)tapDetected:(id)sender{
    @try{
        UIImageView *profileButton = (UIImageView *)sender;
        NSDictionary *dic = [NSDictionary dictionary];
        if(self.selectBoardKind==1){
            dic = [self.normalDataArray objectAtIndex:profileButton.tag];
        } else if(self.selectBoardKind==2){
            dic = [self.projectDataArray objectAtIndex:profileButton.tag];
        }
        
        NSString *userNo = [dic objectForKey:@"CUSER_NO"];
        NSString *userType = [dic objectForKey:@"SNS_USER_TYPE"];
        
        CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
        destination.userNo = userNo;
        destination.userType = userType;
        destination.fromSegue = @"POST_PROFILE_MODAL";
        
        destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:destination animated:YES completion:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];//appDelegate.main_url;
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        if([serviceName isEqualToString:@"getPostLists"]){
            self.selectBoardKind=1;
            paramString = [NSString stringWithFormat:@"stPostSeq=%@&usrNo=%@&searchNm=""&dvcId=%@",self.lastPostNo, myUserNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
            
        } else if([serviceName isEqualToString:@"getTaskLists"]){
            self.selectBoardKind=2;
            paramString = [NSString stringWithFormat:@"stTaskSeq=%@&usrNo=%@&searchNm=""&dvcId=%@",self.lastTaskNo, myUserNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
        }
        
//        else if([serviceName isEqualToString:@"deletePost"]){
//            paramString = [NSString stringWithFormat:@"usrNo=120818&postNo=10123"];
//        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if ([session start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)refreshCallGetPostList{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];//appDelegate.main_url;
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        NSString *paramString = [NSString stringWithFormat:@"stPostSeq=1&usrNo=%@&searchNm=""&dvcId=%@", myUserNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        if (self.snsNo!=nil) {
            paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
        }
        
        self.normalDataArray = [[NSMutableArray alloc]init];
        //        tmpDataArr = [[NSMutableArray alloc] init];
        self.lastPostNo = @"1";
        
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getPostLists"]];
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        [session start];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    self.tableView.scrollEnabled = YES;
    
    @try {
        if(error!=nil || [error isEqualToString:@"(null)"]) {
            if ([error isEqualToString:@"The request timed out."]) {
                
            } else {
                NSLog(@"Error Message : %@",error);
            }
            
        } else {
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            
            if ([wsName isEqualToString:@"getPostLists"]) {
                NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                datasetCnt = (int)dataSets.count;
                cachingCnt = 0;
                dataCnt = 0;
                
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=datasetCnt; i++){
                    seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
                    NSArray *contents = [[dataSets objectAtIndex:i-1] objectForKey:@"CONTENT"];
//                    NSLog(@"contents : %@", contents);
                    [self postImgCaching:contents indexPath:[seq intValue]-2];
                }
                /*
                NSLog(@"시작=====================================================");
                dispatch_group_t group = dispatch_group_create();
                dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                    for(int i=0; i<datasetCnt; i++){
                        BOOL isImg = NO;
                        
                        NSArray *contentArr = [[dataSets objectAtIndex:i] objectForKey:@"CONTENT"];
                        NSMutableArray *tmpArr = [NSMutableArray array];
                        
                        for(int j=0; j<contentArr.count; j++){
                            NSString *type = [[contentArr objectAtIndex:j] objectForKey:@"TYPE"];
                            if([type isEqualToString:@"TEXT"]){
                                NSString *value = [[contentArr objectAtIndex:j] objectForKey:@"VALUE"];
                                
                                NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
                                [tmpDict setObject:@"TEXT" forKey:@"TYPE"];
                                [tmpDict setObject:value forKey:@"VALUE"];
                                
                                [tmpArr addObject:tmpDict];
                            }
                            else if([type isEqualToString:@"IMG"]){
                                if(!isImg){
                                    NSDictionary *valueDic = [[contentArr objectAtIndex:j] objectForKey:@"VALUE"];
                                    NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                                    //NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                                    originImg = [originImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    
                                    NSDictionary *imageHeader = [self getImageSizeFromUrl:originImg];
                                    NSLog(@"I(%d) : %@", i, [imageHeader objectForKey:@"PixelHeight"]);
                                    
                                    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
                                    if([imageHeader objectForKey:@"PixelWidth"]!=nil&&[imageHeader objectForKey:@"PixelHeight"]!=nil){
                                        [tmpDict setObject:@"IMG" forKey:@"TYPE"];
                                        [tmpDict setObject:valueDic forKey:@"VALUE"];
                                        [tmpDict setObject:[imageHeader objectForKey:@"PixelWidth"] forKey:@"WIDTH"];
                                        [tmpDict setObject:[imageHeader objectForKey:@"PixelHeight"] forKey:@"HEIGHT"];
                                        
                                    } else {
                                        [tmpDict setObject:@"IMG" forKey:@"TYPE"];
                                        [tmpDict setObject:valueDic forKey:@"VALUE"];
                                        [tmpDict setObject:@"0" forKey:@"WIDTH"];
                                        [tmpDict setObject:@"0" forKey:@"HEIGHT"];
                                    }
                                    
                                    [tmpArr addObject:tmpDict];
                                    
                                    isImg = YES;
                                }
                                
                            } else if([type isEqualToString:@"VIDEO"]) {
                                if(!isImg){
                                    NSDictionary *valueDic = [[contentArr objectAtIndex:j] objectForKey:@"VALUE"];
                                    //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                                    NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                                    thumbImg = [thumbImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    
                                    NSDictionary *imageHeader = [self getImageSizeFromUrl:thumbImg];
                                    NSLog(@"V(%d) : %@", i, [imageHeader objectForKey:@"PixelHeight"]);
                                    
                                    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
                                    if([imageHeader objectForKey:@"PixelWidth"]!=nil&&[imageHeader objectForKey:@"PixelHeight"]!=nil){
                                        [tmpDict setObject:@"IMG" forKey:@"TYPE"];
                                        [tmpDict setObject:valueDic forKey:@"VALUE"];
                                        [tmpDict setObject:[imageHeader objectForKey:@"PixelWidth"] forKey:@"WIDTH"];
                                        [tmpDict setObject:[imageHeader objectForKey:@"PixelHeight"] forKey:@"HEIGHT"];
                                        
                                    } else {
                                        [tmpDict setObject:@"IMG" forKey:@"TYPE"];
                                        [tmpDict setObject:valueDic forKey:@"VALUE"];
                                        [tmpDict setObject:@"0" forKey:@"WIDTH"];
                                        [tmpDict setObject:@"0" forKey:@"HEIGHT"];
                                    }
                                    
                                    [tmpArr addObject:tmpDict];
                                    
                                    isImg = YES;
                                }
                            }
                        }
                        [tmpDataArr replaceObjectAtIndex:i withObject:tmpArr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:tmpDataArr.count-1 inSection:0];
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                        });
                        
                    }
                    
                });
                dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                    NSLog(@"몽땅 로딩 했음!");
                });
                */
                
                if ([result isEqualToString:@"SUCCESS"]) {
                    if ([self.lastPostNo intValue]==1) {
                        self.lastPostNo = seq;
                        self.normalDataArray = [NSMutableArray arrayWithArray:dataSets];
                        
                    } else {
                        if (dataSets.count>0){
                            self.lastPostNo = seq;
                            //[self.normalDataArray addObjectsFromArray:[session.returnDictionary objectForKey:@"DATASET"]]; //thin copy 참조만
                            [self.normalDataArray addObjectsFromArray:dataSets]; //deep copy
                        }
                    }
                    
                    allDataCnt = (int)self.normalDataArray.count;
                    if(allDataCnt>0){
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                        emptyLabel.hidden = YES;
                    } else {
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                        emptyLabel.text = NSLocalizedString(@"no_content_normal_feed", @"no_content_normal_feed");
                        emptyLabel.hidden = NO;
                    }
                    
                    if(dataSets.count>0){
                        if([[MFSingleton sharedInstance] useTask]){
                            if(self.boardSegment.selectedSegmentIndex==0){
                                [self segmentedChange:self.boardSegment];
                            }
                        } else {
                            [self.tableView reloadData];
                            isLoad = YES;
                            
                            isAutoLoad = NO;
                            isManualLoad = NO;
                        }
                    } else {
                        [SVProgressHUD dismiss];
                    }
                    
                    NSLog(@"백그라운드 작업 종료");
                    // background 작업의 종료를 알린다.
                    [[UIApplication sharedApplication] endBackgroundTask:taskId];
                    taskId = UIBackgroundTaskInvalid;

                    
                }else{
                    NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
                    // Background 작업 종료를 알린다.
                    [[UIApplication sharedApplication] endBackgroundTask:taskId];
                    taskId = UIBackgroundTaskInvalid;
                }
                
            } else if([wsName isEqualToString:@"getTaskLists"]){
                NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=dataSets.count; i++){
                    seq = [NSString stringWithFormat:@"%d", [self.lastTaskNo intValue]+i];
                }
                
                if ([result isEqualToString:@"SUCCESS"]) {
                    if ([self.lastTaskNo intValue]==1) {
                        self.lastTaskNo = seq;
                        self.projectDataArray = [NSMutableArray arrayWithArray:dataSets];
                    } else {
                        if (dataSets.count>0){
                            self.lastTaskNo = seq;
                            [self.projectDataArray addObjectsFromArray:dataSets];
                        }
                    }
                    
                    if(dataSets.count>0){
                        if([[MFSingleton sharedInstance] useTask]){
                            if(self.boardSegment.selectedSegmentIndex==0){
                                [self segmentedChange:self.boardSegment];
                            }
                        } else {
                            [self.tableView reloadData];
                        }
                    } else {
                        
                    }
                    
                } else{
                    NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
                }
            }
        }
        [self stopLoading];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);

    [SVProgressHUD dismiss];
    @try{
        if(error.code == -1009){
            isError=YES;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"인터넷 연결이 오프라인 상태입니다." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if(error.code == -1001){
            //요청한 시간이 초과되었습니다.
            //[self callWebService:@"getPostLists"];
        }
        
        [self reconnectFromError];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
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
                taskId = UIBackgroundTaskInvalid;
            }];
        }
        
        [self callWebService:@"getPostLists"];
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

#pragma mark - UITableView Delegate & Datasrouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try{
        if(self.selectBoardKind==1){
            return [self.normalDataArray count];
//            return tmpDataArr.count;
            
        } else if(self.selectBoardKind==2){
            return [self.projectDataArray count];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectBoardKind==1){
        @try{
            NewsFeedViewCell *feedCell = (NewsFeedViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewsFeedViewCell"];
            if (feedCell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedViewCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[NewsFeedViewCell class]]) {
                        feedCell = (NewsFeedViewCell *) currentObject;
                        [feedCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            [self setNewsFeedCell:feedCell indexPath:indexPath];
            
            return feedCell;
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
        
    } /*else if(self.selectBoardKind==2){
       @try{
       [self.collectionView registerNib:[UINib nibWithNibName:@"ProjectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ProjectCollectionViewCell"];
       ProjectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectCollectionViewCell" forIndexPath:indexPath];
       
       if(cell!=nil && self.projectDataArray.count>0){
       NSDictionary *dataSetItem = [self.projectDataArray objectAtIndex:indexPath.item];
       NSLog(@"dataSetItem : %@", dataSetItem);
       NSString *profileImagePath = [NSString urlDecodeString:[dataSetItem objectForKey:@"STATUS_IMG"]]; //thumb
       NSString *snsName = [NSString urlDecodeString:[dataSetItem objectForKey:@"SNS_NM"]];
       NSString *taskDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_DATE"]];
       NSString *writerName = [NSString urlDecodeString:[dataSetItem objectForKey:@"CUSER_NM"]];
       NSString *taskTitle = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_TITLE"]];
       NSString *taskStartDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_START_DATE"]];
       NSString *taskEndDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_END_DATE"]];
       NSNumber *taskStatus = [dataSetItem objectForKey:@"STATUS"];
       NSString *managerName = [NSString urlDecodeString:[dataSetItem objectForKey:@"MANAGER_NAME_LIST"]];
       NSNumber *taskProgress = [dataSetItem objectForKey:@"PROGRESS"];
       NSString *taskCaption = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_CAPTION"]];
       NSArray *contentFileArray = [dataSetItem objectForKey:@"TASK_ATTACHED_FILE"];
       NSString *commCnt = [dataSetItem objectForKey:@"TASK_COMMENT_COUNT"];
       NSString *readCnt = [dataSetItem objectForKey:@"TASK_READ_COUNT"];
       
       if (![profileImagePath isEqual:@""]) {
       UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"profile" :profileImagePath]];
       [cell.userImgBtn setImage:userImg forState:UIControlStateNormal];
       
       } else{
       [cell.userImgBtn setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
       }
       
       NSDate *currentDate = [NSDate date];
       NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
       formatter.dateFormat = @"yyyy-MM-dd HH:mm";
       NSString *tmp = [taskDate substringToIndex:taskDate.length-3];
       NSDate *regiDate = [formatter dateFromString:tmp];
       
       NSCalendar *sysCalendar = [NSCalendar currentCalendar];
       unsigned int unitFlags = NSCalendarUnitDay;
       NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:currentDate options:0];//날짜 비교해서 차이값 추출
       NSInteger date = dateComp.day;
       
       NSString *postDateString = [[NSString alloc]init];
       if(date > 0){
       postDateString = tmp;
       } else{
       postDateString = [MFUtil getTimeIntervalFromDate:regiDate ToDate:currentDate];
       }
       
       cell.userName.text = writerName;
       cell.writeDate.text = postDateString;
       cell.teamName.text = snsName;
       
       [cell.userImgBtn addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
       cell.userImgBtn.tag = indexPath.item;
       
       cell.projectIcon.image = [MFUtil getScaledImage:[UIImage imageNamed:@"project_schedule_blue.png"] scaledToMaxWidth:25.0f];
       cell.projectTitle.text = taskTitle;
       
       NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
       [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
       
       NSDate *sDate = [formatter2 dateFromString:taskStartDate];
       NSDate *eDate = [formatter2 dateFromString:taskEndDate];
       
       NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
       [formatter3 setDateFormat:@"yyyy-MM-dd"];
       NSString *sDateStr = [formatter3 stringFromDate:sDate];
       NSString *eDateStr = [formatter3 stringFromDate:eDate];
       
       if(taskStartDate.length<=0 && taskEndDate.length<=0){
       cell.projectDate.text = @"미정";
       } else if(taskStartDate.length>0 && taskEndDate.length<=0){
       cell.projectDate.text = [NSString stringWithFormat:@"%@ ~ 미정", sDateStr];
       } else if(taskStartDate.length<=0 && taskEndDate.length>0){
       cell.projectDate.text = [NSString stringWithFormat:@"미정 ~ %@", eDateStr];
       } else {
       cell.projectDate.text = [NSString stringWithFormat:@"%@ ~ %@", sDateStr, eDateStr];
       }
       
       
       [cell.statusBtn setBackgroundColor:[UIColor clearColor]];
       [cell.statusBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_progress.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
       [cell.statusBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
       [cell.statusBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
       [cell.statusBtn setTitle:@"상태" forState:UIControlStateNormal];
       
       NSString *statusStr = nil;
       if([taskStatus intValue]==1){
       statusStr = NSLocalizedString(@"task_status1", @"task_status1");
       } else if([taskStatus intValue]==2){
       statusStr = NSLocalizedString(@"task_status2", @"task_status2");
       } else if([taskStatus intValue]==3){
       statusStr = NSLocalizedString(@"task_status3", @"task_status3");
       } else if([taskStatus intValue]==4){
       statusStr = @"보류";
       }
       cell.statusLbl.text = statusStr;
       
       [cell.userBtn setBackgroundColor:[UIColor clearColor]];
       [cell.userBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_member.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
       [cell.userBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
       [cell.userBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
       [cell.userBtn setTitle:@"수행자" forState:UIControlStateNormal];
       cell.userLbl.text = managerName;
       
       [cell.proceedBtn setBackgroundColor:[UIColor clearColor]];
       [cell.proceedBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_graph.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
       [cell.proceedBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
       [cell.proceedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
       [cell.proceedBtn setTitle:@"진행률" forState:UIControlStateNormal];
       
       //[cell.proceedBar setFrame:CGRectMake(cell.proceedBar.frame.origin.x, cell.proceedBar.frame.origin.y, cell.proceedBar.frame.size.width, 20)];
       [cell.ProgressView setProgress:[taskProgress intValue]*0.01 animated:NO];
       
       cell.commCnt.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"comment", @"comment"), commCnt];
       cell.viewCnt.text = [NSString stringWithFormat:@"%@",readCnt];
       
       //읽음카운트 20이상 줄바꿈 현상 수정
       NSDictionary *attributes = @{NSFontAttributeName: [cell.viewCnt font]};
       CGSize textSize = [[cell.viewCnt text] sizeWithAttributes:attributes];
       CGFloat strikeWidth = textSize.width;
       
       //                if(strikeWidth < 14.0f){
       //                    cell.viewCntConstraint.constant = 15;
       //                } else {
       //                    cell.viewCntConstraint.constant = strikeWidth+5;
       //                }
       //                cell.viewCntLabel.textAlignment = NSTextAlignmentRight;
       
       }
       
       return cell;
       
       } @catch(NSException *exception){
       NSLog(@"%s Exception : %@", __func__, exception);
       }
       }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.selectBoardKind==1){
        [self performSegueWithIdentifier:@"POST_DETAIL_PUSH" sender:indexPath];
    } else if(self.selectBoardKind==2){
        [self performSegueWithIdentifier:@"TASK_DETAIL_PUSH" sender:indexPath];
    }
}

-(void)setNewsFeedCell:(NewsFeedViewCell *)feedCell indexPath:(NSIndexPath *)indexPath{
    feedCell.descriptionLabel.text = nil;
    //feedCell.contentImageView.image = nil;
    feedCell.fileName.text = nil;
    feedCell.fileViewHeight.constant = 0;
    feedCell.playButton.hidden = YES;
    
    feedCell.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
    feedCell.descriptionLabel.userInteractionEnabled = YES;
    feedCell.descriptionLabel.tttdelegate = self;
    
    @try{
        if(feedCell!=nil && self.normalDataArray.count>0){
            NSDictionary *dataSetItem = [self.normalDataArray objectAtIndex:indexPath.row];
            
            NSString *profileImagePath = [NSString urlDecodeString:[dataSetItem objectForKey:@"STATUS_IMG"]]; //thumb
            NSString *snsName = [NSString urlDecodeString:[dataSetItem objectForKey:@"SNS_NM"]];
            NSString *postDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"POST_DATE"]];
            NSString *writerName = [NSString urlDecodeString:[dataSetItem objectForKey:@"CUSER_NM"]];
            NSArray *contentArray = [dataSetItem objectForKey:@"CONTENT"];
            NSString *commCnt = [dataSetItem objectForKey:@"POST_COMMENT_COUNT"];
            NSString *readCnt = [dataSetItem objectForKey:@"POST_READ_COUNT"];
            NSString *userType = [dataSetItem objectForKey:@"SNS_USER_TYPE"];
            NSString *userNo = [dataSetItem objectForKey:@"CUSER_NO"];
            
            
            if([userType isEqualToString:@"9"]){
                [feedCell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                feedCell.userTypeLabel.hidden = NO;
                feedCell.userTypeLabel.text = NSLocalizedString(@"withdraw", @"withdraw");
                
            } else {
                if (![profileImagePath isEqual:@""]) {
                    @try{
                        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
                        [feedCell.userImageButton setImage:userImg forState:UIControlStateNormal];
                    } @catch (NSException *exception) {
                        NSLog(@"Exception : %@", exception);
                    }
                
                } else{
                    [feedCell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                }
                
                feedCell.userTypeLabel.hidden = YES;
            }
            
            NSDate *currentDate = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            NSString *tmp = [postDate substringToIndex:postDate.length-3];
            NSDate *regiDate = [formatter dateFromString:tmp];
            
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:currentDate options:0];//날짜 비교해서 차이값 추출
            NSInteger date = dateComp.day;
            
            NSString *postDateString = [[NSString alloc]init];
            if(date > 0){
                NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
                formatter2.dateFormat = NSLocalizedString(@"date13", @"date13");
                postDateString = [formatter2 stringFromDate:regiDate];
            } else{
                postDateString = [MFUtil getTimeIntervalFromDate:regiDate ToDate:currentDate];
            }
            
            feedCell.userNameLabel.text = writerName;
            feedCell.dateLabel.text = postDateString;
            feedCell.teamNameLabel.text = snsName;
            
            [feedCell.userImageButton addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
            feedCell.userImageButton.tag = indexPath.row;
            
            feedCell.commCntLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"comment", @"comment"),commCnt];
            feedCell.viewCntLabel.text = [NSString stringWithFormat:@"%@",readCnt];
            
            //읽음카운트 20이상 줄바꿈 현상 수정
            NSDictionary *attributes = @{NSFontAttributeName: [feedCell.viewCntLabel font]};
            CGSize textSize = [[feedCell.viewCntLabel text] sizeWithAttributes:attributes];
            CGFloat strikeWidth = textSize.width;
            
            if(strikeWidth < 14.0f){
                feedCell.viewCntConstraint.constant = 15;
            } else {
                feedCell.viewCntConstraint.constant = strikeWidth+5;
            }
            feedCell.viewCntLabel.textAlignment = NSTextAlignmentRight;
            
            NSInteger count = [contentArray count]-1;
            NSString *description = @"";
            NSString *thumbImagePath =  @"";
            NSString *originImagePath =  @"";
            NSString *filePath =  @"";
            
            for (int i=(int)count; i>=0; i--) {
                NSDictionary *content = [contentArray objectAtIndex:i];
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"TEXT"]) {
                    
                    NSString *value = [[content objectForKey:@"VALUE"] stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
                    description = [NSString urlDecodeString:value];
                    
                    NSString *newString = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(![newString isEqualToString:@""]){
                        //feedCell.descriptionLabel.text = newString;
                        [feedCell.descriptionLabel setText:newString];
                        [feedCell.descriptionLabel setNumberOfLines:5]; //글내용라인수
                    }
                }
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    feedCell.contentImageView.image = nil;
                    feedCell.playButton.hidden = YES;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
    //                NSLog(@"originImagePath : %@", originImagePath);
                    originImagePath = [originImagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    if (originImagePath!=nil && ![originImagePath isEqualToString:@""]) {
                        feedCell.contentImageView.hidden = NO;
                        //[UIImage imageNamed:@"cover1-1.png"]
                        
                        feedCell.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
                        feedCell.contentImageView.clipsToBounds = YES;
                        
                        [feedCell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error!=nil) NSLog(@"setNewFeed Error : %@", error);
                            if (image) {
                                if(image.size.width>self.tableView.frame.size.width){
                                    image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                    feedCell.contentImageView.image = image;
                                }
                            }
                        }];
                        
//                        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                            [self imageWithURL:[NSURL URLWithString:originImagePath] WithIndexPath:indexPath WithCallback:^(UIImage *downloadedImage, BOOL isCache, NSIndexPath *imageIndexPath) {
//
//                                if (downloadedImage) {
//                                    dispatch_async( dispatch_get_main_queue(), ^{
//                                        UITableViewCell  *existcell = [self.tableView cellForRowAtIndexPath:imageIndexPath];
//                                        if (existcell) {
//                                            // assign image to cell here
//                                            NSLog(@"downloadedImage size : %f*%f", downloadedImage.size.width, downloadedImage.size.height);
//                                            feedCell.contentImageView.image = downloadedImage;
////                                            [self.tableView reloadRowsAtIndexPaths:@[imageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//                                        }
//                                    });
//                                }
//                            }];
//                        });
                        
//                        [feedCell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath]
//                                           placeholderImage:[UIImage imageNamed:@"cover1-1.png"]
//                                                    options:0
//                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                            if(image.size.width>self.tableView.frame.size.width-20){
//                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                            }
//                            feedCell.contentImageView.image = image;
//
////                            [self.tableView beginUpdates];
////                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
////                            [self.tableView endUpdates];
//                        }];
                        
                    } else{
                        feedCell.contentImageView.hidden = YES;
                    }
                }
                
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"VIDEO"]) {
                    feedCell.contentImageView.image = nil;
                    
                    feedCell.contentImageView.hidden = NO;
                    feedCell.playButton.hidden = NO;
                    feedCell.contentImageView.image = nil;
                    feedCell.videoTmpView.gestureRecognizers = nil;
                    feedCell.videoTmpView.tag = indexPath.row;
                    feedCell.playButton.tag = indexPath.row;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    NSString *thumbPath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    thumbPath = [thumbPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    [feedCell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            if(image.size.width>self.tableView.frame.size.width){
                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                feedCell.contentImageView.image = image;
                            }
                        }
                    }];
                    
//                    [feedCell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath]
//                                       placeholderImage:[UIImage imageNamed:@"cover1-1.png"]
//                                                options:0
//                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                        if(image.size.width>self.tableView.frame.size.width-20){
//                            image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                        }
//                        feedCell.contentImageView.image = image;
//
////                        [self.tableView beginUpdates];
////                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
////                        [self.tableView endUpdates];
//                    }];
                }
                
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                    filePath = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                    
                    NSString *fileName = @"";
                    @try{
                        NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
                        fileName = [filePath substringFromIndex:range.location+1];
                        
                    } @catch (NSException *exception) {
                        fileName = filePath;
                        NSLog(@"Exception : %@", exception);
                    }
                    
                    feedCell.fileName.text = fileName;
                    
                    NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
                    NSString *fileExt = [[fileName substringFromIndex:range2.location+1] lowercaseString];
                    
                    if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
                        
                    } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
                        
                    } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
                        
                    } else if([fileExt isEqualToString:@"psd"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
                        
                    } else if([fileExt isEqualToString:@"ai"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
                        
                    } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
                        
                    } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
                        
                    } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
                        
                    } else if([fileExt isEqualToString:@"pdf"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
                        
                    } else if([fileExt isEqualToString:@"txt"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
                        
                    } else if([fileExt isEqualToString:@"hwp"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
                        
                    } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
                        
                    } else {
                        feedCell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
                    }
                }
            }
            
            if(filePath!=nil && ![filePath isEqualToString:@""]){
                feedCell.fileViewHeight.constant = 45;
                feedCell.fileView.hidden = NO;
                feedCell.fileIcon.hidden = NO;
                feedCell.fileName.hidden = NO;
                
                feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, 350, feedCell.fileView.frame.size.width, 0);
                
                if(![description isEqualToString:@""] && ![originImagePath isEqualToString:@""]) {
                    feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, feedCell.contentImageView.frame.origin.y+feedCell.contentImageView.frame.size.height+7, feedCell.fileView.frame.size.width, 45);
                    
                } else if([description isEqualToString:@""] && ![originImagePath isEqualToString:@""]){
                    feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, feedCell.descriptionLabel.frame.origin.y+feedCell.contentImageView.frame.size.height+10, feedCell.fileView.frame.size.width, 45);
                    
                } else if(![description isEqualToString:@""] && [originImagePath isEqualToString:@""]){
                    feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, feedCell.descriptionLabel.frame.origin.y+feedCell.descriptionLabel.frame.size.height+4, feedCell.fileView.frame.size.width, 45);
                    
                } else {
                    feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, feedCell.descriptionLabel.frame.origin.y, feedCell.fileView.frame.size.width, 45);
                }
            } else {
                feedCell.fileViewHeight.constant = 0;
                feedCell.fileView.hidden = YES;
                feedCell.fileIcon.hidden = YES;
                feedCell.fileName.hidden = YES;
                feedCell.fileView.frame = CGRectMake(feedCell.fileView.frame.origin.x, feedCell.fileView.frame.origin.y, feedCell.fileView.frame.size.width, 0);
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)imageWithURL:(NSURL *)imageurl WithIndexPath:(NSIndexPath *)indexpath WithCallback:(void(^)(UIImage *downloadedImage,BOOL isCache , NSIndexPath *imageIndexPath))callback{
    if (![[SDWebImageManager sharedManager ]diskImageExistsForURL:imageurl]) {
        [[SDWebImageManager sharedManager]downloadImageWithURL:imageurl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            // resize image here
            callback(image , NO,indexpath);
        }];

    }
    else{
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[imageurl absoluteString]] ;
        // resize image here
        callback(image, YES ,indexpath);
    }

}

#pragma mark - Prefetch Table Row
-(void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    @try{
        for(int i=0; i<indexPaths.count; i++){
            BOOL isImg = NO;
            
            NSIndexPath *idx = [indexPaths objectAtIndex:i];
            
            NSDictionary *dataSetItem = [self.normalDataArray objectAtIndex:idx.row];
            NSArray *contents = [dataSetItem objectForKey:@"CONTENT"];
            
            NSUInteger count = contents.count;
            for(int i=0; i<(int)count; i++){
                NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
                if([type isEqualToString:@"TEXT"]){
                    
                } else if([type isEqualToString:@"IMG"]){
                    if(!isImg){
                        NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                        NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            //[self cachingUrlImage:originImg indexPath:idx.row];
                            [self downloadImageIfNeeded:[NSURL URLWithString:originImg]];
                        });
                        isImg = YES;
                    }
                    
                } else if([type isEqualToString:@"VIDEO"]) {
                    if(!isImg){
                        NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                        //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                        NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            //[self cachingUrlImage:thumbImg indexPath:idx.row];
                            [self downloadImageIfNeeded:[NSURL URLWithString:thumbImg]];
                        });
                        isImg = YES;
                    }
                    
                } else if([type isEqualToString:@"FILE"]) {
                    
                }
            }
        }
        
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

//스크롤 대충 밑에가면 자동으로 로딩해야 다음 셀 이미지 저장할 수 있음
-(void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
}

- (void)firstDownloadImageIfNeeded:(NSURL *)url
{
    @try{
        if([imgCache diskImageExistsWithKey:url.absoluteString]){
            //NSLog(@"있어도 새로고침 해야지");
            [self.tableView reloadData];
            
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [imageManager downloadImageWithURL:url
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                              
                                          } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                              NSLog(@"없으니까 새로고침 해야지");
                                              [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:YES];
                                              
                                              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                              [CATransaction begin];
                                              [CATransaction setCompletionBlock:^{

                                              }];
                                              [self.tableView beginUpdates];
                                              [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                              [self.tableView endUpdates];
                                              
                                              [CATransaction commit];
                                          }];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)downloadImageIfNeeded:(NSURL *)url {
    @try{
        if([imgCache diskImageExistsWithKey:url.absoluteString]){
            
        } else {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [imageManager downloadImageWithURL:url
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                              
                                          } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                              //                                              NSLog(@"없다 : %@", imageURL.absoluteString);
                                              [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:YES];
                                          }];
            });
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

//이미지로딩테스트중
-(NSDictionary *)getImageSizeFromUrl:(NSString *)urlString{
    NSDictionary* imageHeader = [[NSDictionary alloc] init];
    @try{
        CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL URLWithString:urlString], NULL);
        imageHeader = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
        
        imageHeader = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"PixelWidth", @"0",@"PixelHeight", nil];
    }
    return imageHeader;
}

-(void)postImgCaching:(NSArray *)contents indexPath:(int)index{
    NSUInteger count = contents.count;
    //테스트 위해 일단 이미지 캐시 삭제해야함
    
    @try{
        BOOL isImg = NO;
        
        for(int i=0; i<(int)count; i++){
            
            NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"TEXT"]){
                
            } else if([type isEqualToString:@"IMG"]){
                if(!isImg){
                    dataCnt++;
                    NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                    NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                    //NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                    originImg = [originImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    //추후 valueDic에 이미지 사이즈 정보도 저장이 되어있을 것임.
                    
                    if(index<5){
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:originImg]];
                        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
                            if (!taskData) {
                                NSLog(@"error : %@", error);
                            } else {
                                [self firstDownloadImageIfNeeded:response.URL];
                            }
                        }];
                        [task resume];
                    }
                    isImg = YES;
                }
//                break;
                
            } else if([type isEqualToString:@"VIDEO"]) {
                if(!isImg){
                    dataCnt++;
                    NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                    //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                    NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                    thumbImg = [thumbImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    if(index<5){
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:thumbImg]];
                        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
                            if (!taskData) {
                                NSLog(@"error : %@", error);
                            } else {
                                [self firstDownloadImageIfNeeded:response.URL];
                            }
                        }];
                        [task resume];
                    }
                    isImg = YES;
                }
//                break;
                
            } else if([type isEqualToString:@"FILE"]) {
                
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


#pragma mark - Push Notification
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
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}

-(void)returnNewChatPush:(LGSideMenuController *)vc error:(NSString *)error{
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)noti_FeedProfileChat:(NSNotification *)notification {
    NSLog();

    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    @try{
        //글목록에서 푸시받았을경우
        if([self.parentViewController childViewControllers].count == 1){
            NSString *nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
            NSString *nRoomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
            NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
            NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
//            NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
//            NSString *decodeUserNm = [NSString urlDecodeString:userNm];
//
//            NSArray *roomNmArr = [NSArray array];
//            if([nRoomNm rangeOfString:@","].location != NSNotFound){
//                roomNmArr = [nRoomNm componentsSeparatedByString:@","];
//            } else {
//                if(users.count==1){
//                    roomNmArr = [roomNmArr arrayByAddingObject:nRoomNm];
//                }
//            }
//
//            NSMutableString *resultRoomNm = [NSMutableString string];
//            if(roomNmArr.count>0){
//                for(int i=0; i<roomNmArr.count; i++){
//                    NSString *arrUserNm = [roomNmArr objectAtIndex:i];
//
//                    if(![arrUserNm isEqualToString:[NSString stringWithFormat:@"%@", decodeUserNm]]){
//                        [resultRoomNm appendString:[NSString stringWithFormat:@",%@", arrUserNm]];
//                    } else {
//                        if(roomNmArr.count==1) [resultRoomNm appendString:[NSString stringWithFormat:@"%@", arrUserNm]];
//                    }
//                }
//                if(roomNmArr.count==1) resultRoomNm = [[resultRoomNm substringFromIndex:0] mutableCopy];
//                else resultRoomNm = [[resultRoomNm substringFromIndex:1] mutableCopy];
//            }
            
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

- (void)noti_DeletePost:(NSNotification *)notification{
    NSLog();
    
    @try{
        self.lastPostNo = @"1";
        [self startLoading];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_DeletePost" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_SavePost:(NSNotification *)notification{
    NSLog();
    
    @try{
        self.lastPostNo = @"1";
        [self startLoading];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SavePost" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_SaveTask:(NSNotification *)notification{
    NSLog();
    
    @try{
        self.lastTaskNo = @"1";
        [self startLoading];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SaveTask" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_ForceDeleteSNS:(NSNotification *)notification{
    NSLog();
    
    @try{
        self.lastPostNo = @"1";
        [self startLoading];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_RefreshFeed:(NSNotification *)notification{
    NSLog();
    @try{
        self.lastPostNo = @"1";
        [self refreshCallGetPostList];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    @try {
        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.view.frame.size.height) {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 10;
            
            if(y > h + reload_distance) {
                //아래로 데이터로드
                if(self.selectBoardKind==1){
                    if(isLoad){
                        isManualLoad = YES;
                        if(!isAutoLoad){
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
                                    taskId = UIBackgroundTaskInvalid;
                                }];
                            }
                            
                            [self callWebService:@"getPostLists"];
                        }
                        isLoad = NO;
                        isManualLoad = NO;
                    }
                    
                } else if(self.selectBoardKind==2){
                    [self callWebService:@"getTaskLists"];
                }
                
            }
        }
        [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    @try {
        if(isRefresh) {
            return ;
        }
        
        isDragging = NO;
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT) {
            //새로고침 했을때
            [self startLoading];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)startLoading{
    @try {
        //데이터새로고침
        if(self.selectBoardKind==1){
            //[self refreshCallGetPostList];
            self.lastPostNo = @"1";
            self.normalDataArray = [[NSMutableArray alloc]init];
            tmpDataArr = [[NSMutableArray alloc] init];
            [self callWebService:@"getPostLists"];
            
        } else if(self.selectBoardKind==2){
            self.lastTaskNo = @"1";
            self.projectDataArray = [[NSMutableArray alloc]init];
            [self callWebService:@"getTaskLists"];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)stopLoading {
    [self performSelector:@selector(_stopLoading) withObject:nil afterDelay:1.f];
}
- (void)_stopLoading{
    isRefresh = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    @try {
        CGFloat scrollOffsetY = scrollView.contentOffset.y;
        
        //스크롤 인덱스가 마지막에서 5번째 일 때 새로운 데이터 로딩
        if(allDataCnt>5){
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:allDataCnt-6 inSection:0];
            CGRect rectOfCellInTableView1 = [self.tableView rectForRowAtIndexPath:firstIndexPath];
            
            NSIndexPath *firstIndexPath2 = [NSIndexPath indexPathForRow:allDataCnt-5 inSection:0];
            CGRect rectOfCellInTableView2 = [self.tableView rectForRowAtIndexPath:firstIndexPath2];
            
            if(scrollOffsetY>rectOfCellInTableView1.origin.y && scrollOffsetY<rectOfCellInTableView2.origin.y){
                if(isLoad){
                    isAutoLoad = YES;
                    if(!isManualLoad) {
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
                                taskId = UIBackgroundTaskInvalid;
                            }];
                        }
                        
                        [self callWebService:@"getPostLists"];
                    }
                    isLoad = NO;
                    isAutoLoad = NO;
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(isRefresh){
        return ;
    }
    isDragging = YES;
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"POST_WRITE_MODAL"]){
        [self.tabBarController.tabBar setHidden:YES];
        UINavigationController *destination = segue.destinationViewController;
        PostWriteTableViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.snsNo = self.snsNo;
        vc.snsName = self.snsName;
        vc.fromSegue = segue.identifier;
        
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SavePost:) name:@"noti_SavePost" object:nil];
        
    } else if([segue.identifier isEqualToString:@"POST_SELECT_GROUP_MODAL"]){
        UINavigationController *destination = segue.destinationViewController;
        TeamListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.isEdit = YES;
        vc.fromSegue = segue.identifier;
        
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        if(self.selectBoardKind==1) vc.selectBoardKind=1;
        else if(self.selectBoardKind==2) vc.selectBoardKind=2;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SavePost:) name:@"noti_SavePost" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveTask:) name:@"noti_SaveTask" object:nil];
        
    } else if([segue.identifier isEqualToString:@"POST_DETAIL_PUSH"]){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        self.navigationController.navigationBar.topItem.title = @"";
        PostDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination._postNo = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"POST_NO"];
        destination._snsName = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"SNS_NM"];
        destination._postDate = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"POST_DATE"];
        destination._readCnt = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"POST_READ_COUNT"];
        destination._commCnt = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"POST_COMMENT_COUNT"];
        destination._isRead = [[self.normalDataArray objectAtIndex:indexPath.item] objectForKey:@"IS_READ"];
        destination.indexPath  = indexPath;
        destination.postInfo = [self.normalDataArray objectAtIndex:indexPath.item];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noti_DeletePost:)
                                                     name:@"noti_DeletePost"
                                                   object:nil];
        
    } else if([segue.identifier isEqualToString:@"POST_SEARCH_MODAL"]){
        UINavigationController *nav = segue.destinationViewController;
        SearchViewController *destination = [nav.childViewControllers objectAtIndex:0];
        destination.fromSegue = segue.identifier;
        destination.snsNo = self.snsNo;
        
    } else if([segue.identifier isEqualToString:@"TASK_DETAIL_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
        TaskDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination._taskNo = [[self.projectDataArray objectAtIndex:indexPath.item] objectForKey:@"TASK_NO"];
        destination._snsName = [[self.projectDataArray objectAtIndex:indexPath.item] objectForKey:@"SNS_NM"];
        destination._taskDate = [[self.projectDataArray objectAtIndex:indexPath.item] objectForKey:@"TASK_DATE"];
        destination._readCnt = [[self.projectDataArray objectAtIndex:indexPath.item] objectForKey:@"TASK_READ_COUNT"];
        destination.indexPath  = indexPath;
        destination.taskInfo = [self.projectDataArray objectAtIndex:indexPath.item];
        
    } else {
        
    }
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
//    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//
//    }];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]] options:@{} completionHandler:nil];
}

@end
