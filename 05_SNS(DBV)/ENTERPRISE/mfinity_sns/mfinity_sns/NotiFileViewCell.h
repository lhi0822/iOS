//
//  NotiFileViewCell.h
//  mfinity_sns
//
//  Created by hilee on 14/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotiFileViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *fileDate;
@property (strong, nonatomic) IBOutlet UIImageView *fileUserImg;
@property (strong, nonatomic) IBOutlet UILabel *fileUserNm;
@property (strong, nonatomic) IBOutlet UIView *notiFileView;
@property (strong, nonatomic) IBOutlet UIView *notiFileTitleView;
@property (strong, nonatomic) IBOutlet UIButton *fileTitleBtn;
@property (strong, nonatomic) IBOutlet UIImageView *fileIcon;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIView *fileContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileDateConstraint;

@end

