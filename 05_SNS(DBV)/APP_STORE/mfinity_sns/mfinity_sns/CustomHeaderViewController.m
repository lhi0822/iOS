//
//  CustomHeaderViewController.m
//  ARSegmentPager
//
//  Created by August on 15/5/20.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "CustomHeaderViewController.h"
#import "ProfilePostViewController.h"
#import "ProfileCommViewController.h"
#import "ProfileFileViewController.h"
#import "CustomHeader.h"
#import "TaskDetailViewController.h"
#import "EmptyViewController.h"
#import "NotiChatViewController.h"

#define NAVBAR_CHANGE_POINT 50
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f
#define kSupplementaryViewID @"SUP_VIEW_ID"
#define MODEL_NAME [[UIDevice currentDevice] modelName]

void *CustomHeaderInsetObserver = &CustomHeaderInsetObserver;

@interface CustomHeaderViewController () {
    NSUInteger currPage;
    NSArray *vcArr;
    UINavigationBar *navBar;
    AppDelegate *appDelegate;
    BOOL isFavorite;
}

@property (nonatomic, strong) CustomHeader *header;

@end

@implementation CustomHeaderViewController

- (instancetype)initwithUserNo:(NSString *)userNo userType:(NSString *)userType{
    _userNo = userNo;
    _userType = userType;
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    return [self init];
}

-(instancetype)init
{
    currPage=0;
    isFavorite = NO;
    [self callGetFavoriteUsers];
    
    NSMutableArray *selectUser = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserInfo:self.userNo]];
//    NSLog(@"selectUser : %@", selectUser);
    
    if(selectUser.count==0){
        [self callGetProfile];
    } else {
        self.userName = [[selectUser objectAtIndex:0]objectForKey:@"USER_NM"];
        self.userID = [[selectUser objectAtIndex:0]objectForKey:@"USER_ID"];
        self.phoneNo = [[selectUser objectAtIndex:0]objectForKey:@"USER_PHONE"];
        self.imageFileName = [[selectUser objectAtIndex:0]objectForKey:@"USER_IMG"]; //origin
        self.statusMsg = [[selectUser objectAtIndex:0]objectForKey:@"USER_MSG"];
        self.bgImageFileName = [[selectUser objectAtIndex:0]objectForKey:@"USER_BG_IMG"]; //origin
        
        self.levelName = [[selectUser objectAtIndex:0] objectForKey:@"LEVEL_NM"];
        self.deptName = [[selectUser objectAtIndex:0] objectForKey:@"DEPT_NM"];
        self.exCompName = [[selectUser objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfilePostViewController *vc1 = (ProfilePostViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfilePostViewController"];
    ProfileCommViewController *vc2 = (ProfileCommViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileCommViewController"];
    ProfileFileViewController *vc3 = (ProfileFileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileFileViewController"];
    
    EmptyViewController *emptyView = [[EmptyViewController alloc] init];
    emptyView.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    
    vc1.userNo = self.userNo;
    vc1.userNm = self.userName;
    vc1.userImgPath = self.imageFileName;
    
    vc2.userNo = self.userNo;
    vc2.userNm = self.userName;
    
    vc3.userNo = self.userNo;
    vc3.userNm = self.userName;
    
    self.segUserType = self.userType;
    
    if([self.userType isEqualToString:@"1"]){
        self = [super initWithControllers:emptyView, nil];
        self.segmentHeight = 0;
        
    } else {
        self = [super initWithControllers:vc1,vc2,vc3, nil];
    }
    
    if (self) {
        // your code
        self.segmentMiniTopInset = 64;
        if (@available(iOS 11.0, *)) {
            self.segmentMiniTopInset = 84;
        }
        self.headerHeight = 305;
    }

    return self;
}

-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    if (_header == nil) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"CustomHeader" owner:nil options:nil] lastObject];
    }
    return _header;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"fromSegue : %@", self.fromSegue);

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self addObserver:self forKeyPath:@"segmentTopInset" options:NSKeyValueObservingOptionNew context:CustomHeaderInsetObserver];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    
    currPage=0;
    isFavorite = NO;
    [self callGetFavoriteUsers];
    
    NSMutableArray *selectUser = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserInfo:self.userNo]];
    if(selectUser.count==0){
//        [self callGetProfile];
    } else {
//        self.userName = [[selectUser objectAtIndex:0]objectForKey:@"USER_NM"];
//        self.userID = [[selectUser objectAtIndex:0]objectForKey:@"USER_ID"];
//        self.phoneNo = [[selectUser objectAtIndex:0]objectForKey:@"USER_PHONE"];
//        self.imageFileName = [[selectUser objectAtIndex:0]objectForKey:@"USER_IMG"]; //origin
//        self.statusMsg = [[selectUser objectAtIndex:0]objectForKey:@"USER_MSG"];
//        self.bgImageFileName = [[selectUser objectAtIndex:0]objectForKey:@"USER_BG_IMG"]; //origin
//
//        self.levelName = [[selectUser objectAtIndex:0] objectForKey:@"LEVEL_NM"];
//        self.deptName = [[selectUser objectAtIndex:0] objectForKey:@"DEPT_NM"];
//        self.exCompName = [[selectUser objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"];
        
        [self createItem];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *statusBar;
    if (@available(iOS 13, *)) {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    } else {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    statusBar.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (context == CustomHeaderInsetObserver) {
        CGFloat inset = [change[NSKeyValueChangeNewKey] intValue];
        [self.header updateHeadPhotoWithTopInset:inset];
    }
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"segmentTopInset"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeModal{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"naviNoti" object:nil];
    });
}

