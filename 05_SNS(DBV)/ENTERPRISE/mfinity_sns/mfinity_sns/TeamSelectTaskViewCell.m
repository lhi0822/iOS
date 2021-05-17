//
//  TeamSelectTaskViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 19..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TeamSelectTaskViewCell.h"
#import "MFUtil.h"

@implementation TeamSelectTaskViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImgButton.layer.cornerRadius = self.userImgButton.frame.size.width/2;
    self.userImgButton.clipsToBounds = YES;
    self.userImgButton.contentMode = UIViewContentModeScaleAspectFill;
    self.userImgButton.backgroundColor = [UIColor clearColor];
    self.userImgButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImgButton.layer.borderWidth = 0.3;
    
    self.projectView.layer.cornerRadius = self.projectView.frame.size.width/45;
    self.projectView.clipsToBounds = YES;
    [self.projectView.layer setBorderWidth:0.5];
    [self.projectView.layer setBorderColor:[[MFUtil myRGBfromHex:@"CECFD0"] CGColor]];
    self.projectView.backgroundColor = [MFUtil myRGBfromHex:@"F4F5F6"];
    
    self.statusView.backgroundColor = [UIColor clearColor];
    self.userView.backgroundColor = [UIColor clearColor];
    self.proceedView.backgroundColor = [UIColor clearColor];
    self.bottomView.backgroundColor = [UIColor clearColor];
    
    [self initRoundedFatProgressBar];
}

- (void)initRoundedFatProgressBar
{
    self.ProgressView.progressStretch          = NO;
    self.ProgressView.progressTintColor       = [MFUtil myRGBfromHex:@"4DB6DC"];
    self.ProgressView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.ProgressView.behavior                 = YLProgressBarBehaviorIndeterminate;
    self.ProgressView.trackTintColor = [MFUtil myRGBfromHex:@"CECFD0"];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
