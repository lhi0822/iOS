//
//  MFUtil.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import "KeychainItemWrapper.h"
#import "SecurityManager.h"
#import "FBEncryptorAES.h"
//#import "AppDelegate.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@interface MFUtil : NSObject

#pragma mark - UI
+(UILabel *)navigationTitleStyle:(UIColor *)color title:(NSString *)title;
+(UITabBarController *)setDefualtTabBar;
+(UIColor *) myRGBfromHex: (NSString *) code;
+(CAGradientLayer *)setImageGradient:(CGRect)frame startPoint:(CGPoint)st endPoint:(CGPoint)ed colors:(NSArray *)colors;
+(UIImage *)changeImgColor:(UIImage *)img;
+(UIViewController *)topViewController;
+(UIViewController *)topViewController:(UIViewController *)rootViewController;

#pragma mark - Information
+ (BOOL)isRooted;
+ (BOOL) retinaDisplayCapable;
+(NSString *)getUUID;
+(NSString *)getIPAddress;
+(NSString *)getDevPlatformNumber;
+(NSString *)getMfpsId;
+(NSString *)getChatRoutingKey:(NSString *)roomNo;

#pragma mark - Local
+(NSString *)getFolderName:(NSString *)type;
+(UIImage *)saveThumbImage:(NSString *)folder path:(NSString *)thumbFilePath num:(NSString *)paramNo;

#pragma mark - Controller
//+(NSString *)createChatRoomName:(NSString *)roomName;
+(NSString *)createChatRoomName:(NSString *)roomName roomType:(NSString *)roomType;
+(NSString *)createChatRoomImg:(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo;
//+(NSString *)createChatRoomImg:(AppDelegate *)appDelegate :(NSMutableDictionary *)dict :(NSMutableArray *)array :(NSString *)memberCnt :(NSString *)roomNo;
+(UINavigationController *)showToShareView;

#pragma mark - Date
+(BOOL)isWorkingTime;
+(NSString *)getTimeIntervalFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;

#pragma mark - Json
+(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary;

#pragma mark - String
+(NSDictionary *)getParametersByString:(NSString *)query;
+(NSString *)webServiceParamEncrypt:(NSString*)paramStr;
+(NSString *)paramEncryptAndEncode :(NSString*)paramStr;
+(NSString *)replaceEncodeToChar:(NSString*)str;

#pragma mark - Image Size
+(UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width;
+(UIImage *)getScaledLowImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width;
+(UIImage *)getScaledImage:(UIImage *)image scaledToMaxHeight:(CGFloat)height;
+(UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;

+(UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize :(UIImage *)image;
+ (UIImage *)imageByScalingAndCroppingForSize2:(CGSize)targetSize :(UIImage *)image :(CGFloat)width;

+(UIImage *)rotateImage90:(UIImage *)img;
+(UIImage *)rotateImageReverse90:(UIImage *)img;
+(UIImage *)rotateImage:(UIImage *)img byOrientationFlag:(UIImageOrientation)orient;

+(UIImage *)getResizeImageRatio:(UIImage *)img;
+(CGSize)getResizeVideoRatio:(CGSize)videoSize;


@end

@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
- (NSString *)AES256EncryptWithKeyString:(NSString *)key;
- (NSString *)AES256DecryptWithKeyString:(NSString *)key;
@end

@interface NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
