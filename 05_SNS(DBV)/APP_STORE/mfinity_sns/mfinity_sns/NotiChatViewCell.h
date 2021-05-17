//
//  NotiChatViewCell.h
//  mfinity_sns
//
//  Created by hilee on 10/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface NotiChatViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *notiDate;
@property (strong, nonatomic) IBOutlet UIImageView *notiUserImg;
@property (strong, nonatomic) IBOutlet UILabel *notiUserNm;
@property (strong, nonatomic) IBOutlet UIView *notiView;
@property (strong, nonatomic) IBOutlet UIView *notiTitleView;
@property (strong, nonatomic) IBOutlet UIButton *titleBtn;
@property (strong, nonatomic) IBOutlet UIImageView *notiImgView;
//@property (strong, nonatomic) IBOutlet UILabel *notiContent;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *notiContent;
@property (strong, nonatomic) IBOutlet UILabel *notiTime;
@property (strong, nonatomic) IBOutlet UIView *videoContainer;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiDateConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiContentConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiImgViewConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiImgTrailing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notiViewTrailing;

@end

