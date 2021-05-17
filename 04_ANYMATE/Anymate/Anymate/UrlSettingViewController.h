//
//  SettingViewController.h
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 26..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UrlSettingViewController : UIViewController<NSURLConnectionDataDelegate, UITextFieldDelegate>{
    
    IBOutlet UITextField *urlField;
    IBOutlet UITextField *portField;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *confirm;
    IBOutlet UIButton *cancel;
    IBOutlet UIImageView *logoView;
    NSDictionary *returnDic;
    
    CGRect urlFieldRect;
    CGRect portFieldRect;
    CGRect confirmRect;
    CGRect cancelRect;
}
-(IBAction)endEditing:(id)sender;
-(IBAction)confirm:(id)sender;
-(IBAction)cancel:(id)sender;
@property (nonatomic, retain)NSString *gwUrl;
@property (nonatomic, retain)NSDictionary *returnDic;
@end
