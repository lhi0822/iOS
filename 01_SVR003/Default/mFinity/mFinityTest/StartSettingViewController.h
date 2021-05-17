//
//  StartSettingViewController.h
//  mFinity
//
//  Created by Park on 13. 9. 10..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartSettingViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UIAlertViewDelegate>{
    
    IBOutlet UIToolbar *_toolBar;
    IBOutlet UIBarButtonItem *_button;
    IBOutlet UIBarButtonItem *_button2;
    IBOutlet UIPickerView *_pickerView;
}
-(IBAction)confirm:(id)sender;
-(IBAction)cancel:(id)sender;
@end
