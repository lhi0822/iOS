//
//  ChatSendVideoCell.h
//  mfinity_sns
//
//  Created by hilee on 29/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13ProgressViewRing.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatSendVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateContainer;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgMessage;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UILabel *readCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *failButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet M13ProgressViewRing *compressView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerConstraint;


@end

NS_ASSUME_NONNULL_END
