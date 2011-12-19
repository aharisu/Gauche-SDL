(use sdl)
(use sdl.image)

(define screen #f)
(define background-image #f)

(define (update)
  )

(define (draw)
  (sdl-blit-surface background-image #f screen #f)

  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  ;(sdl-init (logior SDL_INIT_VIDEO SDL_INIT_TIMER))
  (sdl-init SDL_INIT_VIDEO SDL_INIT_TIMER)

  (sdl-wm-set-caption "My SDL Sample Game" #f)
  (set! screen (sdl-set-video-mode 640 480 32 SDL_SWSURFACE))

  (set! background-image (img-load "res/background.png")))

(define-constant wait (/ 1000 60))
(define (main-loop)
  (let loop ([next-frame (sdl-get-ticks)])
    (unless (let proc-event ([event (sdl-poll-event)])
              (and event
                (or
                  (eq? (ref event 'type) SDL_QUIT)
                  (and (eq? (ref event 'type) SDL_KEYUP) (eq? (ref (ref event 'keysym) 'sym) SDLK_ESCAPE))
                  (proc-event (sdl-poll-event)))))
      (let ([next (if (>= (sdl-get-ticks) next-frame)
                    (begin
                      (update)
                      (when (< (sdl-get-ticks) (+ next-frame wait))
                        (draw))
                      (+ next-frame wait))
                    next-frame)])
        (sdl-delay 0)
        (loop next)))))

(define (finalize)
  (sdl-free-surface background-image)
  (sdl-quit))

(initialize)
(main-loop)
(finalize)

