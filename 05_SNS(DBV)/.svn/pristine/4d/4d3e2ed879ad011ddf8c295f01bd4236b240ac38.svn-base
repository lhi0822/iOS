//
//  ChatToastView.m
//  mfinity_sns
//
//  Created by hilee on 2017. 12. 20..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatToastView.h"

@implementation ChatToastView

- (id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        //self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        //self.backgroundColor = [UIColor clearColor];
        
        //[[NSBundle mainBundle] loadNibNamed:@"ChatToastView" owner:self options:nil];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imgView.layer.cornerRadius = self.imgView.frame.size.width/2;
    self.imgView.clipsToBounds = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.backgroundColor = [UIColor clearColor];
    self.imgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imgView.layer.borderWidth = 0.3;
}

@end
