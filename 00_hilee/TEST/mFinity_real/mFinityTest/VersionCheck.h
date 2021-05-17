
#import <Foundation/Foundation.h>

@protocol VersionCheckDelegate;

@interface VersionCheck : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (strong, nonatomic) NSString *returnDataString;

-(void)currentVersionCheck:(NSString *)url param:(NSString *)param;

@property (weak, nonatomic) id <VersionCheckDelegate> delegate;

@end

@protocol VersionCheckDelegate <NSObject>
-(void)returnDataWithObject:(VersionCheck *)session error:(NSString *)error;

@end

