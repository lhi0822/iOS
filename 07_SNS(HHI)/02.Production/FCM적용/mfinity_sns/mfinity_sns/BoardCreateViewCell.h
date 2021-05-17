//
//  BoardCreateViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 3..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardCreateViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editBtnConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editBtnSpaceConstraint;

@end
