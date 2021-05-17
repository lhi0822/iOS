//
//  TaskInfoTableViewCell.m
//  mfinity_sns
//
//  Created by hilee on 22/11/2018.
//  Copyright © 2018 com.dbvalley. All rights reserved.
//

#import "TaskInfoTableViewCell.h"

@implementation TaskInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //[self.slider setUserInteractionEnabled:YES];
    //[self.slider setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sliderValueChanged:(id)sender {
    int value = self.slider.value;
    
    [self.arrowBtn setTitle:[NSString stringWithFormat:@"%d%%", ((int)((value + 2.5) / 5) * 5)] forState:UIControlStateNormal];
    [self.delegate proceedValChange:[NSString stringWithFormat:@"%d", ((int)((value + 2.5) / 5) * 5)]];
}

@end
