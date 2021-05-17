//
//  MymenuSettingViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"

@interface MymenuSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    IBOutlet UIImageView	*imageView;
	IBOutlet UITableView    *myTableView;
    
    MFinityAppDelegate *appDelegate;
    
    NSMutableData *receiveData;
    NSMutableDictionary *menuNameDictionary;
    NSMutableDictionary *menuNoDictionary;
    NSMutableDictionary *menuCheckDictionary;
    NSMutableDictionary *menuRegDictionary;
    NSString				*paramValue;
	NSString				*urlKind;
	NSString				*menu_name;
}

@end
