//
//  LayerNameController.h
//  HISImageLib
//
//  Created by Handy HIS on 13. 6. 12..
//  Copyright (c) 2013년 HandyHIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TblViewController.h"

@interface LayerNameController : UIViewController
{
    
}
@property (retain, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *naviBarItem;

@property(nonatomic,retain) IBOutlet TblViewController *tblController;

@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIButton *okBtn;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;


@end
