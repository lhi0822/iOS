//
//  TeamSelectController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "TeamSelectController.h"
#import "SearchTableViewCell.h"
#import "PostDetailViewController.h"
#import "SNSUserInfoViewController.h"
#import "SNSInfoViewController.h"
#import "TeamSelectViewCell.h"
#import "TeamSelectTaskViewCell.h"
#import "CustomHeaderViewController.h"
#import "TaskDetailViewController.h"
#import "TaskWriteViewController.h"
#import "PostWriteTableViewController.h"
#import "NotiChatViewController.h"


#define NAVBAR_CHANGE_POINT 50

//#define NAVBAR_COLORCHANGE_POINT -80
#define IMAGE_HEIGHT 180
#define SCROLL_DOWN_LIMIT 100
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define LIMIT_OFFSET_Y -(IMAGE_HEIGHT + SCROLL_DOWN_LIMIT)

#define kSupplementaryViewID @"SUP_VIEW_ID"
#define MODEL_NAME [[UIDevice currentDevice] modelName]

@interface TeamSelectController () {
    int snsKind;
    AppDelegate *appDelegate;
    BOOL naviClear;
    
    SDImageCache *imgCache;
    SDWebImageManager *imageManager;
    
    NSMutableArray *memberArr;
    
    int cachingCnt;
    int datasetCnt;
    int dataCnt;
    
    BOOL isLoad;
    int firstImgCnt;
    int allDataCnt;
    NSMutableArray *urlArr;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
    UIView *statusBar;
}

@property (strong, nonatomic) VCFloatingActionButton *addButton;

@end

@implementation TeamSelectController

- (BOOL)isIphoneX
{
    NSString *platform = [[UIDevice currentDevice] modelName];
    NSRange range = NSMakeRange(7, 1);
    NSString *platformNumber = [platform substringWithRange:range];
    if([platformNumber isEqualToString:@"X"]){
        return YES;
    } else {
        return NO;
    }
}
//- (int)navBarBottom {
//    return [self isIphoneX] ? 88 : 64;
//}

- (int)naviChangePoint{
    return [self isIphoneX] ? -80 : -50;
}


- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -IMAGE_HEIGHT, kScreenWidth, IMAGE_HEIGHT)];
        _imageView.clipsToBounds = YES;
        
        //이미지에 블랙(alpha:0.5) 그라데이션 처리
        CAGradientLayer *gradientMask = [MFUtil setImageGradient:self.imageView.bounds startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0) colors:[NSArray arrayWithObjects:
            (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
        [self.imageView.layer addSublayer:gradientMask];
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    @try{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SavePost:) name:@"noti_SavePost" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveTask:) name:@"noti_SaveTask" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamProfileChat:) name:@"noti_TeamProfileChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ModifyBoard:) name:@"noti_ModifyBoard" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ForceDeleteSNS:) name:@"noti_ForceDeleteSNS" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RefreshTeamSelect:) name:@"noti_RefreshTeamSelect" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_CloseSNS:) name:@"noti_CloseSNS" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviNoti:) name:@"naviNoti" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamSelectExit:) name:@"noti_TeamSelectExit" object:nil];
        
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        imgCache = [SDImageCache sharedImageCache];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        [imgCache makeDiskCachePath:cachePath];
        
        imageManager = [SDWebImageManager sharedManager];
        
        //캐시삭제
