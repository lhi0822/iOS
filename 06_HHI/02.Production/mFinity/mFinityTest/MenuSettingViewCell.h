//
//  MenuSettingViewCell.h
//  ezSmart
//
//  Created by mac on 10. 9. 16..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuSettingViewCell : UITableViewCell {
	IBOutlet UILabel	*txtTitle;
	IBOutlet UISwitch	*isMyMenu;
	IBOutlet UIView		*myView;
}

@property (nonatomic, retain) IBOutlet UILabel	*txtTitle;
@property (nonatomic, retain) IBOutlet UISwitch	*isMyMenu;
@property (nonatomic, retain) IBOutlet UIView	*myView;

-(IBAction)tabChanged;

@end
