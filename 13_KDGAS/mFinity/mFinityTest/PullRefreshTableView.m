//
//  PullRefreshTableView.m
//  PullRefreshTableView
//
//  Created by j2enty on 11. 12. 12..
//  Copyright (c) 2011년 j2enty. All rights reserved.
//

#import "PullRefreshTableView.h"
#import "MFinityAppDelegate.h"
#import "IntroViewController.h"
#import <QuartzCore/QuartzCore.h>

#define REFRESH_TABLEVIEW_DEFAULT_ROW               44.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               44.f

#define REFRESH_TITLE_TABLE_PULL                    @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_RELEASE                 @"Refresh pulled the release."
#define REFRESH_TITLE_TABLE_LOAD                    @"Refreshing ..."

#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"


@implementation PullRefreshTableView

#pragma mark
#pragma Private Methods

// 테이블뷰 상단의 헤더뷰 초기화
- (void)_initializeRefreshViewOnTableViewTop
{
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_DEFAULT_HEIGHT, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
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
    [lbRefreshTime setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];    
    [lbRefreshTime setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime setNumberOfLines:2];
    [lbRefreshTime setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime];
    
    [self.view addSubview:vRefresh];
}
- (void)_initializeRefreshViewOnTableViewTail{
    UIView *vRefresh = [[UIView alloc] initWithFrame:CGRectMake(0, 840 + REFRESH_HEADER_DEFAULT_HEIGHT, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];
    [vRefresh setBackgroundColor:[UIColor clearColor]];
    
    if(spRefresh2 == nil)
    {
        spRefresh2 = [[UIActivityIndicatorView alloc] init];
    }
    [spRefresh2 setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 30) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 20) / 2, 20, 20)];
    [spRefresh2 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spRefresh2 setColor:[UIColor blackColor]];
    [spRefresh2 setHidesWhenStopped:YES];
    [vRefresh addSubview:spRefresh2];
    
    if(ivRefreshArrow2 == nil)
    {
        ivRefreshArrow2 = [[UIImageView alloc] init];
    }
    UIImage *imgArrow = [UIImage imageNamed:@"arrow.png"];
    [ivRefreshArrow2 setFrame:CGRectMake((REFRESH_HEADER_DEFAULT_HEIGHT - 34) / 2, (REFRESH_HEADER_DEFAULT_HEIGHT - 44) / 2, 24, 37)];
    [ivRefreshArrow2 setImage:imgArrow];
    [vRefresh addSubview:ivRefreshArrow2];
    
    if(lbRefreshTime2 == nil)
    {
        lbRefreshTime2 = [[UILabel alloc] init];
    }
    [lbRefreshTime2 setFrame:CGRectMake(REFRESH_HEADER_DEFAULT_HEIGHT - 10, 0, self.tableView.frame.size.width, REFRESH_HEADER_DEFAULT_HEIGHT)];    
    [lbRefreshTime2 setBackgroundColor:[UIColor clearColor]];
    [lbRefreshTime2 setFont:[UIFont boldSystemFontOfSize:12.f]];
    [lbRefreshTime2 setNumberOfLines:2];
    [lbRefreshTime2 setTextColor:[UIColor lightGrayColor]];
    [vRefresh addSubview:lbRefreshTime2];
    
    [self.view addSubview:vRefresh];

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
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [[ivRefreshArrow layer] setTransform:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)];
    
    [UIView commitAnimations];
}





#pragma mark
#pragma Public Methods

// 새로고침이 시작될 때 호출 될 메소드
- (void)startLoading
{
    if (_isNotice) {
        isRefresh = YES;
        lbRefreshTime.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [self.tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEADER_DEFAULT_HEIGHT, 0, 0, 0)];
        NSString *lbString = [NSString stringWithFormat:@"%@\nLasted Refresh : %@", REFRESH_TITLE_TABLE_LOAD, refreshTime];
        [ivRefreshArrow setHidden:YES];
        [lbRefreshTime setText:lbString];
        [spRefresh startAnimating];
        
        [UIView commitAnimations];
    }
    
}


// 새로고침을 완료했을 때 호출할 Public 메소드
// 새로고침이 완료되어 해당 메소드를 호출 했을 때 1초간의 텀을 줌
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



#pragma mark
#pragma ViewController Memory Mangements

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {   
        [self.tableView setRowHeight:REFRESH_TABLEVIEW_DEFAULT_ROW];
    }
    return self;
}


#pragma mark
#pragma View lifecycle

- (void)loadView
{
    [super loadView];
   MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isLogin) {
		IntroViewController *loginView = [[IntroViewController alloc] init];
		UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginView];
		navi.navigationBar.tintColor= [UIColor grayColor];
		[navi setNavigationBarHidden:TRUE];
		[self presentViewController:navi animated:NO completion:nil];

	}
    [self performSelector:@selector(_initializeRefreshViewOnTableViewTop)];
    //[self performSelector:@selector(_initializeRefreshViewOnTableViewTail)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshTime = [[self performSelector:@selector(_getCurrentStringTime)] copy];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
}






#pragma mark
#pragma ScrollView Delegate

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


// 테이블뷰의 드래깅이 끝났을 때 호출
// 테이블뷰가 현재 새로고침 중이라면 무시
// 테이블뷰의 헤더부분이 현재 사용자에게 보여지고 있다면 새로고침 시작
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
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


// 테이블뷰의 스크롤이 진행될 때 호출되는 메소드
// 헤더의 화살표, 시간을 변경
// 현재 새로고침 중이라면 출력의 변화 없음
// 현재 사용자의 드래깅이 이어지고 있고, 테이블뷰 오프셋 Y를 모니터링하면서 출력할 내용 변경 함
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    //NSLog(@"scrollOffsetY : %f",scrollOffsetY);
    if(isRefresh)
    {
        if(scrollOffsetY > 0)
        {
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
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



@end