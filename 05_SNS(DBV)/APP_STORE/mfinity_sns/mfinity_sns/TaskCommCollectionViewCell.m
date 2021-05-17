//
//  TaskCommCollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskCommCollectionViewCell.h"

@implementation TaskCommCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImg.layer.cornerRadius = self.userImg.frame.size.width/2;
    self.userImg.clipsToBounds = YES;
    self.userImg.contentMode = UIViewContentModeScaleAspectFill;
    self.userImg.backgroundColor = [UIColor clearColor];
    self.userImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImg.layer.borderWidth = 0.3;
}

@end
