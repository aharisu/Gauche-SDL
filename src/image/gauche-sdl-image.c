/*
 * gauche-sdl-image.c - Gauche SDL_image binding
 *
 *  Copyright(C) 2003 by Michael Vess (mvess@michaelvess.com)
 *
 *  Permission to use, copy, modify, distribute this software and
 *  accompanying documentation for any purpose is hereby granted,
 *  provided that existing copyright notices are retained in all
 *  copies and that this notice is included verbatim in all
 *  distributions.
 *  This software is provided as is, without express or implied
 *  warranty.  In no circumstances the author(s) shall be liable
 *  for any damages arising out of the use of this software.
 *
 *  $Id: gauche-sdl-image.c,v 1.3 2003/01/22 02:26:12 mikiso Exp $
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
