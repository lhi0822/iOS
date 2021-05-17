//
//  NotiLongChatViewCell.h
//  mfinity_sns
//
//  Created by hilee on 14/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotiLongChatViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *longDate;
@property (strong, nonatomic) IBOutlet UIImageView *longUserImg;
@property (strong, nonatomic) IBOutlet UILabel *longUserNm;
@property (strong, nonatomic) IBOutlet UIView *longNotiView;
@property (strong, nonatomic) IBOutlet UIView *longNotiTitleView;
@property (strong, nonatomic) IBOutlet UIButton *titleBtn;
@property (strong, nonatomic) IBOutlet UILabel *contentLbl;
@property (strong, nonatomic) IBOutlet UIButton *moreBtn;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *longDateConstraint;

@end

NS_ASSUME_NONNULL_END