//        [[SDImageCache sharedImageCache] clearMemory];
//        [[SDImageCache sharedImageCache] clearDisk];
        
        cachingCnt = 0;
        datasetCnt = 0;
        dataCnt = 0;
        
        isLoad = NO;
        
        firstImgCnt=0;
        allDataCnt=0;
        
        urlArr = [NSMutableArray array];
        
        snsKind = 0;
        if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
            snsKind = [[self.snsInfoDic objectForKey:@"SNS_KIND"] intValue];
        } else {
            snsKind = self.selectBoardKind;
        }
        
        memberArr = [NSMutableArray array];
        
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        [left setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"back.png"] scaledToMaxWidth:21.0f] forState:UIControlStateNormal];
        left.adjustsImageWhenDisabled = NO;
        left.frame = CGRectMake(0, 0, 50, 50);
        left.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
        [left addTarget:self action:@selector(closeModal:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:left];
        self.navigationItem.leftBarButtonItem = customBarItem;
        self.navigationItem.hidesBackButton = NO;

        UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [right1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_search.png"] scaledToMaxWidth:20] forState:UIControlStateNormal];
        [right1 addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
        
        self.navigationItem.rightBarButtonItem = rightBtn1;
        
        self.extendedLayoutIncludesOpaqueBars = YES; //네비게이션 Translucent 설정 시 플로팅 버튼이 아래로 내려가는 현상때문에 해당 옵션으로 고정.(뷰 사이즈가 늘어나게됨)
        
        [self changeNavBarAnimateWithIsClear:YES]; //수정
        
        self.tableView.estimatedRowHeight = 50;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        self.tableView.prefetchDataSource = self;
        
        UIButton *toolBar1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [toolBar1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_member.png"] scaledToMaxWidth:30] forState:UIControlStateNormal];
        [toolBar1 addTarget:self action:@selector(snsUserInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *toolBarBtn1 = [[UIBarButtonItem alloc]initWithCustomView:toolBar1];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIButton *toolBar2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [toolBar2 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_info.png"] scaledToMaxWidth:12] forState:UIControlStateNormal];
        [toolBar2 addTarget:self action:@selector(snsInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *toolBarBtn2 = [[UIBarButtonItem alloc]initWithCustomView:toolBar2];
        
        NSArray *toolBarBtnArr = [[NSArray alloc]initWithObjects:flexibleSpace, toolBarBtn1, flexibleSpace, toolBarBtn2, flexibleSpace, nil];
        self.toolBar.items = toolBarBtnArr;
        
        self.lastPostNo = @"1";
        self.lastTaskNo = @"1";
        
        [self callWebService:@"getSNSInfo"];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 13, *)) {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    } else {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    
    self.tableView.delegate = self;
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect floatFrame = CGRectNull;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.toolBar.frame.origin.y-self.toolBar.frame.size.height-20, 50, 50);

    } else {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.toolBar.frame.origin.y-self.toolBar.frame.size.height-20, 50, 50);
        } else {
            floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.toolBar.frame.origin.y-self.toolBar.frame.size.height-20, 50, 50);
        }
    }
    
//    self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_board.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:NO];
//    self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
//    self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
//    self.addButton.clipsToBounds = YES;
//    self.addButton.contentMode = UIViewContentModeScaleAspectFit;
//
//    if(snsKind==1){//if(self.selectBoardKind==1){
//        self.addButton.imageArray = @[@"floating_write.png"];
//        self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
//
//    } else if(snsKind==2){//if(self.selectBoardKind==2){
//        self.addButton.imageArray = @[@"floating_newproject.png"];
//        self.addButton.labelArray = @[NSLocalizedString(@"new_task", @"new_task")];
//    }
//
//    self.addButton.hideWhileScrolling = YES;
//    self.addButton.delegate = self;
//
//    [self.view addSubview:self.addButton];
    
    [self.addButton setFrame:floatFrame];
}

//- (void)naviNoti:(NSNotification *)notification{
//    statusBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
//}


#pragma mark - Floating Button Event
-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if(row==0){
        [self createPost:nil];
    }
}

-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewSetting{
    NSLog();
    if(snsKind==1){//if(self.selectBoardKind==1){
        [self callWebService:@"getPostLists"];
    } else if(snsKind==2){//if(self.selectBoardKind==2){
        [self callWebService:@"getTaskLists"];
    }
    
    NSString *coverImg = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"COVER_IMG"]];
    if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
        UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
        if(image!=nil){
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :image];
            self.imageView.image = postCover;
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
            self.imageView.image = postCover;
        }
    } else {
        UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
        self.imageView.image = postCover;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnCoverImg:)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:tap];
    
    //플로팅 버튼
    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, self.toolBar.frame.origin.y-self.toolBar.frame.size.height-20, 50, 50);
//    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width-64, 572, 50, 50);
//    NSLog(@"ViewSetting mainHeight : %f", self.toolBar.frame.origin.y-self.toolBar.frame.size.height-20);
//    NSLog(@"self view size : %f", self.view.frame.size.height);
    
    self.addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floating_menu_board.png"] andPressedImage:[UIImage imageNamed:@"floating_menu_close.png"] withScrollview:self.tableView naviHeight:self.navigationController.navigationBar.frame.size.height isTranslucent:NO];
    
    self.addButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2;
    self.addButton.clipsToBounds = YES;
    self.addButton.contentMode = UIViewContentModeScaleAspectFit;
    
    //[self.addButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
    if(snsKind==1){//if(self.selectBoardKind==1){
        self.addButton.imageArray = @[@"floating_write.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_post", @"new_post")];
        
    } else if(snsKind==2){//if(self.selectBoardKind==2){
        self.addButton.imageArray = @[@"floating_newproject.png"];
        self.addButton.labelArray = @[NSLocalizedString(@"new_task", @"new_task")];
    }
    
    self.addButton.hideWhileScrolling = YES;
    self.addButton.delegate = self;
    
    if([self isIphoneX]){
        self.tableView.contentInset = UIEdgeInsetsMake(IMAGE_HEIGHT-64, 0, 0, 0);
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(IMAGE_HEIGHT, 0, 0, 0);
    }
    
    [self.tableView addSubview:self.imageView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.addButton];
}

