//
//  LongChatViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 5..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"
#import "AppDelegate.h"

@interface LongChatViewController : UIViewController <MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *chatNo;

@end
