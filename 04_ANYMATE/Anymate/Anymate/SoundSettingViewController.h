//
//  SoundSettingViewController.h
//  Anymate
//
//  Created by Jun HyungPark on 2015. 4. 23..
//  Copyright (c) 2015년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>{
     IBOutlet UITableView *_tableView;
}

@end
