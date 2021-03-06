//
//  ChatReceiveFileCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 11..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatReceiveFileCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *fUserName;
@property (strong, nonatomic) IBOutlet UIImageView *fAvatarImage;
//@property (strong, nonatomic) IBOutlet UITextView *fMsgContent;
@property (strong, nonatomic) IBOutlet UIImageView *fBubbleImage;
@property (strong, nonatomic) IBOutlet UILabel *fTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *fDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *fMsgLabel;
@property (strong, nonatomic) IBOutlet UILabel *fReadLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fDateLabelConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fAvatarImageConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fUserNameConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fMsgContentConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fBubbleImgConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fTimeLabelConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fMsgContentWidth;

@property (strong, nonatomic) IBOutlet UIImageView* fFileIcon;
@property (strong, nonatomic) IBOutlet UIView *fFileContainer;

@end
