(use sdl)
(use sdl.image)
(use sdl.ttf)

(define screen #f)
(define background-image #f)
(define font #f)

(define (update)
  )

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  ;; render text
  (sdl-blit-surface (ttf-render-text-solid font "Hello SDL World" (make-sdl-color 255 0 0)) #f
                    screen (make-sdl-rect 10 50 0 0))
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO)
  (ttf-init)

  (sdl-wm-set-caption "My SDL Sample Game-TTF Font-" #f)
  (set! screen (sdl-set-video-mode 640 480 32 SDL_SWSURFACE))

  (set! background-image (img-load "res/background.png"))
  ;; open ttf font
  (set! font (ttf-open-font "res/LAUREHEA.TTF" 42))
  )

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
  (ttf-close-font font)
  (ttf-quit)
  (sdl-quit))

(initialize)
(main-loop)
(finalize)
