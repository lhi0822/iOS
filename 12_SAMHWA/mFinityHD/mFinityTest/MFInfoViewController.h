//
//  InfoViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
@interface MFInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_imageView;
    MFinityAppDelegate *appDelegate;
}

@end
