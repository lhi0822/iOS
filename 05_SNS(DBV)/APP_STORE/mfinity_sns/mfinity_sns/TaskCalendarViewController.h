//
//  TaskCalendarViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 20..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface TaskCalendarViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (strong, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak  , nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
@property (strong, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *naviItem;


@property (strong, nonatomic) NSArray<NSString *> *datesShouldNotBeSelected;
@property (strong, nonatomic) NSArray<NSString *> *datesWithEvent;

@property (strong, nonatomic) NSCalendar *gregorianCalendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
@property (strong, nonatomic) NSDateFormatter *dateFormatter2;

@property NSInteger dateType;

@end
