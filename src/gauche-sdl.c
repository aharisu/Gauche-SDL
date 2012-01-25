/*
 * gauche_sdl.c
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

#include "gauche-sdl.h"


static void condition_print(ScmObj obj, ScmPort* port, ScmWriteContext* ctx)
{
  ScmClass* k = Scm_ClassOf(obj);
  Scm_Printf(port, "#<%A \"%30.1A\">",
      Scm__InternalClassName(k),
      SCM_ERROR_MESSAGE(obj));
}

static ScmObj condition_allocate(ScmClass* klass, ScmObj initargs)
{
  ScmSDLError* e = SCM_ALLOCATE(ScmSDLError, klass);
  SCM_SET_CLASS(e, klass);
  SCM_ERROR_MESSAGE(e) = SCM_FALSE;
  return SCM_OBJ(e);
}

static ScmClass* condition_cpl[] = {
SCM_CLASS_STATIC_PTR(Scm_ErrorClass),
SCM_CLASS_STATIC_PTR(Scm_MessageConditionClass),
SCM_CLASS_STATIC_PTR(Scm_SeriousConditionClass),
SCM_CLASS_STATIC_PTR(Scm_ConditionClass),
SCM_CLASS_STATIC_PTR(Scm_TopClass),
NULL
};

SCM_DEFINE_BASE_CLASS(Scm_SDLErrorClass, ScmSDLError,
    condition_print, NULL, NULL,
    condition_allocate, condition_cpl);

/*
* Module initialization function.
*/
extern void Scm_Init_sdl_lib(ScmModule*);
extern void Scm_Init_sdl_type(ScmModule*);

void Scm_Init_gauche_sdl(void)
{
  ScmModule *mod; 

  /* Register this DSO to Gauche */ 
  SCM_INIT_EXTENSION(gauche_sdl); 
  /* Create the module if it doesn't exist yet. */
  mod = SCM_MODULE(SCM_FIND_MODULE("sdl", TRUE));
  Scm_InitStaticClassWithMeta(SCM_CLASS_SDL_ERROR, 
      "<sdl-error>",
      mod,
      Scm_ClassOf(SCM_OBJ(SCM_CLASS_CONDITION)),
      SCM_FALSE,
      NULL, 0);
 
  /* Register stub-generated procedures */
  Scm_Init_sdl_lib(mod);
  Scm_Init_sdl_type(mod);
}
