//
//  FileListViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "FileListViewController.h"
#import "PhotoViewController.h"
#import "VideoViewController.h"
#import "CustomSegmentedControl.h"
#define kCellPictureViewTag	1000
#define kCellImageViewTag	1001
#define kCellLabelTag		1002

#define kLabelIndentedRect	CGRectMake(100.0, 12.0, 275.0, 20.0)
#define kLabelRect			CGRectMake(65.0, 12.0, 275.0, 20.0)
@interface FileListViewController ()

@end

@implementation FileListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex==0) {
		NSMutableArray *rowsToBeDeleted = [[NSMutableArray alloc] init];
		NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
		int index = 0;
		for (NSNumber *rowSelected in selectedArray){
			if ([rowSelected boolValue]){
				[rowsToBeDeleted addObject:[listData objectAtIndex:index]];
				NSUInteger pathSource[2] = {0, index};
				NSIndexPath *path = [NSIndexPath indexPathWithIndexes:pathSource length:2];
				[indexPaths addObject:path];
			}
			index++;
		}
		if ([rowsToBeDeleted count]==0) {
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message71", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
			[alert show];
            
		} else {
			NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docDir = [arrayPaths objectAtIndex:0];
            //NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            docDir = [docDir stringByAppendingPathComponent:appDelegate.comp_no];
            
            if ([appDelegate.mediaControl isEqualToString:@"video"]) {
                docDir = [docDir stringByAppendingPathComponent:@"/video"];
            }else{
                docDir = [docDir stringByAppendingPathComponent:@"/photo"];
            }
			NSFileManager *manager =[NSFileManager defaultManager];
			for (id value in rowsToBeDeleted){
				NSString *str = value;
				NSArray *tempArr = [str componentsSeparatedByString:@"."];
				NSString *thumfileName = [tempArr objectAtIndex:0];
				thumfileName = [thumfileName stringByAppendingString:@".thum"];
				NSString *pngFileName = [tempArr objectAtIndex:0];
                pngFileName = [pngFileName stringByAppendingString:@".png"];
                
				str = [docDir stringByAppendingPathComponent:str];
				thumfileName = [docDir stringByAppendingPathComponent:thumfileName];
                pngFileName = [docDir stringByAppendingPathComponent:pngFileName];
				[manager removeItemAtPath:str error:NULL];
				[manager removeItemAtPath:thumfileName error:NULL];
                [manager removeItemAtPath:pngFileName error:NULL];
				[listData removeObject:value];
			}
			[myTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			
			inPseudoEditMode = NO;
			//self.toolbar.hidden = YES;//
            //			UIImage *buttonImageRight = [UIImage imageNamed:@"btn_edit.png"];
            //
            //			UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
            //			[rightButton setImage:buttonImageRight forState:UIControlStateNormal];
            //			rightButton.frame = CGRectMake(0, 0, buttonImageRight.size.width,buttonImageRight.size.height);
            //			[rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
            //			UIBarButtonItem *customBarItemRight = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
            //			self.navigationItem.rightBarButtonItem = customBarItemRight;
			//
			
			
			//UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message72", @""),nil]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message72", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
			
			self.navigationItem.leftBarButtonItem = nil;
            
			[self populateSelectedArray];
			[myTableView reloadData];
		}
	}else if (buttonIndex==1){
        UIAlertView *alertView= [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message158", @"") message:NSLocalizedString(@"message73", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
        [alertView show];
    }
}
-(IBAction)doDelete{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") destructiveButtonTitle:NSLocalizedString(@"message77", @"") otherButtonTitles:nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:[UIApplication sharedApplication].keyWindow];
    
}
-(IBAction)allDelete{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message73", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"@message51",@"") otherButtonTitles:NSLocalizedString(@"@message52",@""),nil];
	[alertView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView.title isEqualToString:NSLocalizedString(@"message158", @"")]){
		if (buttonIndex==1) {
			
		}
		else if(buttonIndex==0){
			NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docDir = [arrayPaths objectAtIndex:0];
            docDir = [docDir stringByAppendingPathComponent:appDelegate.comp_no];
            docDir = [docDir stringByAppendingFormat:@"/photo"];
			NSFileManager *manager =[NSFileManager defaultManager];
			NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
			NSMutableArray *deleteList = [[NSMutableArray alloc]init];
			int index = 0;
			for (int i=0; i<[fileList count]; i++) {
				NSString *str = [fileList objectAtIndex:i];
				NSArray *arr = [str componentsSeparatedByString:@"."];
				if ([@"jpg" isEqualToString:[arr objectAtIndex:1]]) {
					NSString *fileName = [docDir stringByAppendingPathComponent:str];
					[manager removeItemAtPath:fileName error:NULL];
					[deleteList addObject:[NSIndexPath indexPathForRow:index inSection:0]];
					index++;
				}else if ([@"thum" isEqualToString:[arr objectAtIndex:1]]) {
					NSString *fileName = [docDir stringByAppendingPathComponent:str];
					[manager removeItemAtPath:fileName error:NULL];
				}
			}
			[listData removeAllObjects];
			[myTableView deleteRowsAtIndexPaths:deleteList withRowAnimation:UITableViewRowAnimationFade];
			inPseudoEditMode = NO;
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message72", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
			
			self.navigationItem.leftBarButtonItem = nil;
			[self populateSelectedArray];
			[myTableView reloadData];
            
            
		}
	}
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.mediaControl isEqualToString:@"video"]) {
        UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        _label.text = NSLocalizedString(@"message75", @"");
        _label.font = [UIFont boldSystemFontOfSize:20.0];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        }
        self.navigationItem.titleView = _label;
        
        //[self.navigationItem setTitle:NSLocalizedString(@"message75", @"")];
    }else {
        UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        _label.text = NSLocalizedString(@"message76", @"");
        _label.font = [UIFont boldSystemFontOfSize:20.0];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        }
        self.navigationItem.titleView = _label;
        
        //[self.navigationItem setTitle:NSLocalizedString(@"message76", @"")];
    }
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
	UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
	self.navigationItem.backBarButtonItem=left;
    
	
	//UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message72", @""),nil]];
    /*
    CustomSegmentedControl *button;
    button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message72", @""),nil]
                                                offColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                 onColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                            offTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                             onTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                fontSize:12];
    
	button.momentary = YES;
	[button addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.rightBarButtonItem=right;
	*/
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message72", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
    
	NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    docDir = [docDir stringByAppendingPathComponent:appDelegate.comp_no];
    if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
        docDir = [docDir stringByAppendingFormat:@"/photo"];
    }
    else if ([appDelegate.mediaControl isEqualToString:@"video"]) {
        docDir = [docDir stringByAppendingFormat:@"/video"];
    }
    NSLog(@"docDic : %@",docDir);
	NSMutableArray *addFileList = [[NSMutableArray alloc] init];
	NSFileManager *manager =[NSFileManager defaultManager];
	NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
    ////NSLog(@"fileList size : %d",[fileList count]);
	for (int i=([fileList count]-1); i>=0; i--) {
        
        NSString *str = [fileList objectAtIndex:i];
        ////NSLog(@"files : %@",str);
        NSArray *arr = [str componentsSeparatedByString:@"."];
		if ([appDelegate.mediaControl isEqualToString:@"camera"]&&[@"jpg" isEqualToString:[arr objectAtIndex:1]]) {
			[addFileList addObject:str];
		}
        if ([appDelegate.mediaControl isEqualToString:@"video"]&&[@"mp4" isEqualToString:[arr objectAtIndex:1]]) {
            [addFileList addObject:str];
        }
	}
	
	listData = addFileList;
	/*
     UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
     lpgr.minimumPressDuration = 0.5f;
     lpgr.cancelsTouchesInView = NO;
     lpgr.delegate = self;
     [self.myTableView addGestureRecognizer:lpgr];
     
     [lpgr release];
     */
    inPseudoEditMode = NO;
	
	selectedImage = [UIImage imageNamed:@"selected.png"];
	unselectedImage = [UIImage imageNamed:@"unselected.png"];
	
	[self populateSelectedArray];
    // Do any additional setup after loading the view from its nib.
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
	if(gestureRecognizer.state == UIGestureRecognizerStateRecognized){
		CGPoint p = [gestureRecognizer locationInView:myTableView];
		NSIndexPath *indexPath = [myTableView indexPathForRowAtPoint:p];
		if (indexPath == nil) {
            
		}else {
			indexRow = indexPath.row;
			NSString *str = [listData objectAtIndex:indexRow];
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:str message:@"삭제하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인",nil];
			[alert show];
            
		}
	}
}
- (void) populateSelectedArray {
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[listData count]];
	for (int i=0; i < [listData count]; i++)
		[array addObject:[NSNumber numberWithBool:NO]];
	selectedArray = array;
	
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		UILabel *label = [[UILabel alloc] initWithFrame:kLabelRect];
		label.tag = kCellLabelTag;
		[cell.contentView addSubview:label];
        
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
        if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
            documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
        }
        else if ([appDelegate.mediaControl isEqualToString:@"video"]) {
            documentFolder = [documentFolder stringByAppendingFormat:@"/video"];
        }
		NSMutableString *filePath = [NSMutableString stringWithString:documentFolder];
		[filePath appendString:@"/"];
		NSString *temp = [filePath lastPathComponent];
		NSArray *arr = [temp componentsSeparatedByString:@"."];
		NSString *thumFileName = [arr objectAtIndex:0];
		thumFileName = [thumFileName stringByAppendingString:@".thum"];
		NSMutableString *filePath2 = [NSMutableString stringWithString:documentFolder];
		[filePath2 appendString:@"/"];
		[filePath2 appendString:thumFileName];
        NSData *descryptData = [NSData dataWithContentsOfFile:filePath2];
		UIImage *image = [UIImage imageWithData:descryptData ];
		UIImageView *pictureView = [[UIImageView alloc] initWithImage:image];
		pictureView.frame = CGRectMake(5.0, 10.0, 50.0, 50.0);
		[cell.contentView addSubview:pictureView];
		pictureView.tag = kCellPictureViewTag;
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:unselectedImage];
		imageView.frame = CGRectMake(5.0, cell.frame.size.height/2, 23.0, 23.0);
		[cell.contentView addSubview:imageView];
		imageView.hidden = !inPseudoEditMode;
		imageView.tag = kCellImageViewTag;
        
		
    }
    
	NSUInteger row =indexPath.row;
	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    
    if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
        documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
    }
    else if ([appDelegate.mediaControl isEqualToString:@"video"]) {
        documentFolder = [documentFolder stringByAppendingFormat:@"/video"];
    }
	NSMutableString *filePath = [NSMutableString stringWithString:documentFolder];
	[filePath appendString:@"/"];
	[filePath appendString:[listData objectAtIndex:row]];
	NSString *temp = [filePath lastPathComponent];
	NSArray *arr = [temp componentsSeparatedByString:@"."];
	NSString *thumFileName = [arr objectAtIndex:0];
	thumFileName = [thumFileName stringByAppendingString:@".thum"];
	NSMutableString *filePath2 = [NSMutableString stringWithString:documentFolder];
	[filePath2 appendString:@"/"];
	[filePath2 appendString:thumFileName];
    NSData *descryptData = [NSData dataWithContentsOfFile:filePath2];
    UIImage *image = [UIImage imageWithData:descryptData];
	//UIImage *image = [UIImage imageWithContentsOfFile:filePath2];
    //NSLog(@"image : %@",image);
	//cell.imageView.image = image;
	//cell.textLabel.text= [self.listData objectAtIndex:row];
	
	
	[UIView beginAnimations:@"cell shift" context:nil];
	
	UIImageView *picture = (UIImageView *)[cell.contentView viewWithTag:kCellPictureViewTag];
	picture.image = image;
	picture.hidden = NO;
	picture.frame = (inPseudoEditMode) ?  CGRectMake(40.0, 10.0, 50.0, 50.0) : CGRectMake(5.0, 10.0, 50.0, 50.0);
	
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
	label.text = [listData objectAtIndex:[indexPath row]];
	//label.font = [UIFont boldSystemFontOfSize:30];
	label.frame = (inPseudoEditMode) ? kLabelIndentedRect : kLabelRect;
	label.opaque = NO;
	
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
	NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
	imageView.image = ([selected boolValue]) ? selectedImage : unselectedImage;
	imageView.hidden = !inPseudoEditMode;
	[UIView commitAnimations];
	
	
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat{
	return 70;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[myTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (inPseudoEditMode)
	{
		BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
		[selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
		[myTableView reloadData];
	}
	else{
		//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		NSUInteger row = [indexPath row];
        NSString *rowValue = [listData objectAtIndex:row];
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
        
        if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
            documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
        }
        else if ([appDelegate.mediaControl isEqualToString:@"video"]) {
            documentFolder = [documentFolder stringByAppendingFormat:@"/video"];
        }
        NSString *filePath = [documentFolder stringByAppendingPathComponent:rowValue];
        NSString *fileName = [rowValue lastPathComponent];
        
        NSArray *arr = [fileName componentsSeparatedByString:@"."];
        if ([[arr objectAtIndex:1] isEqualToString:@"jpg"]) {
            
            PhotoViewController *vc = [[PhotoViewController alloc] init];
            vc.imagePath = filePath;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if([[arr objectAtIndex:1] isEqualToString:@"mp4"]){
            NSString *temp = fileName;
            NSArray *arr = [temp componentsSeparatedByString:@"."];
            NSString *thumFileName = [arr objectAtIndex:0];
            thumFileName = [thumFileName stringByAppendingString:@".png"];
            
            VideoViewController *vc = [[VideoViewController alloc] init];
            vc.thumNailPath = [documentFolder stringByAppendingPathComponent:thumFileName];
            vc.videoPath = filePath;
            [self.navigationController pushViewController:vc animated:YES];
            
            
            
        }
	}
}
-(void) navigationGoBack {
	[self.navigationController popViewControllerAnimated:YES];
}
-(void) leftBtnClick{
	if (inPseudoEditMode) {
		UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message77", @""),NSLocalizedString(@"message158", @""),nil];
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[popupQuery showInView:[UIApplication sharedApplication].keyWindow];
        
	}else {
		[self.navigationController popViewControllerAnimated:YES];
	}
    
}
-(void) rightBtnClick{
    
	//CustomSegmentedControl *rightButton;
	//UISegmentedControl *leftButton;
	
	if (!inPseudoEditMode) {
        /*
        rightButton= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message52", @""),nil]
                                                         offColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                          onColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                     offTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                      onTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                         fontSize:12];
		
		leftButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message84", @""),nil]];
		leftButton.momentary = YES;
		leftButton.segmentedControlStyle = UISegmentedControlStyleBar;
		leftButton.tintColor = [UIColor redColor];
		[leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventValueChanged];
		UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
		self.navigationItem.leftBarButtonItem=left;
        */
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message52", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message84", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(leftBtnClick)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
        
	}else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message72", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
        /*
		rightButton= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"message72", @""),nil]
                                                         offColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                          onColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                     offTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                      onTextColor:[appDelegate myRGBfromHex:appDelegate.naviFontColor]
                                                         fontSize:12];
         */
		self.navigationItem.leftBarButtonItem=nil;
	}
    
	//rightButton.momentary = YES;
	//rightButton.segmentedControlStyle = UISegmentedControlStyleBar;
	//rightButton.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
	//[rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventValueChanged];
	//UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
	//self.navigationItem.rightBarButtonItem=right;
	
	inPseudoEditMode = !inPseudoEditMode;
	
	[myTableView reloadData];
}
-(UIImage *) generatephotoThumbail:(UIImage *)image withRatio:(float)ratio {
	CGRect cropRect;
	if (image.size.width == image.size.height) {
		cropRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	}else if (image.size.width>image.size.height) {
		int xgap = (image.size.width - image.size.height)/2;
		cropRect = CGRectMake(xgap, 0.0, image.size.width, image.size.height);
	}else {
		int ygap = (image.size.height - image.size.width)/2;
		cropRect = CGRectMake(0.0, ygap, image.size.width, image.size.height);
	}
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	NSData *pngData = UIImagePNGRepresentation(cropped);
	UIImage *myThumNail = [[UIImage alloc]initWithData:pngData];
	
	UIGraphicsBeginImageContext(CGSizeMake(ratio, ratio));
	[myThumNail drawInRect:CGRectMake(0.0, 0.0, ratio, ratio)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
	
}
- (void)playbackDidFinish:(NSNotification *)noti {
    //NSLog(@"playback callback");
    MPMoviePlayerController *player = [noti object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self dismissMoviePlayerViewControllerAnimated];
}
@end
