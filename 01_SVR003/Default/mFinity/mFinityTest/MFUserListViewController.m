//
//  MFUserListViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 5..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//
#import "MFinityAppDelegate.h"
#import "MFUserListViewController.h"
#import "CustomSegmentedControl.h"
#import "StringUtil.h"
#import "MFMessageViewController.h"
#define kCellImageViewTag	1001
#define kCellLabelTag		1002
@interface MFUserListViewController (){
    UIImage *selectedImage;
    UIImage *unselectedImage;
}

@end

@implementation MFUserListViewController
const NSInteger EDITING_HORIZONTAL_OFFSET = 35;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.searchDisplayController.searchResultsDelegate = self;
    //Initialize the array.
    searchUserInfoArray = [[NSMutableArray alloc] init];
    //Initialize the copy array.

    //Set the title
    CustomSegmentedControl *editButton = [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"전체주소록",@"부서주소록",nil]
                                                                             offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                              onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                                         offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                          onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                                             fontSize:12];
    
    editButton.momentary = NO;
    editButton.selectedSegmentIndex = 0;
    editButton.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [editButton addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = editButton;
    CustomSegmentedControl *button2;
    button2= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"닫기",nil]
                                                 offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                  onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                             offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                              onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 fontSize:12];
    button2.momentary = YES;
    [button2 addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.leftBarButtonItem=left;
    
    CustomSegmentedControl *button3;
    button3= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"완료",nil]
                                                 offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                  onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                             offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                              onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 fontSize:12];
    button3.momentary = YES;
    [button3 addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button3];
    self.navigationItem.rightBarButtonItem=right;
    
    self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    //Add the search bar
    myTableView.tableHeaderView = _searchBar;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.showsScopeBar = NO;
    selectedImage = [UIImage imageNamed:@"IsSelected.png"];
	unselectedImage = [UIImage imageNamed:@"NotSelected.png"];
    isAll = YES;
    searching = NO;
    letUserSelectRow = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    appDelegate.msgUserInfo = [[NSMutableArray alloc]init];
    NSString *urlString = [NSString stringWithFormat:@"%@/PMsgUserList?comp_no=%@&returnType=JSON",appDelegate.main_url,appDelegate.comp_no];
    //NSString *urlString = @"http://svr001.ezsmart.co.kr:7076/dataservice/PMsgUserList?comp_no=10&returnType=JSON";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (urlCon) {
        receiveData = [[NSMutableData alloc]init];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NavigationButton Click
- (void)segmentButtonClick:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex == 0) {
        myTableView.tableHeaderView = _searchBar;
        //myTableView.tableHeaderView = nil;
        isAll = YES;
    }else if(sender.selectedSegmentIndex == 1){
        isAll = NO;
        //myTableView.tableHeaderView = _searchBar;
        myTableView.tableHeaderView = nil;
    }
    [myTableView reloadData];
}

