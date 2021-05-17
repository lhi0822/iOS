//
//  orglistController.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "orglistController.h"
#import "contentViewController.h"

@interface orglistController ()

@end

@implementation orglistController
@synthesize btnfind, txtfind, listView, DataArray, sfind;

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
    lbltitle.text = @"직원검색";
    
    [lbltitle sizeToFit];
    currentpage = 1;
    totalpage = 1;
    self.navigationItem.titleView = lbltitle;
    self.txtfind.text = self.sfind;
    self.DataArray = [[NSMutableArray alloc] init];
    [self showWithLabel];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
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
- (IBAction)btnfindPress:(id)sender {
    [self.txtfind resignFirstResponder];
    self.DataArray = [[NSMutableArray alloc] init];
    [self showWithLabel];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
}

- (IBAction)btnbackPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnhomePress:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) showWithLabel {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // The hud will dispable all input on the view
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        
        // Add HUD to screen
        [self.view addSubview:HUD];
        
        HUD.labelText = @"로딩중";
        // Regisete for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        
        [HUD show:YES];
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(closeWithLabel) userInfo:nil repeats:NO];
    }
    
    
    
}

-(void) closeWithLabel {
    
    if (HUD != nil) {
        [HUD removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
}

- (void)loadData {
    
    NSString *strurl = [NSString stringWithFormat:@"%@api/userList.jsp?sKeywd=%@&nPgNum=%d&pagCnt=20",host,[self.txtfind.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], currentpage];
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
    [self.listView reloadData];
    isLoaing = false;
    [self closeWithLabel];
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
        
        UIImageView *imgback = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, self.listView.frame.size.width, 1)];
        imgback.image = [UIImage imageNamed:@"line.png"];
        [cell.contentView addSubview:imgback];
    }
    NSDictionary *dt = [self.DataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dt objectForKey:@"emp_name"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    cell.detailTextLabel.text = [dt objectForKey:@"emp_department"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dt = [self.DataArray objectAtIndex:indexPath.row];
    
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle = @"직원검색";
    content.surl = [NSString stringWithFormat:@"%@api/userView.jsp?emp_id=%@",host,[dt objectForKey:@"emp_id"]];
    [self.navigationController pushViewController:content animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSArray *visiblePaths = [self.listView indexPathsForVisibleRows];
    // NSLog(@"%@",[visiblePaths description]);
    if ([visiblePaths count] > 0) {
        NSIndexPath *indexPath = [visiblePaths objectAtIndex:0];
        
        //NSLog(@"%d   %d    %f",offsety, indexPath.row *85, ([self.DataArray count] * 85) - listView.frame.size.height);
        if (indexPath.row *50 > ((([self.DataArray count]+1) * 50) - self.listView.frame.size.height)-20 && !isLoaing && (currentpage < totalpage) ) {
            isLoaing = TRUE;
            currentpage = currentpage + 1;
            [self showWithLabel];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
            
            //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showMore:) userInfo:nil repeats:NO];
            
        }
    }
    
    /* */
    
}


@end
