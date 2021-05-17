//
//  TempNoticeViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "NoticeViewController.h"
#import "CustomSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>
#import "IntroViewController.h"
#import "NoticeCell.h"
#import "CustomSegmentedControl.h"
#import "WebViewController.h"
#import "LockInsertView.h"
#import "MFMessageViewController.h"
#import "MFUserListViewController.h"
#import "MFSQLManager.h"
#import "MFChatRoomInfo.h"
#define REFRESH_TABLEVIEW_DEFAULT_ROW               44.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               44.f

#define REFRESH_TITLE_TABLE_PULL                    @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_RELEASE                 @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_LOAD                    @"Refreshing ..."

#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"
@interface NoticeViewController ()

@end

@implementation NoticeViewController
BOOL isEditing;
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
    isEditing = NO;
    self.isNotice = YES;
    noticeViewFlag = YES;
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    messageList = [NSMutableArray arrayWithObjects:@"관리자",@"임윤정",@"박수완",@"이대성",@"김동현",@"박준형", nil];
    //UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"message53", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"message53", @"");
	//self.navigationItem.backBarButtonItem = back;
    [self performSelector:@selector(_initializeRefreshViewOnTableViewTop)];
}
- (void)segmentButtonClick:(UISegmentedControl *)sender{
    NSString *url;
    if (sender.selectedSegmentIndex == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        noticeViewFlag = YES;
        self.isNotice = YES;
        _tableView.rowHeight = 44;
        url = [NSString stringWithFormat:@"%@/getNoticeList2?cuser_no=%@&app_no=%@",appDelegate.main_url,appDelegate.user_no,appDelegate.app_no];
        NSURL *rankUrl = [NSURL URLWithString:url];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if(urlCon){
            receiveData = [[NSMutableData alloc] init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
    }else if(sender.selectedSegmentIndex == 1){
        CustomSegmentedControl *button;
        button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Edit",nil]
                                                    offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                     onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                    fontSize:12];
        button.momentary = YES;
        [button addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem=left;
        CustomSegmentedControl *button2;
        UIImage *pencil = [UIImage imageNamed:@"pencil-10-icon-21x21.png"];

        
        button2= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:pencil,nil]
                                                     offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                      onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                 offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                  onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                     fontSize:12];
        button2.momentary = YES;
        [button2 addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventValueChanged];

        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button2];
        self.navigationItem.rightBarButtonItem=right;
        
        noticeViewFlag =  NO;
        self.isNotice = NO;
        [self deleteLoading];
        chatRoomList = [[NSMutableArray alloc]init];
        MFSQLManager *sqlManager = [[MFSQLManager alloc]init];
        MFChatRoomInfo *chatInfo = [[MFChatRoomInfo alloc]init];
        NSString *sqlString = @"SELECT ROOM_NO,USER_NO_LIST, USER_NM_LIST FROM MFINITY_ROOM ";
        sqlString = [sqlString stringByAppendingFormat:@"WHERE USER_NO=%@",appDelegate.user_no];
        sqlite3_stmt *stmt = [sqlManager getStatement:@"MFMessenger.sqlite" :sqlString :YES];

        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSLog(@"room number : %s",sqlite3_column_text(stmt, 0));
            NSLog(@"user no list : %s",sqlite3_column_text(stmt, 1));
            //str = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))]
            chatInfo.roomNo = [NSString stringWithUTF8String :(char *)(sqlite3_column_text(stmt, 0))];
            chatInfo.userNo = [NSString stringWithUTF8String :(char *)(sqlite3_column_text(stmt, 1))];
            chatInfo.userNm = [NSString stringWithUTF8String :(char *)(sqlite3_column_text(stmt, 2))];
            NSLog(@"user nm list : %s",sqlite3_column_text(stmt, 2));
            [chatRoomList addObject:chatInfo];
        }

        _tableView.rowHeight = 80;
        [_tableView reloadData];
        NSString *sqlString2 = @"SELECT MESSAGE FROM MFINITY_CHAT WHERE PUSH_NO=(SELECT MAX(PUSH_NO) FROM MFINITY_CHAT WHERE ROOM_NO=";
        //NSString *sqlString2 = @"select max(room_no) from mfinity_chat";
        for (MFChatRoomInfo *tmpInfo in chatRoomList) {
            sqlString2 = [sqlString2 stringByAppendingFormat:@"%@)",tmpInfo.roomNo];
            NSLog(@"sqlString2 : %@",sqlString2);
            sqlite3_stmt *stmt2 = [sqlManager getStatement:@"MFMessenger.sqlite" :sqlString2 :YES];
            while (sqlite3_step(stmt2)==SQLITE_ROW) {
                NSLog(@"message : %s",sqlite3_column_text(stmt2, 0));
                tmpInfo.lastMessage = [NSString stringWithUTF8String :(char *)(sqlite3_column_text(stmt2, 0))];
            }
        }

    }
    
    
}
- (void)leftButtonClick{
    
    if (!isEditing) {
        [_tableView setEditing:YES animated:YES];
        isEditing = YES;
    }else{
        [_tableView setEditing:NO animated:YES];
        isEditing = NO;
    }
    
}
- (void)rightButtonClick{
    
    MFUserListViewController *userListViewController = [[MFUserListViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:userListViewController];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)_startConnection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlString;
    if (noticeViewFlag) {
        urlString = [[NSString alloc] initWithFormat:@"%@/getNoticeList2?cuser_no=%@&app_no=%@",appDelegate.main_url,appDelegate.user_no,appDelegate.app_no];
    }else{
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
		[navi setNavigationBarHidden:TRUE];
		[self presentViewController:navi animated:NO completion:nil];
        
	}else {
        if (!isDraw) {
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
                [editButton addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventValueChanged];
                self.navigationItem.titleView = editButton;
                [self performSelector:@selector(_startConnection)];
                
            }
        }else{
            //            NSString *str = [NSString stringWithFormat:@"%@",appDelegate.msgUserInfo];
            //            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"전송될 사람 목록" message:str delegate:nil cancelButtonTitle:@"confirm" otherButtonTitles: nil];
            //            [alertView show];
        }
        int badgeInt = [appDelegate.badgeCount intValue];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeInt];
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""]) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badgeInt]];
        }
        
	}
    
}
//JSON데이터를 해석하는 메소드
- (void)_fetchedData:(NSData *)responseData
{
    NSError *error;
    NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]];

    NSMutableDictionary *mdic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[dic count]; i++) {
        NSDictionary *tempDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i]];
        [mdic setObject:[MFinityAppDelegate getAllValueUrlDecoding:tempDic] forKey:[NSString stringWithFormat:@"%d",i]];
    }

    if (noticeViewFlag) {
        badgeList = [[NSMutableDictionary alloc]init];
        noticeList = [[NSDictionary alloc]initWithDictionary:mdic];
        for (int i=0; i<[noticeList count]; i++) {
            NSDictionary *dic = [noticeList objectForKey:[NSString stringWithFormat:@"%d",i]];
            [badgeList setObject:[dic objectForKey:@"BADGE"] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }else{
        if (pno==0) {
            pushList = [[NSMutableDictionary alloc]initWithDictionary:mdic];
        }else{
            NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]initWithDictionary:mdic];
            [dic2 addEntriesFromDictionary:pushList];
            pushList = [[NSMutableDictionary alloc]initWithDictionary:dic2];
            
        }
        
    }
    //이상없이 해석이 완료되면 테이블뷰 리로드
    [_tableView reloadData];
    
    //PullRefreshTableView의 StopLoading 호출
    [self stopLoading];
}
#pragma mark
#pragma PullRefreshTableView

