//
//  MFDBHelper.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 22..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MFDBHelper.h"

@implementation MFDBHelper {
    int sqliteOpen;
    BOOL isCorrect;
    
    NSUserDefaults *userDefaults;
}

- (NSString *)setPreferencesKey:(NSString *)keyName{
    NSString *resultKey = @"";
    
    NSString *userId = [userDefaults objectForKey:@"USERID"];
    resultKey = [NSString stringWithFormat:@"%@_%@",userId,keyName];
    NSLog(@"setPreferencesKey : %@", resultKey);
    return resultKey;
}

- (instancetype)init:(NSString *)call userId:(NSString *)userId{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> MFDBHelper 초기화");
    self = [super init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(userId==nil){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"SET_LOCAL_DB : %@", [userDefaults objectForKey:[self setPreferencesKey:@"SETLOCALDB"]]);
        
        NSString *dbPath = [self useAppGroupDB];
        
        if([[userDefaults objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqualToString:@"NOT_SET"]){
            if ([fileManager fileExistsAtPath:dbPath]) {
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 지우고 다시 생성");
                [fileManager removeItemAtPath:dbPath error:nil];
                sqliteOpen = sqlite3_open([dbPath UTF8String], &db);
                
            } else {
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 파일 없음");
                sqliteOpen = sqlite3_open([dbPath UTF8String], &db);
            }
            
//            if([[userDefaults objectForKey:@"DBENCRYPT"] isEqual:@1]){
            if([[MFSingleton sharedInstance] dbEncrypt]){
                [self encryptDB];
            } else {
                [self openDB];
            }
            
            [self dbEncryptCheck];
            [self createTable];
            
            [userDefaults setObject:@"DB_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
            [userDefaults synchronize];
            
        } else {
            if ([fileManager fileExistsAtPath:dbPath]) {
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 파일 있음");
                sqliteOpen = sqlite3_open([dbPath UTF8String], &db);
                [self dbEncryptCheck];
                
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 버전 확인");
                [self compareDBVer];
                
            } else {
                //파일없으면 생성
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 파일 없음2");

                if([[userDefaults objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqualToString:@"NOT_SET"]){
                    sqliteOpen = sqlite3_open([dbPath UTF8String], &db);
                    
//                    if([[userDefaults objectForKey:@"DBENCRYPT"] isEqual:@1]){
                    if([[MFSingleton sharedInstance] dbEncrypt]){
                        [self encryptDB];
                    } else {
                        [self openDB];
                    }
                    
                    [self dbEncryptCheck];
                    [self createTable];
                    
                    [userDefaults setObject:@"DB_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
                    [userDefaults synchronize];
                
                } else {
                    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 파일 없음 재생성");
                    sqliteOpen = sqlite3_open([dbPath UTF8String], &db);
                            
//                    if([[userDefaults objectForKey:@"DBENCRYPT"] isEqual:@1]){
                    if([[MFSingleton sharedInstance] dbEncrypt]){
                        [self encryptDB];
                    } else {
                        [self openDB];
                    }
                    
                    [self dbEncryptCheck];
                    [self createTable];
                    
                    [userDefaults setObject:@"DB_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
                    [userDefaults synchronize];
                }
            }
        }
        [self createLocalFolder];
        
    } else {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> MFDBHelper USER_ID로 초기화");
        self = [super init];
        if (self) {
            userDefaults = [NSUserDefaults standardUserDefaults];
            
            sqliteOpen = sqlite3_open([[self useAppGroupDB] UTF8String], &db);
            [self dbEncryptCheck];
        }
    }
    
    return self;
}

-(void)compareDBVer{
//    15버전 업데이트 기준
//    1. 먼저 DB_VER 테이블이 있는지 확인
//    2. 있으면 데이터 값 확인. 데이터가 널 또는 3보다 작으면 쿼리 전부 실행 후 DB_VER 테이블 삭제
//    3. 데이터가 5이하면 그 이후 버전에 추가된 쿼리 실행 후 DB_VER 테이블 삭제
//    4. 데이터가 6이면(현재) DB_VER 테이블 삭제 및 15 버전 쿼리 실행
//    5. 테이블이 없으면 클래스 버전 확인 15이면 16버전 업데이트 쿼리 실행
    
    //NSLog(@"버전 ; %@", [[MFSingleton sharedInstance] localDBVer]);
    NSString *oldDBVersion = [userDefaults objectForKey:@"DB_VER"];
    NSString *newDBVersion = [[MFSingleton sharedInstance] mNewDBVersion];
    NSLog(@"oldDBVersion : %@ / newDBVersion : %@", oldDBVersion, newDBVersion);
    
    if(oldDBVersion==nil){
        NSString *verCheck = [self selectString:@"SELECT VERSION FROM DB_VERSION;"];
        if(verCheck!=nil){
            NSLog(@"15미만 버전에서 업데이트 했을 경우 쿼리 전체 실행 후 DB_VER 테이블 삭제");
            if([verCheck intValue]<3) {
                NSString *db2_1 = @"UPDATE CHATS SET IS_READ = 1";
                [self crudStatement:db2_1];
                
                NSString *db2_2 = @"DROP TABLE MISSED_CHATS";
                [self crudStatement:db2_2];
                
                NSString *db2_3 = @"CREATE TABLE IF NOT EXISTS MISSED_CHATS (CHAT_NO INTEGER PRIMARY KEY AUTOINCREMENT, ROOM_NO INTEGER NOT NULL, CONTENT_TY TEXT NOT NULL, CONTENT TEXT NOT NULL, FILE_NM TEXT, CONTENT_THUMB TEXT DEFAULT '', ADIT_INFO TEXT);";
                [self crudStatement:db2_3];
            }
            if([verCheck intValue]<4) {
                NSString *db3_1 = @"CREATE TABLE IF NOT EXISTS ROOM_IMAGES(ROOM_NO INTEGER PRIMARY KEY, ROOM_IMG TEXT NOT NULL, REF_NO1 INTEGER, REF_NO2 INTEGER, REF_NO3 INTEGER, REF_NO4 INTEGER);";
                [self crudStatement:db3_1];
            }
            if([verCheck intValue]<5) {
                NSString *db4_1 = @"ALTER TABLE USERS ADD DEPT_NM TEXT DEFAULT ''";
                [self crudStatement:db4_1];
                NSString *db4_2 = @"ALTER TABLE USERS ADD LEVEL_NO TEXT DEFAULT ''";
                [self crudStatement:db4_2];
                NSString *db4_3 = @"ALTER TABLE USERS ADD LEVEL_NM TEXT DEFAULT ''";
                [self crudStatement:db4_3];
                NSString *db4_4 = @"ALTER TABLE USERS ADD DUTY_NO TEXT DEFAULT ''";
                [self crudStatement:db4_4];
                NSString *db4_5 = @"ALTER TABLE USERS ADD DUTY_NM TEXT DEFAULT ''";
                [self crudStatement:db4_5];
                NSString *db4_6 = @"ALTER TABLE USERS ADD JOB_GRP_NM TEXT DEFAULT ''";
                [self crudStatement:db4_6];
                NSString *db4_7 = @"ALTER TABLE USERS ADD EX_COMPANY_NO TEXT DEFAULT ''";
                [self crudStatement:db4_7];
                NSString *db4_8 = @"ALTER TABLE USERS ADD EX_COMPANY_NM TEXT DEFAULT ''";
                [self crudStatement:db4_8];
            }
            if([verCheck intValue]<6) {
                NSString *db5_1 = @"ALTER TABLE CHAT_ROOMS ADD IS_SCROLL INTEGER DEFAULT 0";
                [self crudStatement:db5_1];
            }
            if([verCheck intValue]<7) {
                NSString *db6_1 = @"ALTER TABLE USERS ADD SNS_USER_TYPE INTEGER DEFAULT 0";
                [self crudStatement:db6_1];
            }
            
            NSString *db15_1 = @"ALTER TABLE MISSED_CHATS ADD CONTENT_THUMB TEXT DEFAULT ''";
            [self crudStatement:db15_1];

            NSString *db15_2 = @"DROP TABLE DB_VERSION;";
            [self crudStatement:db15_2];
        
        } else {
            [self createTable];
        }
        
    } else {
//        if([newDBVersion intValue] > [oldDBVersion intValue]){
//        }
        if([oldDBVersion intValue] <= 16){
//            NSLog(@"여기일까????");
            NSString *db16_1 = @"CREATE TABLE IF NOT EXISTS CHAT_ROOM_INFO(ROOM_NO INTEGER PRIMARY KEY, ROOM_TYPE TEXT, LAST_CHAT_NO INTEGER, EXIT_FLAG TEXT);";
            [self crudStatement:db16_1];
        }
    }
}

- (NSString *)getDBPath {
//    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    NSString *dbName = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DBNAME"]];
    NSString *dbName = [userDefaults objectForKey:[self setPreferencesKey:@"DBNAME"]];

    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *dbPath = [NSString stringWithFormat:@"%@.db", [documentsDir stringByAppendingPathComponent:dbName]];
    NSLog(@"DBPath : %@", dbPath);

    return dbPath;
}

- (NSString *)useAppGroupDB{
    /*
    1. 앱그룹 경로에 디비 있는지 체크
    2. 있으면 연결
    3. 없으면,
    4. 기존 경로에 디비 있는지 체크
    5. 있으면 해당 디비를 앱그룹 경로에 복사 후, 기존 경로에 디비 삭제
    6. 앱그룹 디비에 연결
    7. 기존 경로에도 디비가 없으면
    8. 앱그룹 경로에 디비 생성 및 연결
    */
    
//    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    NSString *dbName = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DBNAME"]];
    NSString *dbName;
    NSString *appGroupName;
    dbName = [userDefaults objectForKey:[self setPreferencesKey:@"DBNAME"]];
    appGroupName = [userDefaults objectForKey:@"NOTIGROUPNAME"];
    
    NSString *appGroupDirectoryPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupName].path;
    NSString *groupDbPath = [NSString stringWithFormat:@"%@.db", [appGroupDirectoryPath stringByAppendingPathComponent:dbName]];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *localDbPath = [NSString stringWithFormat:@"%@.db", [documentsDir stringByAppendingPathComponent:dbName]];
    
//    NSLog(@"appGroupDirectoryPath : %@", appGroupDirectoryPath);
//    NSLog(@"localDbPath : %@", localDbPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:groupDbPath]) {
        NSLog(@"앱그룹 경로에 디비 있음");
        [fileManager copyItemAtPath:groupDbPath toPath:localDbPath error:&error];
        [fileManager removeItemAtPath:groupDbPath error:&error];

    } else {
        NSLog(@"앱그룹 경로에 디비 없음");
        if ([fileManager fileExistsAtPath:localDbPath]) {
            NSLog(@"로컬 경로에 디비 있음");
        } else {
            NSLog(@"로컬 경로에 디비 없음");
        }
    }
    groupDbPath = localDbPath;
    NSLog(@"groupDbPath : %@", groupDbPath);
    
//    if ([fileManager fileExistsAtPath:groupDbPath]) {
//        NSLog(@"앱그룹 경로에 디비 있음");
//        //[fileManager removeItemAtPath:groupDbPath error:&error];
//
//    } else {
//        NSLog(@"앱그룹 경로에 디비 없음");
//        if ([fileManager fileExistsAtPath:localDbPath]) {
//            NSLog(@"로컬 경로에 디비 있음, 앱 경로로 복사");
//
//            //[fileManager removeItemAtPath:prevPath error:&error];
//
//        } else {
//            NSLog(@"로컬 경로에 디비 없음");
//        }
//    }
    
//    if ([fileManager fileExistsAtPath:localDbPath]) {
//        NSLog(@"경로에 디비 있음");
//        [fileManager removeItemAtPath:localDbPath error:&error];
//
//    } else {
//        NSLog(@"경로에 디비 없음");
//        if ([fileManager fileExistsAtPath:groupDbPath]) {
//            NSLog(@"앱 경로에 디비 있음, 로컬 경로로 복사");
//            [fileManager copyItemAtPath:groupDbPath toPath:localDbPath error:&error];
//
//
//        } else {
//            NSLog(@"앱 경로에 디비 없음");
//        }
//    }
//    groupDbPath = localDbPath;
    
    return groupDbPath;
}

- (void)openDB {
    //데이터베이스 생성
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 생성");
    if(sqliteOpen != SQLITE_OK){
        NSAssert(0, @"DB failed to open.");
    }
}

-(void)encryptDB{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> 암호화DB 생성");
    
    //DB파일 암호화
    sqlite3_stmt *stmt;
    bool sqlcipher_valid = NO;

    if (sqliteOpen == SQLITE_OK) {
        NSString *aes256key = [userDefaults objectForKey:@"AES256KEY"];
        
        const char* key = [aes256key UTF8String];
        sqlite3_key(db, key, (int)strlen(key));
        if (sqlite3_exec(db, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL) == SQLITE_OK) {
            if(sqlite3_prepare_v2(db, "PRAGMA cipher_version;", -1, &stmt, NULL) == SQLITE_OK) {
                if(sqlite3_step(stmt)== SQLITE_ROW) {
                    const unsigned char *ver = sqlite3_column_text(stmt, 0);
                    if(ver != NULL) {
                        sqlcipher_valid = YES;
                    }
                }
                sqlite3_finalize(stmt);
            }
        }
    } else {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> 암호화DB 생성 FAILED");
    }
}

-(void)dbEncryptCheck{
    if (sqliteOpen == SQLITE_OK) {
        NSLog(@"1. >>>>>>>>>>>>>>>>>>>>>>>>>> SQLite OPEN");

        if([[MFSingleton sharedInstance] dbEncrypt]){
            NSLog(@"2. >>>>>>>>>>>>>>>>>>>>>>>>>> 암호화 DB 사용");
            if (sqlite3_exec(db, (const char*) "PRAGMA key = 'E3Z2S1M5A9R8T1F3E2E4L31504081532'", NULL, NULL, NULL) == SQLITE_OK) {
                NSLog(@"3. >>>>>>>>>>>>>>>>>>>>>>>>>> 암호화DB 패스워드 체크");
                isCorrect = YES;
            } else {
                NSLog(@"3-2. >>>>>>>>>>>>>>>>>>>>>>>>>> 암호화DB 패스워드 체크 실패");
                isCorrect = NO;
            }
        } else {
            NSLog(@"2-2. >>>>>>>>>>>>>>>>>>>>>>>>>> 일반 DB 사용");
            isCorrect = YES;
        }
        
    } else {
        NSLog(@"1-2. >>>>>>>>>>>>>>>>>>>>>>>>>> SQLite OPEN FAILED");
    }
}

-(void)restoreInsertDB{
    NSString *dbName = [userDefaults objectForKey:[self setPreferencesKey:@"DBNAME"]];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *dbPath = [NSString stringWithFormat:@"%@.db", [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"TEMP_%@", dbName]]];
    NSLog(@"TEMP_DBPATH : %@", dbPath);
    
//    NSString *dbPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"BP15214.db"];
    //aaa : /private/var/containers/Bundle/Application/19E9BDEB-03DA-48C5-8FE5-AAC7B38394E3/mfinity_sns.app/BP15214.db
    
    if(isCorrect){
        if (sqliteOpen == SQLITE_OK) {
            //현재 연결된 DB(BP15214.db)에 복원할 디비(TEMP_BP15214.db)를 연결
            NSString *attachSQL = [NSString stringWithFormat:@"ATTACH DATABASE \'%@\' AS RESOTRE_DB KEY 'E3Z2S1M5A9R8T1F3E2E4L31504081532';", dbPath];
            
            if (sqlite3_exec(db, [attachSQL UTF8String], NULL, NULL, NULL) == SQLITE_OK) {
                
                //복원할 디비에서 전체 테이블 검색
                NSString *masterQuery = [NSString stringWithFormat:@"SELECT name FROM RESOTRE_DB.sqlite_master WHERE type='table';"];
                const char *masterStmt = [masterQuery UTF8String];
                sqlite3_stmt *statement;
                
                if (sqlite3_prepare_v2(db, masterStmt, -1, &statement, NULL) == SQLITE_OK) {
                    int rowCount = 0;
                    while(sqlite3_step(statement) == SQLITE_ROW) {
                        rowCount = sqlite3_column_int(statement, 0);
                        
                        NSString * currentTable = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                        //NSLog(@"Here's the current table: %@",currentTable);
                        
                        NSString *tblUpdate;
                        //복원할 디비 데이터를 원본 디비로 INSERT OR REPLACE
                        tblUpdate = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ SELECT * FROM RESOTRE_DB.%@;", currentTable, currentTable];
                        
                        const char *updateStmt = [tblUpdate UTF8String];
                        if (sqlite3_exec(db, updateStmt, NULL, NULL, NULL) == SQLITE_OK) {
                            NSLog(@"tblUpdate : %@", tblUpdate);
                        } else {
                            NSLog(@"ATTACHE INSERT ERROR : %s\n", sqlite3_errmsg(db));
                        }
                    }
                } else {
                    NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), masterQuery);
                }
                sqlite3_finalize(statement);
              
                NSString *detachSQL = [NSString stringWithFormat:@"DETACH DATABASE RESTORE_DB;"];
                if (sqlite3_exec(db, [detachSQL UTF8String], NULL, NULL, NULL) == SQLITE_OK) {
                    NSLog(@"복원 했으니 연결 해제");
                } else {
                    //NSLog(@"이건 왜 안돼? : %s\n", sqlite3_errmsg(db));
                }
            } else {
                NSLog(@"Could not exec statement: %s\n", sqlite3_errmsg(db));
            }
        }
    } else {
        NSLog(@"restoreInsertDB isCorrect Value = NO");
    }

//    [SVProgressHUD dismiss];
}

