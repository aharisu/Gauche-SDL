/*
 * gauche-sdl-smpeg.c - Gauche SDL_smpeg binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-smpeg.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_smpeglib(ScmModule *mod);
extern void Scm_Init_smpeg_type(ScmModule* mod);

void Scm_Init_gauche_sdl_smpeg(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_smpeg);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.smpeg", TRUE));
   Scm_Init_sdl_smpeglib(mod);
   Scm_Init_smpeg_type(mod);
}
