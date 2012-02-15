/*
 * gauche_sdl.h
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

/* Prologue */
#ifndef GAUCHE_GAUCHE_SDL_H
#define GAUCHE_GAUCHE_SDL_H

#include <gauche.h>
#include <gauche/extend.h>
#include <gauche/class.h>

SCM_DECL_BEGIN

typedef struct ScmSDLErrorRec {
  ScmError common;
}ScmSDLError;
SCM_CLASS_DECL(Scm_SDLErrorClass);
#define SCM_CLASS_SDL_ERROR (&Scm_SDLErrorClass)

void avoid_gc_register(intptr_t ptr);
void avoid_gc_unregister(intptr_t ptr);

#define ENSURE_NOT_NULL(data) \
if(!(data)) Scm_Error("already been released. object is invalied.");

/* Epilogue */
SCM_DECL_END

#endif  /* GAUCHE_GAUCHE_SDL_H */
