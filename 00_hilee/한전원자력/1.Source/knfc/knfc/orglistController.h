//
//  orglistController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface orglistController : UIViewController {
    UIButton *btnfind;
    UITextField *txtfind;
    UITableView *listView;
    NSMutableArray *DataArray;
    NSString *sfind;
    int currentpage, totalpage;
    BOOL isLoaing;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) NSString *sfind;
@property (nonatomic, retain) IBOutlet UIButton *btnfind;
@property (nonatomic, retain) IBOutlet UITextField *txtfind;
@property (nonatomic, retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) NSMutableArray *DataArray;

- (IBAction)btnfindPress:(id)sender;
- (IBAction)btnbackPress:(id)sender;
- (IBAction)btnhomePress:(id)sender;
- (void)loadData;

@end
