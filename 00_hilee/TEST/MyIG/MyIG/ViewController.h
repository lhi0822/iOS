//
//  ViewController.h
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MIURLSession.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <MIURLSessionDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@interface UIImageView (resize)
- (void)imageFromURL:(NSString *)imgUrl completion:(void (^)(UIImage *newImg))completion;
@end

