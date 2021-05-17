//
//  ChatRecvImgCell.h
//  mfinity_sns
//
//  Created by hilee on 30/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatRecvImgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateContainer;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIImageView *imgMessage;
@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerConstraint;

@end

NS_ASSUME_NONNULL_END
