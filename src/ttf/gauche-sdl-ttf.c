/*
 * gauche-sdl-ttf.c - Gauche SDL_ttf binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-ttf.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_ttflib(ScmModule *mod);
extern void Scm_Init_ttf_type(ScmModule* mod);

void Scm_Init_gauche_sdl_ttf(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_ttf);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.ttf", TRUE));
   Scm_Init_sdl_ttflib(mod);
   Scm_Init_ttf_type(mod);
}
