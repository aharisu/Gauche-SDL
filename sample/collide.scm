(use sdl)
(use sdl.collide)
(use sdl.image)

(use gauche.record)
(use srfi-4)


(define-constant width 640)
(define-constant height 480)

(define screen #f)
(define background-image #f)
(define player #f)
(define obstacle #f)

(define (load-image filename)
  (let1 img (img-load filename)
    (sdl-set-color-key img (logior SDL_RLEACCEL SDL_SRCCOLORKEY)
                       (sdl-map-rgb (ref img 'format) 255 0 255))
    (begin0
      (sdl-display-format img)
      (sdl-free-surface img))))

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

(define (update-input)
  (let ([keys (sdl-get-key-state)])
    (copy-input cur-input prev-input)
    (input-left-set! cur-input (or (ref keys SDLK_LEFT) (ref keys SDLK_h)))
    (input-up-set! cur-input (or (ref keys SDLK_UP) (ref keys SDLK_k)))
    (input-right-set! cur-input (or (ref keys SDLK_RIGHT) (ref keys SDLK_l)))
    (input-down-set! cur-input (or (ref keys SDLK_DOWN) (ref keys SDLK_j)))
    (input-button1-set! cur-input (or (ref keys SDLK_LSHIFT) (ref keys SDLK_z)))
    (input-button2-set! cur-input (or (ref keys SDLK_LCTRL) (ref keys SDLK_x)))))

(define pos-x 0)
(define pos-y 0)

(define (update)
  (update-input)
  (let* ([speed (if (input-button1 cur-input) 2 6)]
         [delta-x (+ (if (input-left cur-input) (- speed) 0)
                     (if (input-right cur-input) speed 0))]
         [delta-y (+ (if (input-up cur-input) (- speed) 0)
                     (if (input-down cur-input) speed 0))])
    (when (and (or (not (zero? delta-x)) (not (zero? delta-y)))
            (not (cld-pixel player (+ pos-x delta-x) (+ pos-y delta-y)
                            obstacle 300 180 6)))
      (set! pos-x (+ pos-x delta-x))
      (set! pos-y (+ pos-y delta-y))
      (cond
        [(< pos-x 0) (set! pos-x 0)]
        [(> pos-x (- width 50)) (set! pos-x (- width 50))])
      (cond
        [(< pos-y 0) (set! pos-y 0)]
        [(> pos-y (- height 50)) (set! pos-y (- height 50))]))))

(define (draw)
  (sdl-blit-surface background-image #f screen (make-sdl-rect 0 0 0 0))
  (sdl-blit-surface obstacle #f screen (make-sdl-rect 300 180 0 0))
  (sdl-blit-surface player #f screen (make-sdl-rect pos-x pos-y 0 0))
  (sdl-flip screen))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO)
  (sdl-wm-set-caption "My SDL Sample Game-Collide-" #f)
  (set! screen (sdl-set-video-mode width height 32 SDL_HWSURFACE SDL_DOUBLEBUF))
  (set! background-image (img-load "res/background.png"))
  (set! player (load-image "res/player.bmp"))
  (set! obstacle (load-image "res/obstacle.bmp"))
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
  (sdl-free-surface player)
  (sdl-free-surface obstacle)
  (sdl-quit))


(initialize)
(main-loop)
(finalize)


