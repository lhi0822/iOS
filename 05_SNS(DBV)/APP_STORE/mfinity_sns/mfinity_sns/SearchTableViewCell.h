//
//  SearchTableViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *userImageButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UIView *fileView;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UIImageView *fileIcon;

@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCnt;
@property (strong, nonatomic) IBOutlet UIImageView *eyeIcon;
@property (strong, nonatomic) IBOutlet UILabel *readCnt;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *readCntConstraint;

@end
