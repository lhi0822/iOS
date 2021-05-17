//
//  listViewController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface listViewController : UIViewController {
    UITableView *listView;
    NSMutableArray *DataArray;
    NSString *stype;
    int currentpage, totalpage;
}
@property (nonatomic, retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) NSMutableArray *DataArray;
@property (nonatomic, retain) NSString *stype;

- (IBAction)btnbackPress:(id)sender;
- (IBAction)btnhomePress:(id)sender;
- (void)loadData;

@end
