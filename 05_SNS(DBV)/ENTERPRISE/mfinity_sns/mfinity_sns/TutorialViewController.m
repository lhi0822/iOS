//
//  TutorialViewController.m
//  mfinity_sns
//
//  Created by hilee on 27/03/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "TutorialViewController.h"
#import "MFUtil.h"

#define VIEW_COUNT 4

@interface TutorialViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TutorialViewController {
    AppDelegate *appDelegate;
    UIPageControl *pageControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"tutorial", @"tutorial")];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(leftSideMenuButtonPressed:)];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    
    [_scrollView setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width*VIEW_COUNT, _scrollView.frame.size.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:_scrollView];
    
    
    pageControl = [[UIPageControl alloc] init];
    
    [pageControl setFrame:CGRectMake((self.view.frame.size.width/2)-(pageControl.frame.size.width/2), _scrollView.frame.origin.y+_scrollView.frame.size.height+10, pageControl.frame.size.width, pageControl.frame.size.height)];
    
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.currentPageIndicatorTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    [self.view addSubview:pageControl];
    
    
    
    //NSArray *tutorialArr = @[[UIImage imageNamed:@"Feed_1066.png"], [UIImage imageNamed:@"Board_1066.png"], [UIImage imageNamed:@"Chat_1066.png"] ,[UIImage imageNamed:@"Mypage_1066.png"]];
    NSArray *tutorialArr = @[[UIImage imageNamed:@"Feed_700.png"], [UIImage imageNamed:@"Board_700.png"], [UIImage imageNamed:@"Chat_700.png"] ,[UIImage imageNamed:@"Mypage_700.png"]];
    
    for (int index=0; index<VIEW_COUNT; index++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(index*self.view.frame.size.width, 0, self.view.frame.size.width, _scrollView.frame.size.height)];
        imgView.image = [tutorialArr objectAtIndex:index];
        //        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_scrollView addSubview:imgView];
    }
}

- (void)leftSideMenuButtonPressed:(id)sender {
    if([[appDelegate.appPrefs objectForKey:@"IS_TUTORIAL"] isEqual:@"YES"]){
        [appDelegate.appPrefs setObject:@"NO" forKey:@"IS_TUTORIAL"];
        [appDelegate.appPrefs synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger currentOffset = scrollView.contentOffset.x;
    NSInteger index = currentOffset / self.view.frame.size.width;
    
    //페이징 스크롤이 완전히 끝나야 페이지 인덱스가 바뀜
//    if (currentOffset % (int)self.view.frame.size.width == 0) {
//        pageControl.currentPage = index;
//    }
    
    //페이지의 경계를 기준으로 가까운 뷰의 인덱스로 바뀜
    currentOffset = scrollView.contentOffset.x/self.view.frame.size.width * 10;
    if (currentOffset%10 <5) {
        index = currentOffset / 10;
    } else{
        index = currentOffset / 10 + 1;
    }
    pageControl.currentPage = index;
}

@end
