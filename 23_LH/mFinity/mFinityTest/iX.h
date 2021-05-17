//
//  iX.h
//  ixShield
//
//  Created by Ju Young CHOI on 2017. 4. 17..
//  Copyright © 2017년 nshc. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
#include <stdio.h>

#define VERIFY_NONE "VERIFY_NONE"
#define VERIFY_SIM  "VERIFY_SIM"
#define VERIFY_FAIL "VERIFY_FAIL"
#define VERIFY_SUCC "VERIFY_SUCC"

#define IX_RESOURCE_BASIC   1
#define IX_RESOURCE_ALL     2

typedef enum {
    IX_INTEGRITY_LOCAL = 1,
    IX_INTEGRITY_SERVER = 2,
    IX_INTEGRITY_ALL = 3,
}IX_INTEGRITY_TYPE;

//typedef enum {
//    IX_RESOURCE_BASIC = 1,
//    IX_RESOURCE_ALL = 2,
//}IX_RESOURCE_INTEGRITY_TYPE;

struct ix_init_info {
    char init_data[256];
    IX_INTEGRITY_TYPE integrity_type;
    char userId[24];
    char subId[256];
};

struct ix_verify_info {
    char verify_result[12];
    char verify_data[2048];
};

struct ix_detected_pattern {
    char pattern_type_id[12];
    char pattern_obj[128];
    char pattern_desc[128];
};

struct ix_detected_pattern_list_gamehack {
    struct ix_detected_pattern *pattern;
    int list_cnt;
};

#define ix_sysCheckStart            a3c76b59d787bed13ac3766dd1e003fdc
#define ix_sysCheck_gamehack        a9df283f2e4fa792c3408608bd7a65de7
#define ix_getVersion               a00e17c1385b820db0f6850b74288f1ea

#define ix_runAntiDebugger          f16fc676040b6d2ee392956bfee0fcbd
#define ix_integrityCheck           a106c4e13097eb3613110ee85730fc9f9
#define ix_resourceIntegrityCheck   a50add3ba09d1d889ca8a0d21ced83f56
#define ix_getDecodeStr             a6422359711c9dba4e55df3cf722f7c2b
#define ix_getObfuscatorDecodeStr   a41186fe91a8ab499a9e085f0d45b78aa

#define ix_set_debug                edcd2fe64ae616873665179ec518037a
#define ix_not_use_update           a1cbc62a6034a2869b7ae2eabec5f17e4
#define ix_check_fakegps            a62abe6af02ba65a192dc422dd75dc890
#define ix_set_send_log             a457dd377b0aaf7087ecaf363e218e06a
#define ix_send_message             e26c7fd8c5ebbfade33e34260b343d43
#define ix_dealloc                  d3ceca1132b5c407a149d812a800dc61
#define ix_getErrorCodeToReason     a5e0e3b02e146814e3230c963c68cbe25

#define ix_version "1.4.2"

// System Check
extern int ix_sysCheckStart(struct ix_detected_pattern **p_info);
// System + GameHack Check
extern int ix_sysCheck_gamehack(struct ix_detected_pattern **p_info, struct ix_detected_pattern_list_gamehack **p_list_gamehack);

// get ix Version
extern const char *ix_getVersion();

// Check Debugger
extern int ix_runAntiDebugger(void);

// integrity Check
extern int ix_integrityCheck(struct ix_init_info *info, struct ix_verify_info *v_info);

// Resource Integrity Check
extern int ix_resourceIntegrityCheck(int type, struct ix_verify_info *v_info);

// string obfuscation
extern const char *ix_getDecodeStr(const char * decStr, int *errorCode);
extern const char *ix_getObfuscatorDecodeStr(const char * decStr, int *errorCode);

extern void ix_set_debug();

// Default : YES
extern void ix_not_use_update();

// Fake GPS
extern int ix_check_fakegps();

// Default : YES
extern void ix_set_send_log(BOOL isLog);

// send Log message
extern int ix_send_message(const char *log);

extern void ix_dealloc();

extern const char *ix_getErrorCodeToReason(int code);
    
#ifdef __cplusplus
};
#endif
