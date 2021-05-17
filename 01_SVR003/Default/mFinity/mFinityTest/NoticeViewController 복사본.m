//
//  SecondViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "NoticeViewController.h"
#import "IntroViewController.h"
#import "NoticeCell.h"
#import "CustomSegmentedControl.h"
#import "WebViewController.h"
#import "LockInsertView.h"
@interface NoticeViewController ()

@end

@implementation NoticeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"bottom_icon02.png"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    pno = 0;
    noticeViewFlag = YES;
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    /*
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
    label.text = appDelegate.noticeTitle;
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.mainShadowOffset floatValue], [appDelegate.mainShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    */
    CustomSegmentedControl *editButton = [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:appDelegate.noticeTitle,@"Message",nil]
                                                                             offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                              onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                         offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                          onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                             fontSize:12];
    
    editButton.momentary = YES;

    editButton.segmentedControlStyle = UISegmentedControlStyleBar;
    [editButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = editButton;
    //UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithCustomView:editButton];
    
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editBtn, nil];
    
    //self.navigationItem.rightBarButtonItem = editBtn;
    //self.navigationItem.rightBarButtonItem = newBtn;
    
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editBtn,nil];
    //self.navigationItem.title = appDelegate.noticeTitle;
    //UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"message53", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
    //self.navigationItem.backBarButtonItem = left;
    CustomSegmentedControl *button;
    button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Push",nil]
                                                    offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                     onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                    fontSize:12];
    [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
    /*
    UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Push",nil]];
    button.momentary = YES;

    button.segmentedControlStyle = UISegmentedControlStyleBar;
    button.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
     */
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
  
    //self.navigationItem.leftBarButtonItem=leftBtn;
    //[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]} forState:UIControlStateNormal];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"message53", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
    
	self.navigationItem.backBarButtonItem = left;
}
- (void)rightButtonClick:(UISegmentedControl *)sender{
    NSLog(@"sender : %d",sender.selectedSegmentIndex);
}
- (void)leftBtnClick{
    CustomSegmentedControl *button;
	//UISegmentedControl *leftButton;
    if (appDelegate.isOffLine) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message112", @"")];
    }else{
        if (noticeViewFlag) {
            //appDelegate.noticeTitle = @"Push List";
            /*
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
            label.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
            label.text = @"Push List";
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                label.shadowOffset = CGSizeMake([appDelegate.mainShadowOffset floatValue], [appDelegate.mainShadowOffset floatValue]);
            }
            self.navigationItem.titleView = label;
            */
            
            button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:appDelegate.noticeTitle,nil]
                                                        offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                         onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                    offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                     onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                        fontSize:12];
           
            //leftButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:appDelegate.noticeTitle,nil]];
            
            NSString *url = [NSString stringWithFormat:@"%@/getPushList2?cuser_no=%@&pno=%@&psize=%@",appDelegate.main_url,appDelegate.user_no,[NSString stringWithFormat:@"%d",pno],appDelegate.moreCount];
            NSURL *rankUrl = [NSURL URLWithString:url];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            if(urlCon){
                receiveData = [[NSMutableData alloc] init];
            }else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
            
        }else{
            /*
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
            label.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
            label.text =appDelegate.noticeTitle;
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                label.shadowOffset = CGSizeMake([appDelegate.mainShadowOffset floatValue], [appDelegate.mainShadowOffset floatValue]);
            }
            self.navigationItem.titleView = label;
             */
            button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Push",nil]
                                                        offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                         onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                    offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                     onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                        fontSize:12];
            //leftButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Push",nil]];
           
            NSString *url = [NSString stringWithFormat:@"%@/getNoticeList2?cuser_no=%@&app_no=%@",appDelegate.main_url,appDelegate.user_no,appDelegate.app_no];
            NSURL *rankUrl = [NSURL URLWithString:url];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            if(urlCon){
                receiveData = [[NSMutableData alloc] init];
            }else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
        }
        button.momentary = YES;
        button.segmentedControlStyle = UISegmentedControlStyleBar;
        button.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem=left;
        noticeViewFlag = !noticeViewFlag;
    }
    
    //[self getXmlFromServer:[[NSString alloc] initWithFormat:@"%@/getPushList?cuser_no=%@",appDelegate._main_url,appDelegate._user_no]];
}
- (void)_startConnection
{
    NSLog(@"startConnection");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlString;
    if (noticeViewFlag) {
        NSLog(@"noticeViewFlag");
        urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2?cuser_no=%@&app_no=%@",appDelegate.main_url,appDelegate.user_no,appDelegate.app_no];
    }else{
        NSLog(@"pushListViewFlag");
        urlString = [[NSString alloc] initWithFormat:@"%@/getPushList2?cuser_no=%@&pno=%@&psize=%@",appDelegate.main_url,appDelegate.user_no,[NSString stringWithFormat:@"%d",pno],appDelegate.moreCount];
    }

    NSURL *rankUrl = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(urlCon){
        receiveData = [[NSMutableData alloc] init];
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
    isDraw = YES;
}
-(void) viewDidAppear:(BOOL)animated{
 
	
    if (!appDelegate.isLogin) {
		IntroViewController *loginView = [[IntroViewController alloc] init];
		UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginView];
		navi.navigationBar.tintColor= [UIColor grayColor];
		[navi setNavigationBarHidden:TRUE];
		[self presentViewController:navi animated:NO completion:nil];

	}else {
        //[appDelegate chageTabBarColor:NO];
        if (!isDraw) {
            //self.navigationItem.title = appDelegate.noticeTitle;
            if (appDelegate.isOffLine) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message112", @"")];
            }else{
                [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
                CustomSegmentedControl *editButton = [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:appDelegate.noticeTitle,@"Message",nil]
                                                                                         offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                                          onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                                     offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                                      onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                                         fontSize:12];
                
                editButton.momentary = NO;
                editButton.selectedSegmentIndex = 0;
                editButton.segmentedControlStyle = UISegmentedControlStyleBar;
                [editButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventValueChanged];
                self.navigationItem.titleView = editButton;
                /*
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
                label.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
                label.text = appDelegate.noticeTitle;
                label.font = [UIFont boldSystemFontOfSize:20.0];
                label.backgroundColor = [UIColor clearColor];
                label.textAlignment = NSTextAlignmentCenter;
                if ([appDelegate.mainIsShadow isEqualToString:@"Y"]) {
                    label.shadowColor = [appDelegate myRGBfromHex:appDelegate.mainShadowColor];
                    label.shadowOffset = CGSizeMake([appDelegate.mainShadowOffset floatValue], [appDelegate.mainShadowOffset floatValue]);
                }
                self.navigationItem.titleView = label;
                 */
                [self performSelector:@selector(_startConnection)];
            }
        }
        int badgeInt = [appDelegate.badgeCount intValue];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeInt];
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""]) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeInt]];
        }
    
	}
    CustomSegmentedControl *button;
    button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Push",nil]
                                                offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                 onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                            offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                             onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                fontSize:12];
    [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
    /*
     UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Push",nil]];
     button.momentary = YES;
     
     button.segmentedControlStyle = UISegmentedControlStyleBar;
     button.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
     [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
     */
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //self.navigationItem.leftBarButtonItem=leftBtn;
    
}
//JSON데이터를 해석하는 메소드
- (void)_fetchedData:(NSData *)responseData
{
    NSError *error;
    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]];
    if (noticeViewFlag) {
        badgeList = [[NSMutableDictionary alloc]init];
        noticeList = [[NSDictionary alloc]initWithDictionary:dic];
        for (int i=0; i<[noticeList count]; i++) {
            NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",i]];
            [badgeList setObject:[dic objectForKey:@"BADGE"] forKey:[NSString stringWithFormat:@"%d",i]];
        }
         NSLog(@"badgeList : %@",badgeList);
    }else{
        if (pno==0) {
            pushList = [[NSDictionary alloc]initWithDictionary:dic];
        }else{
            NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]initWithDictionary:dic];
            [dic2 addEntriesFromDictionary:pushList];
            pushList = [[NSDictionary alloc]initWithDictionary:dic2];

        }
        
    }
    
    
    //이상없이 해석이 완료되면 테이블뷰 리로드
    [self.tableView reloadData];
    
    //PullRefreshTableView의 StopLoading 호출
    [super stopLoading];
}
#pragma mark
#pragma PullRefreshTableView