- (IBAction)snsUserInfoClick:(id)sender {
    //[self performSegueWithIdentifier:@"BOARD_MEMBER_PROFILE_MODAL" sender:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SNSUserInfoViewController *destination = (SNSUserInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SNSUserInfoViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    NSString *snsLeader = [self.snsInfoDic objectForKey:@"CREATE_USER_NO"];
    destination.snsNo = self.snsNo;
    destination.snsName = self.snsName;
    destination.snsLeader = snsLeader;
    destination.snsInfoDic = self.snsInfoDic;
    
    //navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)snsInfoClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SNSInfoViewController *destination = (SNSInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SNSInfoViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    destination.snsInfoDic = self.snsInfoDic;
    
    //navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        if([serviceName isEqualToString:@"getPostLists"]){
            paramString = [NSString stringWithFormat:@"stPostSeq=%@&usrNo=%@&searchNm=""&dvcId=%@",self.lastPostNo, myUserNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
            
        } else if([serviceName isEqualToString:@"getTaskLists"]){
            paramString = [NSString stringWithFormat:@"stTaskSeq=%@&usrNo=%@&searchNm=""&dvcId=%@",self.lastTaskNo, myUserNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
            
        } else if([serviceName isEqualToString:@"getSNSInfo"]){
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&snsKind=%d&dvcId=%@", myUserNo, self.snsNo, snsKind, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if([session start]){
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)refreshCallGetList{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *paramString = nil;
        NSURL *url = nil;
        
        if(snsKind==1){//if(self.selectBoardKind==1){
            url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getPostLists"]];
            paramString = [NSString stringWithFormat:@"stPostSeq=1&usrNo=%@&searchNm=""&dvcId=%@", myUserNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
            
            self.normalDataArr = [[NSMutableArray alloc]init];
            self.lastPostNo = @"1";
            
        } else if(snsKind==2){//if(self.selectBoardKind==2){
            url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getTaskLists"]];
            paramString = [NSString stringWithFormat:@"stTaskSeq=1&usrNo=%@&searchNm=""&dvcId=%@", myUserNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            if (self.snsNo!=nil) {
                paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
            }
            
            self.projectDataArr = [[NSMutableArray alloc]init];
            self.lastTaskNo = @"1";
        }
        
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

- (void)tapOnCoverImg:(UITapGestureRecognizer*)tap{
    
}

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    
    if (error!=nil || [error isEqualToString:@"(null)"]) {
        if ([error isEqualToString:@"The request timed out."]) {
            if ([wsName isEqualToString:@"getPostLists"]) {
                [self callWebService:@"getPostLists"];
            }
        } else{
            NSLog(@"Error Message : %@",error);
            if ([wsName isEqualToString:@"getPostLists"]) {
                
            } else {
                
            }
        }
    } else{
        @try{
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([wsName isEqualToString:@"getPostLists"]) {
                    
                    NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
//                    NSLog(@"dataSets aa : %@", dataSets);
                    
                    datasetCnt = (int)dataSets.count;
                    cachingCnt = 0;
                    dataCnt = 0;
                    
                    NSString *seq = [[NSString alloc]init];
                    for(int i=1; i<=dataSets.count; i++){
                        seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
                        NSArray *contents = [[dataSets objectAtIndex:i-1] objectForKey:@"CONTENT"];
                        [self postImgCaching:contents indexPath:[seq intValue]-2];
                    }
                    
                    if(dataSets.count>0){
                        if ([self.lastPostNo intValue]==1) {
                            self.lastPostNo = seq;
                            self.normalDataArr = [NSMutableArray arrayWithArray:dataSets];
                            
                        } else {
                            self.lastPostNo = seq;
                            [self.normalDataArr addObjectsFromArray:dataSets]; //deep copy
                        }
                        
                        allDataCnt = (int)self.normalDataArr.count;
                        
                        [self.tableView reloadData];
                        isLoad = YES;
                        
//                        if(cachingCnt>0){
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                NSLog(@"캐시 새로 저장했으니 새로고침 한다.");
//                                [self.tableView reloadData];
//                                [SVProgressHUD dismiss];
//                            });
//                        } else {
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                NSLog(@"캐시 새로 저장하진 않았지만 새로고침 한다.");
//                                [self.tableView reloadData];
//                            });
//                        }
                        
                    } else {
                        NSLog(@"없음");
                    }
                    
                } else if([wsName isEqualToString:@"getTaskLists"]){
                    NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                    
                    NSString *seq = [[NSString alloc]init];
                    for(int i=1; i<=dataSets.count; i++){
                        seq = [NSString stringWithFormat:@"%d", [self.lastTaskNo intValue]+i];
                    }
                    
                    if(dataSets.count>0){
                        if ([self.lastTaskNo intValue]==1) {
                            self.lastTaskNo = seq;
                            self.projectDataArr = [NSMutableArray arrayWithArray:dataSets];
                            
                        } else {
                            self.lastTaskNo = seq;
                            [self.projectDataArr addObjectsFromArray:dataSets];
                        }
                        
                        [self.tableView reloadData];
                        
                    } else {
                        
                    }
                    
                } else if([wsName isEqualToString:@"getSNSInfo"]){
                    NSDictionary *dic = session.returnDictionary;
                    NSArray *dataSetArr = [dic objectForKey:@"DATASET"];
                    
                    self.snsInfoDic = [NSDictionary dictionary];
                    self.snsInfoDic = [dataSetArr objectAtIndex:0];
                    
                    [self viewSetting];
                }
                
            } else{
                NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
            }
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
    }
}

-(void)postImgCaching:(NSArray *)contents indexPath:(int)index{
    NSUInteger count = contents.count;
    
    @try{
        for(int i=0; i<(int)count; i++){
            NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"TEXT"]){
                
            } else if([type isEqualToString:@"IMG"]){
                dataCnt++;
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                
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

//                if(index<3){
//                    [self cachingUrlImage:originImg indexPath:index];
//                }
                
//                if(![imgCache diskImageExistsWithKey:originImg]){
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
//                        [downLoader downloadImageWithURL:[NSURL URLWithString:originImg] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//                        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                            if (image && finished) {
//                                //NSLog(@"이미지 다운 완료!");
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                    [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:originImg toDisk:YES];
//
//                                    //NSLog(@"이미지 인덱스 : %d", idx);
//
//                                    cachingCnt++;
//
//                                    NSLog(@"11 dataCnt : %d, cachingCnt : %d", dataCnt, cachingCnt);
//
//                                    if(dataCnt==cachingCnt){
//                                        [self cellRefresh];
//                                    }
//                                });
//                            }
//                        }];
//                    });
//                }
                break;
                
            } else if([type isEqualToString:@"VIDEO"]) {
                dataCnt++;
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                
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
                
//                if(index<3){
//                    [self cachingUrlImage:thumbImg indexPath:index];
//                }
                
//                if(![imgCache diskImageExistsWithKey:thumbImg]){
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
//                        [downLoader downloadImageWithURL:[NSURL URLWithString:thumbImg] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//                        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                            if (image && finished) {
//                                //NSLog(@"이미지 다운 완료!");
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                    [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:thumbImg toDisk:YES];
//
//                                    cachingCnt++;
//
//                                    if(dataCnt==cachingCnt){
//                                        [self cellRefresh];
//                                    }
//                                });
//                            }
//                        }];
//                    });
//                }
                break;
                
            } else if([type isEqualToString:@"FILE"]) {
                
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)cellRefresh{
    cachingCnt=0;
    dataCnt=0;
    [self.tableView reloadData];
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
    [self reconnectFromError];
}
-(void)setTimer{
    timerCount = 0;
    timerEndCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
-(void)handleTimer:(NSTimer *)timer {
    timerCount++;
    if (timerCount==timerEndCount) {
        [self callWebService:@"getSNSInfo"];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try{
        if(snsKind==1){//if(self.selectBoardKind==1){
            return self.normalDataArr.count;
            
        } else if(snsKind==2){//if(self.selectBoardKind==2){
            return self.projectDataArr.count;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        if(snsKind==1){//if(self.selectBoardKind==1){
            TeamSelectViewCell *cell = (TeamSelectViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TeamSelectViewCell"];
            
            if (cell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TeamSelectViewCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[TeamSelectViewCell class]]) {
                        cell = (TeamSelectViewCell *) currentObject;
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            
            cell.descriptionLabel.text = nil;
            cell.contentImageView.image = nil;
            cell.fileName.text = nil;
            cell.fileViewHeight.constant = 0;
            cell.playButton.hidden = YES;
            
            if(cell!=nil && self.normalDataArr.count>0){
                NSDictionary *dataSetItem = [self.normalDataArr objectAtIndex:indexPath.item];
                
                NSString *userNo = [dataSetItem objectForKey:@"CUSER_NO"];
                NSString *profileImagePath = [NSString urlDecodeString:[dataSetItem objectForKey:@"STATUS_IMG"]];
                //NSString *snsName = [NSString urlDecodeString:[dataSetItem objectForKey:@"SNS_NM"]];
                NSString *postDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"POST_DATE"]];
                NSString *writerName = [NSString urlDecodeString:[dataSetItem objectForKey:@"CUSER_NM"]];
                NSArray *contentArray = [dataSetItem objectForKey:@"CONTENT"];
                NSString *commCnt = [dataSetItem objectForKey:@"POST_COMMENT_COUNT"];
                NSString *readCnt = [dataSetItem objectForKey:@"POST_READ_COUNT"];
                NSString *userType = [dataSetItem objectForKey:@"SNS_USER_TYPE"];
                
                if([userType isEqualToString:@"9"]){
                    [cell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                    cell.userTypeLabel.hidden = NO;
                    cell.userTypeLabel.text = NSLocalizedString(@"withdraw", @"withdraw");
                    
                } else {
                    if (![profileImagePath isEqual:@""]) { //프로필저장폴더 유저넘버로 폴더 분리 추가해야함1!!!
                        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
                        [cell.userImageButton setImage:userImg forState:UIControlStateNormal];

                    } else{
                        [cell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                    }
                    cell.userTypeLabel.hidden = YES;
                }
                
//                if (![profileImagePath isEqual:@""]) {
//                    NSString *contentsImagePath = [profileImagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//
//                    NSURL *url = [NSURL URLWithString:[contentsImagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
//                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                        if (data) {
//                            UIImage *image = [UIImage imageWithData:data];
//                            if (image) {
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :image];
//                                    [cell.userImageButton setImage:userImg forState:UIControlStateNormal];
//                                });
//                            }
//                        }
//                    }];
//                    [task resume];
//                } else{
//                    [cell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
//                }
                
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
                
                cell.userNameLabel.text = writerName;
                cell.dateLabel.text = postDateString;
                
                [cell.userImageButton addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
                cell.userImageButton.tag = indexPath.item;
                
                cell.commentCnt.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"comment", @"comment"), commCnt];
                cell.readCnt.text = [NSString stringWithFormat:@"%@",readCnt];
                
                //읽음카운트 20이상 줄바꿈 현상 수정
                NSDictionary *attributes = @{NSFontAttributeName: [cell.readCnt font]};
                CGSize textSize = [[cell.readCnt text] sizeWithAttributes:attributes];
                CGFloat strikeWidth = textSize.width;
                
                if(strikeWidth < 14.0f){
                    cell.readCntConstraint.constant = 15;
                } else {
                    cell.readCntConstraint.constant = strikeWidth+5;
                }
                cell.readCnt.textAlignment = NSTextAlignmentRight;
                
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
                            cell.descriptionLabel.text = newString;
                            [cell.descriptionLabel setNumberOfLines:5]; //글내용라인수
                        }
                    }
                    if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]){
                        cell.playButton.hidden = YES;
                        
                        NSDictionary *value = [content objectForKey:@"VALUE"];
                        thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                        originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                        originImagePath = [originImagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                        
                        if (originImagePath!=nil && ![originImagePath isEqualToString:@""]) {
                            cell.contentImageView.hidden = NO;
                            
                            [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath]
                                                     placeholderImage:nil
                                                              options:0
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                                if(image.size.width>self.tableView.frame.size.width){
                                                                    image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                                }
                                                                
                                                                cell.contentImageView.image = image;
                                                            }];
                            
//                            [imgCache queryDiskCacheForKey:originImagePath done:^(UIImage *image, SDImageCacheType cacheType) {
//                                if (image) {
//                                    //NSLog(@"이미지가 있다 (%ld) size : %f*%f", (long)indexPath.row, image.size.width, image.size.height);
//                                    image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                    cell.contentImageView.image = image;
//
//                                }else{
//                                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                                        SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
//                                        [downLoader downloadImageWithURL:[NSURL URLWithString:originImagePath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//                                        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                                            if (image && finished) {
//                                                NSLog(@"다운 완료! (%ld) size : %f*%f", (long)indexPath.row, image.size.width, image.size.height);
//                                                dispatch_async(dispatch_get_main_queue(), ^{
//                                                    UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                                    cell.contentImageView.image = img;
//                                                    [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:originImagePath toDisk:YES];
//                                                });
//
//                                            }
//                                        }];
//                                    });
//                                }
//                            }];
                            
                        } else{
                            cell.contentImageView.hidden = YES;
                        }
                        
                    }
                    if ([[content objectForKey:@"TYPE"] isEqualToString:@"VIDEO"]) {
                        cell.contentImageView.hidden = NO;
                        cell.playButton.hidden = NO;
                        cell.contentImageView.image = nil;
                        cell.videoTmpView.gestureRecognizers = nil;
                        cell.videoTmpView.tag = indexPath.row;
                        cell.playButton.tag = indexPath.row;
                        
                        NSDictionary *value = [content objectForKey:@"VALUE"];
                        
                        //서버 리턴 썸네일 있을 때
                        NSString *thumbPath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                        thumbPath = [thumbPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                        
                        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath]
                                                 placeholderImage:nil
                                                          options:0
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if(image.size.width>self.tableView.frame.size.width){
                                                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                            }
                                                            cell.contentImageView.image = image;
                                                        }];
                        
//                        [imgCache queryDiskCacheForKey:thumbPath done:^(UIImage *image, SDImageCacheType cacheType) {
//                            if (image) {
//                                //NSLog(@"이미지가 있다 (%ld) size : %f*%f", (long)indexPath.row, image.size.width, image.size.height);
//                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                cell.contentImageView.image = image;
//
//                            }else{
//                                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                                    SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
//                                    [downLoader downloadImageWithURL:[NSURL URLWithString:thumbPath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//                                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                                        if (image && finished) {
//                                            NSLog(@"다운 완료! (%ld) size : %f*%f", (long)indexPath.row, image.size.width, image.size.height);
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
//                                                cell.contentImageView.image = img;
//                                                [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:thumbPath toDisk:YES];
//                                            });
//
//                                        }
//                                    }];
//                                });
//                            }
//                        }];
                        
                    }
                    if ([[content objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                        cell.playButton.hidden = YES;
                        
                        filePath = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                        
                        NSString *fileName = @"";
                        @try{
                            NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
                            fileName = [filePath substringFromIndex:range.location+1];
                            
                        } @catch (NSException *exception) {
                            fileName = filePath;
                            NSLog(@"Exception : %@", exception);
                        }
                        
                        cell.fileName.text = fileName;
                        
                        NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
                        NSString *fileExt = [[fileName substringFromIndex:range2.location+1] lowercaseString];
                        
                        if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
                            
                        } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
                            
                        } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
                            
                        } else if([fileExt isEqualToString:@"psd"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
                            
                        } else if([fileExt isEqualToString:@"ai"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
                            
                        } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
                            
                        } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
                            
                        } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
                            
                        } else if([fileExt isEqualToString:@"pdf"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
                            
                        } else if([fileExt isEqualToString:@"txt"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
                            
                        } else if([fileExt isEqualToString:@"hwp"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
                            
                        } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                            cell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
                            
                        } else {
                            cell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
                        }
                    }
                }
                
                if(filePath!=nil && ![filePath isEqualToString:@""]){
                    cell.fileViewHeight.constant = 45;
                    cell.fileView.hidden = NO;
                    cell.fileIcon.hidden = NO;
                    cell.fileName.hidden = NO;
                    
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, 350, cell.contentView.frame.size.width, 0);
                    
                    if(![description isEqualToString:@""] && ![originImagePath isEqualToString:@""]) {
                        cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.contentImageView.frame.origin.y+cell.contentImageView.frame.size.height+7, cell.contentView.frame.size.width, 45);
                        
                    } else if([description isEqualToString:@""] && ![originImagePath isEqualToString:@""]){
                        cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y+cell.contentImageView.frame.size.height+10, cell.contentView.frame.size.width, 45);
                        
                    } else if(![description isEqualToString:@""] && [originImagePath isEqualToString:@""]){
                        cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y+cell.descriptionLabel.frame.size.height+4, cell.contentView.frame.size.width, 45);
                        
                    } else {
                        cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y, cell.contentView.frame.size.width, 45);
                    }
                }
                else {
                    cell.fileViewHeight.constant = 0;
                    cell.fileView.hidden = YES;
                    cell.fileIcon.hidden = YES;
                    cell.fileName.hidden = YES;
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.fileView.frame.origin.y, cell.contentView.frame.size.width, 0);
                }
            }
            return cell;
            
        } else if(snsKind==2){//if(self.selectBoardKind==2){
            TeamSelectTaskViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamSelectTaskViewCell"];
            
            if (cell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TeamSelectTaskViewCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[TeamSelectTaskViewCell class]]) {
                        cell = (TeamSelectTaskViewCell *) currentObject;
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            
            if(cell!=nil && self.projectDataArr.count>0){
                NSDictionary *dataSetItem = [self.projectDataArr objectAtIndex:indexPath.item];
                
                NSString *userNo = [dataSetItem objectForKey:@"CUSER_NO"];
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
                //NSString *taskCaption = [NSString urlDecodeString:[dataSetItem objectForKey:@"TASK_CAPTION"]];
                //NSArray *contentFileArray = [dataSetItem objectForKey:@"TASK_ATTACHED_FILE"];
                NSString *commCnt = [dataSetItem objectForKey:@"TASK_COMMENT_COUNT"];
                NSString *readCnt = [dataSetItem objectForKey:@"TASK_READ_COUNT"];
                
                if (![profileImagePath isEqual:@""]) {
                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
                    [cell.userImgButton setImage:userImg forState:UIControlStateNormal];
                    
                } else{
                    [cell.userImgButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
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
                
                NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
                [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
                
                NSDate *sDate = [formatter2 dateFromString:taskStartDate];
                NSDate *eDate = [formatter2 dateFromString:taskEndDate];
                
                NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                [formatter3 setDateFormat:@"yyyy-MM-dd"];
                NSString *sDateStr = [formatter3 stringFromDate:sDate];
                NSString *eDateStr = [formatter3 stringFromDate:eDate];
                
                cell.userName.text = writerName;
                cell.taskDate.text = postDateString;
                cell.teamName.text = snsName;
                
                [cell.userImgButton addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
                cell.userImgButton.tag = indexPath.item;
                
                cell.projectIcon.image = [MFUtil getScaledImage:[UIImage imageNamed:@"project_schedule_blue.png"] scaledToMaxWidth:25.0f];
                cell.projectTitle.text = taskTitle;
                
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
            }
            
            return cell;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    /*if(self.selectBoardKind==1)*/ if(snsKind==1) [self performSegueWithIdentifier:@"TEAM_POST_DETAIL" sender:indexPath];
    else if(snsKind==2)/*if(self.selectBoardKind==2)*/ [self performSegueWithIdentifier:@"TEAM_TASK_DETAIL" sender:indexPath];
}

-(void)cachingUrlImage:(NSString *)urlString indexPath:(NSInteger)index{
    @try{
        [imgCache queryDiskCacheForKey:urlString done:^(UIImage *image, SDImageCacheType cacheType) {
            if (image) {
                
            }else{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
                    [downLoader downloadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (image && finished) {
//                            NSLog(@"이미지 다운 완료 (%ld)", index);
                            [[SDImageCache sharedImageCache]storeImage:image recalculateFromImage:NO imageData:data forKey:urlString toDisk:YES];
                            if(index<3){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

                                    [CATransaction begin];
                                    [CATransaction setCompletionBlock:^{
                                        //self.tableView.scrollEnabled = YES;
                                        //[SVProgressHUD dismiss];
                                    }];
                                    [self.tableView beginUpdates];
                                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                    [self.tableView endUpdates];

                                    [CATransaction commit];
                                });
                            }
                        }
                    }];
                });
            }
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    //NSLog(@"prefetch indexPaths : %@", indexPaths);
    
    @try{
        for(int i=0; i<indexPaths.count; i++){
            NSIndexPath *idx = [indexPaths objectAtIndex:i];
            
            NSDictionary *dataSetItem = [self.normalDataArr objectAtIndex:idx.row];
            NSArray *contents = [dataSetItem objectForKey:@"CONTENT"];
            
            NSUInteger count = contents.count;
            for(int i=0; i<(int)count; i++){
                NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
                if([type isEqualToString:@"TEXT"]){
                    
                } else if([type isEqualToString:@"IMG"]){
                    NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                    NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                    
                    [self downloadImageIfNeeded:[NSURL URLWithString:originImg]];
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        [self cachingUrlImage:originImg indexPath:idx.row];
//                    });
                    break;
                    
                } else if([type isEqualToString:@"VIDEO"]) {
                    NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                    //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                    NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                    
                    [self downloadImageIfNeeded:[NSURL URLWithString:thumbImg]];
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        [self cachingUrlImage:thumbImg indexPath:idx.row];
//                    });
                    break;
                    
                } else if([type isEqualToString:@"FILE"]) {
                    
                }
            }
        }
        //    if(urlArr.count>0){
        //        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urlArr progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
        //
        //        } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        //            NSLog(@"미리 캐싱 완료!!!");
        //        }];
        //    }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

//스크롤 대충 밑에가면 자동으로 로딩해야 다음 셀 이미지 저장할 수 있음
-(void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
}

- (void)firstDownloadImageIfNeeded:(NSURL *)url
{
    if([imageManager cachedImageExistsForURL:url]){
        //NSLog(@"있어도 새로고침 해야지");
        [self.tableView reloadData];
    } else {
        [imageManager downloadImageWithURL:url
                                   options:0
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      
                                  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                      NSLog(@"없으니까 새로고침 해야지");
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
        
    }
}
- (void)downloadImageIfNeeded:(NSURL *)url {
    @try{
        if([imageManager cachedImageExistsForURL:url]){
            
        } else {
            [imageManager downloadImageWithURL:url
                                       options:0
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                          
                                      } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                          //NSLog(@"%s: downloaded %@", __FUNCTION__, self.title);
//                                          NSLog(@"없다 : %@", imageURL.absoluteString);
                                      }];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

- (void)tapDetected:(id)sender{
    @try{
        UIImageView *profileButton = (UIImageView *)sender;
        
        NSDictionary *dic = [NSDictionary dictionary];
        if(snsKind==1){//if(self.selectBoardKind==1){
            dic = [self.normalDataArr objectAtIndex:profileButton.tag];
            
        } else if(snsKind==2){//if(self.selectBoardKind==2){
            dic = [self.projectDataArr objectAtIndex:profileButton.tag];
            
        }
        
        NSString *userNo = [dic objectForKey:@"CUSER_NO"];
        NSString *userType = [dic objectForKey:@"SNS_USER_TYPE"];
        
        CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
        destination.userNo = userNo;
        destination.userType = userType;
        
        if([self.fromSegue isEqualToString:@"BOARD_SELECT_TEAM"]) destination.fromSegue = @"BOARD_PROFILE_MODAL";
        else destination.fromSegue = @"POST_PROFILE_MODAL";
        
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:destination animated:YES completion:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)createPost:(id)sender {
    if (self.snsNo != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        if(snsKind==1){//if(self.selectBoardKind==1){
            PostWriteTableViewController *destination = (PostWriteTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostWriteTableViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            
            destination.fromSegue = @"BOARD_POST_WRITE_MODAL";
            destination.snsNo = self.snsNo;
            destination.snsName = self.snsName;
            
            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:navController animated:YES completion:nil];
            
        } else if(snsKind==2){//if(self.selectBoardKind==2){
            TaskWriteViewController *destination = (TaskWriteViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskWriteViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            
            destination.fromSegue = @"BOARD_TASK_WRITE_MODAL";
            destination.snsNo = self.snsNo;
            destination.snsName = self.snsName;
            
            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (void)rightSideMenuButtonPressed:(id)sender {
    //[self performSegueWithIdentifier:@"BOARD_POST_SEARCH_MODAL" sender:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *destination = (SearchViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    destination.fromSegue = @"BOARD_POST_SEARCH_MODAL";
    destination.snsNo = self.snsNo;
    
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"TEAM_POST_DETAIL"]){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        self.navigationController.navigationBar.topItem.title = @"";
        PostDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination._postNo = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"POST_NO"];
        destination._snsName = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"SNS_NM"];
        destination._postDate = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"POST_DATE"];
        destination._readCnt = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"POST_READ_COUNT"];
        destination._commCnt = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"POST_COMMENT_COUNT"];
        destination._isRead = [[self.normalDataArr objectAtIndex:indexPath.item] objectForKey:@"IS_READ"];
        destination.indexPath  = indexPath;
        destination.postInfo = [self.normalDataArr objectAtIndex:indexPath.item];
        
        destination.fromSegue = segue.identifier;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_DeletePost:) name:@"noti_DeletePost" object:nil];
        
        if(naviClear){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //텍스트 뷰 커서에 따라 스크롤 위치 변경해주기 위해.
                [self.tableView scrollRectToVisible:CGRectMake(0, -75, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
            });
        }
        
        
    } else if([segue.identifier isEqualToString:@"TEAM_TASK_DETAIL"]){
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SaveTask:) name:@"noti_SaveTask" object:nil];
        
        self.navigationController.navigationBar.topItem.title = @"";
        TaskDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination._taskNo = [[self.projectDataArr objectAtIndex:indexPath.item] objectForKey:@"TASK_NO"];
        destination._snsName = [[self.projectDataArr objectAtIndex:indexPath.item] objectForKey:@"SNS_NM"];
        destination._taskDate = [[self.projectDataArr objectAtIndex:indexPath.item] objectForKey:@"TASK_DATE"];
        destination._readCnt = [[self.projectDataArr objectAtIndex:indexPath.item] objectForKey:@"TASK_READ_COUNT"];
        destination.indexPath  = indexPath;
        destination.taskInfo = [self.projectDataArr objectAtIndex:indexPath.item];
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(noti_DeletePost:)
        //                                                     name:@"noti_DeletePost"
        //                                                   object:nil];
    }
    
    /*else if([segue.identifier isEqualToString:@"BOARD_POST_WRITE_MODAL"]){
     [self.tabBarController.tabBar setHidden:YES];
     UINavigationController *destination = segue.destinationViewController;
     PostWriteViewController *vc = [[destination childViewControllers] objectAtIndex:0];
     vc.snsNo = self.snsNo;
     vc.snsName = self.snsName;
     vc.fromSegue = segue.identifier;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SavePost:) name:@"noti_SavePost" object:nil];
     
     } else if([segue.identifier isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
     UINavigationController *nav = segue.destinationViewController;
     SearchViewController *destination = [nav.childViewControllers objectAtIndex:0];
     destination.fromSegue = segue.identifier;
     destination.snsNo = self.snsNo;
     
     } else if([segue.identifier isEqualToString:@"BOARD_MEMBER_PROFILE_MODAL"]){
     self.navigationController.navigationBar.topItem.title = @"";
     SNSUserInfoViewController *destination = segue.destinationViewController;
     NSString *snsLeader = [self.snsInfoDic objectForKey:@"CREATE_USER_NO"];
     destination.snsNo = self.snsNo;
     destination.snsName = self.snsName;
     destination.snsLeader = snsLeader;
     destination.snsInfoDic = self.snsInfoDic;
     
     }*/
}

