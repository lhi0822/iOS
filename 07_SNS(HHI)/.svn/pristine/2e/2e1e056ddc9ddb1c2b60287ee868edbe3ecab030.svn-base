//
//  TaskInfoTableViewCell.h
//  mfinity_sns
//
//  Created by hilee on 22/11/2018.
//  Copyright © 2018 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextView.h"

@protocol TaskInfoTableViewCellDelegate <NSObject>
@required
-(void)proceedValChange:(NSString *)val;

@end

@interface TaskInfoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *iconBtn;
@property (strong, nonatomic) IBOutlet UILabel *valueLbl;
//@property (strong, nonatomic) IBOutlet UITextView *descTxtView;
@property (strong, nonatomic) IBOutlet MFTextView *descTxtView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *arrowBtn;
- (IBAction)sliderValueChanged:(id)sender;

@property (strong, nonatomic) id <TaskInfoTableViewCellDelegate> delegate;

@end
