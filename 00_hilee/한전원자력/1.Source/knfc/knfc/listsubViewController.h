//
//  listsubViewController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 21..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface listsubViewController : UIViewController {
    UITableView *ilstView;
    NSMutableArray *DataArray;
    NSString *stype;
}
@property (nonatomic, retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) NSMutableArray *DataArray;
@property (nonatomic, retain) NSString *stype;

- (IBAction)btnbackPress:(id)sender;

@end
