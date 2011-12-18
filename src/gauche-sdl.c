/*
 * gauche_sdl.c
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