- (void)leftButtonClick:(UISegmentedControl *)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightButtonClick:(UISegmentedControl *)sender{
    [appDelegate.msgUserInfo removeAllObjects];
    if (isAll) {
       
        for (int i=0; i<[userInfoDictionary count]; i++) {
            NSArray *temp = [userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
            for (int j=1; j<[temp count]; j++) {
                NSDictionary *tempDic = [temp objectAtIndex:j];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                if ([[tempDic objectForKey:@"CHECK"]isEqualToString:@"Y"]) {
                    
                    [dic setObject:[tempDic objectForKey:@"USER_NM"] forKey:@"USER_NM"];
                    [dic setObject:[tempDic objectForKey:@"CUSER_ID"] forKey:@"CUSER_ID"];
                    [appDelegate.msgUserInfo addObject:dic];
                }
            }
        }
        
    }else{
        for (NSString *str in deptInfoDictionary) {
            NSDictionary *temp = [deptInfoDictionary objectForKey:str];
            for(NSString *key in [temp allKeys]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
                NSDictionary *dic = [temp objectForKey:key];
                if ([[dic objectForKey:@"CHECK"]isEqualToString:@"Y"]) {
                    [tempDic setObject:key forKey:@"USER_NM"];
                    [tempDic setObject:[dic objectForKey:@"CUSER_ID"] forKey:@"CUSER_ID"];
                    [appDelegate.msgUserInfo addObject:tempDic];
                }
                
            }
        }
    }
    MFMessageViewController *vc = [[MFMessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Search
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [_searchBar setShowsCancelButton:YES animated:NO];
    for (UIView *subView in _searchBar.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [(UIButton *)subView setTitle:@"목록" forState:UIControlStateNormal];
        }
    }
    [myTableView reloadSectionIndexTitles];
}
-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    //NSLog(@"searchDisplayControllerDidEndSearch");
    searching = NO;
    [searchUserInfoArray removeAllObjects];
    myTableView.scrollEnabled = YES;
    [myTableView reloadSectionIndexTitles];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searching = NO;
    searchBar.text = @"";
    myTableView.scrollEnabled = YES;
    [searchUserInfoArray removeAllObjects];
    
    [myTableView reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsScopeBar = NO;
    searchBar.scopeButtonTitles = nil;
    return YES;
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    theSearchBar.scopeButtonTitles = nil;
    searching = YES;
    letUserSelectRow = NO;
    myTableView.scrollEnabled = NO;
    
    //Add the done button.
    
}
- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    myTableView.scrollEnabled = YES;
    //searching = NO;
    letUserSelectRow = YES;
}
-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    [tableView setMultipleTouchEnabled:YES];
    
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    
    //[copyListOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        searching = YES;
        letUserSelectRow = NO;
        myTableView.scrollEnabled = YES;
        //[self searchTableView];
        [self copyListForSearch];
    }
    else {
        searching = NO;
        letUserSelectRow = YES;
        myTableView.scrollEnabled = NO;
    }
    
    [myTableView reloadData];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    return YES;
}
- (void)copyListForSearch{
    
    NSString *searchText = [_searchBar.text uppercaseString];
    [searchUserInfoArray removeAllObjects];
    
    for (int i=0; i<[userInfoDictionary count]; i++) {
        NSArray *tempArr = [userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
        for (int j=1; j<[tempArr count]; j++) {
            NSDictionary *tempDic = [tempArr objectAtIndex:j];
            NSString *tempString = [[tempDic objectForKey:@"USER_NM"]uppercaseString];
            NSString *tempChosungString = [StringUtil get1stChars:tempString];//초성뽑기
            //NSString *tempCheck = [tempDic objectForKey:@"CHECK"];
            
            NSRange resultRange = [tempString rangeOfString:searchText];//검색 키워드와 기존 데이타 대조 결과
            NSRange resultStringRange = [tempChosungString rangeOfString:searchText];//초성검색 키워드와 기존 데이타 초성 대조 결과
            
            //검색 키워드와 기존 데이타 대조 결과
            if(resultRange.location != NSNotFound){
                ////NSLog(@"tempDic : %@",tempDic);
                [searchUserInfoArray addObject:tempDic];
                
            }
            //초성검색 키워드와 기존 데이타 초성 대조 결과
            else if(resultStringRange.location != NSNotFound){
                [searchUserInfoArray addObject:tempDic];
                
            }
        }
    }
    
    
}

- (NSString *)getUTF8String:(NSString *)korString{
    
    NSArray *chosung = [[NSArray alloc]initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    NSString *textResult = @"";
    
    NSInteger code = [korString characterAtIndex:0];
    if (code >= 44032 && code <= 55203) {
        NSInteger uniCode = code - 44032;
        NSInteger chosungIndex = uniCode / 21 /28;
        textResult = [NSString stringWithFormat:@"%@%@",textResult,[chosung objectAtIndex:chosungIndex]];
    }else{
        textResult = [NSString stringWithFormat:@"%@%@",textResult,[korString substringWithRange:NSMakeRange(0, 1)]];
        textResult = [textResult uppercaseString];
    }
    
    return textResult;
}
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self copyListForSearch];
    //[self searchTableView];
}


