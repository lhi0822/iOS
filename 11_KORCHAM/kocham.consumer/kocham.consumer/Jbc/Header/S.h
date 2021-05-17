#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface S : NSObject
<UIAlertViewDelegate> {
	NSInputStream *iStream;
	NSOutputStream *oStream;
}
@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;

- (NSInteger) toa;
- (NSInteger) tob;
- (NSInteger) toc;
- (NSInteger) tod;
- (NSInteger) toe;
- (NSInteger) tof;
- (NSInteger) tog;
- (NSInteger) toh;
- (NSInteger) toi;
- (NSInteger) toj;

@end
