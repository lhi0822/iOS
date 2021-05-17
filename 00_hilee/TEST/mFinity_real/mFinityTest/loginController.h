
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface loginController : UIViewController <UIAlertViewDelegate> {
    UITextField *txtid, *txtpwd;
    UIButton *btnlogin;
    IBOutlet UIButton *btncheck;
    IBOutlet UIButton *device_btn;
    BOOL savecheck;
}
@property (nonatomic,retain) IBOutlet UITextField *txtid, *txtpwd;
@property (nonatomic, retain) IBOutlet UIButton *btnlogin;
@property (nonatomic, retain) IBOutlet UIButton *device_btn;
@property (nonatomic, retain) IBOutlet UIView * red_view;
@property (nonatomic, retain) IBOutlet UIView * motp_view;

- (IBAction)btnloginPress:(id)sender;
- (IBAction)btncheckPress:(id)sender;
- (IBAction)btnAddPress:(id)sender;

@end

