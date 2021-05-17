//
//  MFPostCommentCell.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 29..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFPostCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *commentView;

@end
