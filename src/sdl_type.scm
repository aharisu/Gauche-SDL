;;;
;;; sdl_type.scm
;;;
;;; MIT License
;;; Copyright 2011-2012 aharisu
;;; All rights reserved.
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in all
;;; copies or substantial portions of the Software.
;;;
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;; SOFTWARE.
;;;
;;;
;;; aharisu
;;; foo.yobina@gmail.com
;;;

(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "//sdl header")
              (cgen-extern "#include<SDL/SDL.h>")
              (cgen-extern "")
              (cgen-extern "
                           typedef struct SDL_AudioSpecWrapperRec {
                            SDL_AudioSpec audio;
                            ScmClosure* callback;
                            ScmObj userdata;
                           }SDL_AudioSpecWrapper;

                           typedef struct SDL_RWopsWrapperRec {
                            SDL_RWops ops;
                            ScmClosure* seek;
                            ScmClosure* read;
                            ScmClosure* write;
                            ScmClosure* close;
                            ScmObj vector;
                            ScmObj data;
                           }SDL_RWopsWrapper;

                           ")
              (cgen-body "

                         void free_RWopsWrapper(SDL_RWopsWrapper* wrapper)
                         {
                          SDL_RWclose(&wrapper->ops);
                          //SDL_FreeRW(&wrapper->ops);
                         }

                         ")
              )
            (lambda () ;;epilogue
              ))
  0)


;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    (SDL_AudioSpecWrapper <sdl-audio-spec> #t #f "")
    (SDL_AudioCVT <sdl-audio-cvt> #t #f "")
    (SDL_CDtrack <sdl-cd-track> #f #f "")
    (SDL_CD <sdl-cd> #t #f "")
    (SDL_keysym <sdl-keysym> #f #f "")
    (SDL_ActiveEvent <sdl-active-event> #f #f "")
    (SDL_KeyboardEvent <sdl-keyboard-event> #f #f "")
    (SDL_MouseMotionEvent <sdl-mouse-motion-event> #f #f "")
    (SDL_MouseButtonEvent <sdl-mouse-button-event> #f #f "")
    (SDL_JoyAxisEvent <sdl-joy-axis-event> #f #f "")
    (SDL_JoyBallEvent <sdl-joy-ball-event> #f #f "")
    (SDL_JoyHatEvent <sdl-joy-hat-event> #f #f "")
    (SDL_JoyButtonEvent <sdl-joy-button-event> #f #f "")
    (SDL_ResizeEvent <sdl-resize-event> #f #f "")
    (SDL_ExposeEvent <sdl-expose-event> #f #f "")
    (SDL_QuitEvent <sdl-quit-event> #f #f "")
    (SDL_UserEvent <sdl-user-event> #f #f "")
    ;(SDL_SysWMEvent <sdl-sys-wmevent> #f #f "")
    (SDL_Event <sdl-event> #f #f "")
    (SDL_RWopsWrapper <sdl-rw-ops-user> #t  "free_RWopsWrapper" "")
    (SDL_Rect <sdl-rect> #f #f "")
    (SDL_Color <sdl-color> #f #f "")
    (SDL_Palette <sdl-palette> #f #f "")
    (SDL_PixelFormat <sdl-pixel-format> #t #f "")
    (SDL_Surface <sdl-surface> #t #f "")
    (SDL_VideoInfo <sdl-video-info> #t #f "")
    (SDL_Overlay <sdl-overlay> #t SDL_FreeYUVOverlay "")
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    (SDL_Joystick <sdl-joystick> #t #f "")
    (SDL_mutex <sdl-mutex> #t "SDL_DestroyMutex" "")
    (SDL_sem <sdl-semaphore> #t "SDL_DestroySemaphore" "")
    (SDL_cond <sdl-cond> #t "SDL_DestroyCond" "")
    (SDL_RWops <sdl-rw-ops> #t  "SDL_RWclose SDL_FreeRW" "")
    (SDL_Thread <sdl-thread> #t #f "")
    (SDL_TimerID <sdl-timer> #f "" "")
    (SDL_Cursor <sdl-cursor> #t "SDL_FreeCursor" "")
    ))
