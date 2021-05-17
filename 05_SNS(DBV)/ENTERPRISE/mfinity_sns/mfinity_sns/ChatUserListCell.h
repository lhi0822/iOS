//
//  ChatUserListCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatUserListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *arrowButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UILabel *nodeNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UIButton *leaderBtn;
@property (strong, nonatomic) IBOutlet UILabel *unInstallLbl;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;


@end
