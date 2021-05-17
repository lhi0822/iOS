//
//  CreateTaskFileCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 15..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "CreateTaskFileCell.h"
#import "AppDelegate.h"

@implementation CreateTaskFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.deleteBtn.layer.cornerRadius = self.deleteBtn.frame.size.width/2;
    self.deleteBtn.clipsToBounds = YES;
    self.deleteBtn.contentMode = UIViewContentModeScaleAspectFill;
    self.deleteBtn.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.deleteBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.deleteBtn.layer.borderWidth = 0.3;
}

@end
