//
//  SearchChatListViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 28..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchChatListViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *chatImage;
@property (strong, nonatomic) IBOutlet UILabel *chatName;
@property (strong, nonatomic) IBOutlet UILabel *chatContent;
@property (strong, nonatomic) IBOutlet UILabel *userCount;
@property (strong, nonatomic) IBOutlet UIImageView *chatAlarm;
@property (strong, nonatomic) IBOutlet UILabel *chatDate;
@property (strong, nonatomic) IBOutlet UILabel *nChatLabel;
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatNameWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userCountWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nChatWidth;

@end
