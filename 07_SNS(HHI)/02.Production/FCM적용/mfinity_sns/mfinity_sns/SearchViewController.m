//
//  SearchViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "SearchViewController.h"
#import "NewsFeedViewCell.h"
#import "PostDetailViewController.h"
#import "TaskDetailViewController.h"
#import "TeamListViewController.h"
#import "NewsFeedViewController.h"
#import "MFGroupCell.h"
#import "TeamSelectController.h"
#import "SearchChatListViewCell.h"
#import "MFDBHelper.h"
#import "NotiChatViewController.h"

#define ROW_TAG 1000

#define REFRESH_TABLEVIEW_DEFAULT_ROW               44.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               44.f
#define REFRESH_TITLE_TABLE_PULL                    @"당겼다 놔주세요."
#define REFRESH_TITLE_TABLE_RELEASE                 @"당겼다 놔주세요."
#define REFRESH_TITLE_TABLE_LOAD                    @"새로고치는 중..."
#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"

#define kSupplementaryViewID @"SUP_VIEW_ID"
#define MODEL_NAME [[UIDevice currentDevice] modelName]

@interface SearchViewController () {
    NSString *searchText;
    NSString *urlString;
    int notMemberCnt;
    AppDelegate *appDelegate;
    SDImageCache *imgCache;
}

@end

