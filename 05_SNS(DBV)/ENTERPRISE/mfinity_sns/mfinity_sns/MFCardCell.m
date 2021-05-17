//
//  MFCardCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MFCardCell.h"

@implementation MFCardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [self cardSetup];
    [self imageSetup];
}

-(void)cardSetup
{
    
}

-(void)imageSetup
{
    _profileImageButton.layer.cornerRadius = _profileImageButton.frame.size.width/2;
    _profileImageButton.clipsToBounds = YES;
    _profileImageButton.contentMode = UIViewContentModeScaleAspectFit;
    _profileImageButton.backgroundColor = [UIColor whiteColor];
    _profileImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _profileImageButton.layer.borderWidth = 0.3;
}

//- (void)awakeFromNib
//{
//    // Initialization code
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
