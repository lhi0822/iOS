//
//  TaskHistoryHeaderViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskHistoryHeaderViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *topSpaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;

@end
