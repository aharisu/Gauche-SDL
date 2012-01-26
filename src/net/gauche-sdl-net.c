/*
 * gauche-sdl-net.c - Gauche SDL_net binding
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

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-net.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_netlib(ScmModule *mod);
extern void Scm_Init_net_type(ScmModule* mod);

void Scm_Init_gauche_sdl_net(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_net);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.net", TRUE));
   Scm_Init_sdl_netlib(mod);
   Scm_Init_net_type(mod);
}
