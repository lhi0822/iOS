//
//  TextLabelTableViewCell.h
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextLabelTableViewCell : UITableViewCell
//@property (strong, nonatomic) IBOutlet UILabel *txtLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *txtLabel;

@end

NS_ASSUME_NONNULL_END
