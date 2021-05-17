//
//  PostModifyTextCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 16..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostModifyTextCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *txtLabel;
@property (strong, nonatomic) IBOutlet UILabel *tmpLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *fileButton;
@property (strong, nonatomic) IBOutlet UIView *videoContainer;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textLabelConstraint;

@end
