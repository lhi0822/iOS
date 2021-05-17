//
//  BoardTypeViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 3..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardTypeViewCell : UITableViewCell
    
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
    
@end