-(void)clearDataBase{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *bundleFolder = [documentFolder stringByAppendingFormat:@"/%@/",bundleIdentifier];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self useAppGroupDB]]) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> DB 지우고 다시 생성");
        [fileManager removeItemAtPath:[self useAppGroupDB] error:nil];
        [fileManager removeItemAtPath:bundleFolder error:nil];
        sqliteOpen = sqlite3_open([[self useAppGroupDB] UTF8String], &db);
    }
    
    [self createLocalFolder];
    
//    if([[userDefaults objectForKey:@"DBENCRYPT"] isEqual:@1]){
    if([[MFSingleton sharedInstance] dbEncrypt]){
        [self encryptDB];
    } else {
        [self openDB];
    }
    
    [self dbEncryptCheck];
    
    [self createTable];
    
    [userDefaults setObject:@"DB_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
    [userDefaults synchronize];
}

#pragma mark - CREATE DATA
-(void)createLocalFolder{
    NSLog(@"%s", __func__);
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *bundleFolder = [documentFolder stringByAppendingFormat:@"/%@/",bundleIdentifier];
    NSString *compFolder = [bundleFolder stringByAppendingFormat:@"/%@/",[userDefaults objectForKey:@"COMP_NO"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:bundleFolder];
    if (issue) {
        
    }else{
        [fileManager createDirectoryAtPath:compFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *folderArr = @[@"Post", @"Task", @"Chat", @"Profile", @"ProfileBg", @"Cover", @"Cache"];
    for(int i=0; i<folderArr.count; i++){
        NSString *saveFolder = [compFolder stringByAppendingFormat:@"/%@/",[folderArr objectAtIndex:i]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
        if (issue) {
            
        }else{
            [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (void)createTable {
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>> 테이블 생성 및 데이터 추가");
    
    NSString *CHAT_ROOMS = @"CREATE TABLE IF NOT EXISTS CHAT_ROOMS (ROOM_NO INTEGER PRIMARY KEY, ROOM_NM TEXT NOT NULL, ROOM_TYPE TEXT NOT NULL, ROOM_NOTI INTEGER DEFAULT 1, NEW_CHAT INTEGER DEFAULT 0, CUSTOM_ROOM_NM TEXT DEFAULT '', IS_SCROLL INTEGER DEFAULT 0);";
    [self crudStatement:CHAT_ROOMS];
    
    NSString *CHAT_USERS = @"CREATE TABLE IF NOT EXISTS CHAT_USERS (ROOM_NO INTEGER, USER_NO INTEGER NOT NULL, PRIMARY KEY(ROOM_NO,USER_NO));";
    [self crudStatement:CHAT_USERS];
    
    NSString *USERS = @"CREATE TABLE IF NOT EXISTS USERS (USER_NO INTEGER PRIMARY KEY, USER_ID TEXT NOT NULL, USER_NM TEXT NOT NULL, USER_IMG TEXT, USER_MSG TEXT, USER_PHONE TEXT, DEPT_NO TEXT NOT NULL, USER_BG_IMG TEXT, DEPT_NM TEXT DEFAULT '', LEVEL_NO TEXT DEFAULT '', LEVEL_NM TEXT DEFAULT '', DUTY_NO TEXT DEFAULT '', DUTY_NM TEXT DEFAULT '', JOB_GRP_NM TEXT DEFAULT '', EX_COMPANY_NO TEXT DEFAULT '', EX_COMPANY_NM TEXT DEFAULT '', SNS_USER_TYPE INTEGER DEFAULT 0);";
    [self crudStatement:USERS];
    
    NSString *DEPTS = @"CREATE TABLE IF NOT EXISTS DEPTS (DEPT_NO TEXT PRIMARY KEY, DEPT_NM TEXT NOT NULL, UP_DEPT_NO TEXT NOT NULL);";
    [self crudStatement:DEPTS];
    
    NSString *SNS = @"CREATE TABLE IF NOT EXISTS SNS (SNS_NO INTEGER PRIMARY KEY, SNS_NM TEXT NOT NULL, SNS_TY TEXT NOT NULL, NEED_ALLOW TEXT, SNS_DESC TEXT, COVER_IMG TEXT, CUSER_NO INTEGER, USER_NM TEXT, CREATE_DATE TEXT, COMP_NO INTEGER NOT NULL, POST_NOTI INTEGER DEFAULT 1, COMMENT_NOTI INTEGER DEFAULT 1, SNS_KIND TEXT NOT NULL);";
    [self crudStatement:SNS];
    
    NSString *SNS_USERS = @"CREATE TABLE IF NOT EXISTS SNS_USERS (SNS_NO INTEGER NOT NULL, CUSER_NO INTEGER NOT NULL, PRIMARY KEY(SNS_NO,CUSER_NO));";
    [self crudStatement:SNS_USERS];
    
    /*
     UNREAD_COUNT는 전체 안읽은 개수
     IS_READ는 내가 읽었는지 안읽었는지
     IS READ : 0:내가 안읽음, 1: 내가 읽음
     */
    NSString *CHATS = @"CREATE TABLE IF NOT EXISTS CHATS (CHAT_NO INTEGER PRIMARY KEY, ROOM_NO INTEGER NOT NULL, USER_NO INTEGER NOT NULL, CONTENT_TY TEXT NOT NULL, CONTENT TEXT, LOCAL_CONTENT TEXT NOT NULL, FILE_NM TEXT, ADIT_INFO TEXT, DATE TEXT NOT NULL, IS_READ INTEGER DEFAULT 0, UNREAD_COUNT INTEGER DEFAULT 0, CONTENT_PREV TEXT);";
    [self crudStatement:CHATS];
    
    NSString *MISSED_CHAT = @"CREATE TABLE IF NOT EXISTS MISSED_CHATS (CHAT_NO INTEGER PRIMARY KEY AUTOINCREMENT, ROOM_NO INTEGER NOT NULL, CONTENT_TY TEXT NOT NULL, CONTENT TEXT NOT NULL, FILE_NM TEXT, CONTENT_THUMB TEXT DEFAULT '', ADIT_INFO TEXT);";
    [self crudStatement:MISSED_CHAT];
    
    NSString *ROOM_IMAGES = @"CREATE TABLE IF NOT EXISTS ROOM_IMAGES(ROOM_NO INTEGER PRIMARY KEY, ROOM_IMG TEXT NOT NULL, REF_NO1 INTEGER, REF_NO2 INTEGER, REF_NO3 INTEGER, REF_NO4 INTEGER);";
    [self crudStatement:ROOM_IMAGES];
    
    NSString *CHAT_ROOM_INFO = @"CREATE TABLE IF NOT EXISTS CHAT_ROOM_INFO(ROOM_NO INTEGER PRIMARY KEY, ROOM_TYPE TEXT, LAST_CHAT_NO INTEGER, EXIT_FLAG TEXT);";
    [self crudStatement:CHAT_ROOM_INFO];
    
    NSString *insertUsers1 = @"INSERT OR REPLACE INTO USERS VALUES(0,'admin','SYSTEM','','','','0','','','','','','','','','',1);";
    [self crudStatement:insertUsers1];

    NSString *insertUsers2 = @"INSERT OR REPLACE INTO USERS VALUES(2,'admin','admin','','','','0','','','','','','','','','',1);";
    [self crudStatement:insertUsers2];
}

#pragma mark - QUERY EXECUTE
- (void)crudStatement:(NSString *)crudStmt{
    if(isCorrect){
        const char *sqlStatement = [crudStmt UTF8String];
        
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                NSLog(@"Error updating table: %s", sqlite3_errmsg(db));
            }else{
                NSLog(@"MFDBHelper CrudStatement Succeed!");
            }
            
            if(sqlite3_finalize(compiledStatement) != SQLITE_OK){
                NSLog(@"SQL Error : %s",sqlite3_errmsg(db));
            }
        } else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), crudStmt);
        }
    } else {
        NSLog(@"isCorrect Value = NO");
    }
}

- (void)crudStatement:(NSString *)crudStmt completion:(void (^)())completion{
    if(isCorrect){
        const char *sqlStatement = [crudStmt UTF8String];
        
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                NSLog(@"Error updating table: %s", sqlite3_errmsg(db));
            }else{
                NSLog(@"MFDBHelper CrudStatement Succeed!");
                completion();
            }
            
            if(sqlite3_finalize(compiledStatement) != SQLITE_OK){
                NSLog(@"SQL Error : %s",sqlite3_errmsg(db));
            }
        } else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), crudStmt);
        }
    } else {
        NSLog(@"isCorrect Value = NO");
    }
}

