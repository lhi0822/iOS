/*
 * aes_mod.h
 *
 *  Created on: Sep 21, 2015
 *      Author: bhchae
 */

#ifndef AES_MOD_H_
#define AES_MOD_H_

extern int NF_decryptAESData(unsigned int opMode, unsigned char *key, int keyLen, unsigned char *data, int dataLen,
                unsigned char *initialVector, int initialVectorLen, unsigned char **outData, int *outDataLen);

extern int NF_encryptAESData(unsigned int opMode, unsigned char *key, int keyLen, unsigned char *data, int dataLen,
                      unsigned char *initialVector, int initialVectorLen, unsigned char **outData, int *outDataLen);

#endif /* AES_MOD_H_ */
