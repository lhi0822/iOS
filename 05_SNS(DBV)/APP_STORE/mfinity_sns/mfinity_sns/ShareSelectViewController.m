//
//  ShareSelectViewController.m
//  mfinity_sns
//
//  Created by hilee on 20/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "ShareSelectViewController.h"

@interface ShareSelectViewController () {
    AppDelegate *appDelegate;
    BOOL isFirst;
    
    int notMemberCnt;
    UIImage *postCover;
    SDImageCache *imgCache;
    
    NSString *selectIdx;
    
    BOOL shareTab;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
}

@end

@implementation ShareSelectViewController

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"share", @"share")];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ShareViewClose:) name:@"noti_ShareViewClose" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
    if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
        //미디어 접근 권한 사용 및 권한이 없을 경우

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
//                                                             [self closeButtonClick];
                                                         }];
        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];

    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]) shareTab = NO;
    //else shareTab = YES;
    shareTab = YES;
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    isFirst = YES;
    selectIdx = @"";
   
    if(shareTab){
        self.segContainer.hidden = NO;
        
        [self.segContainer setFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        [self.segment setFrame:CGRectMake(self.segment.frame.origin.x, self.segment.frame.origin.y, self.segment.frame.size.width, 35)];
        
        [self.segment setTitle:NSLocalizedString(@"share_tab_item_board", @"share_tab_item_board") forSegmentAtIndex:0];
        [self.segment setTitle:NSLocalizedString(@"share_tab_item_chat", @"share_tab_item_chat") forSegmentAtIndex:1];
        
        self.segment.tintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.segment.selectedSegmentIndex = 0;
        self.segment.userInteractionEnabled = YES;
        self.segment.clipsToBounds = YES;
        
        [self.segment addTarget:self action:@selector(segmentedChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.segment];
        
        self.normalDataArray = [NSMutableArray array];
        self.selectShareKind=1;
        [self callWebService:@"getUserSNSLists" :1];
        
    } else {
        self.segContainer.hidden = YES;
        self.tableViewTopConstraint.constant = 0;

        self.normalDataArray = [NSMutableArray array];
        self.selectShareKind=1;
        [self callWebService:@"getUserSNSLists" :1];
    }
}

-(void)segmentedChange:(UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 0) {
        self.selectShareKind = 1;
        if(isFirst) {

            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
            [self callWebService:@"getUserSNSLists" :1];
            isFirst = NO;
        }
        [self.tableView reloadData];

    } else if(sender.selectedSegmentIndex == 1) {
        self.selectShareKind = 2;

        if(isFirst) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
            [self readFromDatabase];
            isFirst = NO;
        }
        [self.tableView reloadData];
    }
}