#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (isAll) {
        if (searching) {
            return @"";
        }else{
            return [[userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",section]]objectAtIndex:0];
        }
    }else{
        NSArray *arr = [[deptInfoDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
        return [arr objectAtIndex:section];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isAll) {
        if (searching) {
            return 1;
        }else{
            return [userInfoDictionary count];
        }
    }else{
        return [deptInfoDictionary count];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isAll) {
        if (searching){
            return [searchUserInfoArray count];
        }
        else {
            return [[userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",section]]count]-1;
        }
    }else{
        NSArray *arr = [[deptInfoDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
        return [[deptInfoDictionary objectForKey:[arr objectAtIndex:section]] count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const NSInteger IMAGE_SIZE = 20;
    const NSInteger SIDE_PADDING = 5;
    UIImageView *indicator;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotSelected.png"]];
        indicator.tag = kCellImageViewTag;
        indicator.frame =CGRectMake(SIDE_PADDING, (0.5 * tableView.rowHeight) - (0.5 * IMAGE_SIZE), IMAGE_SIZE, IMAGE_SIZE);
        [cell.contentView addSubview:indicator];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(SIDE_PADDING+indicator.frame.size.width+SIDE_PADDING, 1, 200, 40)];
        label.tag = kCellLabelTag;
        [cell.contentView addSubview:label];
    }
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
    if (isAll) {
        if (searching) {
            if ([searchUserInfoArray count]!=0) {
                
                label.text = [[searchUserInfoArray objectAtIndex:indexPath.row] objectForKey:@"USER_NM"];
                
                //UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
                NSString *selected = [[searchUserInfoArray objectAtIndex:indexPath.row] objectForKey:@"CHECK"];
                if ([selected isEqualToString:@"Y"]) {
                    imageView.image = selectedImage;
                }else{
                    imageView.image = unselectedImage;
                }
                [UIView commitAnimations];
            }
        }else{
            for (int i = 0; i<[userInfoDictionary count]; i++) {
                if ([[[userInfoDictionary allKeys]objectAtIndex:i]isEqualToString:[NSString stringWithFormat:@"%d",indexPath.section]]) {
                    if (indexPath.section==[[[userInfoDictionary allKeys]objectAtIndex:i]intValue]) {
                        NSArray *tempArr = [userInfoDictionary objectForKey:[[userInfoDictionary allKeys]objectAtIndex:i]];
                        NSDictionary *tempDic = [tempArr objectAtIndex:indexPath.row+1];
                        if (indexPath.row == [[tempDic objectForKey:@"ROW"]intValue]) {
                            label.text = [tempDic objectForKey:@"USER_NM"];
                            
                            NSString *selected = [tempDic objectForKey:@"CHECK"];
                            if ([selected isEqualToString:@"Y"]) {
                                imageView.image = selectedImage;
                            }else{
                                imageView.image = unselectedImage;
                            }
                            [UIView commitAnimations];
                        }
                        
                    }
                }
            }
            
        }
    }else{
        NSArray *arr = [[deptInfoDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSDictionary *dic = [deptInfoDictionary objectForKey:[arr objectAtIndex:indexPath.section]];
        arr = [[dic allKeys]sortedArrayUsingSelector:@selector(compare:)];
        label.text = [arr objectAtIndex:indexPath.row];
        if ([[[dic objectForKey:label.text] objectForKey:@"CHECK"] isEqualToString:@"Y"]) {
            imageView.image = selectedImage;
        }else{
            imageView.image = unselectedImage;
        }
        [UIView commitAnimations];
        
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

#pragma mark - Connection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message56", @"") otherButtonTitles: nil];
    [alertView show];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receiveData options:kNilOptions error:&error];


    
    userInfoDictionary = [[NSMutableDictionary alloc]init];
    deptInfoDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *mutableArr;
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]init];
    NSString *preChosung = @"";
    int sectionCount=0;
    int arrayCount=0;
    for (int i=0; i<[dic count]; i++) {
        NSDictionary *tmp = [MFinityAppDelegate getAllValueUrlDecoding:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
        NSString *deptNM = [tmp objectForKey:@"DEPT_NM"];
        [userDic setValue:[tmp objectForKey:@"USER_NM"] forKey:@"USER_NM"];
        [userDic setValue:[tmp objectForKey:@"CUSER_ID"] forKey:@"CUSER_ID"];
        [userDic setValue:[tmp objectForKey:@"LEVEL_NM"] forKey:@"LEVEL_NM"];
        [userDic setValue:[NSString stringWithFormat:@"%d",i] forKey:@"TAG"];
        [userDic setValue:@"N" forKey:@"CHECK"];
        NSString *choSung =[self getUTF8String:[tmp objectForKey:@"USER_NM"]];
        if (![preChosung isEqualToString:choSung]) {
            preChosung = choSung;
            sectionCount++;
            mutableArr = [[NSMutableArray alloc]init];
            [mutableArr addObject:choSung];
            arrayCount = 0;
        }
        [mutableDic setValue:@"" forKey:deptNM];
        
        [userDic setObject:[NSString stringWithFormat:@"%d",arrayCount++] forKey:@"ROW"];
        [mutableArr addObject:userDic];
        [userInfoDictionary setObject:mutableArr forKey:[NSString stringWithFormat:@"%d",sectionCount-1]];
        
    }
    deptInfoDictionary = [[NSMutableDictionary alloc]init];
    NSString *str;
    for (int i=0; i<[mutableDic count]; i++) {
        NSMutableDictionary *md = [[NSMutableDictionary alloc]init];
        for(int j=0; j<[dic count];j++){
            NSDictionary *tmp = [MFinityAppDelegate getAllValueUrlDecoding:[dic objectForKey:[NSString stringWithFormat:@"%d",j]]];
            if ([[[mutableDic allKeys]objectAtIndex:i]isEqualToString:[tmp objectForKey:@"DEPT_NM"]]) {
                NSMutableDictionary *tmp2 = [[NSMutableDictionary alloc]init];
                str = [tmp objectForKey:@"DEPT_NM"];
                [tmp2 setObject:[tmp objectForKey:@"CUSER_ID"] forKey:@"CUSER_ID"];
                [tmp2 setObject:@"N" forKey:@"CHECK"];
                [md setObject:tmp2 forKey:[tmp objectForKey:@"USER_NM"]];
            }
        }
        [deptInfoDictionary setObject:md forKey:[[mutableDic allKeys] objectAtIndex:i]];
    }
    
    [myTableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self checkForuserInfoList:indexPath];
    
    [tableView reloadData];
}
- (void)checkForuserInfoList:(NSIndexPath *)indexPath{
    if (isAll) {
        if (searching) {
            NSDictionary *dic = [searchUserInfoArray objectAtIndex:indexPath.row];
            if ([[dic objectForKey:@"CHECK"]isEqualToString:@"N"]) {
                [dic setValue:@"Y" forKey:@"CHECK"];
            }else{
                [dic setValue:@"N" forKey:@"CHECK"];
            }
        }else{
            NSArray *arr = [userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
            NSDictionary *dic = [arr objectAtIndex:indexPath.row+1];
            if ([[dic objectForKey:@"CHECK"]isEqualToString:@"N"]) {
                [dic setValue:@"Y" forKey:@"CHECK"];
            }else{
                [dic setValue:@"N" forKey:@"CHECK"];
            }
        }
    }else{
        NSArray *arr = [[deptInfoDictionary allKeys]sortedArrayUsingSelector:@selector(compare:)];
        NSDictionary *dic = [deptInfoDictionary objectForKey:[arr objectAtIndex:indexPath.section]];
        arr = [[dic allKeys]sortedArrayUsingSelector:@selector(compare:)];
        dic = [dic objectForKey:[arr objectAtIndex:indexPath.row]];
        if ([[dic objectForKey:@"CHECK"]isEqualToString:@"N"]) {
            [dic setValue:@"Y" forKey:@"CHECK"];
        }else{
            [dic setValue:@"N" forKey:@"CHECK"];
        }
        
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    /*
     NSMutableArray *returnArr = [[NSMutableArray alloc]init];
     for (int i=0; i<[mutableDic count]; i++) {
     [returnArr addObject:[[mutableDic objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:0]];
     }
     return returnArr;
     *///*
    if (self.searchDisplayController.active) {
        return nil;
    }else{
        if (isAll) {
            NSMutableArray *returnArr = [[NSMutableArray alloc]init];
            for (int i=0; i<[userInfoDictionary count]; i++) {
                [returnArr addObject:[[userInfoDictionary objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:0]];
            }
            return returnArr;
        }else{
            return nil;
        }
        
        
    }
    //*/
}
@end
