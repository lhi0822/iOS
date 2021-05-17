//
//  MFSignPadViewController.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 8. 23..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MFLineDrawView.h"
//#import "UIViewController+KNSemiModal.h"
@protocol MFSignPadViewDelegate;

@interface MFSignPadViewController : UIViewController{
    MFLineDrawView *drawScreen;
}
@property (assign, nonatomic) id <MFSignPadViewDelegate> delegate;
@property (nonatomic, weak)IBOutlet UIView *signView;
@property (nonatomic, strong)NSString *userSpecific;
@property (nonatomic, strong)NSString *callbackFunc;

-(IBAction)clearButtonClick:(id)sender;
-(IBAction)saveButtonClick:(id)sender;
-(IBAction)cancelButtonClick:(id)sender;
@end

@protocol MFSignPadViewDelegate <NSObject>
@required
-(void)returnSignFilePath:(NSString *)filePath;

@end
