//
//  NotiSetViewController.m
//  mfinity_sns
//
//  Created by hilee on 11/06/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiSetViewController.h"

#define HEADER_HEIGHT 45
#define SWITCH_TAG 1000

@interface NotiSetViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation NotiSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSString *titleStr = NSLocalizedString(@"myinfo_noti", @"myinfo_noti");
    
    self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:titleStr];
    
    self.notiKeyArr = [NSMutableArray array];
    [self.notiKeyArr addObject:NSLocalizedString(@"myinfo_post_noti", @"myinfo_post_noti")];
    [self.notiKeyArr addObject:NSLocalizedString(@"myinfo_comment_noti", @"myinfo_comment_noti")];
    [self.notiKeyArr addObject:NSLocalizedString(@"myinfo_chat_noti", @"myinfo_chat_noti")];
    
    NSString *postNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWPOST"]];
    NSString *commNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]];
    NSString *chatNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCHAT"]];
    NSLog(@"[NotiSet] POST : %@ / COMM : %@ / CHAT : %@", postNoti, commNoti, chatNoti);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"myinfo_noti_title", @"myinfo_noti_title");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notiKeyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoticeSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoticeSetTableViewCell"];
    
    if(cell == nil){
        cell = [[NoticeSetTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NoticeSetTableViewCell"];
    }
    int sectionTag=SWITCH_TAG;
    
    cell.keyLabel.text = [self.notiKeyArr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.noticeSwitch.tag = sectionTag+indexPath.row;
    [cell.noticeSwitch setOnTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
    
    NSString *postNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWPOST"]];
    NSString *commNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]];
    NSString *chatNoti = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"NOTINEWCHAT"]];
    
    if(indexPath.row==0){
        if([postNoti isEqualToString:@"1"]){
            [cell.noticeSwitch setOn:YES animated:NO];
        } else {
            [cell.noticeSwitch setOn:NO animated:NO];
        }
    } else if(indexPath.row==1){
        if([commNoti isEqualToString:@"1"]){
            [cell.noticeSwitch setOn:YES animated:NO];
        } else {
            [cell.noticeSwitch setOn:NO animated:NO];
        }
    } else if(indexPath.row==2){
        if([chatNoti isEqualToString:@"1"]){
            [cell.noticeSwitch setOn:YES animated:NO];
        } else {
            [cell.noticeSwitch setOn:NO animated:NO];
        }
    }
    
    [cell.noticeSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell.keyLabel sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if(![mySwitch isOn]){
        if(mySwitch.tag==SWITCH_TAG){
            [appDelegate.appPrefs setObject:@"0" forKey:[appDelegate setPreferencesKey:@"NOTINEWPOST"]];
            [appDelegate.appPrefs synchronize];
            
            
        } else if(mySwitch.tag==SWITCH_TAG+1){
            [appDelegate.appPrefs setObject:@"0" forKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]];
            [appDelegate.appPrefs synchronize];
            
            
        } else if(mySwitch.tag==SWITCH_TAG+2){
            [appDelegate.appPrefs setObject:@"0" forKey:[appDelegate setPreferencesKey:@"NOTINEWCHAT"]];
            [appDelegate.appPrefs synchronize];
            
        }
    } else {
        if(mySwitch.tag==SWITCH_TAG){
            [appDelegate.appPrefs setObject:@"1" forKey:[appDelegate setPreferencesKey:@"NOTINEWPOST"]];
            [appDelegate.appPrefs synchronize];
            
            
        } else if(mySwitch.tag==SWITCH_TAG+1){
            [appDelegate.appPrefs setObject:@"1" forKey:[appDelegate setPreferencesKey:@"NOTINEWCOMM"]];
            [appDelegate.appPrefs synchronize];
            
            
        } else if(mySwitch.tag==SWITCH_TAG+2){
            [appDelegate.appPrefs setObject:@"1" forKey:[appDelegate setPreferencesKey:@"NOTINEWCHAT"]];
            [appDelegate.appPrefs synchronize];
            
            
        }
    }
}

@end
