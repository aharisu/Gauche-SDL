/*
 * gauche-sdl-gfx.c - Gauche SDL_gfx binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-gfx.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_gfxlib(ScmModule *mod);
extern void Scm_Init_gfx_type(ScmModule* mod);

void Scm_Init_gauche_sdl_gfx(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_gfx);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.gfx", TRUE));
   Scm_Init_sdl_gfxlib(mod);
   Scm_Init_gfx_type(mod);
}
