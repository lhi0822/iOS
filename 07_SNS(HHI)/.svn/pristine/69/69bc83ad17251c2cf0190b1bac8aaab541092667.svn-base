//
//  ChangeLeaderViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 10..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "ChangeLeaderViewController.h"
#import "MFUtil.h"
#import "MFDBHelper.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#define REFRESH_HEADER_DEFAULT_HEIGHT   64.f

@interface ChangeLeaderViewController () {
    NSMutableArray *sortDataArr;
    AppDelegate *appDelegate;
    
    BOOL isLoad;
    BOOL isRefresh;
    BOOL isScroll;
    
    int pSize;
    NSString *stSeq;
    
    NSMutableArray *existUserArr;
}

@end

@implementation ChangeLeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"change_leader_title", @"change_leader_title")];
    
    stSeq = @"1";
    isLoad = YES;
    isRefresh = NO;
    isScroll = NO;
    pSize = 30;
    
    self.dataSetArray = [NSMutableArray array];
    existUserArr = [NSMutableArray array];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self callGetSNSUserList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callGetSNSUserList{
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];//appDelegate.main_url;
    NSString *paramString = [NSString stringWithFormat:@"snsNo=%@&usrNo=%@&currentUserNos=&pSize=%d&stSeq=%@&dvcId=%@", self.snsNo, myUserNo, pSize, stSeq, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getSNSMemberList"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        self.tableView.scrollEnabled = NO;
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSessionDelegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    self.tableView.scrollEnabled = YES;
    [SVProgressHUD dismiss];
    
    if (error!=nil) {
        NSLog(@"error : %@",error);
        
    }else{
        NSDictionary *dic = session.returnDictionary;
        NSMutableArray *dataSets = [dic objectForKey:@"DATASET"];
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];

        if(dataSets.count==0||dataSets.count<pSize) isLoad = NO;
        else isLoad = YES;
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        sortDataArr = [NSMutableArray array];
        
        for(int i=0; i<dataSets.count; i++){
            NSString *userNo = [[dataSets objectAtIndex:i] objectForKey:@"CUSER_NO"];
            
            if(![existUserArr containsObject:userNo]){
                [existUserArr addObject:userNo];
                
                [indexPaths addObject:[NSIndexPath indexPathForRow:[stSeq integerValue]+i-1 inSection:0]];
                
                if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                    [sortDataArr addObject:[dataSets objectAtIndex:i]];
                }
            }
        }
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"USER_NM" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [sortDataArr sortUsingDescriptors:sortDescriptors];
        
//        dataSetArr = sortDataArr;
//        [self.tableView reloadData];
        
        if([[NSString stringWithFormat:@"%@", stSeq] isEqualToString:@"1"]){
            self.dataSetArray = [NSMutableArray arrayWithArray:sortDataArr];
            if(isRefresh){
                isRefresh = NO;
            }
            [self.tableView reloadData];
            
        } else {
            [self.dataSetArray addObjectsFromArray:sortDataArr];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        
        NSString *seq = [[NSString alloc]init];
        for(int i=1; i<=self.dataSetArray.count; i++){
            seq = [NSString stringWithFormat:@"%d", [stSeq intValue]+i];
        }
        stSeq = seq;
        isScroll = YES;
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    self.tableView.scrollEnabled = YES;
    NSLog(@"error : %@", error);
    
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        [self callGetSNSUserList];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSetArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userImgView.image = nil;
    
    NSDictionary *dataDict = [self.dataSetArray objectAtIndex:indexPath.row];
    //NSString *userId = [NSString urlDecodeString:[dataDict objectForKey:@"CUSER_ID"]];
    NSString *userNo = [dataDict objectForKey:@"CUSER_NO"];
    NSString *userName = [NSString urlDecodeString:[dataDict objectForKey:@"USER_NM"]];
    NSString *profileImg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_IMG"]];
//    NSString *profileMsg = [NSString urlDecodeString:[dataDict objectForKey:@"PROFILE_MSG"]];
    
    NSString *levelName = [NSString urlDecodeString:[dataDict objectForKey:@"LEVEL_NM"]];
    //NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"CORP_NM"]];
    NSString *deptName = [NSString urlDecodeString:[dataDict objectForKey:@"DEPT_NM"]];
    NSString *exCompName = [NSString urlDecodeString:[dataDict objectForKey:@"EX_COMPANY_NM"]];
    
    if([[NSString stringWithFormat:@"%@",userNo] isEqualToString:[NSString stringWithFormat:@"%@",self.leaderNo]]){
        cell.checkButton.hidden = YES;
        cell.leaderBtn.hidden = NO;
        
        [cell.leaderBtn setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(11, 11) :[UIImage imageNamed:@"icon_crown.png"]] forState:UIControlStateNormal];
        [cell.leaderBtn setBackgroundColor:[UIColor whiteColor]];
        
    } else {
        cell.checkButton.hidden = NO;
        cell.leaderBtn.hidden = YES;
    }
    
    if(![profileImg isEqualToString:@""]){
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
        cell.userImgView.image = userImg;
    } else {
        UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[UIImage imageNamed:@"profile_default.png"]];
        cell.userImgView.image = userImg;
    }
    
    NSString *levelStr = @"";
    NSString *deptStr = @"";
    if(levelName!=nil&&![levelName isEqualToString:@""]) levelStr = [NSString stringWithFormat:@"%@/", levelName];
    if(deptName!=nil&&![deptName isEqualToString:@""]) deptStr = [NSString stringWithFormat:@"%@/", deptName];
    
    NSString *userStr = @"";
    if(levelName.length<1&&deptName.length<1&&exCompName.length<1) userStr = [NSString stringWithFormat:@"%@", userName];
    else userStr = [NSString stringWithFormat:@"%@/%@%@%@", userName, levelStr, deptStr, exCompName];
    
    [cell.userImgView setFrame:CGRectMake(20, (cell.frame.size.height/2) - (45/2), 45, 45)];
    [cell.leaderBtn setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width-cell.leaderBtn.frame.size.width, cell.leaderBtn.frame.origin.y, cell.leaderBtn.frame.size.width, cell.leaderBtn.frame.size.height)];
    [cell.nodeNameLabel setFrame:CGRectMake(cell.userImgView.frame.origin.x+cell.userImgView.frame.size.width+10, cell.nodeNameLabel.frame.origin.y, cell.nodeNameLabel.frame.size.width, cell.nodeNameLabel.frame.size.height)];
