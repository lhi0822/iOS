//
//  NotificationSettingViewCell.h
//  mFinity
//
//  Created by hilee on 2021/05/06.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationSettingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (weak, nonatomic) IBOutlet UISwitch *valueSwitch;

@end

NS_ASSUME_NONNULL_END
