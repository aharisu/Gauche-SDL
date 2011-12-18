/*
 * gauche-sdl-image.c - Gauche SDL_image binding
 */

#include <gauche.h>
#include <gauche/extend.h>
#include "gauche-sdl-image.h"

/*****************************************************************************
 * Initialization
 */

extern void Scm_Init_sdl_imagelib(ScmModule *mod);

void Scm_Init_gauche_sdl_image(void)
{
   ScmModule *mod;
   SCM_INIT_EXTENSION(gauche_sdl_image);
   mod = SCM_MODULE(SCM_FIND_MODULE("sdl.image", TRUE));
   Scm_Init_sdl_imagelib(mod);
}
