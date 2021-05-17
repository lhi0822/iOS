//
//  NoticeCell.h
//  EzSmart
//
//  Created by mac on 11. 10. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoticeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;


@end
