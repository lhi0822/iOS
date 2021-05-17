//
//  DynamicTableViewCell.h
//  DynamicCellHeight
//
//  Created by Timo Josten on 08/07/15.
//  Copyright (c) 2015 mkswap.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"

@interface DynamicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (strong, nonatomic) IBOutlet UIView *labelContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (strong, nonatomic) IBOutlet MFTextView *textView;

@end
