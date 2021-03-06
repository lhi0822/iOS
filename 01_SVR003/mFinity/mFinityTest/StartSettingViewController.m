//
//  StartSettingViewController.m
//  mFinity
//
//  Created by Park on 13. 9. 10..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "StartSettingViewController.h"
#import "MFinityAppDelegate.h"
#import "UIViewController+KNSemiModal.h"
@interface StartSettingViewController (){
    NSMutableArray *tabNameArray;
    int checkRow;
}
@property (nonatomic, strong)NSString *startString;

@end

@implementation StartSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    _button.title = NSLocalizedString(@"message51", @"확인");
    _button2.title = NSLocalizedString(@"message52", @"취소");
    //_tableView.backgroundView = _imageView;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message37", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }self.navigationItem.titleView = label;
    [_toolBar setBarTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    [_toolBar setTranslucent:NO];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _startString = [prefs stringForKey:@"startString"];
    
    NSLog(@"_startString : %@",_startString);
    tabNameArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[appDelegate.titleArray count]; i++) {
        
        NSString *tempString = [NSString stringWithFormat:@"%@",[appDelegate.titleArray objectAtIndex:i]];
        if ([[appDelegate.tabNumberArray objectAtIndex:i] intValue]!=5) {
            [tabNameArray addObject:tempString];
        }
        
    }
    [_pickerView selectRow:[prefs integerForKey:@"startTabNumber"] inComponent:0 animated:YES];
    NSLog(@"tabNameArray : %@",tabNameArray);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
-(IBAction)cancel:(id)sender{
    [self dismissSemiModalView];
}
-(IBAction)confirm:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:checkRow forKey:@"startTabNumber"];
    [prefs setObject:_startString forKey:@"startString"];
    [prefs synchronize];
    [self dismissSemiModalView];
}
#pragma mark
#pragma mark UIPickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_startString = [tabNameArray objectAtIndex:row];
    checkRow = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	return [tabNameArray count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [tabNameArray objectAtIndex:row];
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 1, 300, 43)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = [tabNameArray objectAtIndex:indexPath.row];
    [cell.contentView addSubview:label];
    if ([label.text isEqualToString:_startString]) {
        checkRow = indexPath;
        cell.selected = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if(![[tabNameArray objectAtIndex:indexPath.row]isEqualToString:_startString]){
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:checkRow];
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        checkRow = indexPath;
        _startString = [tabNameArray objectAtIndex:indexPath.row];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:checkRow.row forKey:@"startTabNumber"];
    [prefs setObject:_startString forKey:@"startString"];
    [prefs synchronize];

}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	////NSLog(@"section : %d",section);
//	UILabel *label = [[UILabel alloc]init];
//	label.backgroundColor = [UIColor clearColor];
//    label.text = _startString;
//    return label;
//	
//	
//}
 */
#pragma mark


@end
