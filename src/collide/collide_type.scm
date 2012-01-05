(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "//sdl header")
              (cgen-extern "#include<SDL/SDL.h>")
              (cgen-extern "#include<SDL_collide.h>")
              (cgen-extern "")
              )
            (lambda () ;;epilogue
              ))
  0)


;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    (SDL_CollideMask <cld-mask> #f "SDL_CollideFreeMask" "")
    ))
