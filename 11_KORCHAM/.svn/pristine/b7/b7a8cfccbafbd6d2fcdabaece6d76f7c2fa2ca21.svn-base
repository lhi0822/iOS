//
//  iX.h
//  ixShield(AV)
//
//  Created by Ju Young CHOI on 2017. 4. 17..
//  Copyright © 2017년 nshc. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
#include <stdio.h>

struct ix_detected_pattern {
    char pattern_type_id[12];
    char pattern_obj[128];
    char pattern_desc[128];
};

#define ix_sysCheckStart            a3c76b59d787bed13ac3766dd1e003fdc
#define ix_not_use_update           a1cbc62a6034a2869b7ae2eabec5f17e4
#define ix_runAntiDebugger          f16fc676040b6d2ee392956bfee0fcbd
#define ix_getVersion               a00e17c1385b820db0f6850b74288f1ea
#define ix_set_debug                edcd2fe64ae616873665179ec518037a
#define ix_dealloc                  d3ceca1132b5c407a149d812a800dc61

#define ix_version "1.3.0"

// System Check
extern int ix_sysCheckStart(struct ix_detected_pattern **p_info);

// ixshield(AV) Version
extern const char *ix_getVersion();

// Check Debugger
extern int ix_runAntiDebugger(void);

extern void ix_set_debug();

// Default : YES
extern void ix_not_use_update();

extern void ix_dealloc();
    
#ifdef __cplusplus
};
#endif
