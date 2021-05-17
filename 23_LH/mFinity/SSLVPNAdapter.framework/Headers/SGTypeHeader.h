//
//  SGTypeHeader.h
//  SSLVPN Adapter
//
//  Created by sjseong on 2018. 8. 17..
//

#ifndef SGTypeHeader_h
#define SGTypeHeader_h

#define RHttpTypeString(enum) [@[@"POST",@"GET",@"PUT"] objectAtIndex:enum]
#define RLoginTypeString(enum) [@[@"0",@"1",@"2",@"3"] objectAtIndex:enum]
#define RInnerAuthTypeString(enum) [@[@"1",@"2",@"3"] objectAtIndex:enum]
#define RMultiSSLPolicyTypeString(enum) [@[@"sslrule_sid",@"sslrule_name",@"sslrule_type"] objectAtIndex:enum]

typedef NS_ENUM(NSInteger, HTTP_RTYPE) {
    HTTP_POST,
    HTTP_GET,
    HTTP_PUT
};

typedef NS_ENUM(NSInteger, INNER_AUTH_RTYPE) {
    AUTH_LOCAL_DB = 1,
    AUTH_INTERNAL_OTP,
    AUTH_LOCAL_DB_AND_INTERNAL_OTP
};

typedef NS_ENUM(NSInteger, LOGIN_RTYPE) {
    LOGIN_PASS = 0,
    LOGIN_CERT,
    LOGIN_PASS_OR_CERT,
    LOGIN_PASS_AND_CERT
};

typedef NS_ENUM(NSInteger, MULTI_SSL_POLICY_RTYPE) {
    MULTI_SSL_POLICY_TOKEN,
    MULTI_SSL_POLICY_NAME,
    MULTI_SSL_POLICY_TYPE
};



#endif /* SGTypeHeader_h */
