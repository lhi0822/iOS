//
//  PostOrderModifyViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 10..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostOrderModifyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *postDic;
@property (strong, nonatomic) NSArray *contentArr;
@property (nonatomic, assign) BOOL isEdit;

@end
