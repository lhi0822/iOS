//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesTimestampFormatter.h"

@interface JSQMessagesTimestampFormatter ()

@property (strong, nonatomic, readwrite) NSDateFormatter *dateFormatter;

@end



@implementation JSQMessagesTimestampFormatter

#pragma mark - Initialization

+ (JSQMessagesTimestampFormatter *)sharedFormatter
{
    static JSQMessagesTimestampFormatter *_sharedFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[JSQMessagesTimestampFormatter alloc] init];
    });
    
    return _sharedFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDoesRelativeDateFormatting:YES];
        
        UIColor *color = [UIColor lightGrayColor]; //날짜색상
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _dateTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
        
        _timeTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
    }
    return self;
}

#pragma mark - Formatter

- (NSString *)timestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }

    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSAttributedString *)attributedTimestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:NSLocalizedString(@"date14", @"date14")];
    NSString *dateString = [dateFormat stringFromDate:date];
    //NSLog(@"dateString : %@", dateString);
    
    //NSString *relativeDate = [self relativeDateForDate:date];
    //NSString *time = [self timeForDate:date];
    
    NSMutableAttributedString *timestamp = [[NSMutableAttributedString alloc] initWithString:dateString attributes:self.dateTextAttributes];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    //[timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:time attributes:self.timeTextAttributes]];
    
    return [[NSAttributedString alloc] initWithAttributedString:timestamp];
}

- (NSAttributedString *)attributedSystemstampForDate:(NSString *)str
{
    if (!str) {
        return nil;
    }
    
    NSMutableAttributedString *timestamp = [[NSMutableAttributedString alloc] initWithString:str attributes:self.dateTextAttributes];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    return [[NSAttributedString alloc] initWithAttributedString:timestamp];
}


- (NSString *)timeForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)relativeDateForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [self.dateFormatter stringFromDate:date];
}

@end