- (NSMutableArray *)selectRoomList {
    NSString *sqlString = [self getRoomList];
    return [self selectMutableArray:sqlString];
}

- (NSString *)selectString:(NSString *)selectStmt{
    NSString *returnStr;
    if(isCorrect){
        const char *sqlStatement = [selectStmt UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = valueString;
                }
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), selectStmt);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    return returnStr;
}

- (NSString *)selectString:(NSString *)selectStmt :(NSString *)param1{
    NSString *returnStr;
    
    return returnStr;
}

- (NSMutableArray *)selectValueMutableArray:(NSString *)query{
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableDictionary *dict = nil;
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                dict = [[NSMutableDictionary alloc]init];
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [arr addObject:valueString];
                }
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    return arr;
}

- (NSMutableArray *)selectArray:(NSString *)query{
    NSMutableArray *arr = [NSMutableArray array];
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [arr addObject:valueString];
                }
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    return arr;
}

- (NSMutableArray *)selectMutableArray:(NSString *)query{
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableDictionary *dict = nil;
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                dict = [[NSMutableDictionary alloc]init];
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dict setObject:valueString forKey:keyString];
                }
                
                [arr addObject:dict];
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    return arr;
}

- (NSMutableArray *)selectMutableArray:(NSString *)query :(NSMutableArray *)paramArr{
    NSMutableDictionary *dict = nil;
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                dict = [[NSMutableDictionary alloc]init];
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dict setObject:valueString forKey:keyString];
                }
                [paramArr insertObject:dict atIndex:0];
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    return paramArr;
}

