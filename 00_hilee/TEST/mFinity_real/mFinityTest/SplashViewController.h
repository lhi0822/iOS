
#import <UIKit/UIKit.h>
#import "VersionCheck.h"


@interface SplashViewController : UIViewController <VersionCheckDelegate>{
	NSTimer *timer;
	UIImageView *splashImageView;

}
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) UIImageView *splashImageView;

@end