// 새로고침이 시작될 때 호출 될 메소드
- (void)startLoading
{
    if (noticeViewFlag) {
        //PullRefreshTableView의 StartLoading 호출
        [self startLoading2];
        [self performSelector:@selector(_startConnection)];
    }
    
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
        return [chatRoomList count];
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
        if (indexPath.row==0) {
            //cell.contentView.backgroundColor = [UIColor yellowColor];
            titleLabel.text = @"관리자";
        }else{
            
            
        }
        MFChatRoomInfo *info=[chatRoomList objectAtIndex:indexPath.row];
        titleLabel.text = info.userNm;
        titleLabel.frame = CGRectMake(10, 5, 230, 15);
        //cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, 260, 64)];
        detail.text = info.lastMessage;
        detail.backgroundColor = [UIColor clearColor];
        detail.font = [UIFont systemFontOfSize:13];
        detail.alpha = 0.6;
        detail.numberOfLines = 0;

        CGSize textSize = [detail.text sizeWithFont:detail.font constrainedToSize:detail.frame.size lineBreakMode:detail.lineBreakMode];
        detail.frame = CGRectMake(detail.frame.origin.x, detail.frame.origin.y, detail.frame.size.width, textSize.height);
        [cell.contentView addSubview:detail];
        
        
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
        ////NSLog(@"menuHitURL : %@",menuHitURL);
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
        MFMessageViewController *messageViewController = [[MFMessageViewController alloc]init];
        [self.navigationController pushViewController:messageViewController animated:YES];
        /*
         if (indexPath.row == [pushList count]) {
         ++pno
         [self performSelector:@selector(_startConnection)];
         }else{
         NSDictionary *dic = [pushList objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
         
         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dic objectForKey:@"V3"] message:[dic objectForKey:@"V2"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
         [alertView show];
         }
         */
        
    }
	
	
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [messageList removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
    [_tableView reloadData];
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}
#pragma mark
#pragma HTTPConnection Delegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
		
	}else{
		[receiveData setLength:0];
	}
	
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *requestUrl = connection.currentRequest.URL.absoluteString;
    NSArray *paths = [requestUrl componentsSeparatedByString:@"/"];
    NSString *temp = [paths objectAtIndex:4];
    NSArray *methodNames = [temp componentsSeparatedByString:@"?"];
    
    if ([[methodNames objectAtIndex:0]isEqualToString:@"getNoticeList2"]||[[methodNames objectAtIndex:0]isEqualToString:@"getPushList2"]) {
        [self _fetchedData:receiveData];
    }
    [_tableView reloadData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            _tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_RELEASE, refreshTime];
            [lbRefreshTime setText:lbString];
            [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        }
        [UIView commitAnimations];
    }
    
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
- (void)stopLoading
{
    [self performSelector:@selector(_stopLoading) withObject:nil afterDelay:1.f];
}
- (void)deleteLoading
{
    ivRefreshArrow.hidden = YES;
    lbRefreshTime.hidden = YES;
    spRefresh.hidden = YES;
    
}
// 새로고침이 완료될 때 호출 할 메소드
- (void)_stopLoading
{
    isRefresh = NO;
    
    refreshTime = nil;
    refreshTime = [[self performSelector:@selector(_getCurrentStringTime)] copy];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    
    [UIView setAnimationDidStopSelector:@selector(_stopLoadingComplete)];
    [_tableView setContentInset:UIEdgeInsetsZero];
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    [UIView commitAnimations];
}
- (void)startLoading2
{
    if (_isNotice) {
        isRefresh = YES;
        lbRefreshTime.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [_tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
        NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_LOAD, refreshTime];
        [ivRefreshArrow setHidden:YES];
        [lbRefreshTime setText:lbString];
        [spRefresh startAnimating];
        
        [UIView commitAnimations];
    }
    
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = NO;
    if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT)
    {
        [self startLoading];
    }
}
- (void)scrollViewDidScroll2:(UIScrollView *)scrollView
{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    ////NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            _tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            _tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
        }
    }
    else if(isDragging && scrollOffsetY < 0)
    {
        [UIView beginAnimations:nil context:NULL];
        if(scrollOffsetY < -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_RELEASE, refreshTime];
            [lbRefreshTime setText:lbString];
            [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
        }
        [UIView commitAnimations];
    }
}
// 최근 새로고침 시간을 String형으로 반환
- (NSString *)_getCurrentStringTime
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:REFRESH_TIME_FORMAT];
    NSString *returnString = [dateFormatter stringFromDate:date];
    return returnString;
}

