//
//  ViewController.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 18..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "ViewController.h"
#import "listViewController.h"
#import "orglistController.h"
#import "AppDelegate.h"
#import "contentViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize btnfind, btnlogout, txtfind, listView, listView1, btnmore1, btnmore2, DataArray1, DataArray2;
@synthesize btnmore3, newbtn1, newbtn2, newbtn3, newbtn4, newbtn5, newbtn6 ;


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
    
    [self buttonSetting];
}

- (void)viewDidLoad {
    [self loadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buttonSetting{
//    CUSTOM------------------------------------------------------
    [self.btnlogout setTitle:@"로그아웃" forState:UIControlStateNormal];
    self.btnlogout.titleLabel.font = [UIFont systemFontOfSize:16];
    
    self.listLabel1.text = @"업무공지 / 게시판";
    self.listLabel1.font = [UIFont systemFontOfSize:16];
    self.listLabel1.textColor = [UIColor colorWithRed:((float) 238 / 255.0f) green:((float) 29 / 255.0f) blue:((float) 35 / 255.0f) alpha:1.0];
    [self.listLabel1 sizeToFit];
    
    self.listLabel2.text = @"E-mail";
    self.listLabel2.font = [UIFont systemFontOfSize:16];
    self.listLabel2.textColor = [UIColor colorWithRed:((float) 11 / 255.0f) green:((float) 76 / 255.0f) blue:((float) 162 / 255.0f) alpha:1.0];
    [self.listLabel2 sizeToFit];
    
    self.listLabel3.text = @"기타 유용한 정보";
    self.listLabel3.font = [UIFont systemFontOfSize:16];
    self.listLabel3.textColor = [UIColor colorWithRed:((float) 58 / 255.0f) green:((float) 165 / 255.0f) blue:((float) 5 / 255.0f) alpha:1.0];
    [self.listLabel3 sizeToFit];
    
    [newbtn1 setTitle:@"KNF 둘레길" forState:UIControlStateNormal];
    newbtn1.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [newbtn2 setTitle:@"버스 노선도" forState:UIControlStateNormal];
    newbtn2.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [newbtn3 setTitle:@"KNF 생활백서" forState:UIControlStateNormal];
    newbtn3.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [newbtn4 setTitle:@"오늘의 식단" forState:UIControlStateNormal];
    newbtn4.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [newbtn5 setTitle:@"행동 강령" forState:UIControlStateNormal];
    newbtn5.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [newbtn6 setTitle:@"갑질근절 가이드라인" forState:UIControlStateNormal];
    [newbtn6 setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -38.0, 0.0, 0.0)];
    UIImage *image = [self getScaledImage:[UIImage imageNamed:@"icon_pdf.png"] scaledToMaxWidth:20];
    [newbtn6 setImage:image forState:UIControlStateNormal];
    [newbtn6 setImageEdgeInsets:UIEdgeInsetsMake(0.0, 120.0, 0.0, 0.0)];
    newbtn6.titleLabel.font = [UIFont systemFontOfSize:13];
    
    self.txtfind.delegate = self;
}
-(UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;

    CGFloat scaleFactor=1;

    scaleFactor = width / oldWidth;

    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);

    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)btnfindPress:(id)sender {
    [self.txtfind resignFirstResponder];
    if ([self.txtfind.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"검색어를 입력하세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alert show];
        return;
    }
    orglistController *org = [[orglistController alloc] initWithNibName:@"orglistController" bundle:nil];
    org.sfind = self.txtfind.text;
    [self.navigationController pushViewController:org animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.txtfind resignFirstResponder];
    
    if ([self.txtfind.text length] > 0) {
        orglistController *org = [[orglistController alloc] initWithNibName:@"orglistController" bundle:nil];
        org.sfind = self.txtfind.text;
        [self.navigationController pushViewController:org animated:YES];
    }
    return YES;
}

- (IBAction)btnlogoutPress:(id)sender {
//    CUSTOM------------------------------------------------------
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app logout];
    
//    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//    content.stitle = @"비밀번호변경";
//    content.surl = [NSString stringWithFormat:@"%@api/password.jsp",host];
//    [self.navigationController pushViewController:content animated:YES];
}

- (IBAction)btnmore1Press:(id)sender {
    listViewController *list = [[listViewController alloc] initWithNibName:@"listViewController" bundle:nil];
    list.stype = @"noti";
    [self.navigationController pushViewController:list animated:YES];
}

- (IBAction)btnmore2Press:(id)sender {
    listViewController *list = [[listViewController alloc] initWithNibName:@"listViewController" bundle:nil];
    list.stype = @"email";
    [self.navigationController pushViewController:list animated:YES];
}

