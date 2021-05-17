//
//  VideoTableViewCell.m
//  mfinity_sns
//
//  Created by hilee on 14/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "VideoTableViewCell.h"

@implementation VideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)videoCompessToPercent:(float)progress{
//    @try{
//        dispatch_async(dispatch_get_main_queue(), ^{
//          NSLog(@"여기에 찍히는 거지 progress : %f", progress);
//            self.compressView.hidden = NO;
//
////            [self.compressView setPrimaryColor:[MFUtil myRGBfromHex:@"0093D5"]];
//            [self.compressView setPrimaryColor:[MFUtil myRGBfromHex:@"ffffff"]];
//            [self.compressView setProgress:progress animated: YES];
//       });
//
//    } @catch (NSException *exception) {
//       NSLog(@"%s Exception : %@", __func__, exception);
//    }
//}

@end
