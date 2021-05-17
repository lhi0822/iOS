//
//  PopoverViewController.h
//  Anymate
//
//  Created by Kyeong In Park on 13. 1. 4..
//  Copyright (c) 2013년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,NSURLConnectionDataDelegate,UINavigationBarDelegate>{
    IBOutlet UITableView *_tableView;
    NSArray *tableList;
    NSString *returnString;
    IBOutlet UINavigationBar *naviBar;
}

@end