- (NSMutableDictionary *)selectMutableDictionary:(NSString *)query :(NSMutableArray *)paramArr{
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableDictionary *dict = nil;
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                dict = [[NSMutableDictionary alloc]init];
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dict setObject:valueString forKey:keyString];
                    
                    if([keyString isEqualToString:@"USER_NO"]){
                        [paramArr addObject:[NSNumber numberWithInteger:[valueString integerValue]]];
                    }
                }
                [arr addObject:dict];
            }
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
        
    } else {
        NSLog(@"isCorrect Value = NO");
    }
    
    [resultDic setObject:arr forKey:@"USER_ARR"];
    [resultDic setObject:paramArr forKey:@"EXIST_USER_ARR"];
    
    return resultDic;
}

-(NSString *)testQurey{
    NSString *query = @"select * from chat_rooms where room_no = 999";
    NSString *returnStr;
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    
    if(isCorrect){
        const char *sqlStatement = [query UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            [dict1 setObject:@"SUCCEED" forKey:@"RESULT"];
            
            int rowCount = 0;
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                
                NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
                
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dict2 setObject:valueString forKey:keyString];
                }
                
                [arr addObject:dict2];
            }
            if(rowCount==0){
                [dict1 setObject:@"" forKey:@"DATASET"];
            }else{
                [dict1 setObject:arr forKey:@"DATASET"];
            }
            
            
        }else {
            NSLog(@"Failed! : %s\n query : %@", sqlite3_errmsg(db), query);
        }
        sqlite3_finalize(compiledStatement);
    }
    
    NSLog(@"dict1 : %@", dict1);
    NSData *strData = [NSJSONSerialization dataWithJSONObject:dict1 options:kNilOptions error:nil];
    returnStr = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    NSLog(@"returnStr : %@", returnStr);
    return returnStr;
}

