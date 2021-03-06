//
//  BoardTypeViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 3..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "BoardTypeViewController.h"
#import "BoardTypeViewCell.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIDevice-Hardware.h"
#import "MFUtil.h"
#import "MFSingleton.h"

@interface BoardTypeViewController () {
    NSArray *keyArray;
    NSArray *valArray;
    BoardTypeViewCell *cell;
    NSInteger currentSelectedIndex;
    UIButton *currentBtn;
    NSMutableArray *btnArray;
    int cellHeight;
}

@end

@implementation BoardTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    cellHeight = 0;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    btnArray = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BoardTypeViewCell" bundle:nil] forCellReuseIdentifier:@"BoardTypeViewCell"];
    
    if([self.fromSegue isEqualToString:@"SELECT_SNS_KIND"]){
        keyArray = @[NSLocalizedString(@"board_info_kind_normal", @"board_info_kind_normal"), NSLocalizedString(@"board_info_kind_project", @"board_info_kind_project")];
        valArray = @[NSLocalizedString(@"board_info_kind_normal_desc", @"board_info_kind_normal_desc"), NSLocalizedString(@"board_info_kind_project_desc", @"board_info_kind_project_desc")];
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_TYPE"]){
        keyArray = @[NSLocalizedString(@"board_info_visible_type_public", @"board_info_visible_type_public"), /*@"이름공개",*/ NSLocalizedString(@"board_info_visible_type_secret", @"board_info_visible_type_secret")];
        valArray = @[NSLocalizedString(@"board_info_visible_type_public_desc", @"board_info_visible_type_public_desc"),
                     /*@"사용자가 게시판 검색 시 검색결과에 노출되지만 게시판에 가입 할 수 없는 게시판 입니다. 초대로 가입 가능 합니다.",*/
                     NSLocalizedString(@"board_info_visible_type_secret_desc", @"board_info_visible_type_secret_desc")];
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_ALLOW"]){
        keyArray = @[NSLocalizedString(@"board_info_need_allow_no", @"board_info_need_allow_no"), NSLocalizedString(@"board_info_need_allow_yes", @"board_info_need_allow_yes")];
        valArray = @[NSLocalizedString(@"board_info_need_allow_no_desc", @"board_info_need_allow_no_desc"), NSLocalizedString(@"board_info_need_allow_yes_desc", @"board_info_need_allow_yes_desc")];
        
    } else if([self.fromSegue isEqualToString:@"SELECT_TASK_STATUS"]){
        keyArray = @[NSLocalizedString(@"task_status1", @"task_status1"), NSLocalizedString(@"task_status2", @"task_status2"), NSLocalizedString(@"task_status3", @"task_status3"), NSLocalizedString(@"task_status4", @"task_status4")];
        valArray = @[NSLocalizedString(@"task_status1", @"task_status1"), NSLocalizedString(@"task_status2", @"task_status2"), NSLocalizedString(@"task_status3", @"task_status3"), NSLocalizedString(@"task_status4", @"task_status4")];
        
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.tableView.frame.size.width, self.tableView.contentSize.height)];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return keyArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self.fromSegue isEqualToString:@"SELECT_SNS_KIND"]){
        return NSLocalizedString(@"board_info_kind", @"board_info_kind");
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_TYPE"]){
        return NSLocalizedString(@"board_info_visible_type", @"board_info_visible_type");
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_ALLOW"]){
        return NSLocalizedString(@"board_info_need_allow", @"board_info_need_allow");
        
    } else if([self.fromSegue isEqualToString:@"SELECT_TASK_STATUS"]){
        return @"상태";
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor blackColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:20];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = [tableView dequeueReusableCellWithIdentifier:@"BoardTypeViewCell"];
    if(cell == nil){
        cell = [[BoardTypeViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"BoardTypeViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLabel.text = [keyArray objectAtIndex:indexPath.row];
    cell.descLabel.numberOfLines=0;
    if(valArray.count>0) cell.descLabel.text = [valArray objectAtIndex:indexPath.row];
    [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_blue_blank.png"] scaledToMaxWidth:25.0f] forState:UIControlStateNormal];
    
//    UIImage *checkImg;
//    if (@available(iOS 13.0, *)) {
//        checkImg = [[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_blue.png"] scaledToMaxWidth:25.0f] imageWithTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] renderingMode:UIImageRenderingModeAlwaysOriginal];
//    } else {
//        checkImg = [[MFUtil changeImgColor:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_blue.png"] scaledToMaxWidth:25.0f]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }
//    [cell.checkButton setImage:checkImg forState:UIControlStateNormal];
    [cell.checkButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"checkbox_blue.png"] scaledToMaxWidth:25.0f] forState:UIControlStateSelected];
    
    [cell.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkButton.tag = indexPath.row;
    
    [cell.checkButton setSelected:NO];
    
    currentSelectedIndex = [self.codeNo integerValue];
    
    if (indexPath.row == currentSelectedIndex) {
        [cell.checkButton setSelected:YES];
        currentBtn = cell.checkButton;
    }
    
    
    [btnArray addObject:cell.checkButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeSubInfo2" object:nil];
    [self checkAction:[btnArray objectAtIndex:indexPath.row]];
}

-(void)checkAction:(id)sender{
    currentBtn.selected = NO;
    UIButton *button = (UIButton *) sender;
    button.selected = !button.isSelected;
    currentBtn = button;
    currentSelectedIndex = button.tag;
    
    NSDictionary *dic = [NSDictionary dictionary];
    NSString *valueStr;
    if([self.fromSegue isEqualToString:@"SELECT_SNS_KIND"]){
        if(currentSelectedIndex==0) valueStr = @"1";
        else if(currentSelectedIndex==1) valueStr = @"2";
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"KIND", @"TYPE", valueStr, @"SNS_KIND", nil];
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_TYPE"]){
        if(currentSelectedIndex==0) valueStr = @"3";
        else if(currentSelectedIndex==1) valueStr = @"1";
        //else if(currentSelectedIndex==1) valueStr = @"2";
        //else if(currentSelectedIndex==2) valueStr = @"1";
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TYPE", @"TYPE", valueStr, @"SNS_TYPE", nil];
        
    } else if([self.fromSegue isEqualToString:@"SELECT_SNS_ALLOW"]){
        if(currentSelectedIndex==0) valueStr = @"0";
        else if(currentSelectedIndex==1) valueStr = @"1";
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"ALLOW", @"TYPE", valueStr, @"SNS_ALLOW", nil];
        
    } else if ([self.fromSegue isEqualToString:@"SELECT_TASK_STATUS"]){
        if(currentSelectedIndex==0) valueStr = @"1";
        else if(currentSelectedIndex==1) valueStr = @"2";
        else if(currentSelectedIndex==2) valueStr = @"3";
        else if(currentSelectedIndex==3) valueStr = @"4";
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TASK_STATUS", @"TYPE", valueStr, @"TASK_STATUS", nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeSubInfo2" object:nil userInfo:dic];
}


@end
