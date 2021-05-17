#ifndef _NSAFER_ECPARAMS_H_
#define _NSAFER_ECPARAMS_H_

#include "ns_api.h"

#define MEM_MARGIN_1	1
#define MAX_SCALAR_LEN 150
#define MAX_GFP_LEN (300 + MEM_MARGIN_1)
#define MAX_GF2E_LEN (50 + MEM_MARGIN_1)
#define MAX_GF_LEN (MAX_GFP_LEN>MAX_GF2E_LEN?MAX_GFP_LEN:MAX_GF2E_LEN)
#define ECC_FIELD_TYPE_GF2E 0
#define ECC_FIELD_TYPE_GFP 1

typedef struct _ECC_STATIC_PARAMS{
	int field_type;
	NS_ULONG normbits;
	NS_ULONG field_len;
	NS_ULONG order_len;
	NS_ULONG cofactor_len;
	NS_ULONG mod[MAX_GF_LEN]; /*an irr polynomial or a prime number*/
	NS_ULONG a[MAX_GF_LEN];
	NS_ULONG b[MAX_GF_LEN];
	NS_ULONG base_point_x[MAX_GF_LEN];
	NS_ULONG base_point_y[MAX_GF_LEN];
	NS_ULONG order[MAX_GF_LEN];
	NS_ULONG cofactor[MAX_GF_LEN];
}ECC_STATIC_PARAMS;

#endif