#pragma mark - QUERY STRING
#pragma mark SELECT
//getSNS
-(NSString *)getAllSnsList{
    NSString *query = @"SELECT SNS_NO, SNS_NM, SNS_TY, NEED_ALLOW, SNS_DESC, COVER_IMG, CUSER_NO, CREATE_DATE, COMP_NO, SNS_KIND, POST_NOTI, COMMENT_NOTI, USER_NM FROM SNS";
    return query;
}
-(NSString *)getSnsList:(NSString *)snsKind{
    NSString *query = [NSString stringWithFormat:@"SELECT SNS_NO, SNS_NM, SNS_TY, NEED_ALLOW, SNS_DESC, COVER_IMG, CUSER_NO, CREATE_DATE, COMP_NO, SNS_KIND, POST_NOTI, COMMENT_NOTI, USER_NM FROM SNS WHERE SNS_KIND = %@", snsKind];
    return query;
}
//getSNSNoList
-(NSString *)getSnsNo:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"SELECT SNS_NO FROM SNS WHERE SNS_NO=%@", snsNo];
    return query;
}
-(NSString *)getSnsName:(NSString *)snsName{
    NSString *query = [NSString stringWithFormat:@"SELECT SNS_NM FROM SNS WHERE SNS_NO=%@", snsName];
    return query;
}
//getSnsUserList
-(NSString *)getSnsUserList:(NSString *)userList{
    NSString *query = [NSString stringWithFormat:@"SELECT X.* FROM ( SELECT USER_NO, USER_ID, USER_NM, USER_IMG, USER_BG_IMG, USER_MSG, USER_PHONE, DEPT_NO, DEPT_NM, CASE LENGTH(LEVEL_NO) WHEN 0 THEN '99999999' ELSE LEVEL_NO END AS LEVEL_NO, LEVEL_NM, CASE LENGTH(DUTY_NO) WHEN 0 THEN '99999999' ELSE DUTY_NO END AS DUTY_NO, DUTY_NM, JOB_GRP_NM, EX_COMPANY_NO, EX_COMPANY_NM, SNS_USER_TYPE FROM USERS WHERE USER_NO IN (%@)) X ORDER BY X.DUTY_NO ASC, X.LEVEL_NO ASC, X.USER_NM ASC;", userList];
    return query;
}

//getPostAndCommentNoti
-(NSString *)getPostNoti:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"SELECT POST_NOTI FROM SNS WHERE SNS_NO=%@", snsNo];
    return query;
}
//getPostAndCommentNoti
-(NSString *)getCommentNoti:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"SELECT COMMENT_NOTI FROM SNS WHERE SNS_NO=%@", snsNo];
    return query;
}
//getRoomList
-(NSString *)getRoomList{
    NSString *query = @"SELECT Z.LAST_MSG_TY, SUM(Z.NOT_READ_COUNT) NOT_READ_COUNT, Z.ROOM_NO, Z.ROOM_TYPE, Z.ROOM_NM, Z.ROOM_NOTI, Z.NEW_CHAT, Z.CONTENT_TY, Z.CONTENT, Z.LAST_DATE, Z.MEMBER_COUNT, Z.MEMBER_NO FROM ( SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'SUCCEED' LAST_MSG_TY, X1.NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' WHEN X2.CONTENT_TY = 'LONG_TEXT' THEN X2.CONTENT_PREV ELSE X2.CONTENT END CONTENT, X2.DATE LAST_DATE FROM (SELECT SUM(CASE A.IS_READ WHEN 1 THEN 0 ELSE 1 END) NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO AND A.CONTENT_TY != 'SYS' GROUP BY A.ROOM_NO )X1, CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO UNION SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'MISSED' LAST_MSG_TY, 0 NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' ELSE X2.CONTENT END CONTENT, DATETIME('NOW','LOCALTIME') LAST_DATE FROM (SELECT 0 NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM MISSED_CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO GROUP BY A.ROOM_NO )X1, MISSED_CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO ) Z GROUP BY Z.ROOM_NO ORDER BY Z.NEW_CHAT DESC , Z.LAST_DATE DESC;";
    return query;
}
-(NSString *)getRoomList:(NSString*)param{
    NSString *query = [NSString stringWithFormat:@"SELECT Z.LAST_MSG_TY, SUM(Z.NOT_READ_COUNT) NOT_READ_COUNT, Z.ROOM_NO, Z.ROOM_TYPE, Z.ROOM_NM, Z.ROOM_NOTI, Z.NEW_CHAT, Z.CONTENT_TY, Z.CONTENT, Z.LAST_DATE, Z.MEMBER_COUNT, Z.MEMBER_NO FROM ( SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'SUCCEED' LAST_MSG_TY, X1.NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' WHEN X2.CONTENT_TY = 'LONG_TEXT' THEN X2.CONTENT_PREV ELSE X2.CONTENT END CONTENT, X2.DATE LAST_DATE FROM (SELECT SUM(CASE A.IS_READ WHEN 1 THEN 0 ELSE 1 END) NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO AND A.CONTENT_TY != 'SYS' AND (UPPER(a.content) like '%@%%' OR UPPER(b.room_nm) like '%@%%') GROUP BY A.ROOM_NO )X1, CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO UNION SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'MISSED' LAST_MSG_TY, 0 NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' ELSE X2.CONTENT END CONTENT, DATETIME('NOW','LOCALTIME') LAST_DATE FROM (SELECT 0 NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM MISSED_CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO AND (UPPER(a.content) like '%@%%' OR UPPER(b.room_nm) like '%@%%') GROUP BY A.ROOM_NO )X1, MISSED_CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO ) Z GROUP BY Z.ROOM_NO ORDER BY Z.NEW_CHAT DESC , Z.LAST_DATE DESC;", param, param, param, param];
    return query;
}
-(NSString *)getNotOfTypeRoomList:(NSString *)roomType{
    NSString *query = [NSString stringWithFormat:@"SELECT Z.LAST_MSG_TY, SUM(Z.NOT_READ_COUNT) NOT_READ_COUNT, Z.ROOM_NO, Z.ROOM_TYPE, Z.ROOM_NM, Z.ROOM_NOTI, Z.NEW_CHAT, Z.CONTENT_TY, Z.CONTENT, Z.LAST_DATE, Z.MEMBER_COUNT, Z.MEMBER_NO FROM ( SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'SUCCEED' LAST_MSG_TY, X1.NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' WHEN X2.CONTENT_TY = 'LONG_TEXT' THEN X2.CONTENT_PREV ELSE X2.CONTENT END CONTENT, X2.DATE LAST_DATE FROM (SELECT SUM(CASE A.IS_READ WHEN 1 THEN 0 ELSE 1 END) NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO AND A.CONTENT_TY != 'SYS' AND B.ROOM_TYPE != %@ GROUP BY A.ROOM_NO )X1, CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO UNION SELECT X.*, GROUP_CONCAT(Y.USER_NO) MEMBER_NO, COUNT(Y.USER_NO) MEMBER_COUNT FROM (SELECT 'MISSED' LAST_MSG_TY, 0 NOT_READ_COUNT, X2.ROOM_NO ROOM_NO, X3.ROOM_TYPE ROOM_TYPE, CASE WHEN LENGTH(X3.CUSTOM_ROOM_NM) > 0 THEN X3.CUSTOM_ROOM_NM ELSE X3.ROOM_NM END ROOM_NM, X3.ROOM_NOTI ROOM_NOTI, X3.NEW_CHAT NEW_CHAT, X2.CONTENT_TY CONTENT_TY, CASE WHEN X2.CONTENT_TY = 'FILE' THEN '파일' WHEN X2.CONTENT_TY = 'IMG' THEN '사진' WHEN X2.CONTENT_TY = 'VIDEO' THEN '동영상' WHEN X2.CONTENT_TY = 'INVITE' THEN '초대' ELSE X2.CONTENT END CONTENT, DATETIME('NOW','LOCALTIME') LAST_DATE FROM (SELECT 0 NOT_READ_COUNT, MAX(A.CHAT_NO) CHAT_NO, A.ROOM_NO FROM MISSED_CHATS A, CHAT_ROOMS B WHERE A.ROOM_NO = B.ROOM_NO GROUP BY A.ROOM_NO )X1, MISSED_CHATS X2, CHAT_ROOMS X3 WHERE X2.CHAT_NO = X1.CHAT_NO AND X3.ROOM_NO = X2.ROOM_NO AND X2.ROOM_NO = X1.ROOM_NO) X,CHAT_USERS Y WHERE X.ROOM_NO = Y.ROOM_NO GROUP BY X.ROOM_NO ) Z GROUP BY Z.ROOM_NO ORDER BY Z.NEW_CHAT DESC , Z.LAST_DATE DESC;", roomType];
    return query;
}
//getRoomInfo
-(NSString *)getRoomName:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_NM FROM CHAT_ROOMS WHERE ROOM_NO = %@", roomNo];
    return query;
}
//getRoomInfo
-(NSString *)getRoomType:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_TYPE FROM CHAT_ROOMS WHERE ROOM_NO = %@", roomNo];
    return query;
}
//getRoomInfo
-(NSString *)getRoomInfo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_NM, ROOM_NOTI, ROOM_TYPE FROM CHAT_ROOMS WHERE ROOM_NO = %@", roomNo];
    return query;
}
//getRoomNoti
-(NSString *)getRoomNoti:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_NOTI FROM CHAT_ROOMS WHERE ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getRoomImg:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_IMG FROM ROOM_IMAGES WHERE ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getUpdateRoomList:(NSString *)myUserNo roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT A.ROOM_NO ROOM_NO, A.ROOM_NM ROOM_NM, A.ROOM_NOTI ROOM_NOTI, A.NEW_CHAT NEW_CHAT, (SELECT COUNT(B.USER_NO) FROM CHAT_USERS B WHERE B.ROOM_NO = A.ROOM_NO) MEMBER_COUNT, IFNULL((SELECT DATE FROM CHATS C WHERE C.ROOM_NO = A.ROOM_NO ORDER BY C.CHAT_NO DESC LIMIT 1),'') LAST_DATE, IFNULL(B.USER_IMG,'') ROOM_IMG FROM CHAT_ROOMS A LEFT OUTER JOIN(SELECT C.ROOM_NO, GROUP_CONCAT(D.USER_IMG) USER_IMG FROM CHAT_USERS C, USERS D WHERE LENGTH(D.USER_IMG) > 0 AND D.USER_NO = C.USER_NO AND C.USER_NO != %@ GROUP BY C.ROOM_NO) B ON A.ROOM_NO = B.ROOM_NO WHERE A.ROOM_NO = %@ ORDER BY ROOM_NO ASC;", myUserNo, roomNo];
    return query;
}
-(NSString *)getRoomNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_NO FROM CHAT_USERS WHERE USER_NO = %@", userNo];
    return query;
}
-(NSString *)getCustomRoomName:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT CUSTOM_ROOM_NM FROM CHAT_ROOMS WHERE ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getUserNoAndUserImg:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT A.USER_NO, A.USER_IMG FROM USERS A, CHAT_USERS B, CHAT_ROOMS C WHERE A.USER_NO = B.USER_NO AND B.ROOM_NO = C.ROOM_NO AND C.ROOM_NO = %@", roomNo];
    return query;
}
//-(NSString *)getCurrRoomAndChat{
//    NSString *query = [NSString stringWithFormat:@"SELECT A.ROOM_NO, IFNULL(MAX(B.CHAT_NO), 0) FROM CHAT_ROOMS A, CHATS B WHERE A.ROOM_NO = B.ROOM_NO GROUP BY A.ROOM_NO"];
//    return query;
//}
-(NSString *)getChatRoomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT ROOM_NO FROM CHAT_ROOMS"];
    return query;
}


