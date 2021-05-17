//
//  InfoViewController.h
//  Anymate
//
//  Created by Kyeong In Park on 13. 1. 4..
//  Copyright (c) 2013년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface InfoViewController : UIViewController{
    IBOutlet UILabel *currentVersion2;
    IBOutlet UILabel *currentVersion;
    IBOutlet UILabel *latestVersion;
    IBOutlet UILabel *latestVersion2;
    IBOutlet UIButton *upDateButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *imageView2;
    CGRect currentVersion2Rect;
    CGRect currentVersionRect;
    CGRect latestVersionRect;
    CGRect latestVersion2Rect;
    CGRect upDateButtonRect;
    CGPoint imageView2Center;
    AppDelegate *appDelegate;
}
- (IBAction)upDate:(id)sender;
- (IBAction)close:(id)sender;
@end
