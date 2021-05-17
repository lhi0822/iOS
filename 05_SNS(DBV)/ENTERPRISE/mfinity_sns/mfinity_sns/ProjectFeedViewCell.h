//
//  ProjectFeedViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2020/09/22.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"

@interface ProjectFeedViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *teamName;
@property (strong, nonatomic) IBOutlet UILabel *midLabel;
@property (strong, nonatomic) IBOutlet UIButton *userImgBtn;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *writeDate;

@property (strong, nonatomic) IBOutlet UIView *projectView;
@property (strong, nonatomic) IBOutlet UIImageView *projectIcon;
@property (strong, nonatomic) IBOutlet UILabel *projectTitle;
@property (strong, nonatomic) IBOutlet UILabel *projectDate;

@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;
@property (strong, nonatomic) IBOutlet UILabel *statusLine;

@property (strong, nonatomic) IBOutlet UIView *userView;
@property (strong, nonatomic) IBOutlet UIButton *userBtn;
@property (strong, nonatomic) IBOutlet UILabel *userLbl;
@property (strong, nonatomic) IBOutlet UILabel *userLine;

@property (strong, nonatomic) IBOutlet UIView *proceedView;
@property (strong, nonatomic) IBOutlet UIButton *proceedBtn;
//@property (strong, nonatomic) IBOutlet UIProgressView *proceedBar;
@property (strong, nonatomic) IBOutlet UILabel *proceedLine;
@property (strong, nonatomic) IBOutlet YLProgressBar *ProgressView;

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *bottomLine;
@property (strong, nonatomic) IBOutlet UILabel *commCnt;
@property (strong, nonatomic) IBOutlet UIImageView *viewIcon;
@property (strong, nonatomic) IBOutlet UILabel *viewCnt;

@end