// 테이블뷰 상단의 헤더뷰 초기화
- (void)_initializeRefreshViewOnTableViewTop
{
    //NSLog(@"_initializeRefreshViewOnTableViewTop");
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, _tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [vRefresh setBackgroundColor:[UIColor clearColor]];
    
    if(spRefresh == nil)
    {
        spRefresh = [[UIActivityIndicatorView alloc] init];
    }
    [spRefresh setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 30) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 20) / 2, 20, 20)];
    [spRefresh setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spRefresh setColor:[UIColor blackColor]];
    [spRefresh setHidesWhenStopped:YES];
    [vRefresh addSubview:spRefresh];
    
    if(ivRefreshArrow == nil)
    {
        ivRefreshArrow = [[UIImageView alloc] init];
    }
    UIImage *imgArrow = [UIImage imageNamed:@"arrow.png"];
    [ivRefreshArrow setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 34) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 44) / 2, 24, 37)];
    [ivRefreshArrow setImage:imgArrow];
    [vRefresh addSubview:ivRefreshArrow];
    
    if(lbRefreshTime == nil)
    {
        lbRefreshTime = [[UILabel alloc] init];
    }
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, _tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [_tableView addSubview:vRefresh];
}
// 새로고침 애니메이션을 정지할 때 호출할 메소드
- (void)_stopLoadingComplete
{
    NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_PULL, refreshTime];
    if (_isNotice) {
        [ivRefreshArrow setHidden:NO];
    }
    [lbRefreshTime setText:lbString];
    [spRefresh stopAnimating];
}

// 테이블뷰를 드래깅 할 때 호출
// 테이블뷰가 현재 새로고침 중이라면 무시
// 새로고침 중이 아니라면 드래깅 중이라는 것을 알려줌
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(isRefresh)
    {
        return ;
    }
    
    isDragging = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