- (void)noti_ShareViewClose:(NSNotification *)notification {
    NSLog();
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
    [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
    [shareDefaults synchronize];
    
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_CHAT"];
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_POST"];
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_INFO"];
    [appDelegate.appPrefs synchronize];
    
    appDelegate.canFeedRefresh = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)closeButtonClick{
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
    [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
    [shareDefaults synchronize];
    
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_CHAT"];
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_POST"];
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_INFO"];
    [appDelegate.appPrefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
-(void)rightSideMenuButtonPressed:(id)sender{
    @try{
        if(self.selectShareKind==1){
            NSLog(@"boardData : %@", [self.normalDataArray objectAtIndex:[selectIdx intValue]]);
            
            NSString *snsNo = [[self.normalDataArray objectAtIndex:[selectIdx intValue]] objectForKey:@"SNS_NO"];
            NSString *snsName = [NSString urlDecodeString:[[self.normalDataArray objectAtIndex:[selectIdx intValue]] objectForKey:@"SNS_NM"]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostWriteTableViewController *destination = (PostWriteTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostWriteTableViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            
            destination.fromSegue = @"SHARE_POST_MODAL";
            destination.snsNo = snsNo;
            destination.snsName = snsName;
            
            [self presentViewController:navController animated:YES completion:nil];
            
        } else if(self.selectShareKind==2){
            NSLog(@"chatData : %@", [self.chatArray objectAtIndex:[selectIdx intValue]]);
            
            @try{
                appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
                
                self.navigationController.navigationBar.topItem.title = @"";
                
                ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
                CGRect screen = [[UIScreen mainScreen]bounds];
                CGFloat screenWidth = screen.size.width;
                CGFloat screenHeight = screen.size.height;
                rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
                
                if(self.chatArray.count > 0){
                    destination.fromSegue = @"SHARE_CHAT_MODAL";
                    destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NM"]];
                    destination.roomNo = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"];
                    destination.roomNoti = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NOTI"];
                    rightViewController.roomNo = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"];
                    rightViewController.roomNoti = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NOTI"];
                    
                } else {
//                    destination.roomName = self.nRoomName;
//                    destination.roomNo = self.nRoomNo;
//                    destination.roomNoti = @"1";
//                    rightViewController.roomNo = self.nRoomNo;
//                    rightViewController.roomNoti = @"1";
                }
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
                
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:container animated:YES];
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
            }
        }
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
*/
 
- (void)callWebService:(NSString *)serviceName :(int)snsKind{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    NSString *paramString = nil;
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    if([serviceName isEqualToString:@"getUserSNSLists"]){
        paramString = [NSString stringWithFormat:@"compNo=%@&usrId=%@&snsKind=%d&searchNm=""&dvcId=%@",compNo, [appDelegate.appPrefs objectForKey:@"USERID"], snsKind, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        
    }
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if([session start]){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)readFromDatabase {
    //NSString *sqlString = [appDelegate.dbHelper getRoomList];
    NSString *sqlString = [appDelegate.dbHelper getNotOfTypeRoomList:@"0"];
    
    //[self selectStatement:self.DBPath :sqlString];
    self.chatArray = [NSMutableArray array];
    self.tempArr = [NSMutableArray array];
    
    self.chatArray = [appDelegate.dbHelper selectMutableArray:sqlString];
    self.tempArr = [self.chatArray mutableCopy];
    
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.selectShareKind==1){
        return self.normalDataArray.count-notMemberCnt;

    } else if(self.selectShareKind==2){
        return self.chatArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectShareKind==1){
        return UITableViewAutomaticDimension;
        
    } else if(self.selectShareKind==2){
        return 76;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectShareKind==1){
        MFGroupCell *cell = (MFGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"MFGroupCell"];

        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MFGroupCell" owner:self options:nil];

            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[MFGroupCell class]]) {
                    cell = (MFGroupCell *) currentObject;
                    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                }
            }
        }
        [self setUpBoardListCell:cell atIndexPath:indexPath];
        return cell;

    } else if(self.selectShareKind==2){
        SearchChatListViewCell *cell = (SearchChatListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchChatListViewCell"];

        if (cell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"SearchChatListViewCell" owner:self options:nil];

            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[SearchChatListViewCell class]]) {
                    cell = (SearchChatListViewCell *) currentObject;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                }
            }
        }
        [self setUpChatListCell:cell atIndexPath:indexPath];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectIdx = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    @try{
        if(self.selectShareKind==1){
            NSString *snsNo = [[self.normalDataArray objectAtIndex:[selectIdx intValue]] objectForKey:@"SNS_NO"];
            NSString *snsName = [NSString urlDecodeString:[[self.normalDataArray objectAtIndex:[selectIdx intValue]] objectForKey:@"SNS_NM"]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostWriteTableViewController *destination = (PostWriteTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostWriteTableViewController"];
            //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            
            if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]) destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
            else if([self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]) destination.fromSegue = @"SHARE_FROM_POST_MODAL";
            else destination.fromSegue = @"SHARE_POST_MODAL";
            
            destination.snsNo = snsNo;
            destination.snsName = snsName;
            
            //[self presentViewController:navController animated:YES completion:nil];
            [self.navigationController pushViewController:destination animated:YES];
            
        } else if(self.selectShareKind==2){
            @try{
                appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
                self.navigationController.navigationBar.topItem.title = @"";
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ChatViewController *destination = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                RightSideViewController *rightViewController = (RightSideViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
                CGRect screen = [[UIScreen mainScreen]bounds];
                CGFloat screenWidth = screen.size.width;
                CGFloat screenHeight = screen.size.height;
                rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);

                if(self.chatArray.count > 0){
                    if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]) destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
                    else if([self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]) destination.fromSegue = @"SHARE_FROM_POST_MODAL";
                    else destination.fromSegue = @"SHARE_CHAT_MODAL";

                    destination.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NM"]];
                    destination.roomNo = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"];
                    destination.roomNoti = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NOTI"];

                    rightViewController.roomNo = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"];
                    rightViewController.roomNoti = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NOTI"];
                    rightViewController.roomName = [NSString urlDecodeString:[[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NM"]];
                    rightViewController.roomType = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_TYPE"];

                } else {
                    //                    destination.roomName = self.nRoomName;
                    //                    destination.roomNo = self.nRoomNo;
                    //                    destination.roomNoti = @"1";
                    //                    rightViewController.roomNo = self.nRoomNo;
                    //                    rightViewController.roomNoti = @"1";
                }
                
                NSString *roomNo = [[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"];
                NSLog(@"roomNo : %@ / currNo : %@", roomNo, _currNo);
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
                container.fromSegue = destination.fromSegue;
                [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
//
                NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:[[self.chatArray objectAtIndex:[selectIdx intValue]] objectForKey:@"ROOM_NO"]];
                [appDelegate.dbHelper crudStatement:sqlString];
                
                [self.tabBarController.tabBar setHidden:YES];
                
                if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", _currNo]]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareChatUpdate" object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    [self.navigationController pushViewController:container animated:YES];
                }

//                [self.navigationController pushViewController:container animated:YES]; //원래
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
            }
        }
//        [self dismissViewControllerAnimated:YES completion:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setUpBoardListCell:(MFGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath {
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
            cell.nameTopConstraint.constant = 12;
            cell.descHeightConstraint.constant = 0;
        } else {
            cell.nameTopConstraint.constant = 4;
            cell.descHeightConstraint.constant = 18;
        }
        
        postCover = nil;
        if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&![coverImg isEqualToString:@"(null)"]&&coverImg!=nil){
            //캐싱된 이미지 가져오기
            [cell.snsImageView sd_setImageWithURL:[NSURL URLWithString:coverImg] placeholderImage:nil options:SDWebImageRefreshCached];
            
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
        [cell.memberBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_member_count1", @"board_info_member_count1"), userCnt] forState:UIControlStateNormal];
        
        if([waitingCnt intValue]>0){
            cell.label2.hidden = NO;
            cell.inviteBtn.hidden = NO;
            [cell.inviteBtn setBackgroundColor:[UIColor clearColor]];
            [cell.inviteBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [cell.inviteBtn setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"board_info_invite_count", @"board_info_invite_count"),waitingCnt] forState:UIControlStateNormal];
            
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

- (void)setUpChatListCell:(SearchChatListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        cell.bottomLabel.hidden = YES;
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

        if (self.chatArray.count>0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            NSString *lastDate = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"LAST_DATE"];
            NSString *roomNo = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"ROOM_NO"];
//            NSString *newChat = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"NEW_CHAT"];
//            NSString *memberCnt = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"];
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
                    //[self createChatRoomImg:@"INSERT" :roomUsers :roomImgArr :[NSString stringWithFormat:@"%lu", (unsigned long)selectArr.count] :roomNo];
                    //cell.chatImage.image = roomImg;
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
                
            } else {
                cell.chatContent.text = content;
            }
            
            cell.chatDate.text = lastDateString;
            
            if([[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"] intValue] <= 2){
                //cell.userCount.hidden = YES;
                cell.userCountWidth.constant=0;
                
            } else {
                cell.userCount.text = [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"MEMBER_COUNT"];
                //cell.userCount.hidden = NO;
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
            
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
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
        //NSLog(@"wsName : %@", wsName);
        NSDictionary *dic = session.returnDictionary;
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getUserSNSLists"]) {
                notMemberCnt=0;
                
                self.normalDataArray = [dic objectForKey:@"DATASET"];
                NSLog(@"normalDataArray : %@", self.normalDataArray);
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
                    NSString *userCount = [dataSet objectForKey:@"USER_COUNT"];
                    NSString *waitingCount = [dataSet objectForKey:@"WAITING_USER_COUNT"];

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
                    
                    if(selectArr.count>0){
                        NSString *sqlString = [appDelegate.dbHelper updateSnsInfo:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg snsNo:snsNo];
                        [appDelegate.dbHelper crudStatement:sqlString];
                        
                        NSString *sqlString2 = [appDelegate.dbHelper updateSnsMemberInfo:createUserNo createUserNm:createUserNm snsNo:snsNo];
                        [appDelegate.dbHelper crudStatement:sqlString2];
                        
                    } else {
                        NSString *sqlString = [appDelegate.dbHelper insertOrUpdateSns:snsNo snsName:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg createUserNo:createUserNo createUserNm:createUserNm createDate:createDate compNo:compNo snsKind:snsKind];
                        [appDelegate.dbHelper crudStatement:sqlString];
                    }
                }
                
                [self.tableView reloadData];
            }
        }
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        //[self callWebService:@"getUserSNSLists" :1];
    }
    [self reconnectFromError];
}

- (NSInteger)formattedDateCompareToNow:(NSDate *)date{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
    NSInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
    return dayDiff;
}

-(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo{
    NSString *imgPath = [MFUtil createChatRoomImg:dict :array :memberCnt :roomNo];
    [self.tableView reloadData];
    return imgPath;
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
