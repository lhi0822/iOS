//
//  MFSQLManager.h
//  mFinity
//
//  Created by Kyeong In Park on 13. 4. 11..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface MFSQLManager : NSObject{
    sqlite3 *db;
}
-(sqlite3_stmt *)getStatement:(NSString *)dbFileName :(NSString *)sqlString :(BOOL)isBundle;
@end
