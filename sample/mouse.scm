(use sdl)
(use sdl.image)
(use sdl.ttf)

(define screen #f)
(define background-image #f)
(define font #f)

(define cur-x 0)
(define cur-y 0)
(define rel-x 0)
(define rel-y 0)
(define left-down #f)
(define right-down #f)
(define center-down #f)

(define (update)
  (receive (x y state) (sdl-get-mouse-state)
    (set! cur-x x)
    (set! cur-y y)
    (set! left-down (not (zero? (logand SDL_BUTTON_LMASK state))))
    (set! right-down (not (zero? (logand SDL_BUTTON_RMASK state))))
    (set! center-down (not (zero? (logand SDL_BUTTON_MMASK state))))
    )
  (receive (x y state) (sdl-get-relative-mouse-state)
    (set! rel-x x)
    (set! rel-y y))
  )

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  ;; render text
  (let1 height (ttf-font-height font)
    (sdl-blit-surface (ttf-render-text-solid font (x->string cur-x) (make-sdl-color 0 0 0)) #f
                      screen (make-sdl-rect 10 50 0 0))
    (sdl-blit-surface (ttf-render-text-blended font (x->string cur-y) (make-sdl-color 0 0 0)) #f
                      screen (make-sdl-rect 10 (+ 40 (* height 1)) 0 0))
    (sdl-blit-surface (ttf-render-text-solid font (x->string rel-x) (make-sdl-color 0 0 0)) #f
                      screen (make-sdl-rect 10 (+ 40 (* height 2)) 0 0))
    (sdl-blit-surface (ttf-render-text-blended font (x->string rel-y) (make-sdl-color 0 0 0)) #f
                      screen (make-sdl-rect 10 (+ 40 (* height 3)) 0 0))
    (when left-down
      (sdl-blit-surface (ttf-render-text-blended font "left down" (make-sdl-color 0 0 0)) #f
                        screen (make-sdl-rect 10 (+ 40 (* height 4)) 0 0)))
    (when right-down
      (sdl-blit-surface (ttf-render-text-blended font "right down" (make-sdl-color 0 0 0)) #f
                        screen (make-sdl-rect 10 (+ 40 (* height 5)) 0 0)))
    (when center-down
      (sdl-blit-surface (ttf-render-text-blended font "center down" (make-sdl-color 0 0 0)) #f
                        screen (make-sdl-rect 10 (+ 40 (* height 6)) 0 0)))
    )
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO)
  (ttf-init)

  (sdl-wm-set-caption "My SDL Sample Game-TTF Font-" #f)
  (set! screen (sdl-set-video-mode 640 480 32 SDL_SWSURFACE))

  (set! background-image (img-load "res/background.png"))
  ;; open ttf font
  (set! font (ttf-open-font "res/YOzBAF.TTC" 42))
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
