//
//  ProjectCollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 9..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "ProjectCollectionViewCell.h"
#import "MFUtil.h"

@implementation ProjectCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImgBtn.layer.cornerRadius = self.userImgBtn.frame.size.width/2;
    self.userImgBtn.clipsToBounds = YES;
    self.userImgBtn.contentMode = UIViewContentModeScaleAspectFill;
    self.userImgBtn.backgroundColor = [UIColor clearColor];
    self.userImgBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImgBtn.layer.borderWidth = 0.3;
    
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
//    self.ProgressView.hideStripes              = YES;
    self.ProgressView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.ProgressView.behavior                 = YLProgressBarBehaviorIndeterminate;
//    self.ProgressView.type               = YLProgressBarTypeFlat;
    self.ProgressView.trackTintColor = [MFUtil myRGBfromHex:@"CECFD0"];
}

@end
