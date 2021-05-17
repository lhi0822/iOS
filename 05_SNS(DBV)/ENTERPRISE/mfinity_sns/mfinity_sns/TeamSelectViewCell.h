//
//  TeamSelectViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 9. 6..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamSelectViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *userImageButton;
@property (strong, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UIView *videoTmpView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIView *fileView;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UIImageView *fileIcon;

@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCnt;
@property (strong, nonatomic) IBOutlet UIImageView *eyeIcon;
@property (strong, nonatomic) IBOutlet UILabel *readCnt;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *readCntConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileViewHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgViewHeight;

@end
