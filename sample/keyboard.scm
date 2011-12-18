(use sdl)
(use sdl.image)

(use gauche.record)
(use srfi-4)


(define-constant width 640)
(define-constant height 480)

(define screen #f)
(define background-image #f)
(define onpu-image #f)


(define-record-type input #t #f
  (left)
  (up)
  (right)
  (down)
  (button1)
  (button2))

(define (copy-input src dst)
  (input-left-set! dst (input-left src))
  (input-up-set! dst (input-up src))
  (input-right-set! dst (input-right src))
  (input-down-set! dst (input-down src))
  (input-button1-set! dst (input-button1 src))
  (input-button2-set! dst (input-button2 src)))

(define-constant prev-input (make-input #f #f #f #f #f #f))
(define-constant cur-input (make-input #f #f #f #f #f #f))

(define pos-x 0)
(define pos-y 0)

(define-macro (c-or . exprs)
  (cond 
    [(null? exprs) #f]
    [(null? (cdr exprs)) `(not (zero? ,(car exprs)))]
    [else (let ([tmp (gensym)])
            `(let ([,tmp (not (zero? ,(car exprs)))])
               (if ,tmp ,tmp (c-or . ,(cdr exprs)))))]))

(define (update-input)
  (let ([keys (sdl-get-key-state)])
    (copy-input cur-input prev-input)
    (input-left-set! cur-input (c-or (u8vector-ref keys SDLK_LEFT) (u8vector-ref keys SDLK_h)))
    (input-up-set! cur-input (c-or (u8vector-ref keys SDLK_UP) (u8vector-ref keys SDLK_k)))
    (input-right-set! cur-input (c-or (u8vector-ref keys SDLK_RIGHT) (u8vector-ref keys SDLK_l)))
    (input-down-set! cur-input (c-or (u8vector-ref keys SDLK_DOWN) (u8vector-ref keys SDLK_j)))
    (input-button1-set! cur-input (c-or (u8vector-ref keys SDLK_LSHIFT) (u8vector-ref keys SDLK_z)))
    (input-button2-set! cur-input (c-or (u8vector-ref keys SDLK_LCTRL) (u8vector-ref keys SDLK_x)))))

(define (update)
  (update-input)
  (let ([speed (if (input-button1 cur-input) 2 6)])
    (when (and (input-button2 cur-input) (not (input-button2 prev-input)))
      (set! pos-x 0)
      (set! pos-y 0))
    (when (input-left cur-input)
      (set! pos-x (- pos-x speed)))
    (when (input-right cur-input)
      (set! pos-x (+ pos-x speed)))
    (when (input-up cur-input)
      (set! pos-y (- pos-y speed)))
    (when (input-down cur-input)
      (set! pos-y (+ pos-y speed)))
    (cond
      [(< pos-x 0) (set! pos-x 0)]
      [(> pos-x (- width 64)) (set! pos-x (- width 64))])
    (cond
      [(< pos-y 0) (set! pos-y 0)]
      [(> pos-y (- height 64)) (set! pos-y (- height 64))])))

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  (sdl-blit-surface onpu-image #f screen (make-sdl-rect pos-x pos-y 0 0))
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init (logior SDL_INIT_VIDEO SDL_INIT_AUDIO SDL_INIT_TIMER))
  (sdl-wm-set-caption "My SDL Sample Game-Keyboard-" #f)
  (set! screen (sdl-set-video-mode width height 32 SDL_SWSURFACE))
  (set! background-image (img-load "res/background.png"))
  (set! onpu-image (img-load "res/onpu.png")))

(define-constant wait (/ 1000 60))
(define (main-loop)
  (let loop ([next-frame (sdl-get-ticks)])
    (unless (let proc-event ([event (sdl-poll-event)])
              (and event
                (or
                  (eq? (ref event 'type) SDL_QUIT)
                  (and (eq? (ref event 'type) SDL_KEYUP) (eq? (ref (ref event 'keysym) 'sym) SDLK_ESCAPE))
                  (proc-event (sdl-poll-event)))))
      (when (>= (sdl-get-ticks) next-frame)
        (update)
        (when (< (sdl-get-ticks) (+ next-frame wait))
          (draw))
        (sdl-delay 0))
      (loop (+ next-frame wait)))))

(define (finalize)
  (sdl-free-surface background-image)
  (sdl-free-surface onpu-image)
  (sdl-quit))


(initialize)
(main-loop)
(finalize)


