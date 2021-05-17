//
//  TaskDetailCollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskDetailCollectionViewCell.h"
#import "MFUtil.h"

@implementation TaskDetailCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initRoundedFatProgressBar];
}

- (void)initRoundedFatProgressBar {
    self.ProgressView.progressStretch          = NO;
    self.ProgressView.progressTintColor       = [MFUtil myRGBfromHex:@"4DB6DC"];
    self.ProgressView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.ProgressView.behavior                 = YLProgressBarBehaviorIndeterminate;
    self.ProgressView.trackTintColor = [MFUtil myRGBfromHex:@"CECFD0"];
}

@end
