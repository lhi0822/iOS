//
//  MyTabViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 11. 27..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tabArr;

@property (strong, nonatomic) NSMutableArray *tabTitleArr;
@property (strong, nonatomic) NSMutableArray *tabImgArr;

@end
