//
//  LongChatSendViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 4..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"

@interface LongChatSendViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImg;
@property (strong, nonatomic) IBOutlet UITextView *msgContent;
//@property (strong, nonatomic) IBOutlet MFTextView *msgContent;
@property (strong, nonatomic) IBOutlet UIButton *viewButton;
@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *failButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateLabelConstraint;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;

@end