#pragma mark - Push Notification
- (void)noti_SavePost:(NSNotification *)notification{
    NSLog();
    
    self.lastPostNo = @"1";
    self.selectBoardKind=1;
    snsKind=1;
    [self startLoading];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SavePost" object:nil];
}

- (void)noti_SaveTask:(NSNotification *)notification{
    NSLog();
    
    self.lastTaskNo = @"1";
    self.selectBoardKind=2;
    snsKind=2;
    [self startLoading];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SaveTask" object:nil];
}

- (void)noti_DeletePost:(NSNotification *)notification{
    NSLog();
    
    self.lastPostNo = @"1";
    [self startLoading];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_DeletePost" object:nil];
}

- (void)noti_ForceDeleteSNS:(NSNotification *)notification{
    self.lastPostNo = @"1";
    [self startLoading];
}

- (void)noti_TeamProfileChat:(NSNotification *)notification {
    NSLog(@"FROM_SEGUE : %@", [notification.userInfo objectForKey:@"FROM_SEGUE"]);
    
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    if([[notification.userInfo objectForKey:@"FROM_SEGUE"] isEqualToString:@"BOARD_MEMBER_PROFILE_MODAL"]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    @try{
        //그룹선택-글목록에서 푸시받았을경우
        if([self.parentViewController childViewControllers].count == 1){ //> 1){
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
                    NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
                    NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
                    NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                    NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
                    NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
                    NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
                    NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
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

- (void)noti_ModifyBoard:(NSNotification *)notification{
    self.snsInfoDic = notification.userInfo;
    [self refreshCallGetList];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_ModifyBoard" object:nil];
}

- (void)noti_RefreshTeamSelect:(NSNotification *)notification{
    self.snsInfoDic = notification.userInfo;
    
    NSString *coverImg = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"COVER_IMG"]];
    if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
        UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
        if(image!=nil){
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :image];
            self.imageView.image = postCover;
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
            self.imageView.image = postCover;
        }
    } else {
        UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
        self.imageView.image = postCover;
    }
    
    [self refreshCallGetList];
}

