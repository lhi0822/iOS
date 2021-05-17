//
//  ChatListViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface ChatListViewCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *chatName;
@property (strong, nonatomic) IBOutlet UILabel *chatContent;
@property (strong, nonatomic) IBOutlet UIImageView *chatImage;
@property (strong, nonatomic) IBOutlet UILabel *userCount;
@property (strong, nonatomic) IBOutlet UIImageView *chatAlarm;
@property (strong, nonatomic) IBOutlet UILabel *chatDate;
@property (strong, nonatomic) IBOutlet UILabel *nChatLabel;
@property (strong, nonatomic) IBOutlet UILabel *myLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatNameWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userCountWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nChatWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatDateWidth;

//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameCountConstraint;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *alarmDateConstraint;

@end
