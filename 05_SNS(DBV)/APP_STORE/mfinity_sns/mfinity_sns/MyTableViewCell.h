//
//  MyTableViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 5. 24..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UIButton *editIcon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editWidthConstraint;

@end
