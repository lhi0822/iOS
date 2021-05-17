//
//  SearchChatViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 28..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "SearchChatViewController.h"

@interface SearchChatViewController ()

@end

@implementation SearchChatViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchResultsUpdater = self;
        self.delegate = self;
        self.searchBar.delegate = self;
        
        self.hidesNavigationBarDuringPresentation = NO;
        self.dimsBackgroundDuringPresentation = YES;
        
        self.navigationItem.titleView = self.searchBar;
        self.definesPresentationContext = YES;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
