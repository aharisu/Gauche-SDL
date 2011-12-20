/*
 * gauche-sdl-mixer.c - Gauche SDL_mixer binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-mixer.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_mixerlib(ScmModule *mod);
extern void Scm_Init_mixer_type(ScmModule* mod);

void Scm_Init_gauche_sdl_mixer(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_mixer);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.mixer", TRUE));
   Scm_Init_sdl_mixerlib(mod);
   Scm_Init_mixer_type(mod);
}
