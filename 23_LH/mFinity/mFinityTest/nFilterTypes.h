//
//  nFilterTypes.h
//  nFilter For iPad
//
//  Created by Kinamee on 11. 2. 24..
//  Copyright 2011 NSHC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NCenter,
	NLeft,
	NRight, 	
} NAlignment;

typedef enum {
	NKeymodeEng,
	NKeymodeSEng,
	NKeymodeHan,
	NKeymodeSHan,
	NKeymodeSpecl,
    NKeymodeEngAll
} NKeymodeType;

typedef enum {
	NEngLower,
	NEngUpper,
	NSpecial,
	NNum,
 	NKor
} NKeymodeTypeR;

typedef NS_ENUM (NSInteger, NFilterButtonType)
{
    NFilterButtonTypeOK      ,
    NFilterButtonTypeCancel  ,
    NFilterButtonTypeReplace ,
    NFilterButtonTypeDelete  ,
    NFilterButtonTypeNext    ,
    NFilterButtonTypePrev    ,
    NFilterButtonTypeSpace,
    NFilterButtonTypeSpecialAndEng
};

struct NFilterMargin
{
    NSInteger left;
    NSInteger top;
    NSInteger right;
    NSInteger bottom;
};
typedef struct NFilterMargin NFilterMargin;

typedef NS_ENUM (NSInteger, NFilterToolbarAlign)
{
    NFilterToolbarAlignTop  ,
    NFilterToolbarAlignBottom
};

typedef NS_ENUM (NSInteger, NFilterButtonTextLanguage)
{
    NFilterButtonTextKr      ,
    NFilterButtonTextEn
};