- (void)noti_CloseSNS:(NSNotification *)notification{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    @try{
        [self changeNavBarAnimateWithIsClear:NO];
        
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
- (void)noti_NewChatPush:(NSNotification *)notification {
    @try{
        [self changeNavBarAnimateWithIsClear:NO];
        
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

//- (void)noti_TeamExit:(NSNotification *)notification {
//    [self dismissViewControllerAnimated:YES completion:nil];
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
//}
- (void)noti_TeamSelectExit:(NSNotification *)notification {
    NSLog();
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
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
            if(snsKind==1) /*if(self.selectBoardKind==1)*/ {
                //[self callWebService:@"getPostLists"];
            }
            else if(snsKind==2)/*if(self.selectBoardKind==2)*/ {
                [self callWebService:@"getTaskLists"];
            }
        }
    }
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    isDragging = NO;
    
    float topSize = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    if(scrollView.contentOffset.y <= -(topSize+100)) { //+100안해주면 top에서 아래서 스크롤 할때마다 호출됨
        [self startLoading];
    }
}
- (void)startLoading {
    //데이터새로고침
    [self refreshCallGetList];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;

    if(offsetY < LIMIT_OFFSET_Y) {
        [scrollView setContentOffset:CGPointMake(0, LIMIT_OFFSET_Y)];
    }

    CGFloat newOffsetY = scrollView.contentOffset.y;
    if (newOffsetY <= -IMAGE_HEIGHT) {
        self.imageView.frame = CGRectMake(0, newOffsetY, kScreenWidth, -newOffsetY);
    }

    if ((int)offsetY>[self naviChangePoint]) {
        [self changeNavBarAnimateWithIsClear:NO];
    } else {
        [self changeNavBarAnimateWithIsClear:YES];
    }
    
    if (self.lastContentOffset < scrollView.contentOffset.y) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.toolBar setHidden:YES];
            [self.addButton setHidden:YES];
        }];
    } else if (self.lastContentOffset > scrollView.contentOffset.y) {
        [self.toolBar setHidden:NO];
        [self.addButton setHidden:NO];
        
    } else {
        
    }
    
    if(allDataCnt>5){
        //스크롤 인덱스가 마지막에서 5번째 일 때 새로운 데이터 로딩
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:allDataCnt-6 inSection:0];
        CGRect rectOfCellInTableView1 = [self.tableView rectForRowAtIndexPath:firstIndexPath];
        
        NSIndexPath *firstIndexPath2 = [NSIndexPath indexPathForRow:allDataCnt-5 inSection:0];
        CGRect rectOfCellInTableView2 = [self.tableView rectForRowAtIndexPath:firstIndexPath2];
        
        if(offsetY>rectOfCellInTableView1.origin.y && offsetY<rectOfCellInTableView2.origin.y){
            if(isLoad){
                [self callWebService:@"getPostLists"];
                isLoad = NO;
            }
        }
    }
}

- (void)changeNavBarAnimateWithIsClear:(BOOL)isClear {
    [UIView animateWithDuration:0.3 animations:^{
         if (isClear == YES) {
             self.navigationController.navigationBar.translucent = YES;
             [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault]; //네비게이션에 불투명 흰색 없애기
             self.navigationController.navigationBar.shadowImage = [UIImage new]; //네비게이션 선 없애기
//
//             self.navigationController.navigationBar.backgroundColor = [UIColor clearColor]; //(기존)
             self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
             self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
             
             self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.snsName];
             naviClear = YES;

         } else {
             self.navigationController.navigationBar.translucent = NO;
//             self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]; //(기존)
             self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
             self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
             
             self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.snsName];
             naviClear = NO;
         }
     }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.y;
}

@end