- (IBAction)btnmore3Press:(id)sender{
    
}
- (IBAction)newbtn1Press:(id)sender{
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"KNF 둘레길";
    content.surl    = @"http://m.knfc.co.kr/kepco/contents/list_road.jsp";
    [self.navigationController pushViewController:content animated:YES];
}
- (IBAction)newbtn2Press:(id)sender{
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"버스 노선도";
    content.surl    = @"http://m.knfc.co.kr/kepco/contents/list_busline.jsp";
    [self.navigationController pushViewController:content animated:YES];
}
- (IBAction)newbtn3Press:(id)sender{
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"KNF 생활백서";
//    content.surl    = @"http://192.168.0.159:8080/kepco/api/pdf_viewer.jsp"; //테스트
    content.surl    = @"http://m.knfc.co.kr/kepco/api/pdf_viewer.jsp";
    [self.navigationController pushViewController:content animated:YES];
}
- (IBAction)newbtn4Press:(id)sender {
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"오늘의 식단";
//    content.surl    = @"http://192.168.0.159:8080/kepco/api/foodmenuView.jsp"; //테스트
    content.surl    = @"http://m.knfc.co.kr/kepco/api/foodmenuView.jsp";
    [self.navigationController pushViewController:content animated:YES];
}
- (IBAction)newbtn5Press:(id)sender {
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"행동 강령";
    content.surl    = @"http://m.knfc.co.kr/kepco/contents/list_conduct.jsp";
    [self.navigationController pushViewController:content animated:YES];
}
- (IBAction)newbtn6Press:(id)sender {
    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
    content.stitle  = @"갑질근절 가이드라인";
    content.surl    = @"http://m.knfc.co.kr/kepco/filedata/guide/gap_guide.pdf";
    [self.navigationController pushViewController:content animated:YES];
}

- (void)loadData {
    self.DataArray1 = [[NSMutableArray alloc] init];
    self.DataArray2 = [[NSMutableArray alloc] init];
    NSString *spage = @"3";
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        spage = @"4";
    }
    NSString *strurl = [NSString stringWithFormat:@"%@api/noticeList.jsp?pagCnt=%@&board_attribute=1",host,spage];
    NSLog(@"loadData strurl : %@", strurl);
    NSData *returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
    
    NSString *stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"loadData stStr : %@",stStr);
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
    
    NSLog(@"loadData dict : %@",[dict description]);
    [self.DataArray1 addObjectsFromArray:[dict objectForKey:@"searchResult"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    strurl = [NSString stringWithFormat:@"%@api/mailList.jsp?pagCnt=%@&user_id=%@",host,spage,[defaults objectForKey:@"user_id"]];
    NSLog(@"%@", strurl);
    returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
    
    stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",stStr);
    //[returnData release];
    //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
    stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
    if ([returnData length] == 0) {
        return;
    }
    //jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict1;
    if (!jsonSerializationClass) {
        //iOS < 5 didn't have the JSON serialization class
        dict1 = [returnData objectFromJSONData]; //JSONKit
    }
    else {
        NSError *jsonParsingError = nil;
        dict1 = [NSJSONSerialization JSONObjectWithData:returnData options:0   error:&jsonParsingError];
        
    }
    NSLog(@"%@",[dict1 description]);
    [self.DataArray2 addObjectsFromArray:[dict1 objectForKey:@"searchResult"]];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.listView]) {
        return [self.DataArray1 count];
    }
    return [self.DataArray2 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.listView]) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            UIImageView *imgback = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, self.listView.frame.size.width, 1)];
            imgback.image = [UIImage imageNamed:@"line.png"];
            [cell.contentView addSubview:imgback];
        }
        NSDictionary *dt = [self.DataArray1 objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [dt objectForKey:@"board_title"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            UIImageView *imgback = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, self.listView.frame.size.width, 1)];
            imgback.image = [UIImage imageNamed:@"line.png"];
            [cell.contentView addSubview:imgback];
        }
        NSDictionary *dt = [self.DataArray2 objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [dt objectForKey:@"mail_title"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        return cell;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.listView]) {
        NSDictionary *dt = [self.DataArray1 objectAtIndex:indexPath.row];
        contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
        content.stitle = [dt objectForKey:@"board_title"];
        content.surl = [NSString stringWithFormat:@"%@/api/noticeView.jsp?board_seq=%@",host,[dt objectForKey:@"board_seq"]];
        [self.navigationController pushViewController:content animated:YES];
    } else {
        NSDictionary *dt = [self.DataArray2 objectAtIndex:indexPath.row];
        contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
        content.stitle = [dt objectForKey:@"mail_title"];
        content.surl = [NSString stringWithFormat:@"%@/api/mailView.jsp?mail_seq=%@",host,[dt objectForKey:@"mail_seq"]];
        [self.navigationController pushViewController:content animated:YES];
    }
}


@end
