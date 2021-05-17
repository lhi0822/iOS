//
//  MFSQLManager.m
//  mFinity
//
//  Created by Kyeong In Park on 13. 4. 11..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFSQLManager.h"

@implementation MFSQLManager
-(sqlite3_stmt *)getStatement:(NSString *)dbFileName :(NSString *)sqlString :(BOOL)isBundle{
    sqlite3_stmt *sqlStatement;
    @try {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *dbFilePath;
        if (isBundle) {
            dbFilePath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbFileName];
        }else{
            dbFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:dbFileName];
        }
        NSLog(@"MFSQLManager DBFILEPATH : %@",dbFilePath);
        if(![manager fileExistsAtPath:dbFilePath]){
            NSLog(@"MFSQLManager dbFile not exists");
        }
        if (!(sqlite3_open([dbFilePath UTF8String], &db)== SQLITE_OK)) {
            NSLog(@"MFSQLManager error has occured");
        }
        const char *sql = [sqlString UTF8String];
        NSLog(@"sql : %s",sql);
        if (sqlite3_prepare(db, sql, -1, &sqlStatement, NULL)!=SQLITE_OK) {
            NSLog(@"MFSQLManager Problem with prepare statement");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"MFSQLManager exception : %@",exception);
    }
    @finally {
        return sqlStatement;
    }
}
@end
