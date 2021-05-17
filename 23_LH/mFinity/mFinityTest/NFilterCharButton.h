//
//  NFIlterCharButton.h
//  nFilter
//
//  Created by bhchae on 2016. 7. 5..
//  Copyright © 2016년 bhchae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFilterCharButton : UIButton

@property (nonatomic, strong) UILabel *lbText;
@property (nonatomic, strong) UILabel *lbSmallText;
@property (nonatomic, assign) BOOL showSmallText;
@property (nonatomic, strong) NSString *keyValue;

- (void)hideLabel:(BOOL)hidden;
@end
