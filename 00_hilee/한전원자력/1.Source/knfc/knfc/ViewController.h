//
//  ViewController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 18..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate> {
    UIButton *btnlogout, *btnfind, *btnmore1, *btnmore2, *btnmore3;
    UITextField *txtfind;
    UITableView *listView, *listView1;
    NSMutableArray *DataArray1, *DataArray2;
    UIButton * newbtn1, * newbtn2, * newbtn3, *newbtn4, *newbtn5, *newbtn6;
}
@property (nonatomic, retain) NSMutableArray *DataArray1, *DataArray2;
@property (nonatomic, retain) IBOutlet UIButton *btnlogout, *btnfind, *btnmore1, *btnmore2, *btnmore3;
@property (nonatomic, retain) IBOutlet UITextField *txtfind;
@property (nonatomic, retain) IBOutlet UITableView *listView, *listView1;
@property (nonatomic, retain) IBOutlet UIButton * newbtn1, * newbtn2, * newbtn3, *newbtn4, *newbtn5, *newbtn6 ;
@property (weak, nonatomic) IBOutlet UILabel *listLabel1;
@property (weak, nonatomic) IBOutlet UILabel *listLabel2;
@property (weak, nonatomic) IBOutlet UILabel *listLabel3;

- (IBAction)btnlogoutPress:(id)sender;
- (IBAction)btnfindPress:(id)sender;
- (IBAction)btnmore1Press:(id)sender;
- (IBAction)btnmore2Press:(id)sender;
- (IBAction)btnmore3Press:(id)sender;

- (IBAction)newbtn1Press:(id)sender;
- (IBAction)newbtn2Press:(id)sender;
- (IBAction)newbtn3Press:(id)sender;
- (IBAction)newbtn4Press:(id)sender;
- (IBAction)newbtn5Press:(id)sender;
- (IBAction)newbtn6Press:(id)sender;

- (void)loadData;

@end