//getUserInfo
-(NSString *)getUserInfo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM USERS WHERE USER_NO = %@;", userNo];
    return query;
}
-(NSString *)getSnsUserType:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"SELECT SNS_USER_TYPE FROM USERS WHERE USER_NO = %@", userNo];
    return query;
}
-(NSString *)getRoomUserInfo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT A.* FROM USERS A, CHAT_USERS B WHERE A.USER_NO = B.USER_NO AND B.ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getRoomUserNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT USER_NO FROM CHAT_USERS WHERE ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getRoomUserCount:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(USER_NO) FROM CHAT_USERS WHERE ROOM_NO = %@", roomNo];
    return query;
}
//getUnreadChatNoRange
-(NSString *)getUnreadChatNoRange:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT IFNULL(MIN(CHAT_NO),'-1') FIRST_CHAT, IFNULL(MAX(CHAT_NO),'-1') LAST_CHAT FROM CHATS WHERE CONTENT_TY != 'SYS' AND IS_READ = 0 AND ROOM_NO = %@", roomNo];
    return query;
}
-(NSString *)getUnreadChatNoRange:(NSString *)roomNo myUserNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"SELECT IFNULL(MIN(CHAT_NO),'-1') FIRST_CHAT, IFNULL(MAX(CHAT_NO),'-1') LAST_CHAT FROM CHATS WHERE CONTENT_TY != 'SYS' AND IS_READ = 0 AND ROOM_NO = %@ AND USER_NO != %@", roomNo, userNo];
    return query;
}
-(NSString *)getMyUnreadChatNoRange:(NSString *)roomNo myUserNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"SELECT IFNULL(MIN(CHAT_NO),'-1') FIRST_CHAT, IFNULL(MAX(CHAT_NO),'-1') LAST_CHAT FROM CHATS WHERE CONTENT_TY != 'SYS' AND IS_READ = 1 AND ROOM_NO = %@ AND USER_NO = %@", roomNo, userNo];
    return query;
}

//lastInsertRowID
-(NSString *)getLastInsertRowID{
    NSString *query = @"SELECT * FROM MISSED_CHATS ORDER BY CHAT_NO DESC LIMIT 1;";
    return query;
}
-(NSString *)getContentLongChat:(NSString *)chatNo{
    NSString *query = [NSString stringWithFormat:@"SELECT CONTENT FROM CHATS WHERE CHAT_NO=%@", chatNo];
    return query;
}
-(NSString *)getMissedChat:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT *,datetime('now','localtime') DATE FROM MISSED_CHATS WHERE ROOM_NO = %@;", roomNo];
    return query;
}
-(NSString *)getCheckMissedChatDate:(NSString *)roomNo type:(NSString *)type content:(NSString *)content{
    NSString *query = [NSString stringWithFormat:@"SELECT *,datetime('now','localtime') DATE FROM MISSED_CHATS WHERE ROOM_NO = %@ AND CONTENT_TY = %@ AND CONTENT = %@;", roomNo, type, content];
    return query;
}