@implementation SearchViewController

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"검색", @"검색")];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewTaskPush:) name:@"noti_NewTaskPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    self.lastPostNo = @"1";
    
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"]){
        self.searchBar.placeholder = NSLocalizedString(@"search_feed", @"search_feed");
    } else if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
        self.searchBar.placeholder = NSLocalizedString(@"search_board", @"search_board");
    } else if([self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        self.searchBar.placeholder = NSLocalizedString(@"search_board", @"search_board");
    } else if([self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        self.searchBar.placeholder = NSLocalizedString(@"search_feed", @"search_feed");
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        self.searchBar.placeholder = NSLocalizedString(@"search_message", @"search_message");
    } else {
        self.searchBar.placeholder = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text{
    searchText = text;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        self.boardDataSetArray = [[NSMutableArray alloc]init];
        //[self callGetSNSList:searchText];
        [self callWebService:@"getUserSNSLists" :searchText];
        
    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        self.postDataSetArray = [[NSMutableArray alloc]init];
        self.lastPostNo = @"1";
        //[self callGetPostList:searchText];
        [self callWebService:@"getPostLists" :searchText];
        
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        [self chatListReadFromDatabase:searchText];
    }
}

-(void)callWebService:(NSString *)serviceName :(NSString *)param{
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    NSString *paramString;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    if([serviceName isEqualToString:@"getUserSNSLists"]){
        paramString = [NSString stringWithFormat:@"compNo=%@&usrId=%@&snsKind=1&searchNm=%@&dvcId=%@",compNo, [appDelegate.appPrefs objectForKey:@"USERID"], param, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        
    } else if([serviceName isEqualToString:@"getPostLists"]){
        paramString = [NSString stringWithFormat:@"stPostSeq=%@&usrNo=%@&searchNm=%@&dvcId=%@",self.lastPostNo, myUserNo, param, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        
        if (self.snsNo!=nil) {
            paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
        }
        
    } else if([serviceName isEqualToString:@"joinSNS"]){
        paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&dvcId=%@", myUserNo, param, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        
    } else if([serviceName isEqualToString:@"withdrawSNS"]){
        NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&snsNo=%@&mfpsId=%@&isJoin=false&dvcId=%@", myUserNo, compNo, param, mfpsId, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    }
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)refreshCallGetPostList:(NSString *)text{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *paramString = [NSString stringWithFormat:@"stPostSeq=1&usrNo=%@&searchNm=%@&dvcId=%@", myUserNo, text, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    if (self.snsNo!=nil) {
        paramString = [paramString stringByAppendingFormat:@"&snsNo=%@",self.snsNo];
    }
    
    self.postDataSetArray = [[NSMutableArray alloc]init];
    self.lastPostNo = @"1";
    
    [self callWebService:@"getPostLists" :text];
}

- (void)chatListReadFromDatabase:(NSString *)text {
    NSString *sqlString = [appDelegate.dbHelper getRoomList:text];
    
    self.chatArray = [NSMutableArray array];
    self.tempArr = [NSMutableArray array];
    
    self.chatArray = [appDelegate.dbHelper selectMutableArray:sqlString];
    self.tempArr = [self.chatArray mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
    
    if([wsName isEqualToString:@"getUserSNSLists"]){
        if (error!=nil) {
            NSLog(@"error : %@",error);
        }else{
            NSDictionary *dic = session.returnDictionary;
            self.boardDataSetArray = [dic objectForKey:@"DATASET"];
            
            notMemberCnt=0;
            for(int i=0; i<self.boardDataSetArray.count; i++){
                NSDictionary *dataSet = [self.boardDataSetArray objectAtIndex:i];
                NSString *itemType = [dataSet objectForKey:@"ITEM_TYPE"];
                
                if(![itemType isEqualToString:@"MEMBER"]){
                    notMemberCnt++;
                }
            }
            [self.tableView reloadData];
        }
        
    } else if([wsName isEqualToString:@"getPostLists"]){
        if (error!=nil || [error isEqualToString:@"(null)"]) {
            if ([error isEqualToString:@"The request timed out."]) {
                [self callWebService:@"getPostLists" :nil];
                
            }else{

            }
            
        } else{
            NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
            
            NSString *seq = [[NSString alloc]init];
            for(int i=1; i<=dataSets.count; i++){
                seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
            }
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([self.lastPostNo intValue]==1) {
                    self.lastPostNo = seq;
                    self.postDataSetArray = [NSMutableArray arrayWithArray:dataSets];
                    
                }else{
                    if (dataSets.count>0){
                        self.lastPostNo = seq;
                        //[self.dataSetArray addObjectsFromArray:[session.returnDictionary objectForKey:@"DATASET"]]; //thin copy 참조만
                        [self.postDataSetArray addObjectsFromArray:dataSets]; //deep copy
                    }
                }
                [self.tableView reloadData];
                
            }else{
                NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
            }
        }
        [self stopLoading];
        
    } else if([wsName isEqualToString:@"joinSNS"]){
        if ([result isEqualToString:@"SUCCESS"]) {
            NSMutableArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
            NSString *affected = [[dataSet objectAtIndex:0] objectForKey:@"AFFECTED"];
            NSString *needAllow = [[dataSet objectAtIndex:0] objectForKey:@"NEED_ALLOW"];
            NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
            
            self.boardDataSetArray = [[NSMutableArray alloc]init];
            [self callWebService:@"getUserSNSLists" :searchText];
            
            if ([affected intValue]>=0) {
                if([needAllow isEqualToString:@"0"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast1_1", @"join_sns_toast1_1"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else if([needAllow isEqualToString:@"1"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast2", @"join_sns_toast2"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            } else {
                //이미 가입 처리
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast10", @"join_sns_toast10") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } else if([wsName isEqualToString:@"withdrawSNS"]){
        [self callWebService:@"getUserSNSLists" :searchText];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast9", @"join_sns_toast9") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil];
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)postImgCaching:(NSArray *)contents{
    NSUInteger count = contents.count;
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    
    @try{
        for(int i=0; i<(int)count; i++){
            NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                
                //썸네일을 로컬에 저장
                NSString *thumbImgPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[thumbImg lastPathComponent]]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbImgPath];
                if(!fileExists){
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImg]];
                    [data writeToFile:thumbImgPath atomically:YES];
                }
                
                
            } else if([type isEqualToString:@"VIDEO"]) {
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                
                //썸네일을 로컬에 저장
                NSString *thumbImgPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[thumbImg lastPathComponent]]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbImgPath];
                if(!fileExists){
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImg]];
                    [data writeToFile:thumbImgPath atomically:YES];
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
        if(self.boardDataSetArray.count > 0){
            return self.boardDataSetArray.count;
        } else {
            return 0;
        }
        
    } else if([self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        if(self.boardDataSetArray.count-notMemberCnt > 0){
            return self.boardDataSetArray.count-notMemberCnt;
        } else {
            return 0;
        }
        
    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        if(self.postDataSetArray.count > 0){
            return self.postDataSetArray.count;
        } else {
            return 0;
        }
        
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        if(self.chatArray.count > 0){
            return self.chatArray.count;
        } else {
            return 0;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        return 80;
        
    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        return UITableViewAutomaticDimension;
        /*
        if(self.postDataSetArray != nil){
            NSDictionary *dataSetItem = [self.postDataSetArray objectAtIndex:indexPath.row];
            NSArray *contentArray =[dataSetItem objectForKey:@"CONTENT"];
            
            BOOL isText = false;
            BOOL isImg = false;
            BOOL isFile = false;
            
            for (NSDictionary *content in contentArray) {
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"TEXT"]) {
                    isText = YES;
                } else if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    isImg = YES;
                } else if ([[content objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                    isFile = YES;
                }
            }
            
            //NSLog(@"contentArray : %@", contentArray);
            
            if(isText && !isImg && !isFile) {
                return 208;
                
            } else if(isText && isImg && !isFile){
                return 458;
                
            } else if(isText && !isImg && isFile){
                return 258;
                
            } else if(isText && isImg && isFile){
                return 513;
                
            } else if(!isText && isImg && !isFile){
                return 422;
                
            } else if(!isText && isImg && isFile){
                return 482;
                
            } else if(!isText && !isImg && isFile){
                return 217;
                
            } else {
                return 513;
            }
        }
         */
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        return 76;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        MFGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFGroupCell"];
        
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MFGroupCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[MFGroupCell class]]) {
                    cell = (MFGroupCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        NSDictionary *sns = [self.boardDataSetArray objectAtIndex:indexPath.row];
        NSString *snsStatus = [sns objectForKey:@"ITEM_TYPE"];
        
        if([self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]&&[snsStatus isEqualToString:@"MEMBER"]){
            [self setUpBoardSearchCell:cell atIndexPath:indexPath];
        } else {
            [self setUpBoardSearchCell:cell atIndexPath:indexPath];
        }
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        cell.gestureRecognizers = nil;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(boardLongClick:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [cell addGestureRecognizer:longPress];
        
        return cell;
        
    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"]){
        NewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsFeedViewCell"];
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[NewsFeedViewCell class]]) {
                    cell = (NewsFeedViewCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        cell.descriptionLabel.text = nil;
        cell.contentImageView.image = nil;
        cell.fileName.text = nil;
        cell.fileViewHeight.constant = 0;
        cell.playButton.hidden = YES;
        
        if(cell!=nil && self.postDataSetArray.count>0){
            NSDictionary *dataSetItem = [self.postDataSetArray objectAtIndex:indexPath.item];
            NSLog(@"searchview datasetitem : %@", dataSetItem);
            
            NSString *userNo = [dataSetItem objectForKey:@"CUSER_NO"];
            NSString *profileImagePath = [NSString urlDecodeString:[dataSetItem objectForKey:@"STATUS_IMG"]];
            NSString *snsName = [NSString urlDecodeString:[dataSetItem objectForKey:@"SNS_NM"]];
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
                if (![profileImagePath isEqual:@""]) {
                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
                    [cell.userImageButton setImage:userImg forState:UIControlStateNormal];
                    
                } else{
                    [cell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                }
                
                cell.userTypeLabel.hidden = YES;
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
            
            cell.userNameLabel.text = writerName;
            cell.dateLabel.text = postDateString;
            cell.teamNameLabel.text = snsName;
            
            [cell.userImageButton addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
            cell.userImageButton.tag = indexPath.item;
            
            cell.commCntLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"comment", @"comment"),commCnt];
            cell.viewCntLabel.text = [NSString stringWithFormat:@"%@",readCnt];
            
            //읽음카운트 20이상 줄바꿈 현상 수정
            NSDictionary *attributes = @{NSFontAttributeName: [cell.viewCntLabel font]};
            CGSize textSize = [[cell.viewCntLabel text] sizeWithAttributes:attributes];
            CGFloat strikeWidth = textSize.width;
            
            if(strikeWidth < 14.0f){
                cell.viewCntConstraint.constant = 15;
            } else {
                cell.viewCntConstraint.constant = strikeWidth+5;
            }
            cell.viewCntLabel.textAlignment = NSTextAlignmentRight;
            
            NSInteger count = [contentArray count]-1;
            NSString *description = @"";
            NSString *thumbImagePath =  @"";
            NSString *originImagePath =  @"";
            NSString *filePath =  @"";
            
            for (int i=(int)count; i>=0; i--) {
                NSDictionary *content = [contentArray objectAtIndex:i];
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"TEXT"]) {
                    cell.playButton.hidden = YES;
                    
                    description = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                    
                    NSString *newString = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    cell.descriptionLabel.text = newString;
                    
                    [cell.descriptionLabel setNumberOfLines:5];
                }
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    cell.playButton.hidden = YES;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                    
                    if (originImagePath!=nil && ![originImagePath isEqualToString:@""]) {
                        cell.contentImageView.hidden = NO;
                        
                        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath]
                                                 placeholderImage:nil
                                                          options:SDWebImageProgressiveDownload
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if(image.size.width>self.tableView.frame.size.width){
                                                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                                cell.contentImageView.image = image;
                                                            }
                                                            
                                                            [self.tableView beginUpdates];
                                                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                            [self.tableView endUpdates];
                                                        }];
                        
                        
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
                    
                    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath]
                                             placeholderImage:nil
                                                      options:SDWebImageProgressiveDownload
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                        if(image.size.width>self.tableView.frame.size.width){
                                                            image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                            cell.contentImageView.image = image;
                                                        }
                                                        
                                                        [self.tableView beginUpdates];
                                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                        [self.tableView endUpdates];
                                                    }];
                    
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
        
    } else if([self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        NewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsFeedViewCell"];
        
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[NewsFeedViewCell class]]) {
                    cell = (NewsFeedViewCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        cell.descriptionLabel.text = nil;
        cell.contentImageView.image = nil;
        cell.fileName.text = nil;
        cell.fileViewHeight.constant = 0;
        cell.playButton.hidden = YES;
        
        if(cell!=nil && self.postDataSetArray.count>0){
            NSDictionary *dataSetItem = [self.postDataSetArray objectAtIndex:indexPath.item];
            
            NSString *userNo = [dataSetItem objectForKey:@"CUSER_NO"];
            NSString *profileImagePath = [NSString urlDecodeString:[dataSetItem objectForKey:@"STATUS_IMG"]];
            NSString *snsName = [NSString urlDecodeString:[dataSetItem objectForKey:@"SNS_NM"]];
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
                if (![profileImagePath isEqual:@""]) {
                    UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
                    [cell.userImageButton setImage:userImg forState:UIControlStateNormal];
                    
                } else{
                    [cell.userImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
                }
                
                cell.userTypeLabel.hidden = YES;
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
            
            cell.userNameLabel.text = writerName;
            cell.dateLabel.text = postDateString;
            cell.teamNameLabel.text = snsName;
            
            [cell.userImageButton addTarget:self action:@selector(tapDetected:) forControlEvents:UIControlEventTouchUpInside];
            cell.userImageButton.tag = indexPath.item;
            
            cell.commCntLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"comment", @"comment"),commCnt];
            cell.viewCntLabel.text = [NSString stringWithFormat:@"%@",readCnt];
            
            //읽음카운트 20이상 줄바꿈 현상 수정
            NSDictionary *attributes = @{NSFontAttributeName: [cell.viewCntLabel font]};
            CGSize textSize = [[cell.viewCntLabel text] sizeWithAttributes:attributes];
            CGFloat strikeWidth = textSize.width;
            
            if(strikeWidth < 14.0f){
                cell.viewCntConstraint.constant = 15;
            } else {
                cell.viewCntConstraint.constant = strikeWidth+5;
            }
            cell.viewCntLabel.textAlignment = NSTextAlignmentRight;
            
            NSInteger count = [contentArray count]-1;
            NSString *description = @"";
            NSString *thumbImagePath =  @"";
            NSString *originImagePath =  @"";
            NSString *filePath =  @"";
            
            for (int i=(int)count; i>=0; i--) {
                NSDictionary *content = [contentArray objectAtIndex:i];
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"TEXT"]) {
                    cell.playButton.hidden = YES;
                    
                    description = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                    
                    NSString *newString = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(![newString isEqualToString:@""]){
                        cell.descriptionLabel.text = newString;
                        [cell.descriptionLabel setNumberOfLines:5];
                    }
                }
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    cell.playButton.hidden = YES;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                    
                    if (originImagePath!=nil && ![originImagePath isEqualToString:@""]) {
                        cell.contentImageView.hidden = NO;
                        
                        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath]
                                                 placeholderImage:nil
                                                          options:SDWebImageProgressiveDownload
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if(image.size.width>self.tableView.frame.size.width){
                                                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                                cell.contentImageView.image = image;
                                                            }
                                                            
                                                            [self.tableView beginUpdates];
                                                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                            [self.tableView endUpdates];
                                                        }];
                        
                        
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
                    
                    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath]
                                             placeholderImage:nil
                                                      options:SDWebImageProgressiveDownload
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                        if(image.size.width>self.tableView.frame.size.width){
                                                            image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                            cell.contentImageView.image = image;
                                                        }
                                                        
                                                        [self.tableView beginUpdates];
                                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                        [self.tableView endUpdates];
                                                    }];
                    
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
        
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        SearchChatListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchChatListViewCell"];
        
        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"SearchChatListViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[SearchChatListViewCell class]]) {
                    cell = (SearchChatListViewCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        @try{
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
            
            if (self.chatArray.count>0) {
                @try{
                    //내가 보낸 메시지에 대해서는 뱃지 처리 안해주면 됨
                    
//                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                    NSString *lastDate = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"LAST_DATE"];
//                    NSString *tmp = [lastDate substringToIndex:lastDate.length-3];
//                    NSDate *regiDate = [formatter dateFromString:tmp];
                    NSString *roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
                    NSString *newChat = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"NEW_CHAT"];
//                    NSString *memberCnt = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"];
//                    NSString *roomImgPath = [[self.tempArr objectAtIndex:indexPath.row] objectForKey:@"ROOM_IMG"]; //origin
                    NSString *notReadCount = [[self.tempArr objectAtIndex:indexPath.row] objectForKey:@"NOT_READ_COUNT"];
                    NSString *roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
                    NSString *contentType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT_TY"];
                    NSString *content = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"]];
                    NSString *contentPrev = [NSString urlDecodeString:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT_PREV"]];
                    
                    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
                    formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSDate *date1 = [formatter2 dateFromString:lastDate];
                    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                    [formatter3 setDateFormat:@"yyyy-MM-dd a hh:mm"];
                    NSString *date2 = [formatter3 stringFromDate:date1];
                    //NSLog(@"date2 : %@", date2);
                    
                    NSInteger compDate = [self formattedDateCompareToNow:date1];
                    NSString *lastDateString = [[NSString alloc]init];
                    if(compDate==0) {
                        date2 = [date2 substringFromIndex:lastDate.length-8];
                    } else {
                        date2 = [date2 substringToIndex:lastDate.length-9];
                    }
                    lastDateString = date2;
                    
                    NSString *roomImage = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomImg:roomNo]];
                    if(roomImage!=nil&&![roomImage isEqualToString:@""]){
                        NSString *roomImgPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@", roomNo, roomImage];
                        UIImage *roomImg = [UIImage imageWithContentsOfFile:roomImgPath];
                        if(roomImg){
                            cell.chatImage.image = roomImg;
                        } else {
                            NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserNoAndUserImg:roomNo]];
                            
                            NSMutableDictionary *roomUsers = [NSMutableDictionary dictionary];
                            NSMutableArray *roomImgArr = [NSMutableArray array];
                            NSMutableArray *myRoomImgArr = [NSMutableArray array];
                            int roomImgCount = 1;
                            
                            for(int i=0; i<selectArr.count; i++){
                                NSString *chatUserNo = [[selectArr objectAtIndex:i] objectForKey:@"USER_NO"];
                                NSString *chatUserImg = [[selectArr objectAtIndex:i] objectForKey:@"USER_IMG"];
                                
                                if(![[NSString stringWithFormat:@"%@", chatUserNo] isEqualToString:[NSString stringWithFormat:@"%@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]]]]){
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
                                NSString *roomImgPath = [self createChatRoomImg:roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                cell.chatImage.image = [UIImage imageWithContentsOfFile:roomImgPath];
                            } else {
                                NSString *roomImgPath = [self createChatRoomImg:roomUsers :myRoomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                                cell.chatImage.image = [UIImage imageWithContentsOfFile:roomImgPath];
                            }
                        }
                    } else {
                        cell.chatImage.image = [UIImage imageNamed:@"profile_default.png"];
                    }
                    
                    if([roomType intValue]==3) {
                        cell.myLabel.text = NSLocalizedString(@"me", @"me");
                        cell.myLabel.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                        if([cell.myLabel.text isEqualToString:@"me"]){
                            cell.myLabel.font = [UIFont systemFontOfSize:10];
                        } else {
                            cell.myLabel.font = [UIFont systemFontOfSize:12];
                        }
                        cell.myLabel.hidden = NO;
                    }
                    else cell.myLabel.hidden = YES;
                    
                    NSString *decodeRoomNm = [NSString urlDecodeString:[[self.tempArr objectAtIndex:indexPath.row] objectForKey:@"ROOM_NM"]];
                    cell.chatName.text = decodeRoomNm;
                    
                    if([contentType isEqualToString:@"LONG_TEXT"]){
                        cell.chatContent.text = contentPrev;
                        
                    } else if([contentType isEqualToString:@"INVITE"]){
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite")]];
                        
                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [UIImage imageNamed:@"icon_mail.png"];
                        textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [attributedString appendAttributedString:attrStringWithImage];
                        [attributedString appendAttributedString:attributedString2];
                        
                        cell.chatContent.attributedText = attributedString;
                        
                    } else if([contentType isEqualToString:@"TEXT"]){
                        cell.chatContent.text = content;
                        
                    } else if([contentType isEqualToString:@"IMG"]){
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_image", @"chat_receive_image")]];
                        
                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [UIImage imageNamed:@"icon_photo.png"];
                        textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [attributedString appendAttributedString:attrStringWithImage];
                        [attributedString appendAttributedString:attributedString2];
                        
                        cell.chatContent.attributedText = attributedString;
                        
                    } else if([contentType isEqualToString:@"VIDEO"]){
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_video", @"chat_receive_video")]];
                        
                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [UIImage imageNamed:@"icon_photo.png"];
                        textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [attributedString appendAttributedString:attrStringWithImage];
                        [attributedString appendAttributedString:attributedString2];
                        
                        cell.chatContent.attributedText = attributedString;
                        
                    } else if([contentType isEqualToString:@"FILE"]){
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
                        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",NSLocalizedString(@"chat_receive_file", @"chat_receive_file")]];
                        
                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [UIImage imageNamed:@"file_zip.png"];
                        textAttachment.bounds = CGRectMake(0, -1.5, 14, 13);
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [attributedString appendAttributedString:attrStringWithImage];
                        [attributedString appendAttributedString:attributedString2];
                        
                        cell.chatContent.attributedText = attributedString;
                        
                    }else {
                        cell.chatContent.text = content;
                    }
                    
                    cell.chatDate.text = lastDateString;
                    
                    if([[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"] intValue] <= 2){
                        cell.userCountWidth.constant=0;
                        
                    } else {
                        cell.userCount.text = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"];
                        cell.userCountWidth.constant=15;
                    }
                    
                    if([notReadCount intValue]>0){
                        cell.nChatLabel.hidden = NO;
                        
                        if([notReadCount intValue]>99) {
                            notReadCount = [NSString stringWithFormat:@"99+"];
                            cell.nChatWidth.constant = 35;
                        } else {
                            cell.nChatWidth.constant = 21;
                        }
                        cell.nChatLabel.text = [NSString stringWithFormat:@"%@", notReadCount];
                        
                    } else {
                        cell.nChatLabel.hidden = YES;
                    }
                    
                    NSString *roomNoti = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NOTI"];
                    if([roomNoti isEqualToString:@"1"]){ //on
                        cell.chatAlarm.hidden = YES;
                    } else {
                        [cell.chatAlarm setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"icon_alarm_off2.png"] scaledToMaxWidth:12.0f]];
                        cell.chatAlarm.hidden = NO;
                    }
                    
                    NSDictionary *attributes = @{NSFontAttributeName: [cell.chatName font]};
                    CGSize textSize = [[cell.chatName text] sizeWithAttributes:attributes];
                    CGFloat strikeWidth = textSize.width;
                    
                    if(strikeWidth >= 150.0f){
                        cell.chatNameWidth.constant = 177;
                        cell.chatName.textAlignment = NSTextAlignmentLeft;
                    } else{
                        cell.chatNameWidth.constant = strikeWidth+3;
                        cell.chatName.textAlignment = NSTextAlignmentLeft;
                    }
                    
                    return cell;
                    
                } @catch(NSException *exception){
                    NSLog(@"Exception : %@", exception);
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
}
- (NSInteger)formattedDateCompareToNow:(NSDate *)date
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
    NSInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
    return dayDiff;
}

- (void)setUpBoardSearchCell:(MFGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.label3.hidden = YES;
    cell.requestBtn.hidden = YES;
    
    NSDictionary *sns = [self.boardDataSetArray objectAtIndex:indexPath.row];
    NSString *coverImg = [NSString urlDecodeString:[sns objectForKey:@"COVER_IMG"]];
    NSString *snsName = [NSString urlDecodeString:[sns objectForKey:@"SNS_NM"]];
    NSString *snsDesc = [NSString urlDecodeString:[sns objectForKey:@"SNS_DESC"]];
    NSString *createUser = [NSString urlDecodeString:[sns objectForKey:@"CREATE_USER_NM"]];
    NSString *userCnt = [sns objectForKey:@"USER_COUNT"];
    NSString *waitingCnt = [sns objectForKey:@"WAITING_USER_COUNT"];
    NSString *snsStatus = [sns objectForKey:@"ITEM_TYPE"];
    
    if([snsDesc isEqualToString:@""]){
        cell.nameTopConstraint.constant = 12;
        cell.descHeightConstraint.constant = 0;
    } else {
        cell.nameTopConstraint.constant = 4;
        cell.descHeightConstraint.constant = 18;
    }
    
    if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
        UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
        if(image!=nil){
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :image];
            cell.snsImageView.image = postCover;
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[UIImage imageNamed:@"cover3-2.png"]];
            cell.snsImageView.image = postCover;
        }
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
    }else {
        [cell.leaderBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    [cell.memberBtn setBackgroundColor:[UIColor clearColor]];
    [cell.memberBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [cell.memberBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_member_count1", @"board_info_member_count1") ,userCnt] forState:UIControlStateNormal];
    
    if([waitingCnt intValue]>0){
        cell.label2.hidden = NO;
        cell.inviteBtn.hidden = NO;
        [cell.inviteBtn setBackgroundColor:[UIColor clearColor]];
        [cell.inviteBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.inviteBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_invite_count", @"board_info_invite_count"), waitingCnt] forState:UIControlStateNormal];
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
        //[self performSegueWithIdentifier:@"BOARD_SEARCH_DETAIL_VIEW" sender:indexPath];
        [self selectedBoardItemType:indexPath];
        
    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
        [self performSegueWithIdentifier:@"SEARCH_POST_DETAIL_PUSH" sender:indexPath];
        
    } else if([self.fromSegue isEqualToString:@"POST_BOARD_SEARCH_MODAL"]){
        [self performSegueWithIdentifier:@"SEARCH_POST_WRITE_MODAL" sender:indexPath];
        
    } else if([self.fromSegue isEqualToString:@"SEARCH_CHAT_LIST_MODAL"]){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
        
        NSString *roomType = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_TYPE"];
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
            
            NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"]];
            [appDelegate.dbHelper crudStatement:sqlString];
            
            [self.tabBarController.tabBar setHidden:YES];
            [self.navigationController pushViewController:container animated:YES];
        }
    }
}

- (void)tapDetected:(id)sender{
    
}

-(void)boardLongClick:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        NSString *itemType = [[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"ITEM_TYPE"];
        if([itemType isEqualToString:@"JOIN_STANDBY"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"join_sns_toast8", @"join_sns_toast8") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSString *snsNo = [[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 [self callWebService:@"withdrawSNS" :snsNo];
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

-(void)selectedBoardItemType:(NSIndexPath *)indexPath{
    NSString *itemType = [[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"ITEM_TYPE"];
    NSString *snsNo = [[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
    NSString *snsName = [NSString urlDecodeString:[[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
    
    if([itemType isEqualToString:@"MEMBER"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TeamSelectController *vc = (TeamSelectController *)[storyboard instantiateViewControllerWithIdentifier:@"TeamSelectController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        vc.snsNo = snsNo;
        vc.snsName = snsName;
        vc.snsInfoDic = [self.boardDataSetArray objectAtIndex:indexPath.row];
        vc.fromSegue = @"BOARD_SEARCH_MODAL";
        
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        self.navigationController.navigationBar.topItem.title = @"";
        [self presentViewController:nav animated:YES completion:nil];
        
    } else if([itemType isEqualToString:@"NOMEMBER"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast0", @"join_sns_toast0"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             //[self callJoinSNS:snsNo];
                                                             [self callWebService:@"joinSNS" :snsNo];
                                                         }];
        
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if([itemType isEqualToString:@"JOIN_STANDBY"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast4", @"join_sns_toast4"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
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
            //[self performSelector:@selector(callGetPostList:)];
            
            if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
                
            } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
                [self callWebService:@"getPostLists" :searchText];
            }
            
        }
    }
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = NO;
    if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT)
    {
        [self startLoading];
    }
}
- (void)startLoading {
    //PullRefreshTableView의 StartLoading 호출
    [self startLoading2];
    
    //데이터새로고침
    //    if([self.fromSegue isEqualToString:@"BOARD_SEARCH_MODAL"]){
    //
    //    } else if([self.fromSegue isEqualToString:@"POST_SEARCH_MODAL"] || [self.fromSegue isEqualToString:@"BOARD_POST_SEARCH_MODAL"]){
    //        [self refreshCallGetPostList:searchText];
    //    }
}
- (void)startLoading2 {
    isRefresh = YES;
    lbRefreshTime.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
    
    NSString *lbString = [NSString stringWithFormat:@"%@\n마지막으로 불러온 시간 : %@", REFRESH_TITLE_TABLE_LOAD, refreshTime];
    
    [ivRefreshArrow setHidden:YES];
    [lbRefreshTime setText:lbString];
    [spRefresh startAnimating];
    
    [UIView commitAnimations];
}
- (void)stopLoading {
    [self performSelector:@selector(_stopLoading) withObject:nil afterDelay:1.f];
}
- (void)deleteLoading {
    ivRefreshArrow.hidden = YES;
    lbRefreshTime.hidden = YES;
    spRefresh.hidden = YES;
}
- (void)_stopLoading {
    isRefresh = NO;
    
    refreshTime = nil;
    refreshTime = [[self performSelector:@selector(_getCurrentStringTime)] copy];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    
    [UIView setAnimationDidStopSelector:@selector(_stopLoadingComplete)];
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    [UIView commitAnimations];
}
- (NSString *)_getCurrentStringTime {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:REFRESH_TIME_FORMAT];
    NSString *returnString = [dateFormatter stringFromDate:date];
    return returnString;
}
- (void)_stopLoadingComplete {
    NSString *lbString = [NSString stringWithFormat:@"%@\n마지막으로 불러온 시간 : %@", REFRESH_TITLE_TABLE_PULL, refreshTime];
    
    [ivRefreshArrow setHidden:NO];
    
    [lbRefreshTime setText:lbString];
    [spRefresh stopAnimating];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            NSString *lbString = [NSString stringWithFormat:@"%@\n마지막으로 불러온 시간 : %@", REFRESH_TITLE_TABLE_RELEASE, refreshTime];
            [lbRefreshTime setText:lbString];
            [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        }
        [UIView commitAnimations];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = YES;
}
// 테이블뷰 상단의 헤더뷰 초기화
- (void)_initializeRefreshViewOnTableViewTop
{
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [vRefresh setBackgroundColor:[UIColor clearColor]];
    
    if(spRefresh == nil)
    {
        spRefresh = [[UIActivityIndicatorView alloc] init];
    }
    [spRefresh setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 30) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 20) / 2, 20, 20)];
    [spRefresh setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spRefresh setColor:[UIColor blackColor]];
    [spRefresh setHidesWhenStopped:YES];
    [vRefresh addSubview:spRefresh];
    
    if(ivRefreshArrow == nil)
    {
        ivRefreshArrow = [[UIImageView alloc] init];
    }
    UIImage *imgArrow = [UIImage imageNamed:@"arrow.png"];
    [ivRefreshArrow setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 34) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 44) / 2, 24, 37)];
    [ivRefreshArrow setImage:imgArrow];
    [vRefresh addSubview:ivRefreshArrow];
    
    if(lbRefreshTime == nil) {
        lbRefreshTime = [[UILabel alloc] init];
    }
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [self.view addSubview:vRefresh];
}
- (void)_initializeRefreshViewOnTableViewTail{
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 840 + REFRESH_HEADER_DEFAULT_HEIGHT, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [vRefresh setBackgroundColor:[UIColor clearColor]];
    
    if(spRefresh == nil)
    {
        spRefresh = [[UIActivityIndicatorView alloc] init];
    }
    [spRefresh setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 30) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 20) / 2, 20, 20)];
    [spRefresh setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spRefresh setColor:[UIColor blackColor]];
    [spRefresh setHidesWhenStopped:YES];
    [vRefresh addSubview:spRefresh];
    
    if(ivRefreshArrow == nil)
    {
        ivRefreshArrow = [[UIImageView alloc] init];
    }
    UIImage *imgArrow = [UIImage imageNamed:@"arrow.png"];
    [ivRefreshArrow setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 34) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 44) / 2, 24, 37)];
    [ivRefreshArrow setImage:imgArrow];
    [vRefresh addSubview:ivRefreshArrow];
    
    if(lbRefreshTime == nil)
    {
        lbRefreshTime = [[UILabel alloc] init];
    }
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [self.view addSubview:vRefresh];
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"SEARCH_POST_DETAIL_PUSH"]){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        PostDetailViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination.indexPath  = indexPath;
        destination.postInfo = [self.postDataSetArray objectAtIndex:indexPath.item];
        destination._postNo = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_NO"];
        destination._snsName = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"SNS_NM"];
        destination._postDate = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_DATE"];
        destination._readCnt = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_READ_COUNT"];
        destination._commCnt = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_COMMENT_COUNT"];
        destination._isRead = [[self.postDataSetArray objectAtIndex:indexPath.item] objectForKey:@"IS_READ"];

        destination.fromSegue = segue.identifier;
        
    } else if([segue.identifier isEqualToString:@"SEARCH_POST_WRITE_MODAL"]){
        PostWriteTableViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        destination.snsNo = [[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NO"];
        destination.snsName = [NSString urlDecodeString:[[self.boardDataSetArray objectAtIndex:indexPath.row] objectForKey:@"SNS_NM"]];
        
        self.navigationController.navigationBar.topItem.title = @"";
        
    }
}

-(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSString *imgPath = [MFUtil createChatRoomImg:dict :array :memberCnt :roomNo];
    [self.tableView reloadData];
    return imgPath;
}


@end
