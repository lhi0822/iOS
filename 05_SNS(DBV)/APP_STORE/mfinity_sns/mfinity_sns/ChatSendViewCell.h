//
//  ChatSendViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"
#import "TTTAttributedLabel.h"

@interface ChatSendViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UITextView *msgContent;
@property(nonatomic, weak) IBOutlet UIImageView *bubbleImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateLabelConstraint;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *imgMessage;
@property (strong, nonatomic) IBOutlet UIButton *failButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgContentWidth;
@property (strong, nonatomic) IBOutlet UILabel *readCntLabel;

//@property (strong, nonatomic) IBOutlet MFTextView *msgContentView;
//@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *msgLabel;

@property (strong, nonatomic) IBOutlet UIView *videoContainer;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end
