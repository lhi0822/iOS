//
//  PostCommViewCell.h
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13ProgressViewRing.h"

@interface PostCommViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lineLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *commImgView;
@property (strong, nonatomic) IBOutlet UIView *commMediaView;
@property (strong, nonatomic) IBOutlet UIView *commFileView;
@property (strong, nonatomic) IBOutlet UIButton *commFileBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileBtnConstraint;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UITextView *commTxtView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commTxtConstraint;
@property (weak, nonatomic) IBOutlet M13ProgressViewRing *compressView;

@end
