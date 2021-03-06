//
//  MFPostNameCell.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 26..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFPostNameCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
