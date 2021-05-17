//
//  ChatSendTextCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"
#import "TTTAttributedLabel.h"

@interface ChatSendTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateContainer;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property(nonatomic, weak) IBOutlet UIImageView *bubbleImage;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *readCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *failButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateContainerConstraint;

@end
