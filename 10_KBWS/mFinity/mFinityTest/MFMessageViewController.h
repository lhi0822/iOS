//
//  MFMessageViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 14..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
@interface MFMessageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,HPGrowingTextViewDelegate>{
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;

    UIButton *doneButton;
    UIView *tableInView;
    IBOutlet UIView *containerView;
    HPGrowingTextView *textView;
    NSMutableDictionary *mDic;
    NSMutableArray *array;
}

@end
