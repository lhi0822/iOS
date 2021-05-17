//
//  TaskDetailCollectionViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"
#import "MFTextView.h"

@interface TaskDetailCollectionViewCell : UICollectionViewCell

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

@property (strong, nonatomic) IBOutlet UIView *refUserView;
@property (strong, nonatomic) IBOutlet UIButton *refUserBtn;
@property (strong, nonatomic) IBOutlet UILabel *refUserLbl;
@property (strong, nonatomic) IBOutlet UILabel *refUserLine;


@property (strong, nonatomic) IBOutlet UIView *proceedView;
@property (strong, nonatomic) IBOutlet UIButton *proceedBtn;
//@property (strong, nonatomic) IBOutlet UIProgressView *proceedBar;
@property (strong, nonatomic) IBOutlet UILabel *proceedLine;
@property (strong, nonatomic) IBOutlet YLProgressBar *ProgressView;

@property (strong, nonatomic) IBOutlet UIView *descView;
@property (strong, nonatomic) IBOutlet UIButton *descBtn;
@property (strong, nonatomic) IBOutlet UILabel *descLine;
//@property (strong, nonatomic) IBOutlet UITextView *descTxtView;
@property (strong, nonatomic) IBOutlet MFTextView *descTxtView;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@end
