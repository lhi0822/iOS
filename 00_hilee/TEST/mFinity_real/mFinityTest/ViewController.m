
#import "ViewController.h"
#import "AppDelegate.h"
//#import "listViewController.h"
//#import "orglistController.h"
//#import "contentViewController.h"



@interface ViewController ()

@end

@implementation ViewController
@synthesize btnfind, btnlogout, txtfind, listView, listView1, btnmore1, btnmore2, DataArray1, DataArray2;
@synthesize btnmore3, newbtn1, newbtn2, newbtn3;


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
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

//- (IBAction)btnfindPress:(id)sender {
//    [self.txtfind resignFirstResponder];
//    if ([self.txtfind.text length] == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"검색어를 입력하세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    orglistController *org = [[orglistController alloc] initWithNibName:@"orglistController" bundle:nil];
//    org.sfind = self.txtfind.text;
//    [self.navigationController pushViewController:org animated:YES];
//}
//
//- (IBAction)btnlogoutPress:(id)sender {
//    /*AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [app logout];*/
//    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//    content.stitle = @"비밀번호변경";
//    content.surl = [NSString stringWithFormat:@"%@XXX/password.jsp",host];
//    [self.navigationController pushViewController:content animated:YES];
//}
//
//- (IBAction)btnmore1Press:(id)sender {
//    listViewController *list = [[listViewController alloc] initWithNibName:@"listViewController" bundle:nil];
//    list.stype = @"noti";
//    [self.navigationController pushViewController:list animated:YES];
//}
//
//- (IBAction)btnmore2Press:(id)sender {
//    listViewController *list = [[listViewController alloc] initWithNibName:@"listViewController" bundle:nil];
//    list.stype = @"email";
//    [self.navigationController pushViewController:list animated:YES];
//}
//
//
//- (IBAction)btnmore3Press:(id)sender{
//
//}
//
//- (IBAction)newbtn1Press:(id)sender{
//    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//    content.stitle  = @"TEMP 둘레길";
//    content.surl    = @"http://m.tempc.co.kr/cokep/contents/list_road.jsp";
//    [self.navigationController pushViewController:content animated:YES];
//}
//
//- (IBAction)newbtn2Press:(id)sender{
//    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//    content.stitle  = @"버스 노선도";
//    content.surl    = @"http://m.tempc.co.kr/cokep/contents/list_busline.jsp";
//    [self.navigationController pushViewController:content animated:YES];
//}
//
//- (IBAction)newbtn3Press:(id)sender{
//    contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//    content.stitle  = @"행동 강령";
//    content.surl    = @"http://m.tempc.co.kr/cokep/contents/list_conduct.jsp";
//    [self.navigationController pushViewController:content animated:YES];
//}


//로그아웃 버튼 클릭
- (IBAction)logoutPress:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"로그아웃 하시겠습니까?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
        //로그아웃 시 앱에 저장된 정보 삭제
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"auto"];
        [defaults removeObjectForKey:@"user_id"];
        [defaults removeObjectForKey:@"user_sabun"];
        [defaults removeObjectForKey:@"user_name"];
        [defaults removeObjectForKey:@"user_department"];
        [defaults removeObjectForKey:@"user_positon"];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"save"];
        [defaults synchronize];
        
        loginController *vc = [[loginController alloc]initWithNibName:@"loginController" bundle:Nil];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:NO completion:nil];
                                                         
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    [alert addAction:cancelButton];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


//- (void)loadData {
//    self.DataArray1 = [[NSMutableArray alloc] init];
//    self.DataArray2 = [[NSMutableArray alloc] init];
//    NSString *spage = @"3";
//    if ([[UIScreen mainScreen] bounds].size.height == 568) {
//        spage = @"4";
//    }
//    NSString *strurl = [NSString stringWithFormat:@"%@XXX/noticeList.jsp?pagCnt=%@&board_attribute=1",host,spage];
//    NSLog(@"%@", strurl);
//    NSData *returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
//
//    NSString *stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",stStr);
//    //[returnData release];
//    //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
//    stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//    returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
//    if ([returnData length] == 0) {
//        return;
//    }
//    //jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict;
//    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
//    if (!jsonSerializationClass) {
//        //iOS < 5 didn't have the JSON serialization class
//        dict = [returnData objectFromJSONData]; //JSONKit
//    }
//    else {
//        NSError *jsonParsingError = nil;
//        dict = [NSJSONSerialization JSONObjectWithData:returnData options:0   error:&jsonParsingError];
//
//    }
//
//    NSLog(@"%@",[dict description]);
//    [self.DataArray1 addObjectsFromArray:[dict objectForKey:@"searchResult"]];
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    strurl = [NSString stringWithFormat:@"%@XXX/mailList.jsp?pagCnt=%@&user_id=%@",host,spage,[defaults objectForKey:@"user_id"]];
//    NSLog(@"%@", strurl);
//    returnData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strurl]];
//
//    stStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",stStr);
//    //[returnData release];
//    //stStr = [stStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
//    stStr = [stStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//    returnData = [stStr dataUsingEncoding:NSUTF8StringEncoding];
//    if ([returnData length] == 0) {
//        return;
//    }
//    //jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict1;
//    if (!jsonSerializationClass) {
//        //iOS < 5 didn't have the JSON serialization class
//        dict1 = [returnData objectFromJSONData]; //JSONKit
//    }
//    else {
//        NSError *jsonParsingError = nil;
//        dict1 = [NSJSONSerialization JSONObjectWithData:returnData options:0   error:&jsonParsingError];
//
//    }
//    NSLog(@"%@",[dict1 description]);
//    [self.DataArray2 addObjectsFromArray:[dict1 objectForKey:@"searchResult"]];
//
//}

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
//    if ([tableView isEqual:self.listView]) {
//        NSDictionary *dt = [self.DataArray1 objectAtIndex:indexPath.row];
//        contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//        content.stitle = [dt objectForKey:@"board_title"];
//        content.surl = [NSString stringWithFormat:@"%@/api/noticeView.jsp?board_seq=%@",host,[dt objectForKey:@"board_seq"]];
//        [self.navigationController pushViewController:content animated:YES];
//    } else {
//        NSDictionary *dt = [self.DataArray2 objectAtIndex:indexPath.row];
//        contentViewController *content = [[contentViewController alloc] initWithNibName:@"contentViewController" bundle:nil];
//        content.stitle = [dt objectForKey:@"mail_title"];
//        content.surl = [NSString stringWithFormat:@"%@/api/mailView.jsp?mail_seq=%@",host,[dt objectForKey:@"mail_seq"]];
//        [self.navigationController pushViewController:content animated:YES];
//    }
}


@end
