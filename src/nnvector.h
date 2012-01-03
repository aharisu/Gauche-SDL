#ifndef __NNVECTOR_H__
#define __NNVECTOR_H__

#define NN_SIZE_1 1
#define NN_SIZE_2 2
#define NN_SIZE_4 4

#define NN_SIZE_MASK 0xff

#define NN_SIGN_U 0x100
#define NN_SIGN_S 0x200
#define NN_SIGN_BOOLEAN 0x300

#define TYPE_U8 (NN_SIZE_1 | NN_SIGN_U)
#define TYPE_U16 (NN_SIZE_2 | NN_SIGN_U)
#define TYPE_U32 (NN_SIZE_4 | NN_SIGN_U)
#define TYPE_S8 (NN_SIZE_1 | NN_SIGN_S)
#define TYPE_S16 (NN_SIZE_2 | NN_SIGN_S)
#define TYPE_S32 (NN_SIZE_4 | NN_SIGN_S)
#define TYPE_BOOLEAN (NN_SIZE_1 | NN_SIGN_BOOLEAN)

#define NNVECTOR_LENGTH2SIZE(type, len) (((type) & NN_SIZE_MASK) * (len))
#define NNVECTOR_SIZE2LENGTH(type, size) ((size) / ((type) & NN_SIZE_MASK))

typedef struct nnvectorRec {
  Uint8* buf;
  unsigned int size;
  int type;
}nnvector;

#endif //__NNVECTOR_H__

