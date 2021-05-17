//
//  MFMessageViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 14..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFMessageViewController.h"
#import "MFinityAppDelegate.h"
@interface MFMessageViewController ()

@end

@implementation MFMessageViewController

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
    // Do any additional setup after  loading the view from its nib.
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];

    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
	UIImage *bgImage = [UIImage imageWithData:decryptData];
	_imageView.image = bgImage;
    NSString *titleString;
    NSArray *arr = appDelegate.msgUserInfo;
    for (int i=0;i<[arr count];i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
        if (i==0) {
            titleString = [dic objectForKey:@"USER_NM"];
        }
    }
    if ([arr count]>1) {
        titleString = [titleString stringByAppendingFormat:@" 외 %d명",[arr count]-1];
    }
    self.navigationItem.title = titleString;
    mDic = [[NSMutableDictionary alloc]init];
    array = [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"Fasdfasdfasdfasdf",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Yasdfasdfasdf\nasdf",@"Zasdfasdfasdfasdfasdf",@"가나다라마바사아자차카타파하", nil];
    for (int i=0; i< [array count]; i++) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc]init];
        [tmp setObject:@"N" forKey:@"SELF"];
        [tmp setObject:[array objectAtIndex:i] forKey:@"MESSAGE"];
        [mDic setObject:tmp forKey:[NSString stringWithFormat:@"%d",i]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
   
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height-40)];
    [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:NO];
    //mutiple textField
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyDefault; //just as an example

	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneButton setTitle:@"Send" forState:UIControlStateNormal];
    doneButton.tag = 3001;
    [doneButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneButton.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneButton setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:doneButton];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Send Button
-(void)Send{
    //[textView resignFirstResponder];
    if ([textView.text isEqualToString:@""]) {
        
    }else{
        [array addObject:textView.text];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"Y" forKey:@"SELF"];
        [dic setObject:textView.text forKey:@"MESSAGE"];
        [mDic setObject:dic forKey:[NSString stringWithFormat:@"%d",[mDic count]]];
        textView.text = @"";
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointMake(0, _tableView.contentOffset.y+216) animated:NO];
    }

}
#pragma mark - TextField Touch
- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

    if ([notification name]==UIKeyboardWillShowNotification) {
        CGRect containerFrame = containerView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);

        [_tableView setContentOffset:CGPointMake(0, _tableView.contentOffset.y+216) animated:YES];
        containerView.frame = containerFrame;

    }else if([notification name]==UIKeyboardWillHideNotification){
        CGRect containerFrame = containerView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        float contentOffsetY =  _tableView.contentOffset.y;
       
        containerView.frame = containerFrame;
        [_tableView setContentOffset:CGPointMake(0, contentOffsetY-216) animated:YES];
        
    }
    [UIView commitAnimations];
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
   
    if ([growingTextView.text isEqualToString:@""]) {
        [doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else{
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    UILabel *label = [[UILabel alloc]init];
    [label setFrame:CGRectMake(20, 0, 160, 0)];
    [label setText:[array objectAtIndex:indexPath.row]];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label.frame.size.height+10;
}
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [array count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *label = [[UILabel alloc]init];
        label.tag = 1001;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont systemFontOfSize:17];
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.tag = 1002;
        [imageView addSubview:label];
        [cell.contentView addSubview:imageView];
    }
    NSDictionary *dic = [mDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1002];
    //label.text = [array objectAtIndex:indexPath.row];
    label.text = [dic objectForKey:@"MESSAGE"];
    
    //label.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize textSize = [[label text] sizeWithFont:[label font]];
    CGFloat strikeWidth = textSize.width;

    NSInteger integer = strikeWidth/160;
    label.numberOfLines = 0;

    int labelHeight = 22;
    
    NSInteger imageHeight = 33;
    for (int i=0; i<integer; i++) {
        labelHeight = labelHeight+22;
        imageHeight = imageHeight +15;
    }
    
    
    UIImage *img;
    if ([[dic objectForKey:@"SELF"] isEqualToString:@"N"]) {
        [label setFrame:CGRectMake(18, 0, 160, 0)];
        [label sizeToFit];
        [imageView setFrame:CGRectMake(5, 1, label.frame.size.width+20+10, label.frame.size.height+5)];

        if (label.frame.size.height > 22) {
            [self setUILabel:label verticalAlign:0];
        }
        
        img = [[UIImage imageNamed:@"MessageBubbleGray.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
    }else{
        [label setFrame:CGRectMake(10, 0, 160, 0)];
        [label sizeToFit];
        [imageView setFrame:CGRectMake(320-(label.frame.size.width+20+10), 1, label.frame.size.width+20+10, label.frame.size.height+5)];
        if (label.frame.size.height > 22) {
            [self setUILabel:label verticalAlign:0];
            
        }
        img = [[UIImage imageNamed:@"MessageBubbleBlue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
    }
    
    //label.adjustsFontSizeToFitWidth = YES;
    
    //[imageView setFrame:CGRectMake(5, 1, 40+strikeWidth, tableView.rowHeight)];
    [imageView setImage:img];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [textView resignFirstResponder];
    return indexPath;
}
-(void)setUILabel:(UILabel *)label verticalAlign:(int)vAlign{
    CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    switch (vAlign) {
        case 0:
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, textSize.height);
            break;
        case 1:
            label.frame = CGRectMake(label.frame.origin.x, (label.frame.origin.y + label.frame.size.height)-textSize.height, label.frame.size.width, textSize.height);
            break;
        default:
            break;
    }
}
@end