-(void)userFavoriteClick{
    NSLog(@"%@", isFavorite? @"즐겨찾기 돼 있음->즐찾 해제":@"즐겨찾기 안 돼 있음->즐찾 추가");

    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *paramString = @"";
    NSString *resultUrl = @"";
    
    if(isFavorite){
        paramString = [NSString stringWithFormat:@"usrNo=%@&tarUsrNo=%@&dvcId=%@", userNo, self.userNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        resultUrl = [urlString stringByAppendingPathComponent:@"deleteFavoriteUser"];
        
    } else {
        paramString = [NSString stringWithFormat:@"usrNo=%@&tarUsrNo=%@&dvcId=%@", userNo, self.userNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        resultUrl = [urlString stringByAppendingPathComponent:@"saveFavoriteUser"];
        
    }
    MFURLSession *session = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:resultUrl] option:paramString];
    session.delegate = self;
    [session start];
    
}

-(void)setFavoriteUserView{
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    [self.header.userNameButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 3.0, 0.0)];
    [self.header.userNameButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.header.userNameButton setTitle:self.userName forState:UIControlStateNormal];
    
    if(![self.userType isEqualToString:@"1"]){
        if([[NSString stringWithFormat:@"%@", self.userNo] isEqualToString:[NSString stringWithFormat:@"%@", userNo]]){
            [self.header.userNameButton setImage:nil forState:UIControlStateNormal];
            [self.header.userNameButton removeTarget:self action:@selector(userFavoriteClick) forControlEvents:UIControlEventTouchUpInside];
        } else {
            if(isFavorite==YES){
                [self.header.userNameButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"bookmark_on.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                [self.header.userNameButton addTarget:self action:@selector(userFavoriteClick) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [self.header.userNameButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"bookmark_off.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                [self.header.userNameButton addTarget:self action:@selector(userFavoriteClick) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
}
-(void)createItem{
    [self.header.closeButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
    [self.header.closeButton addTarget:self action:@selector(closeModal) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *levelStr = @"";
    NSString *deptStr = @"";
    if(self.levelName!=nil&&![self.levelName isEqualToString:@""]) levelStr = [NSString stringWithFormat:@"%@/", self.levelName];
    if(self.deptName!=nil&&![self.deptName isEqualToString:@""]) deptStr = [NSString stringWithFormat:@"%@/", self.deptName];
    
    if(self.levelName.length<1&&self.deptName.length<1&&self.exCompName.length<1) self.header.userStatusLabel.text = self.statusMsg;
    else self.header.userStatusLabel.text = [NSString stringWithFormat:@"%@%@%@\n%@", levelStr, deptStr, self.exCompName, self.statusMsg];
    
    [self.header.userStatusLabel setNumberOfLines:3];
    [self.header.userStatusLabel sizeToFit];
    
    if(![self.imageFileName isEqualToString:@""]&&self.imageFileName!=nil){
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:self.imageFileName num:self.userNo]];
        [self.header.profileImageButton setImage:userImg forState:UIControlStateNormal];
    } else {
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[UIImage imageNamed:@"profile_default.png"]];
        [self.header.profileImageButton setImage:userImg forState:UIControlStateNormal];
    }
    
    if(![self.bgImageFileName isEqualToString:@""]&&![self.bgImageFileName isEqualToString:@"(null)"]&&self.bgImageFileName!=nil){
        UIImage *bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.header.profileBgImgView.frame.size.width, self.header.profileBgImgView.frame.size.height) :[MFUtil saveThumbImage:@"ProfileBg" path:self.bgImageFileName num:self.userNo]];
        self.header.profileBgImgView.image = bgImg;
    } else {
        UIImage *bgImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.header.profileBgImgView.frame.size.width, self.header.profileBgImgView.frame.size.height) :[UIImage imageNamed:@"profile_bg_default_hhi.png"]];
        self.header.profileBgImgView.image = bgImg;
    }
    
    [self.header.profileImageButton addTarget:self action:@selector(touchedProfileButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileBgImg:)];
    [self.header.profileBgImgView setUserInteractionEnabled:YES];
    [self.header.profileBgImgView addGestureRecognizer:tap];
    
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    if([self.userType isEqualToString:@"1"]){
        self.header.menuButton1.hidden=YES;
        self.header.menuButton2.hidden=YES;
        self.header.menuButton3.hidden=YES;
        
    } else {
        if(![[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", self.userNo]]){
            //NSLog(@"ProfileViewController sideMemCnt : %lu", (unsigned long)self.sideMemberCnt);
            self.header.menuButton1.hidden=NO;
            self.header.menuButton2.hidden=NO;
            
            self.header.menuButton1.layer.cornerRadius = self.header.menuButton1.frame.size.width/20;
            self.header.menuButton1.clipsToBounds = YES;
            [self.header.menuButton1.layer setBorderWidth:0.5];
            [self.header.menuButton1.layer setBorderColor:[[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
            [self.header.menuButton1 setBackgroundColor:[UIColor clearColor]];
            
            //아이콘색상변경
            UIImage *image1 = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:22.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.header.menuButton1 setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
            [self.header.menuButton1 setImage:image1 forState:UIControlStateNormal];
            
            [self.header.menuButton1 setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
            [self.header.menuButton1 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
            [self.header.menuButton1 setTitle:NSLocalizedString(@"profile_detail_btn1_you", @"profile_detail_btn1_you") forState:UIControlStateNormal];
            [self.header.menuButton1 setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
            [self.header.menuButton1 addTarget:self action:@selector(touchedChatButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.header.menuButton2.layer.cornerRadius = self.header.menuButton2.frame.size.width/20;
            self.header.menuButton2.clipsToBounds = YES;
            [self.header.menuButton2.layer setBorderWidth:0.5];
            [self.header.menuButton2.layer setBorderColor:[[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
            [self.header.menuButton2 setBackgroundColor:[UIColor clearColor]];
            
            //UIImage *image2 = [[MFUtil getScaledImage:[UIImage imageNamed:@"btn_call.png"] scaledToMaxWidth:22.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            //[self.header.menuButton2 setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
            //[self.header.menuButton2 setImage:image2 forState:UIControlStateNormal];
            
            //[self.header.menuButton2 setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
            //[self.header.menuButton2 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
            //[self.header.menuButton2 setTitle:NSLocalizedString(@"profile_detail_btn2_you", @"profile_detail_btn2_you") forState:UIControlStateNormal];
            [self.header.menuButton2 setTitle:self.phoneNo forState:UIControlStateNormal];
            [self.header.menuButton2 setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
            [self.header.menuButton2 removeTarget:self action:@selector(touchedMyInfoButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.header.menuButton2 addTarget:self action:@selector(touchedCallButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.header.menuButton3.hidden=YES;
            
            if([self.fromSegue isEqualToString:@"CHAT_PROFILE_MODAL"]||[self.fromSegue isEqualToString:@"CHAT_SIDE_PROFILE_MODAL"]){
                if([self.chatRoomTy isEqualToString:@"1"]){
                    //1:1채팅
                    self.header.menuButton1.hidden=YES;
                    self.header.menuButton2.hidden=NO;
                    self.header.menuButton3.hidden=YES;
                    
                    [self.header.menuButton2 setFrame:CGRectMake(self.header.menuButton3.frame.origin.x, self.header.menuButton3.frame.origin.y, self.header.menuButton3.frame.size.width, self.header.menuButton2.frame.size.height)];
                    
                    self.header.menuButton2.layer.cornerRadius = self.header.menuButton2.frame.size.width/35;
                    
                } else if([self.chatRoomTy isEqualToString:@"2"]){
                    //단체채팅
                    self.header.menuButton1.hidden=NO;
                    self.header.menuButton2.hidden=NO;
                    self.header.menuButton3.hidden=YES;
                    
                } /*else if([self.chatRoomTy isEqualToString:@"3"]){
                   //나와의채팅
                   self.menuButton1.hidden=YES;
                   self.menuButton2.hidden=YES;
                   self.menuButton3.hidden=NO;
                   }*/
            }
            
        } else {
            self.header.menuButton1.hidden=NO;
            self.header.menuButton2.hidden=NO;
            
            self.header.menuButton1.layer.cornerRadius = self.header.menuButton1.frame.size.width/20;
            self.header.menuButton1.clipsToBounds = YES;
            [self.header.menuButton1.layer setBorderWidth:0.5];
            [self.header.menuButton1.layer setBorderColor:[[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
            [self.header.menuButton1 setBackgroundColor:[UIColor clearColor]];
            //[self.header.menuButton1 setImage:[self getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:22.0f] forState:UIControlStateNormal];
            
            UIImage *image1 = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk_over.png"] scaledToMaxWidth:22.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.header.menuButton1 setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
            [self.header.menuButton1 setImage:image1 forState:UIControlStateNormal];
            
            [self.header.menuButton1 setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
            [self.header.menuButton1 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
            [self.header.menuButton1 setTitle:NSLocalizedString(@"profile_detail_btn1_me", @"profile_detail_btn1_me") forState:UIControlStateNormal];
            [self.header.menuButton1 setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
            [self.header.menuButton1 addTarget:self action:@selector(touchedChatButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if([self.chatRoomTy isEqualToString:@"3"]){
                //나와의채팅
                self.header.menuButton3.layer.cornerRadius = self.header.menuButton3.frame.size.width/35;
                self.header.menuButton3.clipsToBounds = YES;
                [self.header.menuButton3.layer setBorderWidth:0.5];
                [self.header.menuButton3.layer setBorderColor:[[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [self.header.menuButton3 setBackgroundColor:[UIColor clearColor]];
                //[self.header.menuButton3 setImage:[self getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:22.0f] forState:UIControlStateNormal];
                
                UIImage *image2 = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:22.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.header.menuButton3 setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
                [self.header.menuButton3 setImage:image2 forState:UIControlStateNormal];
                
                [self.header.menuButton3 setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
                [self.header.menuButton3 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
                [self.header.menuButton3 setTitle:NSLocalizedString(@"profile_detail_btn2_me", @"profile_detail_btn2_me") forState:UIControlStateNormal];
                [self.header.menuButton3 setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
                [self.header.menuButton3 addTarget:self action:@selector(touchedMyInfoButton:) forControlEvents:UIControlEventTouchUpInside];
                
                self.header.menuButton1.hidden=YES;
                self.header.menuButton2.hidden=YES;
                self.header.menuButton3.hidden=NO;
                
                [self.header.menuButton3 setFrame:CGRectMake(self.header.menuButton3.frame.origin.x, self.header.menuButton3.frame.origin.y, self.view.frame.size.width-(self.header.menuButton3.frame.origin.x*2), self.header.menuButton3.frame.size.height)];
                
            } else {
                self.header.menuButton2.layer.cornerRadius = self.header.menuButton2.frame.size.width/20;
                self.header.menuButton2.clipsToBounds = YES;
                [self.header.menuButton2.layer setBorderWidth:0.5];
                [self.header.menuButton2.layer setBorderColor:[[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [self.header.menuButton2 setBackgroundColor:[UIColor clearColor]];
                //[self.header.menuButton2 setImage:[self getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:22.0f] forState:UIControlStateNormal];
                
                UIImage *image3 = [[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile_over.png"] scaledToMaxWidth:22.0f] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.header.menuButton2 setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
                [self.header.menuButton2 setImage:image3 forState:UIControlStateNormal];
                
                [self.header.menuButton2 setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
                [self.header.menuButton2 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
                [self.header.menuButton2 setTitle:NSLocalizedString(@"profile_detail_btn2_me", @"profile_detail_btn2_me") forState:UIControlStateNormal];
                [self.header.menuButton2 setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
                [self.header.menuButton2 removeTarget:self action:@selector(touchedCallButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.header.menuButton2 addTarget:self action:@selector(touchedMyInfoButton:) forControlEvents:UIControlEventTouchUpInside];
                
                self.header.menuButton1.hidden=NO;
                self.header.menuButton2.hidden=NO;
                self.header.menuButton3.hidden=YES;
                
            }
        }
    }
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
    NSLog();
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
    
    appDelegate.inactiveChatPushInfo=nil;
}

-(void)menuButton1Click:(id)sender{
//    NSLog(@"menuButton1Click");
}
-(void)menuButton2Click:(id)sender{
//    NSLog(@"menuButton2Click");
}

-(IBAction)touchedCallButton:(id)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"profile_detail_btn2_you", @"profile_detail_btn2_you")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                  
                                                                  NSString *inValue = [self.phoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",inValue]] options:@{} completionHandler:nil];
                                                              }];
    
    UIAlertAction *smsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"profile_detail_btn3_you", @"profile_detail_btn3_you")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                  
                                                                  MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                                                                  NSMutableArray *array = [[NSMutableArray alloc]init];
                                                                  
                                                                  NSString *inValue = [self.phoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
                                                                  [array addObject:inValue];
                                                                  if([MFMessageComposeViewController canSendText])
                                                                  {
                                                                      //controller.body = msg;
                                                                      controller.recipients = array;
                                                                      controller.messageComposeDelegate = self;
                                                                      [self presentViewController:controller animated:YES completion:nil];
                                                                  }
                                                              }];
    
    [actionSheet addAction:callAction];
    [actionSheet addAction:smsAction];
    
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

-(IBAction)touchedChatButton:(id)sender{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSMutableArray *deptArr = [NSMutableArray array];
    NSMutableArray *userArr = [NSMutableArray array];
    [userArr addObject:myUserNo];
    
    if(![[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", self.userNo]]) [userArr addObject:self.userNo];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    [resultDic setObject:deptArr forKey:@"depts"];
    [resultDic setValue:userArr forKey:@"users"];
    
    [self callSaveChatInfo:resultDic];
}

-(IBAction)touchedMyInfoButton:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyViewController *vc = (MyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MyViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:self.userName forKey:@"USER_NM"];
    [infoDic setObject:self.imageFileName forKey:@"PROFILE_IMG"];
    [infoDic setObject:self.statusMsg forKey:@"PROFILE_MSG"];
    [infoDic setObject:self.bgImageFileName forKey:@"PROFILE_BACKGROUND_IMG"];
    
    vc.infoDic = infoDic;
    vc.fromSegue = @"PROFILE_TO_MY_MODAL";
    
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)callGetFavoriteUsers {
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&dvcId=%@", userNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getFavoriteUsers"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)callGetProfile {
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&dvcId=%@", self.userNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getProfile"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)callSaveChatInfo: (NSMutableDictionary *)dictionary {
    //saveChatInfo - usrId, attendants:{"depts":"[부서]","users":"[사용자]"}
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userID = [appDelegate.appPrefs objectForKey:@"USERID"];
    
    NSString *inviteMode = @"INVITE_CHAT";
    NSString *inviteRef1 = @"";
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrNo=%@&attendants=%@&inviteMode=%@&inviteRef1=%@&dvcId=%@", userID, userNo, jsonData, inviteMode, inviteRef1, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatInfo"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
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
                [newChatDic setObject:self.fromSegue forKey:@"FROM_SEGUE"];
                
                if([self.fromSegue isEqualToString:@"CHAT_SIDE_PROFILE_MODAL"]){
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SideProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                    
                } else if([self.fromSegue isEqualToString:@"CHAT_PROFILE_MODAL"]){
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SideProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                    
                } else if([self.fromSegue isEqualToString:@"BOARD_PROFILE_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_MEMBER_PROFILE_MODAL"]){
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                    
                } else if([self.fromSegue isEqualToString:@"POST_PROFILE_MODAL"]){
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_FeedProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                    
                } else if([self.fromSegue isEqualToString:@"USER_LIST_PROFILE_MODAL"]){
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_UserListProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                    
                } else {
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostProfileChat"
                                                                            object:nil
                                                                          userInfo:newChatDic];
                    }];
                }
            } else if([wsName isEqualToString:@"getFavoriteUsers"]){
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
                
                @try{
                    NSString *jsonStr = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FAVORITE_USERS"]];
                    if(jsonStr.length>0){
                        NSArray *userArr = [NSArray array];
                        BOOL isTheObjectThere;
                        
                        if([jsonStr rangeOfString:@","].location != NSNotFound){
                            userArr = [jsonStr componentsSeparatedByString:@","];
                            isTheObjectThere = [userArr containsObject:[NSString stringWithFormat:@"%@", self.userNo]];
                            
                        } else {
                            userArr = [userArr arrayByAddingObject:jsonStr];
                            isTheObjectThere = [userArr containsObject:[NSString stringWithFormat:@"%@", self.userNo]];
                        }
//                        NSLog(@"결과 : %@", isTheObjectThere? @"있다":@"없다");
                        if(isTheObjectThere) isFavorite = YES;
                    }
                    [self setFavoriteUserView];
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            } else if([wsName isEqualToString:@"saveFavoriteUser"]){
                @try{
                    int affected = [[dic objectForKey:@"AFFECTED"] intValue];
                    if(affected>0){
                        [self.header.userNameButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"bookmark_on.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                        isFavorite = YES;
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            } else if([wsName isEqualToString:@"deleteFavoriteUser"]){
                @try{
                    int affected = [[dic objectForKey:@"AFFECTED"] intValue];
                    if(affected>0){
                        [self.header.userNameButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"bookmark_off.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                        isFavorite = NO;
                    }
                        
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            } else if([wsName isEqualToString:@"getProfile"]) {
                //getProfile
                NSArray *dataSet = [dic objectForKey:@"DATASET"];
//                NSLog(@"dataSet : %@", dataSet);
                
                @try{
                    self.userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
                    self.userID = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CUSER_ID"]];
                    self.phoneNo = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PHONE_NO"]];
                    self.imageFileName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]]; //origin
                    self.statusMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
                    self.bgImageFileName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]]; //origin
                    
                    self.levelName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NM"]];
                    self.deptName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DEPT_NM"]];
                    self.exCompName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"]];
                    
                    NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
                    NSString *deptNo = [[dataSet objectAtIndex:0] objectForKey:@"DEPT_NO"];
                    NSString *levelNo = [[dataSet objectAtIndex:0] objectForKey:@"LEVEL_NO"];
                    NSString *dutyNo = [[dataSet objectAtIndex:0] objectForKey:@"DUTY_NO"];
                    NSString *dutyName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"DUTY_NM"]];
                    NSString *jobGrpName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"JOB_GRP_NM"]];
                    NSString *exCompNo = [[dataSet objectAtIndex:0] objectForKey:@"EX_COMPANY"];
                    NSString *userType = [[dataSet objectAtIndex:0] objectForKey:@"SNS_USER_TYPE"];
                    
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:_userID userName:_userName userImg:_imageFileName userMsg:_statusMsg phoneNo:_phoneNo deptNo:deptNo userBgImg:_bgImageFileName deptName:_deptName levelNo:levelNo levelName:_levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:_exCompName userType:userType];
                    [appDelegate.dbHelper crudStatement:sqlString];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SetUserData" object:nil];
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
                [self createItem];
                //[self createPageView];
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);

    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        [self callGetFavoriteUsers];
        [self callGetProfile];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = NSLocalizedString(@"cancel", @"");
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = NSLocalizedString(@"fail", @"");
            break;
        }
            
        case MessageComposeResultSent:
            resultString = NSLocalizedString(@"success", @"");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"resultString : %@",resultString);
    }];
    
}
-(IBAction)touchedProfileButton:(id)sender{
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    if ([self.imageFileName isEqualToString:@"-"] || [self.imageFileName isEqualToString:@""]) {
        
    }else{
        NSRange range = [self.imageFileName rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *thumbfileName = [self.imageFileName substringFromIndex:range.location+1];
        
        //self.imageFileName가 썸네일경로이면 thumb를 지우고 원본으로 보여주기위함 (하지만 이미 self.imageFileName은 원본경로)
        self.imageFileName = [self.imageFileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"thumb/%@", thumbfileName] withString:[NSString stringWithFormat:@"%@", thumbfileName]];
        
        imageInfo.imageURL = [NSURL URLWithString:[self.imageFileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                                  initWithImageInfo:imageInfo
                                                  mode:JTSImageViewControllerMode_Image
                                                  backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}
- (void)tapOnProfileBgImg:(UITapGestureRecognizer*)tap{
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    if ([self.bgImageFileName isEqualToString:@"-"] || [self.bgImageFileName isEqualToString:@""]) {
        
    }else{
        NSRange range = [self.bgImageFileName rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *thumbfileName = [self.bgImageFileName substringFromIndex:range.location+1];
        self.bgImageFileName = [self.bgImageFileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"thumb/%@", thumbfileName] withString:[NSString stringWithFormat:@"%@", thumbfileName]];
        
        imageInfo.imageURL = [NSURL URLWithString:[self.bgImageFileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                                  initWithImageInfo:imageInfo
                                                  mode:JTSImageViewControllerMode_Image
                                                  backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
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
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PROFILE_TO_MY_MODAL"]) {
        UINavigationController *destination = segue.destinationViewController;
        MyViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:self.userName forKey:@"USER_NM"];
        [infoDic setObject:self.imageFileName forKey:@"PROFILE_IMG"];
        [infoDic setObject:self.statusMsg forKey:@"PROFILE_MSG"];
        [infoDic setObject:self.bgImageFileName forKey:@"PROFILE_BACKGROUND_IMG"];
        
        vc.infoDic = infoDic;
        vc.fromSegue = @"PROFILE_TO_MY_MODAL";
        
        destination.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:destination animated:YES completion:nil];
    }
}

@end
