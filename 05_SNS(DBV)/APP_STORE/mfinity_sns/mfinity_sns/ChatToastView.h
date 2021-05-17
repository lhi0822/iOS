//
//  ChatToastView.h
//  mfinity_sns
//
//  Created by hilee on 2017. 12. 20..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatToastView : UIView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bottomIcon;
@property (strong, nonatomic) IBOutlet UIButton *bottomBtn;

@end
