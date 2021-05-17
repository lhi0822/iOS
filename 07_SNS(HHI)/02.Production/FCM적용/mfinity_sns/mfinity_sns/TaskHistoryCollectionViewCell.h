//
//  TaskHistoryCollectionViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"

@interface TaskHistoryCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLine;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgLabelConstraint;
@property (strong, nonatomic) IBOutlet MFTextView *msgTextView;

@end
