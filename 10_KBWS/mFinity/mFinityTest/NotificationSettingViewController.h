//
//  NotificationSettingViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>{
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_imageView;
}

@end