//getChatList
-(NSString *)getChatList:(NSString *)roomNo rowCount:(int)rowCnt{
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM ( SELECT '' TYPE, A.ROOM_NO, A.CHAT_NO, A.USER_NO, B.USER_NM, B.USER_IMG, A.CONTENT_TY, A.CONTENT, A.CONTENT_PREV, A.LOCAL_CONTENT, A.FILE_NM, A.ADIT_INFO, A.DATE, A.UNREAD_COUNT FROM CHATS A, USERS B WHERE ROOM_NO = %@ AND A.USER_NO = B.USER_NO UNION SELECT 'MISSED' TYPE, A.ROOM_NO, A.CHAT_NO, 10, '', '', A.CONTENT_TY, A.CONTENT, '', '', A.FILE_NM, A.ADIT_INFO, DATETIME('now','localtime'), 0 UNREAD_COUNT FROM MISSED_CHATS A WHERE A.ROOM_NO = %@ ) X ORDER BY X.TYPE DESC, X.CHAT_NO DESC LIMIT 50 OFFSET %d;", roomNo, roomNo, rowCnt];
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM ( SELECT '' TYPE, A.ROOM_NO, A.CHAT_NO, A.USER_NO, B.USER_NM, B.USER_IMG, A.CONTENT_TY, A.CONTENT, A.CONTENT_PREV, A.LOCAL_CONTENT, A.FILE_NM, '' AS CONTENT_THUMB, A.ADIT_INFO, A.DATE, A.UNREAD_COUNT FROM CHATS A, USERS B WHERE ROOM_NO = %@ AND A.USER_NO = B.USER_NO UNION SELECT 'MISSED' TYPE, A.ROOM_NO, A.CHAT_NO, 10, '', '', A.CONTENT_TY, A.CONTENT, '', '', A.FILE_NM, A.CONTENT_THUMB, A.ADIT_INFO, DATETIME('now','localtime'), 0 UNREAD_COUNT FROM MISSED_CHATS A WHERE A.ROOM_NO = %@ ) X ORDER BY X.TYPE DESC, X.CHAT_NO DESC LIMIT 50 OFFSET %d;", roomNo, roomNo, rowCnt];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM ( SELECT '' TYPE, A.CHAT_NO, A.USER_NO, B.USER_NM, B.USER_IMG, A.CONTENT_TY, A.CONTENT, A.CONTENT_PREV, A.LOCAL_CONTENT, A.FILE_NM, '' AS CONTENT_THUMB, A.ADIT_INFO, A.DATE, A.UNREAD_COUNT FROM CHATS A, USERS B WHERE ROOM_NO = %@ AND A.USER_NO = B.USER_NO UNION SELECT 'MISSED' TYPE, A.CHAT_NO, 10, '', '', A.CONTENT_TY, A.CONTENT, '', '', A.FILE_NM, CONTENT_THUMB, A.ADIT_INFO, DATETIME('now','localtime'), 0 UNREAD_COUNT FROM MISSED_CHATS A WHERE A.ROOM_NO = %@ ) X ORDER BY X.TYPE DESC, X.CHAT_NO DESC LIMIT 50 OFFSET %d;", roomNo, roomNo, rowCnt];
    return query;
}
-(NSString *)getChatInfo{
    NSString *query = @"SELECT CHAT_NO, ROOM_NO, USER_NO, CONTENT FROM CHATS;";
    return query;
}

-(NSString *)getChatLastNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT IFNULL(MAX(CHAT_NO),'-1') LAST_CHAT FROM CHATS WHERE ROOM_NO = %@;", roomNo];
    return query;
}

-(NSString *)getChatRoomInfo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM CHAT_ROOM_INFO WHERE ROOM_NO = %@;", roomNo];
    return query;
}

#pragma mark INSERT
//insertSnsInfo
//-(NSString *)insertOrUpdateSns:(NSString *)snsNo snsName:(NSString *)snsName snsType:(NSString *)snsType needAllow:(NSString *)needAllow snsDesc:(NSString *)snsDesc coverImg:(NSString *)coverImg createUser:(NSString *)createUser createDate:(NSString *)createDate compNo:(NSString *)compNo snsKind:(NSString *)snsKind{
//    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SNS(SNS_NO, SNS_NM, SNS_TY, NEED_ALLOW, SNS_DESC, COVER_IMG, CUSER_NO, CREATE_DATE, COMP_NO, SNS_KIND) VALUES(%@, '%@', '%@', '%@', '%@', '%@', %@, '%@', %@, '%@');", snsNo, snsName, snsType, needAllow, snsDesc, coverImg, createUser, createDate, compNo, snsKind];
//    return query;
//}
-(NSString *)insertOrUpdateSns:(NSString *)snsNo snsName:(NSString *)snsName snsType:(NSString *)snsType needAllow:(NSString *)needAllow snsDesc:(NSString *)snsDesc coverImg:(NSString *)coverImg createUserNo:(NSString *)createUserNo createUserNm:(NSString *)createUserNm createDate:(NSString *)createDate compNo:(NSString *)compNo snsKind:(NSString *)snsKind {
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SNS(SNS_NO, SNS_NM, SNS_TY, NEED_ALLOW, SNS_DESC, COVER_IMG, CUSER_NO, USER_NM, CREATE_DATE, COMP_NO, SNS_KIND) VALUES(%@, '%@', '%@', '%@', '%@', '%@', %@, '%@', '%@', %@, '%@');", snsNo, snsName, snsType, needAllow, snsDesc, coverImg, createUserNo, createUserNm, createDate, compNo, snsKind];
    return query;
}

//insertOrUpdateUser
-(NSString *)insertOrUpdateUsers:(NSString *)userNo userId:(NSString *)userId userName:(NSString *)userName userImg:(NSString *)userImg userMsg:(NSString *)userMsg phoneNo:(NSString *)phoneNo deptNo:(NSString *)deptNo userBgImg:(NSString *)userBgImg deptName:(NSString *)deptName levelNo:(NSString *)levelNo levelName:(NSString *)levelName dutyNo:(NSString *)dutyNo dutyName:(NSString *)dutyName jobGrpName:(NSString *)jobGrpName exCompNo:(NSString *)exCompNo exCompName:(NSString *)exCompName userType:(NSString *)userType{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO USERS VALUES(%@, '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %@);", userNo, userId, userName, userImg, userMsg, phoneNo, deptNo, userBgImg, deptName, levelNo, levelName, dutyNo, dutyName, jobGrpName, exCompNo, exCompName, userType];
    return query;
}
//insertRoom
-(NSString *)insertChatRooms:(NSString *)roomNo roomName:(NSString *)roomName roomType:(NSString *)roomType{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CHAT_ROOMS VALUES (%@, '%@', '%@', 1, 0, '', 0);", roomNo, roomName, roomType];
    return query;
}
//insertChatUser (INSERT OR REPLACE INTO)
-(NSString *)insertChatUsers:(NSString *)roomNo userNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CHAT_USERS VALUES (%@, %@);", roomNo, userNo];
    return query;
}
//insertMissedChat
//-(NSString *)insertMissedChat:(NSString *)roomNo contentType:(NSString *)contentType content:(NSString *)content fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo{
//    NSString *query = [NSString stringWithFormat:@"INSERT INTO MISSED_CHATS(ROOM_NO, CONTENT_TY, CONTENT, FILE_NM, ADIT_INFO) VALUES(%@, '%@', '%@', '%@', '%@');", roomNo, contentType, content, fileName, aditInfo];
//    return query;
//}
-(NSString *)insertMissedChat:(NSString *)roomNo contentType:(NSString *)contentType content:(NSString *)content fileName:(NSString *)fileName contentThumb:(NSString *)contentThumb  aditInfo:(NSString *)aditInfo{
    NSString *query = [NSString stringWithFormat:@"INSERT INTO MISSED_CHATS(ROOM_NO, CONTENT_TY, CONTENT, FILE_NM, CONTENT_THUMB, ADIT_INFO) VALUES(%@, '%@', '%@', '%@', '%@', '%@');", roomNo, contentType, content, fileName, contentThumb, aditInfo];
    return query;
}
-(NSString *)insertOrUpdateChats:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CHATS(CHAT_NO,ROOM_NO,USER_NO,CONTENT_TY,CONTENT,LOCAL_CONTENT,DATE,FILE_NM,ADIT_INFO,IS_READ,UNREAD_COUNT,CONTENT_PREV) VALUES (%@, %@, %@, '%@', '%@', '%@', '%@', '%@', '%@', 0, %@,'%@');", chatNo, roomNo, userNo, contentType, content, localContent, date, fileName, aditInfo, unReadCnt, contentPrev];
    return query;
}
-(NSString *)insertOrUpdateChats2:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo isRead:(NSString *)isRead unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CHATS(CHAT_NO,ROOM_NO,USER_NO,CONTENT_TY,CONTENT,LOCAL_CONTENT,DATE,FILE_NM,ADIT_INFO,IS_READ,UNREAD_COUNT,CONTENT_PREV) VALUES (%@, %@, %@, '%@', '%@', '%@', '%@', '%@', '%@', %@, %@,'%@');", chatNo, roomNo, userNo, contentType, content, localContent, date, fileName, aditInfo, isRead, unReadCnt, contentPrev];
    return query;
}
//insertChat
-(NSString *)insertChats:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo isRead:(NSString *)isRead unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev{
    NSString *query = [NSString stringWithFormat:@"INSERT INTO CHATS(CHAT_NO, ROOM_NO, USER_NO, CONTENT_TY, CONTENT, LOCAL_CONTENT, DATE, FILE_NM, ADIT_INFO, IS_READ, UNREAD_COUNT, CONTENT_PREV) VALUES (%@, %@, %@, '%@', '%@', '%@', '%@', '%@', '%@', %@, %@,'%@');", chatNo, roomNo, userNo, contentType, content, localContent, date, fileName, aditInfo, isRead, unReadCnt, contentPrev];
    return query;
}
//insertRoomImage
-(NSString *)insertRoomImages:(NSString *)roomNo roomImg:(NSString *)roomImg refNo1:(NSString *)refNo1{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ROOM_IMAGES (ROOM_NO, ROOM_IMG, REF_NO1) VALUES (%@, '%@', %@);", roomNo, roomImg, refNo1];
    return query;
}
-(NSString *)insertRoomImages:(NSString *)resultKey roomNo:(NSString *)roomNo roomImg:(NSString *)roomImg resultVal:(NSString *)resultVal{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ROOM_IMAGES (ROOM_NO, ROOM_IMG, %@) VALUES (%@, '%@', %@);", resultKey, roomNo, roomImg, resultVal];
    return query;
}
//insertSnsUser
-(NSString *)insertSnsUser:(NSString *)snsNo userNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SNS_USERS (SNS_NO, CUSER_NO) VALUES (%@, %@);", snsNo, userNo];
    return query;
}

