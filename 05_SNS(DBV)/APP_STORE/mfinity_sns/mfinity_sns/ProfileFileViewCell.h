//
//  ProfileFileViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2017. 10. 19..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileFileViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIView *labelView;
@property (strong, nonatomic) IBOutlet UILabel *fileName;

@property (strong, nonatomic) IBOutlet UIView *smallView;
@property (strong, nonatomic) IBOutlet UIImageView *fileImgView;

@end
