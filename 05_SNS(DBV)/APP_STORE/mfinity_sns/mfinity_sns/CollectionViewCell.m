//
//  CollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImageButton.layer.cornerRadius = self.userImageButton.frame.size.width/2;
    self.userImageButton.clipsToBounds = YES;
    self.userImageButton.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageButton.backgroundColor = [UIColor clearColor];
    self.userImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImageButton.layer.borderWidth = 0.3;
    
    self.fileView.layer.cornerRadius = self.fileView.frame.size.width/45;
    self.fileView.clipsToBounds = YES;
    [self.fileView.layer setBorderWidth:0.5];
    [self.fileView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.fileView setBackgroundColor:[UIColor clearColor]];
}

@end