//insertChatRoomInfo
-(NSString *)insertChatRoomInfo:(NSString *)roomNo roomType:(NSString *)roomType lastChatNo:(NSString *)lastChatNo exitFlag:(NSString *)exitFlag{
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CHAT_ROOM_INFO (ROOM_NO, ROOM_TYPE, LAST_CHAT_NO, EXIT_FLAG) VALUES (%@, '%@', %@, '%@')", roomNo, roomType, lastChatNo, exitFlag];
    return query;
}

#pragma mark UPDATE
//updateSnsInfo
-(NSString *)updateSnsInfo:(NSString *)snsName snsType:(NSString *)snsType needAllow:(NSString *)needAllow snsDesc:(NSString *)snsDesc coverImg:(NSString *)coverImg snsNo:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE SNS SET SNS_NM = '%@', SNS_TY = %@, NEED_ALLOW = %@, SNS_DESC = '%@', COVER_IMG = '%@' WHERE SNS_NO = %@", snsName, snsType, needAllow, snsDesc, coverImg, snsNo];
    return query;
}

-(NSString *)updateSnsMemberInfo:(NSString *)createUserNo createUserNm:(NSString *)createUserNm snsNo:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE SNS SET CUSER_NO = '%@', USER_NM = '%@' WHERE SNS_NO = %@", createUserNo, createUserNm, snsNo];
    return query;
}

//updatePostAndCommentNoti
-(NSString *)updatePostNoti:(NSString *)postNoti snsNo:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE SNS SET POST_NOTI=%@ WHERE SNS_NO=%@;", postNoti, snsNo];
    return query;
}
//updatePostAndCommentNoti
-(NSString *)updateCommentNoti:(NSString *)commNoti snsNo:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE SNS SET COMMENT_NOTI=%@ WHERE SNS_NO=%@;", commNoti, snsNo];
    return query;
}

//updateRoomNewChat
-(NSString *)updateRoomNewChat:(int)newChat roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHAT_ROOMS SET NEW_CHAT = %d WHERE ROOM_NO=%@;", newChat, roomNo];
    return query;
}
//updateChatReadStatus
-(NSString *)updateChatReadStatus:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHATS SET IS_READ = 1 WHERE ROOM_NO=%@;", roomNo];
    return query;
}
//updateChatRoomScrolled
-(NSString *)updateChatRoomScrolled:(int)isScroll roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHAT_ROOMS SET IS_SCROLL = %d WHERE ROOM_NO=%@;", isScroll, roomNo];
    return query;
}
//updateChatUnReadCount
-(NSString *)updateChatUnReadCount:(NSNumber *)unReadCnt roomNo:(NSString *)roomNo chatNoList:(NSString *)chatNoList{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHATS SET UNREAD_COUNT = %@ WHERE ROOM_NO=%@ AND CHAT_NO IN (%@);", unReadCnt, roomNo, chatNoList];
    return query;
}
//updateRoomNoti
-(NSString *)updateRoomNoti:(int)noti roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHAT_ROOMS SET ROOM_NOTI=%d WHERE ROOM_NO=%@;", noti, roomNo];
    return query;
}
//updateChatContent
-(NSString *)updateChatContent:(NSString *)longContent chatNo:(NSString *)chatNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHATS SET CONTENT='%@' WHERE CHAT_NO=%@;", longContent, chatNo];
    return query;
}
//updateRoomName
-(NSString *)updateRoomName:(NSString *)roomName roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHAT_ROOMS SET ROOM_NM = '%@' WHERE ROOM_NO = %@;", roomName, roomNo];
    return query;
}
//updateCustomRoomName
-(NSString *)updateCustomRoomName:(NSString *)roomName roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE CHAT_ROOMS SET CUSTOM_ROOM_NM = '%@' WHERE ROOM_NO = %@;", roomName, roomNo];
    return query;
}

-(NSString *)updateRoomImage:(NSString *)roomImage roomNo:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"UPDATE ROOM_IMAGES SET ROOM_IMG = '%@' WHERE ROOM_NO = %@", roomImage, roomNo];
    return query;
}

#pragma mark DELETE
//deleteChat
-(NSString *)deleteMissedChat:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM MISSED_CHATS WHERE ROOM_NO=%@;", roomNo];
    return query;
}
-(NSString *)deleteChats:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM CHATS WHERE ROOM_NO=%@;", roomNo];
    return query;
}
-(NSString *)deleteChatUsers:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM CHAT_USERS WHERE ROOM_NO=%@;", roomNo];
    return query;
}
-(NSString *)deleteChatRooms:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM CHAT_ROOMS WHERE ROOM_NO=%@;", roomNo];
    return query;
}

//deleteMissedChat
-(NSString *)deleteMissedChat:(NSString *)roomNo chatNo:(NSString *)chatNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM MISSED_CHATS WHERE ROOM_NO=%@ AND CHAT_NO=%@;", roomNo, chatNo];
    return query;
}
-(NSString *)deleteChat:(NSString *)roomNo chatNo:(NSString *)chatNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM CHATS WHERE ROOM_NO=%@ AND CHAT_NO=%@;", roomNo, chatNo];
    return query;
}

//deleteChatUser
-(NSString *)deleteChatUsers:(NSString *)roomNo userNo:(NSString *)userNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM CHAT_USERS WHERE ROOM_NO = %@ AND USER_NO = %@;", roomNo, userNo];
    return query;
}
//deleteRoomImage
-(NSString *)deleteRoomImage:(NSString *)roomNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM ROOM_IMAGES WHERE ROOM_NO=%@;", roomNo];
    return query;
}

-(NSString *)deleteSns:(NSString *)snsNo{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM SNS WHERE SNS_NO = %@;", snsNo];
    return query;
}

@end
