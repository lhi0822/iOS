//
//  MyTabViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 11. 27..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MyTabViewController.h"
#import "MFUtil.h"
#import "MyTabViewCell.h"
#import "AppDelegate.h"

@interface MyTabViewController () {
    UITabBarController *tabBarController;
    AppDelegate *appDelegate;
}

@end

@implementation MyTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_image_tab_reordering", @"myinfo_image_tab_reordering")];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save") style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    
    self.tabArr = [NSMutableArray array];
    self.tabTitleArr = [NSMutableArray array];
    self.tabImgArr = [NSMutableArray array];
    NSMutableArray *tmpTabTitleArr = [NSMutableArray array];
    NSMutableArray *tmpTabImgArr = [NSMutableArray array];
    
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    if([legacyNm isEqualToString:@"NONE"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
        
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f]];
        
    } else if([legacyNm isEqualToString:@"ANYMATE"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:@"Anymate"];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
        
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_anymate.png"] scaledToMaxWidth:24.0f]];
        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f]];
        
    } else if([legacyNm isEqualToString:@"HHI"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
        
//        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_feed.png"] scaledToMaxWidth:24.0f]];
//        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_home.png"] scaledToMaxWidth:24.0f]];
//        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_talk.png"] scaledToMaxWidth:24.0f]];
//        [tmpTabImgArr addObject:[MFUtil getScaledImage:[UIImage imageNamed:@"tabmenu_profile.png"] scaledToMaxWidth:24.0f]];
        
        [tmpTabImgArr addObject:[UIImage imageNamed:@"tabmenu_feed.png"]];
        [tmpTabImgArr addObject:[UIImage imageNamed:@"tabmenu_home.png"]];
        [tmpTabImgArr addObject:[UIImage imageNamed:@"tabmenu_talk.png"]];
        [tmpTabImgArr addObject:[UIImage imageNamed:@"tabmenu_profile.png"]];
    }
    
    NSArray *tmpArr = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"TABITEM"]];
    if(tmpArr != nil){
        self.tabArr = [NSMutableArray arrayWithArray:tmpArr];
        for(int i=0; i<self.tabArr.count; i++){
            NSString *tmp = [self.tabArr objectAtIndex:i];
            int key = [tmp intValue]-1;
            [self.tabTitleArr addObject: [tmpTabTitleArr objectAtIndex:key]];
            [self.tabImgArr addObject:[tmpTabImgArr objectAtIndex:key]];
            
        }
    }else{
        [self.tabArr addObject:@"1"];
        [self.tabArr addObject:@"2"];
        [self.tabArr addObject:@"3"];
        [self.tabArr addObject:@"4"];
        
        if([legacyNm isEqualToString:@"ANYMATE"]) [self.tabArr addObject:@"5"];
        
        self.tabImgArr = tmpTabImgArr;
        self.tabTitleArr = tmpTabTitleArr;
    }
    
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)rightSideMenuButtonPressed:(id)sender {
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    NSMutableArray *tmpTabTitleArr = [NSMutableArray array];
    
    if([legacyNm isEqualToString:@"NONE"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
        
    } else if([legacyNm isEqualToString:@"ANYMATE"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:@"Anymate"];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
        
    } else if([legacyNm isEqualToString:@"HHI"]){
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_newsfeed", @"tab_newsfeed")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_home", @"tab_home")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_chat", @"tab_chat")];
        [tmpTabTitleArr addObject:NSLocalizedString(@"tab_myinfo", @"tab_myinfo")];
    }
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray<MyTabViewCell *> *cells = self.tableView.visibleCells;
    for(int i=0; i<cells.count; i++){
        MyTabViewCell *cell = [cells objectAtIndex:i];
        NSString *title = cell.tabLabel.text;
        for(int j=0; j<tmpTabTitleArr.count; j++){
            NSString *tmpTitle = [tmpTabTitleArr objectAtIndex:j];
            if([title isEqualToString:tmpTitle]){
                [result addObject:[NSString stringWithFormat:@"%d",j+1]];
            }
        }
    }
    
    [appDelegate.appPrefs setObject:result forKey:[appDelegate setPreferencesKey:@"TABITEM"]];
    [appDelegate.appPrefs synchronize];
    
    int index = 0;
    if([legacyNm isEqualToString:@"NONE"]){
        index = (int)[result indexOfObject:@"4"];
    } else if([legacyNm isEqualToString:@"ANYMATE"]){
        index = (int)[result indexOfObject:@"5"];
    } else if([legacyNm isEqualToString:@"HHI"]){
        index = (int)[result indexOfObject:@"4"];
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"save_succeed", @"save_succeed") preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
        UITabBarController *rootViewController = [MFUtil setDefualtTabBar];
        rootViewController.selectedIndex = index; //처음에 보여질 탭 설정
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        [self popoverPresentationController];
    });
    
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tabTitleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTabViewCell *cell = (MyTabViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTabViewCell"];
    
    if (cell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MyTabViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[MyTabViewCell class]]) {
                cell = (MyTabViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    //cell.textLabel.text = [_tabArr objectAtIndex:indexPath.row];
    //cell.snsImageView.image = [self getScaledImage:[tabBarController.tabBar.items objectAtIndex:indexPath.row].image scaledToMaxWidth:20.0f];
    //cell.snsName.text = [NSString stringWithFormat:@"%ld",[tabBarController.tabBar.items objectAtIndex:indexPath.row].tag];
    
    cell.tabImg.image = [self.tabImgArr objectAtIndex:indexPath.row];
    cell.tabLabel.text = [self.tabTitleArr objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
  
}

@end
