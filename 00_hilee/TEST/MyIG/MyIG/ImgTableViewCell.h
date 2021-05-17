//
//  ImgTableViewCell.h
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property BOOL finishReload;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstraint;

@end

NS_ASSUME_NONNULL_END
