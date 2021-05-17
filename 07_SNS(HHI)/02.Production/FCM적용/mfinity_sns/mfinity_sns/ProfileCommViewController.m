//
//  ProfileCommViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 11. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ProfileCommViewController.h"
#import "ProfileCommentViewCell.h"
#import "PostDetailViewController.h"

@interface ProfileCommViewController () {
    AppDelegate *appDelegate;
    NSMutableArray *resultCommArr;
}

@end

@implementation ProfileCommViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.lastPostNo = @"1";
    resultCommArr = [NSMutableArray array];
    [self callGetCommentList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)segmentTitle
{
    return NSLocalizedString(@"profile_comment", @"profile_comment");
}

-(UIScrollView *)streachScrollView
{
    return self.tableView;
}

- (void)callGetCommentList{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&refTy=2&stPostSeq=%@&target_usrNo=%@&dvcId=%@", myUserNo, compNo, self.lastPostNo, self.userNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getWriteLists"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    if (error!=nil || [error isEqualToString:@"(null)"]) {
        if ([error isEqualToString:@"The request timed out."]) {
            [self callGetCommentList];
        }else{
            NSLog(@"Error Message : %@",error);
        }
    } else{
        @try{
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
            
            NSString *seq = [[NSString alloc]init];
            for(int i=1; i<=dataSets.count; i++){
                seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
            }
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([self.lastPostNo intValue]==1) {
                    self.lastPostNo = seq;
                    self.dataSetArray = [NSMutableArray arrayWithArray:dataSets];
                }else{
                    if (dataSets.count>0){
                        self.lastPostNo = seq;
                        [self.dataSetArray addObjectsFromArray:dataSets]; //deep copy
                    }
                }
                
                [self commentSetTableData:self.dataSetArray];
                [self.tableView reloadData];
                
            }else{
                NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
    }
}

-(void)commentSetTableData:(NSMutableArray *)array{
    NSUInteger count = array.count;
    
    @try{
        for(int i=0; i<(int)count; i++){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            NSString *comment = [[array objectAtIndex:i] objectForKey:@"DATA_CONTENT"];
            NSError *jsonError;
            NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
            
            NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:@""];
            
            for(int k=0; k<jsonArr.count; k++){
                NSString *commType = [[jsonArr objectAtIndex:k] objectForKey:@"TYPE"];
                NSArray *commTarget = [[jsonArr objectAtIndex:k] objectForKey:@"TARGET"];
                
                if([commType isEqualToString:@"TEXT"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"TEXT"];
                    NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                    
                    if(commTarget.count>0){
                        for(int j=0; j<commTarget.count; j++){
                            NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                            
                            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]/*NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]*/}];
                            NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
                            [commStr appendAttributedString:attrName];
                            [commStr appendAttributedString:attrSpace];
                        }
                    }
                    
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
                    [commStr appendAttributedString:attrStr];
                    
                    [resultStr appendAttributedString:commStr];
                    
                    [dict setObject:commType forKey:@"TYPE"];
                    [dict setObject:resultStr forKey:@"TEXT"];
                    
                } else if([commType isEqualToString:@"IMG"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                    
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] /*NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]*/}];
                                NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
                                [commStr appendAttributedString:attrName];
                                [commStr appendAttributedString:attrSpace];
                            }
                        }
                        
                        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
                        [commStr appendAttributedString:attrStr];
                    }
                    
                    [dict setObject:commType forKey:@"TYPE"];
                    [dict setObject:origin forKey:@"FILE"];
                    
                } else if([commType isEqualToString:@"VIDEO"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                    NSString *thumb = [[jsonArr objectAtIndex:k] objectForKey:@"THUMB"];
                    
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] /*NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]*/}];
                                NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
                                [commStr appendAttributedString:attrName];
                                [commStr appendAttributedString:attrSpace];
                            }
                        }
                        
                        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
                        [commStr appendAttributedString:attrStr];
                    }
                    
                    [dict setObject:commType forKey:@"TYPE"];
                    [dict setObject:origin forKey:@"FILE"];
                    [dict setObject:thumb forKey:@"THUMB"];
                    
                } else if([commType isEqualToString:@"FILE"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                    
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] /*NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]*/}];
                                NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
                                [commStr appendAttributedString:attrName];
                                [commStr appendAttributedString:attrSpace];
                            }
                        }
                        
                        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
                        [commStr appendAttributedString:attrStr];
                    }
                    
                    [dict setObject:commType forKey:@"TYPE"];
                    [dict setObject:origin forKey:@"FILE"];
                }
            }
            [resultCommArr addObject:dict];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataSetArray.count > 0){
        return self.dataSetArray.count;
        
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCommentViewCell"];
    if (cell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ProfileCommentViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[ProfileCommentViewCell class]]) {
                cell = (ProfileCommentViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    @try{
        if(cell!=nil && self.dataSetArray.count>0){
            cell.contentLabel.text = nil;
            cell.titleLabel.text = nil;
            cell.dateLabel.text = nil;
            
            NSDictionary *dataSetItem = [self.dataSetArray objectAtIndex:indexPath.item];
            
            NSString *dataContent = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_CONTENT"]];
            NSString *dataDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_DATE"]];
            //NSString *dataNo = [dataSetItem objectForKey:@"DATA_NO"];
            //NSString *dataType = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_TYPE"]];
            NSString *ref1 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_01"]];
            //NSString *ref2 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_02"]];
            //NSString *ref3 = [dataSetItem objectForKey:@"REF_03"];
            
            NSError *error;
            NSArray *contentArr = [NSArray array];
            NSData *jsonData = [dataContent dataUsingEncoding:NSUTF8StringEncoding];
            contentArr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSString *dateStr = [dataDate substringToIndex:dataDate.length-3];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            
            NSDate *nsDate = [formatter dateFromString:dateStr];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
            formatter2.dateFormat = NSLocalizedString(@"date13", @"date13");
            NSString *dateStr2 = [formatter2 stringFromDate:nsDate];
            
            NSArray *ref1Dict = [NSArray array];
            NSData *jsonData1 = [ref1 dataUsingEncoding:NSUTF8StringEncoding];
            ref1Dict = [NSJSONSerialization JSONObjectWithData:jsonData1 options:kNilOptions error:&error];
            
            NSString *contentType = [[ref1Dict objectAtIndex:0] objectForKey:@"TYPE"];
            if([contentType isEqualToString:@"TEXT"]){
                cell.contentLabel.text = [NSString urlDecodeString:[[ref1Dict objectAtIndex:0] objectForKey:@"VALUE"]];
            } else if([contentType isEqualToString:@"IMG"]){
                cell.contentLabel.text = NSLocalizedString(@"comment_title_image", @"comment_title_image");
            } else if([contentType isEqualToString:@"VIDEO"]){
                cell.contentLabel.text = NSLocalizedString(@"comment_title_video", @"comment_title_video");
            } else if([contentType isEqualToString:@"FILE"]){
                cell.contentLabel.text = NSLocalizedString(@"comment_title_file", @"comment_title_file");
            } else {

            }
            
            NSString *commType = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
            if([commType isEqualToString:@"TEXT"]){
                cell.titleLabel.attributedText = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"TEXT"];
            } else if([commType isEqualToString:@"IMG"]){
                cell.titleLabel.text = NSLocalizedString(@"comment_content_image", @"comment_content_image");
            } else if([commType isEqualToString:@"VIDEO"]){
                cell.titleLabel.text = NSLocalizedString(@"comment_content_video", @"comment_content_video");
            } else if([commType isEqualToString:@"FILE"]){
                cell.titleLabel.text = NSLocalizedString(@"comment_content_file", @"comment_content_file");
            } else {
                
            }
            
            cell.dateLabel.text = dateStr2;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @try{
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailViewController *destination = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination._postNo = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_NO"];
        destination._postDate = [NSString urlDecodeString:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_DATE"]];
        
        destination._snsNo = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_02"];
        destination._snsName = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getSnsName:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_02"]]];
        destination.indexPath  = indexPath;
        destination.fromSegue = @"PROFILE_COMM_DETAIL";
        
        NSDictionary *postInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.userNo,@"CUSER_NO", nil];
        destination.postInfo = postInfo;
        
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (void)closeButtonClick{
    
}

@end
