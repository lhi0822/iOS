//
//  VideoTableViewCell.h
//  mfinity_sns
//
//  Created by hilee on 14/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13ProgressViewRing.h"
//#import "SDAVAssetExportSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoTableViewCell : UITableViewCell
///<SDAVAssetExportSessionDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *videoView;
@property (strong, nonatomic) IBOutlet UIView *videoTmpView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet M13ProgressViewRing *compressView;

@end

NS_ASSUME_NONNULL_END
