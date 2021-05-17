//
//  FontSettingViewController.h
//  mFinity
//
//  Created by Park on 2014. 4. 2..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"

@interface FontSettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
    MFinityAppDelegate *appDelegate;
}

@end
