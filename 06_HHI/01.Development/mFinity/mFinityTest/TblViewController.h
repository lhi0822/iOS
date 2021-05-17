//
//  TblViewController.h
//  HISImageLib
//
//  Created by Handy HIS on 13. 4. 9..
//  Copyright (c) 2013년 HandyHIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HISImageViewer;

@interface TblViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tblView;
    NSMutableDictionary* diclayerList;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deallocDictionary;
- (void)reloadTableCells;


//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@property(nonatomic,retain) IBOutlet NSMutableDictionary *diclayerList;
//@property(nonatomic) SEL accessoryAction;


@end
