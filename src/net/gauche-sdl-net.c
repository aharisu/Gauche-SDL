/*
 * gauche-sdl-net.c - Gauche SDL_net binding
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
