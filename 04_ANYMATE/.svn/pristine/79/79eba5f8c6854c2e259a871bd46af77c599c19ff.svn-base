//
//  RemoveContentsViewController.m
//  mFinity
//
//  Created by Park on 13. 9. 10..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "CompanySelectViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIViewController+KNSemiModal.h"
@interface CompanySelectViewController (){
    NSMutableArray *deleteArray;
    NSString *deleteTitle;
}

@end

@implementation CompanySelectViewController

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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (@available(iOS 13.0, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            _button.tintColor = [UIColor whiteColor];
        } else {
            _button.tintColor = [appDelegate myRGBfromHex:@"19385b"];
        }
    } else {
        _button.tintColor = [appDelegate myRGBfromHex:@"19385b"];
    }
    
    _button.title = NSLocalizedString(@"확인", @"확인");
    [pickerView selectRow:0 inComponent:0 animated:YES];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.compNm =[[self.compDic allValues] objectAtIndex:row];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return self.compDic.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[self.compDic allValues] objectAtIndex:row];
}

-(IBAction)confirm:(id)sender{

    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"selectView compNm : %@",self.compNm);
    NSLog(@"selectView compDic : %@",self.compDic);
    //[self dismissModalViewControllerAnimated:YES];
    //[self dismissSemiModalViewWithCompletion:NULL];
    if (self.compNm == nil) {
        self.compNm = [[self.compDic allValues]objectAtIndex:0];
    }
    NSLog(@"selectView compNm 2 : %@",self.compNm);
    UINavigationController *vc = (UINavigationController *)[self parentViewController];
    LoginViewController *lvc = (LoginViewController *)[[vc viewControllers] objectAtIndex:0];
    [lvc usingData:self.compNm];
    //NSLog(@"vc : %@",[[vc viewControllers] objectAtIndex:0]);
    
    [self dismissSemiModalView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
