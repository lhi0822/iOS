//
//  InfoViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import <MessageUI/MessageUI.h>

@interface MFInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>{
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_imageView;
    MFinityAppDelegate *appDelegate;
}

@end
