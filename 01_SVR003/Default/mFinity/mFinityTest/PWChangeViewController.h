//
//  PWChangeViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PWChangeViewController : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate>{
    IBOutlet UITextField *currentPW;
	IBOutlet UITextField *_newPWD;
	IBOutlet UITextField *checkPW;
	IBOutlet UILabel *label1;
	IBOutlet UILabel *label2;
	IBOutlet UILabel *label3;
    IBOutlet UIButton *button;
	
	NSString			 *currentKey;
	NSXMLParser				*xmlParser;
	IBOutlet UIImageView	*imageView;
	NSMutableData		 *receiveData;

    NSString *encrytNewPW;
}
@property (nonatomic, assign)BOOL isOffLine;
-(IBAction) PassWordChange;
//-(IBAction) textFieldDoneEditing:(id)sender;
-(void) userCheck:(NSString *)result;
@end
