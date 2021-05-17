//
//  CustomHeader.h
//  ARSegmentPager
//
//  Created by August on 15/5/20.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageControllerHeaderProtocol.h"

@interface CustomHeader : UIView<ARSegmentPageControllerHeaderProtocol>

@property (strong, nonatomic) IBOutlet UIImageView *profileBgImgView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton1;
@property (strong, nonatomic) IBOutlet UIButton *menuButton2;
@property (strong, nonatomic) IBOutlet UIButton *menuButton3;

- (void)updateHeadPhotoWithTopInset:(CGFloat)inset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeButtonTopHeight;

@end
