(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "//sdl header")
              (cgen-extern "#include<SDL/SDL.h>")
              (cgen-extern "#include<SDL/SDL_mixer.h>")
              (cgen-extern "")
              )
            (lambda () ;;epilogue
              ))
  0)

;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    (Mix_Chunk <mix-chunk> #t "Mix_FreeChunk" "")
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    (Mix_Music <mix-music> #t "Mix_FreeMusic" "")
    ))
