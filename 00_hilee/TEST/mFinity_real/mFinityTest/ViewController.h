
#import <UIKit/UIKit.h>
#import "loginController.h"

@interface ViewController : UIViewController {
    UIButton *btnlogout, *btnfind, *btnmore1, *btnmore2, *btnmore3;
    UITextField *txtfind;
    UITableView *listView, *listView1;
    NSMutableArray *DataArray1, *DataArray2;
    UIButton * newbtn1, * newbtn2, * newbtn3;
}
@property (nonatomic, retain) NSMutableArray *DataArray1, *DataArray2;
@property (nonatomic, retain) IBOutlet UIButton *btnlogout, *btnfind, *btnmore1, *btnmore2, *btnmore3;
@property (nonatomic, retain) IBOutlet UITextField *txtfind;
@property (nonatomic, retain) IBOutlet UITableView *listView, *listView1;
@property (nonatomic, retain) IBOutlet UIButton * newbtn1, * newbtn2, * newbtn3;

- (IBAction)btnlogoutPress:(id)sender;
- (IBAction)btnfindPress:(id)sender;
- (IBAction)btnmore1Press:(id)sender;
- (IBAction)btnmore2Press:(id)sender;
- (void)loadData;

- (IBAction)btnmore3Press:(id)sender;
- (IBAction)newbtn1Press:(id)sender;
- (IBAction)newbtn2Press:(id)sender;
- (IBAction)newbtn3Press:(id)sender;

- (IBAction)logoutPress:(id)sender; //로그아웃

@end

