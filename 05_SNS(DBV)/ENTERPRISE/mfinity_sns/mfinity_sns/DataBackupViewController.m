//
//  DataBackupViewController.m
//  mfinity_sns
//
//  Created by hilee on 22/03/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "DataBackupViewController.h"
#import "MyTableViewCell.h"

@interface DataBackupViewController () {
    AppDelegate *appDelegate;
    NSString *backUpDate;
}

@end

@implementation DataBackupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_backup_restore", @"myinfo_backup_restore")];
    
    backUpDate = @"";
    
    self.dataManageKeyArr = [NSMutableArray array];
    [self.dataManageKeyArr addObject:NSLocalizedString(@"myinfo_backup", @"myinfo_backup")];
    [self.dataManageKeyArr addObject:NSLocalizedString(@"myinfo_restore", @"myinfo_restore")];
    
    self.dataInfoKeyArr = [NSMutableArray array];
    [self.dataInfoKeyArr addObject:NSLocalizedString(@"myinfo_backup_date", @"myinfo_backup_date")];
    
    //self.dataInfoValArr = [NSMutableArray array];
    //[self.dataInfoValArr addObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"BACKUPDATE"]]];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getLatestDBInfo"]];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@", userNo];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0) {
        return NSLocalizedString(@"myinfo_backup_restore_title", @"myinfo_backup_restore_title");
    } else if(section == 1) {
        return NSLocalizedString(@"myinfo_backup_restore_info", @"myinfo_backup_restore_info");
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.dataManageKeyArr.count;
        
    } else if (section == 1){
        return self.dataInfoKeyArr.count;
        
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell"];
    
    if(cell == nil){
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyTableViewCell"];
    }
    
    @try{
        if (indexPath.section == 0) {
            cell.keyLabel.text = [self.dataManageKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
        
        } else if (indexPath.section == 1) {
            cell.keyLabel.text = [self.dataInfoKeyArr objectAtIndex:indexPath.row];
            cell.valueLabel.text = backUpDate;
            
            cell.editWidthConstraint.constant = 0;
            cell.editSpaceConstraint.constant = 0;
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        [cell.keyLabel sizeToFit];
        
        return cell;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_backup_action_title", @"myinfo_backup_action_title") message:NSLocalizedString(@"myinfo_backup_action", @"myinfo_backup_action") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self chatDataBackUp];
                                                             //[appDelegate.dbHelper clearDataBase];
                                                         }];
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if(indexPath.section == 0 && indexPath.row == 1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_restore_action_title", @"myinfo_restore_action_title") message:NSLocalizedString(@"myinfo_restore_action", @"myinfo_restore_action") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self chatDataRestore];
//            [appDelegate.dbHelper restoreInsertDB];
                                                         }];
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)chatDataBackUp{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveDBFile"]];
    
    NSString *dbName = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DBNAME"]];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *dbPath = [NSString stringWithFormat:@"%@.db", [documentsDir stringByAppendingPathComponent:dbName]];
    
    NSLog(@"디비경로 : %@", dbPath);
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:userNo forKey:@"usrNo"];
    [param setObject:[NSString stringWithFormat:@"%@.db", dbName] forKey:@"fileName"];

    NSData *data = [NSData dataWithContentsOfFile:dbPath];

    MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:url option:param WithData:data AndFileName:[NSString stringWithFormat:@"%@.db", dbName]];
    sessionUpload.delegate = self;
    [sessionUpload start];
}

-(void)chatDataRestore{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getDBFile"]];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@", userNo];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}


#pragma mark - MFURLSession delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
       
    } else {
        if(session.returnDictionary != nil){
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            
            if ([result isEqualToString:@"SUCCESS"]) {
                @try{
                    NSLog(@"dic : %@",session.returnDictionary);
                    if ([wsName isEqualToString:@"saveDBFile"]) {
                        
                    } else if([wsName isEqualToString:@"getDBFile"]){
                        NSArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                        if(dataSet.count>0){
                            //복구 완료 알림
                            NSString *filePath = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PATH"]];
                            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
                            
//                            DB테스트
//                            NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BP15214.db"];
//                            NSData *data = [NSData dataWithContentsOfFile:filePath];
                            
                            NSString *dbName = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DBNAME"]];
                            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDir = [documentPaths objectAtIndex:0];

                            NSString *dbPath = [NSString stringWithFormat:@"%@.db", [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"TEMP_%@", dbName]]];
                            NSLog(@"복원한 디비 경로 : %@", dbPath);
                            [data writeToFile:dbPath atomically:YES];

                            [appDelegate.dbHelper restoreInsertDB];

                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_restore_action_title", @"myinfo_restore_action_title") message:NSLocalizedString(@"myinfo_restore_action_succeed", @"myinfo_restore_action_succeed") preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [SVProgressHUD dismiss];
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        
                        } else {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_restore_action_title", @"myinfo_restore_action_title") message:NSLocalizedString(@"myinfo_restore_action_null", @"myinfo_restore_action_null") preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [SVProgressHUD dismiss];
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                            [alert addAction:okButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    } else if([wsName isEqualToString:@"getLatestDBInfo"]){
                        NSArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                        if(dataSet.count>0){
                            //NSString *filePath = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PATH"]];
                            NSString *date = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"LATEST_BACKUP_DATE"]];
                            backUpDate = date;
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                        }
                    }
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                    [SVProgressHUD dismiss];
                }
            }
        }
    }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error code : %ld", (long)error.code);
    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
}

#pragma mark - MFURLSessionUpload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    if (error != nil) {
        
    }else{
        if(dictionary != nil){
            NSLog(@"dictionary : %@", dictionary);
            @try{
                //백업 완료 알림
                NSString *affected = [dictionary objectForKey:@"AFFECTED"];
                if ([affected intValue]>0) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_backup_action_title", @"myinfo_backup_action_title") message:NSLocalizedString(@"myinfo_backup_result_succeed", @"myinfo_backup_result_succeed") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         
                                                                         NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
                                                                         NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getLatestDBInfo"]];
                                                                         NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                                                                         
                                                                         NSString *paramString = [NSString stringWithFormat:@"usrNo=%@", userNo];
                                                                         MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
                                                                         session.delegate = self;
                                                                         [session start];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_backup_action_title", @"myinfo_backup_action_title") message:NSLocalizedString(@"myinfo_backup_action_null", @"myinfo_backup_action_null") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
                [SVProgressHUD dismiss];
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
                [SVProgressHUD dismiss];
            }
            
        }
    }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"%@", error);
    [SVProgressHUD dismiss];
}

@end
