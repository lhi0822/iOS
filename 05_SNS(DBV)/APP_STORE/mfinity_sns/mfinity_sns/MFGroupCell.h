//
//  MFGroupCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFGroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *snsImageView;
@property (weak, nonatomic) IBOutlet UILabel *snsName;
@property (strong, nonatomic) IBOutlet UILabel *snsDesc;
@property (strong, nonatomic) IBOutlet UIButton *leaderBtn;
@property (strong, nonatomic) IBOutlet UIButton *memberBtn;
@property (strong, nonatomic) IBOutlet UIButton *inviteBtn;
@property (strong, nonatomic) IBOutlet UIButton *requestBtn;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UIImageView *statusBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *requestBtnLeftConstraint;

@end
