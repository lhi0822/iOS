//
//  listViewController.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "listViewController.h"
#import "contentViewController.h"
#import "listsubViewController.h"

@interface listViewController ()

@end

@implementation listViewController
@synthesize listView, DataArray, stype;

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setImage:[UIImage imageNamed:@"btnback.png"] forState:UIControlStateNormal];
    btnback.frame = CGRectMake(0, 0, 44, 44);
    [btnback addTarget:self action:@selector(btnbackPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbtn = [[UIBarButtonItem alloc] initWithCustomView:btnback];
    self.navigationItem.leftBarButtonItem = leftbtn;
    
    UIButton *btnhome = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnhome setImage:[UIImage imageNamed:@"btnhome.png"] forState:UIControlStateNormal];
    btnhome.frame = CGRectMake(0, 0, 44, 44);
    [btnhome addTarget:self action:@selector(btnhomePress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc] initWithCustomView:btnhome];
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    UILabel *lbltitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    lbltitle.textColor = [UIColor whiteColor];
    lbltitle.font = [UIFont boldSystemFontOfSize:18];
    lbltitle.textAlignment = NSTextAlignmentCenter;
    if ([self.stype isEqualToString:@"noti"]) {
        lbltitle.text = @"공지사항/게시판";
    } else {
        lbltitle.text = @"E-mail";
    }
    [lbltitle sizeToFit];
    
    self.navigationItem.titleView = lbltitle;
    
    [self loadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnbackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnhomePress:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadData {
    self.DataArray = [[NSMutableArray alloc] init];
    if ([self.stype isEqualToString:@"noti"]) {
        NSDictionary *dt = [[NSDictionary alloc] initWithObjectsAndKeys:@"업무공지",@"title",@"1",@"type", nil];
        [self.DataArray addObject:dt];
        
        NSDictionary *dt1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"동호회",@"title",@"2",@"type", nil];
        [self.DataArray addObject:dt1];
        
        NSDictionary *dt2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"애경사",@"title",@"3",@"type", nil];
        [self.DataArray addObject:dt2];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *strurl = [NSString stringWithFormat:@"%@api/mailList.jsp?pagCnt=10&user_id=%@",host,[defaults objectForKey:@"user_id"]];       
        NSLog(@"%@", strurl);
        NSData *returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
        
        NSString *stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",stStr);
        //[returnData release];
        //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
        stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
        if ([returnData length] == 0) {
            return;
        }
        //jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *dict;
        Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
        if (!jsonSerializationClass) {
            //iOS < 5 didn't have the JSON serialization class
            dict = [returnData objectFromJSONData]; //JSONKit
        }
        else {
            NSError *jsonParsingError = nil;
            dict = [NSJSONSerialization JSONObjectWithData:returnData options:0   error:&jsonParsingError];
            
        }
        totalpage = [[dict objectForKey:@"total_page"] intValue];
        NSLog(@"%@",[dict description]);
        [self.DataArray addObjectsFromArray:[dict objectForKey:@"searchResult"]];
    }
    [self.listView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.DataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIImageView *imgback = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, self.listView.frame.size.width, 1)];
        imgback.image = [UIImage imageNamed:@"line.png"];
        [cell.contentView addSubview:imgback];
    }
    NSDictionary *dt = [self.DataArray objectAtIndex:indexPath.row];
    if ([self.stype isEqualToString:@"noti"]) {
        cell.textLabel.text = [dt objectForKey:@"title"];
    } else {
        cell.textLabel.text = [dt objectForKey:@"mail_title"];
    }
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dt = [self.DataArray objectAtIndex:indexPath.row];
    if ([self.stype isEqualToString:@"noti"]) {
        listsubViewController *sub = [[listsubViewController alloc] initWithNibName:@"listsubViewController" bundle:nil];
        sub.stype = [dt objectForKey:@"type"];
        [self.navigationController pushViewController:sub animated:YES];
    } else {
        contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
        content.stitle = [dt objectForKey:@"mail_title"];
        content.surl = [NSString stringWithFormat:@"%@/api/mailView.jsp?mail_seq=%@",host,[dt objectForKey:@"mail_seq"]];
        [self.navigationController pushViewController:content animated:YES];
    }
    
    
    
}


@end
