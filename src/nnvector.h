/*
 * nnvector.h
 *
 * MIT License
 * Copyright 2011-2012 aharisu
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *
 * aharisu
 * foo.yobina@gmail.com
 */

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