//    [cell.checkButton setFrame:CGRectMake(cell.checkButton.frame.origin.x, cell.frame.size.height-(cell.frame.size.height/2)-((cell.checkButton.frame.size.height-10)/2), cell.checkButton.frame.size.width, cell.checkButton.frame.size.height-10)];
    [cell.checkButton setFrame:CGRectMake(cell.checkButton.frame.origin.x, cell.checkButton.frame.origin.y, cell.checkButton.frame.size.width, 40)];
    
    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
    cell.userImgView.clipsToBounds = YES;
    cell.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImgView.layer.borderWidth = 0.3;
    
    cell.leaderBtn.layer.cornerRadius = cell.leaderBtn.frame.size.width/2;
    cell.leaderBtn.clipsToBounds = YES;
    cell.leaderBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.leaderBtn.layer.borderWidth = 0.3;
    
    cell.nodeNameLabel.text = userStr;
    cell.nodeNameLabel.font = [UIFont systemFontOfSize:16];
    
    //cell.checkButton.tag = [userNo integerValue];
    cell.checkButton.tag = indexPath.row+1;
    cell.checkButton.layer.cornerRadius = cell.checkButton.frame.size.width/10;
    cell.checkButton.clipsToBounds = YES;
    [cell.checkButton setImage:nil forState:UIControlStateNormal];
    [cell.checkButton setTitle:NSLocalizedString(@"change_leader_button", @"change_leader_button") forState:UIControlStateNormal];
    [cell.checkButton setBackgroundColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
    [cell.checkButton addTarget:self action:@selector(changeLeaderClick:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)changeLeaderClick:(UIButton *)sender{
    //NSString *userNo = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    NSDictionary *dataDict = [self.dataSetArray objectAtIndex:sender.tag-1];
    NSNumber *userNo = [dataDict objectForKey:@"CUSER_NO"];
    NSString *userName = [NSString urlDecodeString:[dataDict objectForKey:@"USER_NM"]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"change_leader_msg", @"change_leader_msg") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];

                                                         NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"LEADER", @"TYPE", userNo, @"CREATE_USER_NO", userName, @"CREATE_USER_NM", nil];

                                                         UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"change_leader_succeed", @"change_leader_succeed") preferredStyle:UIAlertControllerStyleAlert];
                                                         [self presentViewController:alert animated:YES completion:nil];
                                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeSubInfo2" object:nil userInfo:dic];
                                                             [self dismissViewControllerAnimated:YES completion:nil];

                                                         });
                                                     }];

    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
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
            }
        }
        
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT) {
            stSeq = @"1";
            isRefresh = YES;
            existUserArr = [NSMutableArray array];
            [self callGetSNSUserList];
        }
    } @catch (NSException *exception) {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y>0){
        if (scrollView.contentSize.height-(self.tableView.frame.size.height/1) <= scrollView.contentOffset.y + self.tableView.frame.size.height) {
            if(isLoad && isScroll){
                isScroll = NO;
                [self callGetSNSUserList];
            }
        }
    }
}


@end
