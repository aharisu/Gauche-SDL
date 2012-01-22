/*
 * gauche-sdl-netext.c - sdl.net extension
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-netext.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_netextlib(ScmModule *mod);

void Scm_Init_gauche_sdl_netext(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_netext);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.net.ext", TRUE));
   Scm_Init_sdl_netextlib(mod);
}
