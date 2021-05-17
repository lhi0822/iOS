//
//  UserListCollectionViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 2. 28..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UILabel *userNmLabel;

@end
