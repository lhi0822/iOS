//
//  NewsFeedViewCell.h
//  mfinity_sns
//
//  Created by hilee on 31/01/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface NewsFeedViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
//@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *userImageButton;
@property (strong, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;

@property (strong, nonatomic) IBOutlet UIView *videoTmpView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UIView *fileView;
@property (strong, nonatomic) IBOutlet UIImageView *fileIcon;
@property (strong, nonatomic) IBOutlet UILabel *fileName;

@property (strong, nonatomic) IBOutlet UILabel *commCntLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eyeImg;
@property (strong, nonatomic) IBOutlet UILabel *viewCntLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewCntConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileViewHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoViewConstraint;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property BOOL cellIsLoad;

@end

