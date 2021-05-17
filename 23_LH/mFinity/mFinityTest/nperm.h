#ifndef _PERMUTATION_
#define _PERMUTATION_

#ifdef __cplusplus
extern "C"
{
#endif
/* return codes */

/* nperm library의 버전 정보 */
typedef struct _NP_VERSION {
	unsigned char	major;  /* integer portion of version number  */
	unsigned char	minor;  /* 1/100ths portion of version number */
}NP_VERSION, *NP_VERSION_PTR;

/* nperm library의 세부 정보 */
typedef struct _NP_INFO {
	NP_VERSION			npapiVersion;			/* interface version  */
	unsigned char		manufacturerID[32];		/* blank padded       */
	unsigned int		flags;					/* must be zero       */
	unsigned char		libraryDescription[32];	/* blank padded       */
	NP_VERSION			libraryVersion;			/* version of library */
} NP_INFO, *NP_INFO_PTR;

#define NFR_OK	0
#define NFR_REQ_PERM_SIZE_TOO_LARGE	1000
#define NFR_REQ_PAD_SIZE_TOO_LARGE  1001
#define NFR_MEMALLOC_ERROR			1002
#define NSR_PRNG_GEN_RANDOM_FAILED  1003
#define NFR_GAP_OBJ_NUM_TOO_LARGE	1004
#define NFR_ARGUMENTS_BAD			1005

/* macro constants */

#define NF_MAX_PERM_SIZE	255
#define NF_MAX_PAD_SIZE		255
#define X9_RAND_BLKBYTE_SIZE 20

#define NPERM_VERSION_HEADER	"nperm Version"

#ifdef	WIN32
#define NF_API   __declspec( dllexport )
#else
#define NF_API
#endif

NF_API unsigned long N_GetNPermInfo(NP_INFO_PTR pInfo);

NF_API int N_GenRandFromSeed(unsigned char *seedStr, unsigned int seedStrByte, 
					  unsigned char **randStr, unsigned int randByte);

NF_API void N_FreeRandString(unsigned char *randString, unsigned int randStringSize);

NF_API int TrimObjStr(unsigned char *objStr, int objSize);

NF_API int N_GenPermutation(unsigned char *sharedSecret, int sharedSecretSize, 
					 unsigned char **permString, unsigned int permSize);

NF_API void N_FreePermutation(unsigned char *permString, unsigned int permStringSize);

NF_API int N_GenPadString(unsigned char *seedString, int seedStringSize, 
					 unsigned int numObj, int maxPadSize,
					  unsigned char **padString, unsigned int *padStringSize);

NF_API void N_FreePadString(unsigned char *padString, unsigned int padStringSize);

NF_API int N_GenKeyGapString(unsigned char *seedStr, unsigned int seedStrByte, 
					  unsigned int m, unsigned int n, 
					  unsigned char **gapString, unsigned int *gapStringSize);

NF_API int NM_GenKeyGapString(unsigned char *seedStr, unsigned int seedStrByte,
	unsigned int m, unsigned int n,
	unsigned char **gapString, unsigned int *gapStringSize);

NF_API void N_FreeGapString(unsigned char *gapString, unsigned int gapStringSize);

/* NSHC License */

#define NSL_ARGUMENTS_BAD                   100
#define NSL_NOT_SUPPORTED                   101
#define NSL_DATA_DECODE_FAILED              102
#define NSL_FILE_IO_ERROR                   103
#define NSL_PRODUCT_NAME_ARGUMENTS_BAD      104
#define NSL_DATE_ARGUMENTS_BAD              105
#define NSL_HOST_ID_ARGUMENTS_BAD           106
#define NSL_IP_ADDRESS_ARGUMENTS_BAD        107
#define NSL_DATE_FAILED                     200
#define NSL_HOSTID_FAILED                   201
#define NSL_IP_FAILED                       202
#define NSL_PRODUCT_NAME_FAILED             203
#define NSL_INTEGRITY_CHECK_FAILED          300
#define NSL_SET_LICENSE_FAILED				301		

#define MAX_LINE_BUF_SZ                     32670
#define MAX_TOKEN_BUF                       32670

#define SIGN_BODY_BYTE_LEN                  256
#define BASE64_SIGN_BODY_BYTE_LEN           344
#define    MEM_MARGIN                       8

#define NU_license              NS_License
#define NU_license_checked      NS_LicenseChecked
#define NU_get_license			NS_GetLicense
#define NU_license_free         NS_LicenseFree
#define LicenseUtil             NS_LicenseUtil
#define IFINFO                  NS_IFINFO

typedef struct LicenseUtil *LicenseUtil;

NF_API LicenseUtil NU_license(char *productName, char* hostid, char *license, int licenseLength);
NF_API int NU_license_checked(LicenseUtil instance);
NF_API int NU_get_license(char *data, int dataLength, char **license, int *licenseLength);
NF_API void NU_license_free(LicenseUtil *instance);

#if defined(_DEBUG_LOG)
/* NSHC Debug */

#define MAX_LOG_BUF_SIZE      128
#define MAX_DEBUG_BUF_SIZE    4096

#define NSU_DEBUG_BUF_ERROR                 500     /* over debug buffer size */ 
#define NSU_DEBUG_LOG_ERROR                 501     /* writing debug log error */ 

NF_API int NU_GetLogFileName(char* logfile);
NF_API int NU_LogString(char *data, int datalen, char *display, char *filename);
#endif


#ifdef __cplusplus
}
#endif

#endif /* _PERMUTATION_ */

