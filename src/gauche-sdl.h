/*
 * gauche_sdl.h
 */

/* Prologue */
#ifndef GAUCHE_GAUCHE_SDL_H
#define GAUCHE_GAUCHE_SDL_H

#include <gauche.h>
#include <gauche/extend.h>
#include <gauche/class.h>

SCM_DECL_BEGIN

typedef struct ScmSDLErrorRec {
  ScmError common;
}ScmSDLError;
SCM_CLASS_DECL(Scm_SDLErrorClass);
#define SCM_CLASS_SDL_ERROR (&Scm_SDLErrorClass)

#define ENSURE_NOT_NULL(data) \
if(!(data)) Scm_Error("already been released. object is invalied.");

/* Epilogue */
SCM_DECL_END

#endif  /* GAUCHE_GAUCHE_SDL_H */
