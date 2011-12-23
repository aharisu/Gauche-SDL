(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "//sdl header")
              (cgen-extern "#include<SDL/SDL.h>")
              (cgen-extern "#include<SDL/SDL_framerate.h>")
              (cgen-extern "")
              )
            (lambda () ;;epilogue
              ))
  0)

;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    (FPSmanager <gfx-fps-manager> #t #f "")
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    ))
