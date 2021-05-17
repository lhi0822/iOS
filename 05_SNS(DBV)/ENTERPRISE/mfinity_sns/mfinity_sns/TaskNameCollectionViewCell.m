//
//  TaskNameCollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskNameCollectionViewCell.h"

@implementation TaskNameCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.profileImageButton.layer.cornerRadius = self.profileImageButton.frame.size.width/2;
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageButton.backgroundColor = [UIColor clearColor];
    self.profileImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImageButton.layer.borderWidth = 0.3;
}

@end