// 새로고침이 시작될 때 호출 될 메소드
- (void)startLoading
{
    //PullRefreshTableView의 StartLoading 호출
    [super startLoading];
    [self performSelector:@selector(_startConnection)];
}



#pragma mark
#pragma TableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (noticeViewFlag) {
        return [noticeList count];
    }else{
        return [pushList count];
    }
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //-----------
    static NSString *CellIdentifier = @"NoticeCell";
    
    NoticeCell *cell = (NoticeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NoticeCell" owner:self options:nil];
		
		for (id currentObject in topLevelObject) {
			if ([currentObject isKindOfClass:[NoticeCell class]]) {
				cell = (NoticeCell *) currentObject;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			}
		}
		
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 230, 40)];
    NSString *titleString;
    UILabel *dateLabel = [[UILabel alloc]init];
    titleLabel.tag = indexPath.row;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    dateLabel.font = [UIFont boldSystemFontOfSize:9];
    dateLabel.numberOfLines = 2;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.alpha = 0.6;
    UIImageView *image = nil;
    if (noticeViewFlag) {
        
        //dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 1, 40, 40)];
        [dateLabel setFrame:CGRectMake(265, 1, 55, 40)];
        image = [[UIImageView alloc] initWithFrame:CGRectMake(240, 16, 20, 8)];
        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        //titleLabel.textColor = [self myRGBfromHex:appDelegate.mainFontColor];
        titleString = [dic objectForKey:@"TITLE"];
        titleLabel.text = titleString;
        image.image = [UIImage imageNamed:@"icon_new.gif"];
        //dateLabel.textColor = [self myRGBfromHex:appDelegate.mainFontColor];
        dateLabel.text = [dic objectForKey:@"WRITE_DATE"];
        
        if ([[badgeList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] isEqualToString:@"Y"]) {
            [cell.contentView addSubview:image];
        }
        
    }else{
        [dateLabel setFrame:CGRectMake(265, 1, 55, 40)];
        //dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 1, 60, 40)];
        image = [[UIImageView alloc] initWithFrame:CGRectMake(240, 16, 18, 18)];
        NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        titleString = [dic objectForKey:@"V2"];
        NSString *dateString = [dic objectForKey:@"V3"];
        if ([[dic objectForKey:@"V1"] isEqualToString:@"1"]) {
            image.image = [UIImage imageNamed:@"memo_icon_doc_file.png"];
        }else if([[dic objectForKey:@"V1"] isEqualToString:@"2"]){
            image.image = [UIImage imageNamed:@"main_memo_count_btn.png"];
        }
        titleLabel.text = titleString;
        dateLabel.text = dateString;
        [cell.contentView addSubview:image];
        
    }
    if(titleLabel.text.length>21){
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.numberOfLines = 2;
    }
    
    [cell.contentView addSubview:titleLabel];
	[cell.contentView addSubview:dateLabel];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (noticeViewFlag) {

        NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        NSString *menuHitURL = [[NSString alloc] initWithFormat:@"%@/addNoticeHist?cuser_no=%@&notice_no=%@",appDelegate.main_url,appDelegate.user_no,[dic objectForKey:@"NOTICE_NO"]];
        //NSLog(@"menuHitURL : %@",menuHitURL);
        NSURL *rankUrl = [NSURL URLWithString:menuHitURL];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if ([[dic objectForKey:@"BADGE"] isEqualToString:@"Y"]) {
            int badgeCount = badgeList.count;
            [badgeList setObject:@"N" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            badgeCount--;
            appDelegate.badgeCount = [NSString stringWithFormat:@"%d",badgeCount];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
            if (badgeCount <= 0) {
                [[[[[self tabBarController] tabBar] items]objectAtIndex:[appDelegate.noticeTabBarNumber intValue]]setBadgeValue:nil];
            }else {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
            }
        }
        if(urlCon){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
        
        NSString *url =
        [NSString stringWithFormat:@"%@/NoticeDetail.jsp?cuser_no=%@&app_no=%@&notice_no=%@",appDelegate.main_url,
         appDelegate.user_no,appDelegate.app_no,[dic objectForKey:@"NOTICE_NO"]];
        appDelegate.target_url = url;
        appDelegate.menu_title = [dic objectForKey:@"TITLE"];
        //WebPageView를 호출
        WebViewController *vc = [[WebViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (indexPath.row == [pushList count]) {
            ++pno;
            [self performSelector:@selector(_startConnection)];
        }else{
            NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dic objectForKey:@"V3"] message:[dic objectForKey:@"V2"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
            [alertView show];
        }
        
    }
	
	
}
-(void) showAlertMessage:(NSString*)msgContent Title:(NSString*)msgTitle Btn:(NSString*) buttonLabel{
	
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:msgTitle message:msgContent delegate:nil
										cancelButtonTitle:buttonLabel otherButtonTitles:nil];
	[alert show];

}



#pragma mark
#pragma HTTPConnection Delegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];

	[self showAlertMessage:NSLocalizedString(@"message13", @"") Title:NSLocalizedString(@"message56", @"") Btn:NSLocalizedString(@"message51", @"")];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
		[self showAlertMessage:NSLocalizedString(@"message12", @"") Title:NSLocalizedString(@"message56", @"") Btn:NSLocalizedString(@"message51", @"")];
		
	}else{
		[receiveData setLength:0];
	}
	
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *requestUrl = connection.currentRequest.URL.absoluteString;
    NSLog(@"requestURL : %@",requestUrl);
    NSArray *paths = [requestUrl componentsSeparatedByString:@"/"];
    NSString *temp = [paths objectAtIndex:4];
    NSArray *methodNames = [temp componentsSeparatedByString:@"?"];
    
    if ([[methodNames objectAtIndex:0]isEqualToString:@"getNoticeList2"]||[[methodNames objectAtIndex:0]isEqualToString:@"getPushList2"]) {
        [self _fetchedData:receiveData];
    }
    [self.tableView reloadData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [super scrollViewDidEndDragging:scrollView willDecelerate:NO];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView.contentSize.height-scrollView.contentOffset.y<320) {
        if (!noticeViewFlag && pno< 2) {
            
        }
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        float reload_distance = 10;

        
        if(y > h + reload_distance) {
            ++pno;
            //[self performSelector:@selector(_startConnection)];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
