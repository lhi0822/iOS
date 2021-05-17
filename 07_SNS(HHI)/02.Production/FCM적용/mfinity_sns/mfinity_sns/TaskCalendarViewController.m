//
//  TaskCalendarViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 20..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskCalendarViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFUtil.h"
#import "AppDelegate.h"

@interface TaskCalendarViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation TaskCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.naviBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.naviBar.tintColor = [UIColor whiteColor];
    
    UIButton *moreButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton1 setTitle:NSLocalizedString(@"close", @"close") forState:UIControlStateNormal];
    [moreButton1 addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [moreButton1 setFrame:CGRectMake(0, 0, 40,30)];
    self.naviItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:moreButton1];
    
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        self.calendarHeightConstraint.constant = 400;
    }
    
    self.calendar.accessibilityIdentifier = @"calendar";
    
    self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *locale = [NSLocale currentLocale];
    
    self.dateFormatter1 = [[NSDateFormatter alloc] init];
    self.dateFormatter1.locale = locale;
    self.dateFormatter1.dateFormat = @"yyyy/MM/dd";
    
    self.dateFormatter2 = [[NSDateFormatter alloc] init];
    self.dateFormatter2.locale = locale;
    self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
    
    self.calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesUpperCase;
}

- (void)backClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeTaskDate" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FSCalendarDataSource
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter1 dateFromString:@"1970/01/01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter1 dateFromString:@"2099/12/31"];
}

#pragma mark - FSCalendarDelegate
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    BOOL shouldSelect = ![_datesShouldNotBeSelected containsObject:[self.dateFormatter1 stringFromDate:date]];
    if (!shouldSelect) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FSCalendar" message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[self.dateFormatter1 stringFromDate:date]] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
//        NSLog(@"Should select date %@",[self.dateFormatter1 stringFromDate:date]);
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
//    NSLog(@"did select date %@",[self.dateFormatter1 stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    
    NSDictionary *dic = [NSDictionary dictionary];
    NSString *valueStr = [self.dateFormatter1 stringFromDate:date];
    
    if(_dateType==4){
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TASK_START_DATE", @"TYPE", valueStr, @"TASK_START_DATE", nil];
    } else if(_dateType==5){
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TASK_END_DATE", @"TYPE", valueStr, @"TASK_END_DATE", nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeTaskDate" object:nil userInfo:dic];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
//    NSLog(@"did change to page %@",[self.dateFormatter1 stringFromDate:calendar.currentPage]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date{
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -2);
    }
    return CGPointZero;
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date{
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -10);
    }
    return CGPointZero;
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date{
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return @[[UIColor whiteColor]];
    }
    return nil;
}


@end
