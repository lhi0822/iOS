//
//  RSLicenseUtil.h
//  RSLicenseSDK
//  Copyright © 2018년 RAONSECURE All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSFloating : NSObject
@property (nonatomic, assign) int USERCOUNT;
@property (nonatomic, assign) int DEVICECOUNT;
@property (nonatomic, strong) NSMutableArray *BROWSER;
@property (nonatomic, strong) NSMutableArray *APPID;
@property (nonatomic, strong) NSString *OPTIONS;
@end

@interface RSFeature : NSObject
@property (nonatomic, strong) NSString *EXPIREDATE;
@property (nonatomic, strong) NSString *FEATURENAME;
@property (nonatomic, strong) RSFloating *FLOATING;
@end

@interface RSNodeLocked : NSObject
@property (nonatomic, strong) NSMutableArray *MAC;
@property (nonatomic, strong) NSMutableArray *IP;
@property (nonatomic, strong) NSMutableArray *RSDOMAIN;
@property (nonatomic, strong) NSMutableArray *OS;
@property (nonatomic, strong) NSMutableArray *HOSTID;
@property (nonatomic, assign) int CPUCORECOUNT;
@property (nonatomic, assign) int WASINSTANCECOUNT;
@end

@interface RSLicenseSchema : NSObject
@property (nonatomic, strong) RSNodeLocked *NODELOCKED;
@property (nonatomic, strong) RSFloating *FLOATING;
@end

@interface RSLicenseInfo : NSObject
@property (nonatomic, strong) NSString *PRODUCTNAME;
@property (nonatomic, strong) NSString *PRODUCTVERSION;
@property (nonatomic, strong) NSString *SITENAME;
@property (nonatomic, strong) NSString *SVCNAME;
@property (nonatomic, strong) NSString *SITECODE;
@property (nonatomic, strong) NSString *SVCCODE;
@property (nonatomic, strong) NSString *LICENSECODE;
@property (nonatomic, strong) NSString *ISSUER;
@property (nonatomic, strong) NSString *EXPIREDATE;
@property (nonatomic, strong) NSString *ISSUEDDATE;
@property (nonatomic, strong) NSString *LICENSETYPE;
@end

@interface RSLicense : NSObject
@property (nonatomic, strong) RSLicenseInfo *LICENSEINFO;
@property (nonatomic, strong) RSLicenseSchema *LICENSESCHEMA;
@property (nonatomic, strong) RSFeature *FEATURE;
@property (nonatomic, strong) NSString *LICENSEVERSION;
@property (nonatomic, strong) NSString *EXTENSION;
@end
