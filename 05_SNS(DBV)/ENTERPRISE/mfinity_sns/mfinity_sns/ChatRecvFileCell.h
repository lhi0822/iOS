//
//  ChatRecvFileCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 11..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRecvFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateContainer;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (strong, nonatomic) IBOutlet UIView *fileContainer;
@property (strong, nonatomic) IBOutlet UIImageView* fileIcon;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateContainerConstraint;




@end
