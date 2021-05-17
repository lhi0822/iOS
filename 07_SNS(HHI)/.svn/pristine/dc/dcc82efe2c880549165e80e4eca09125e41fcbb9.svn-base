//
//  TaskHistoryViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 23..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskHistoryViewController.h"
#import "TaskHistoryTableViewCell.h"

@interface TaskHistoryViewController () {
    float historyHeight;
    AppDelegate *appDelegate;
}

@end

@implementation TaskHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"변동이력", @"변동이력")];
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg3", @"")
    //                                                                             style:UIBarButtonItemStylePlain
    //                                                                            target:self
    //                                                                            action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
    
    historyHeight = 0;
    self.lastHistNo = @"1";
    self.dataSetArr = [NSMutableArray array];
    [self callWebService:@"getTaskHistory"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        if([serviceName isEqualToString:@"getTaskHistory"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&taskNo=%@&stSeq=%@", myUserNo, self.taskNo, self.lastHistNo];
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

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    @try {
        if(error!=nil || [error isEqualToString:@"(null)"]) {
            if ([error isEqualToString:@"The request timed out."]) {
                
            } else {
                 NSLog(@"Error Message : %@",error);
            }
        } else {
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            
            if([wsName isEqualToString:@"getTaskHistory"]){
                self.dataSetArr = [session.returnDictionary objectForKey:@"DATASET"];
                NSUInteger count = self.dataSetArr.count;
                NSString *seq = [[NSString alloc]init];
                for(int i=1; i<=count; i++){
                    seq = [NSString stringWithFormat:@"%d", [self.lastHistNo intValue]+i];
                }
                
                [self.tableView reloadData];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
    
    @try{
        if(error.code == -1009){
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"인터넷 연결이 오프라인 상태입니다." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}


#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static TaskHistoryTableViewCell *cell   = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [[NSBundle mainBundle] loadNibNamed:@"TaskHistoryTableViewCell" owner:self options:nil][0];
    });
    
    [self tmpSetUpHistoryCell:cell atIndexPath:indexPath];
    return historyHeight+50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSetArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskHistoryTableViewCell *cell = (TaskHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TaskHistoryTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TaskHistoryTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[TaskHistoryTableViewCell class]]) {
                cell = (TaskHistoryTableViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    NSString *content = [NSString urlDecodeString:[[self.dataSetArr objectAtIndex:indexPath.item] objectForKey:@"CONTENT"]];
    NSString *histDate = [NSString urlDecodeString:[[self.dataSetArr objectAtIndex:indexPath.item] objectForKey:@"HISTORY_DATE"]];
    NSString *histUserNo = [[self.dataSetArr objectAtIndex:indexPath.item] objectForKey:@"CUSER_NO"];
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *histType = [dict objectForKey:@"TYPE"];
    NSString *histName = [dict objectForKey:@"NAME"];
    NSString *histContent = [dict objectForKey:@"CONTENT"];
    
    NSString *tyStr = nil;
    NSString *postPosition = nil;;
    
    if([histType isEqualToString:@"TITLE"]){
        tyStr = @"업무명";
        postPosition = @"을";
    } else if([histType isEqualToString:@"STATUS"]){
        tyStr = @"상태";
        postPosition = @"를";
        
        if([histContent isEqualToString:@"1"]) histContent=NSLocalizedString(@"task_status1", @"task_status1");
        else if([histContent isEqualToString:@"2"]) histContent=@"진행";
        else if([histContent isEqualToString:@"3"]) histContent=NSLocalizedString(@"task_status3", @"task_status3");
        else if([histContent isEqualToString:@"4"]) histContent=@"보류";
        
    } else if([histType isEqualToString:@"MANAGER"]){
        tyStr = @"수행자";
        postPosition = @"를";
        
    } else if([histType isEqualToString:@"REFERENCER"]){
        tyStr = @"참조자";
        postPosition = @"를";
        
    } else if([histType isEqualToString:@"START_DATE"]){
        tyStr = @"시작일";
        postPosition = @"을";
        
    } else if([histType isEqualToString:@"END_DATE"]){
        tyStr = @"완료일";
        postPosition = @"을";
        
    }  else if([histType isEqualToString:@"PROGRESS"]){
        tyStr = @"진행률";
        postPosition = @"을";
        
    } else if([histType isEqualToString:@"CAPTION"]){
        tyStr = @"설명";
        postPosition = @"을";
    }
    else if([histType isEqualToString:@"ATTACHED_FILE"]){
        tyStr = @"첨부파일";
        postPosition = @"을";
    }
    
    if([[NSString stringWithFormat:@"%@", self.createUserNo] isEqualToString:[NSString stringWithFormat:@"%@", histUserNo]]){
        cell.iconView.image = [UIImage imageNamed:@"icon_crown.png"];
    } else {
        
    }
    
    NSMutableAttributedString *attrHistName = [[NSMutableAttributedString alloc] initWithString:histName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:attrHistName];
    
    NSAttributedString *str3;
    if(histContent==nil||[histContent isEqualToString:@""]){
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        if([histType isEqualToString:@"ATTACHED_FILE"]){
            [str appendAttributedString:str2];
            str3 = [[NSAttributedString alloc] initWithString:@"변경하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        } else {
            [str appendAttributedString:str2];
            str3 = [[NSAttributedString alloc] initWithString:@"미지정 하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        }
        
    } else {
        NSMutableAttributedString *attrHistContent = [[NSMutableAttributedString alloc] initWithString:histContent attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],  NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]}];
  
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [str appendAttributedString:str2];
        [str appendAttributedString:attrHistContent];
        str3 = [[NSAttributedString alloc] initWithString:@"(으)로 변경하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    }
    
    [str appendAttributedString:str3];
    
    cell.contentLbl.attributedText = str;
    cell.dateLbl.text = histDate;
    
    return cell;
}

- (void)tmpSetUpHistoryCell:(TaskHistoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    historyHeight = 0;
    NSString *content = [NSString urlDecodeString:[[self.dataSetArr objectAtIndex:indexPath.item] objectForKey:@"CONTENT"]];
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *histType = [dict objectForKey:@"TYPE"];
    NSString *histName = [dict objectForKey:@"NAME"];
    NSString *histContent = [dict objectForKey:@"CONTENT"];
    
    NSString *tyStr = nil;
    NSString *postPosition = nil;;
    
    if([histType isEqualToString:@"TITLE"]){
        tyStr = @"업무명";
        postPosition = @"을";
    } else if([histType isEqualToString:@"STATUS"]){
        tyStr = @"상태";
        postPosition = @"를";
        
        if([histContent isEqualToString:@"1"]) histContent=NSLocalizedString(@"task_status1", @"task_status1");
        else if([histContent isEqualToString:@"2"]) histContent=@"진행";
        else if([histContent isEqualToString:@"3"]) histContent=NSLocalizedString(@"task_status3", @"task_status3");
        else if([histContent isEqualToString:@"4"]) histContent=@"보류";
        
    } else if([histType isEqualToString:@"MANAGER"]){
        tyStr = @"수행자";
        postPosition = @"를";
        
    } else if([histType isEqualToString:@"REFERENCER"]){
        tyStr = @"참조자";
        postPosition = @"를";
        
    } else if([histType isEqualToString:@"START_DATE"]){
        tyStr = @"시작일";
        postPosition = @"을";
        
    } else if([histType isEqualToString:@"END_DATE"]){
        tyStr = @"완료일";
        postPosition = @"을";
        
    }  else if([histType isEqualToString:@"PROGRESS"]){
        tyStr = @"진행률";
        postPosition = @"을";
        
    } else if([histType isEqualToString:@"CAPTION"]){
        tyStr = @"설명";
        postPosition = @"을";
        
    } else if([histType isEqualToString:@"ATTACHED_FILE"]){
        tyStr = @"첨부파일";
        postPosition = @"을";
    }
    
    NSMutableAttributedString *attrHistName = [[NSMutableAttributedString alloc] initWithString:histName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:attrHistName];
    
    NSAttributedString *str3;
    if(histContent==nil||[histContent isEqualToString:@""]){
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition]];
        if([histType isEqualToString:@"ATTACHED_FILE"]){
            [str appendAttributedString:str2];
            str3 = [[NSAttributedString alloc] initWithString:@"변경하였습니다."];
        } else {
            [str appendAttributedString:str2];
            str3 = [[NSAttributedString alloc] initWithString:@"미지정 하였습니다."];
        }
        
    } else {
        NSMutableAttributedString *attrHistContent = [[NSMutableAttributedString alloc] initWithString:histContent attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],  NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]}];
        
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition]];
        [str appendAttributedString:str2];
        [str appendAttributedString:attrHistContent];
        str3 = [[NSAttributedString alloc] initWithString:@"(으)로 변경하였습니다."];
        
    }
   
    [str appendAttributedString:str3];
    
    CGSize maximumSize = CGSizeMake(300, 9999);
    CGRect rect = [str boundingRectWithSize:(CGSize)maximumSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize textStringSize = rect.size;
    
    if(textStringSize.height>cell.contentLbl.frame.size.height){
        historyHeight = textStringSize.height-cell.contentLbl.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
