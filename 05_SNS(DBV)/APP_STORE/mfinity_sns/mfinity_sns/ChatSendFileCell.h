//
//  ChatSendFileCell.h
//  mfinity_sns
//
//  Created by hilee on 15/03/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatSendFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *dateContainer;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (strong, nonatomic) IBOutlet UIImageView* fileIcon;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIView *fileContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerConstraint;

@end

NS_ASSUME_NONNULL_END
