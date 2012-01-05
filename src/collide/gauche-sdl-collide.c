/*
 * gauche-sdl-collide.c - Gauche SDL_collide binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-collide.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_collidelib(ScmModule *mod);
extern void Scm_Init_collide_type(ScmModule* mod);

void Scm_Init_gauche_sdl_collide(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_collide);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.collide", TRUE));
   Scm_Init_sdl_collidelib(mod);
   Scm_Init_collide_type(mod);
}
