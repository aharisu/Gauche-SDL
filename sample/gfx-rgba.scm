(use sdl)
(use sdl.gfx)

(define screen #f)

(define-constant mask1 #xff000000)
(define-constant mask2 #x00ff0000)
(define-constant mask3 #x0000ff00)
(define-constant mask4 #x000000ff)

(define-constant width 640)
(define-constant height 480)



(define (update)
  )

(define (draw)
  (do ([y 0 (+ y 20)])
      [(>= y width) #f]
    (gfx-box-rgba screen 0 (+ y 10) width (+ y 20) 255 255 255 255))

  ;; solit color
  ;;red
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 0 0 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 0 0 0 0)))
  ;;green
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 255 0 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 0 100 0 0)))
  ;;blue
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 0 255 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 100 0 0 0)))
  ;;white
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 255 255 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 100 100 0 0)))
  ;;red
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 0 0 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 200 0 0 0)))
  ;;green
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 255 0 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 200 100 0 0)))
  ;;blue
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 0 255 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 300 0 0 0)))
  ;;white
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 255 255 255)
    (sdl-blit-surface s #f screen (make-sdl-rect 300 100 0 0)))

  ;; transparent color
  ;;red + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 0 0 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 0 200 0 0)))
  ;;green + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 255 0 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 0 300 0 0)))
  ;;blue + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 0 255 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 100 200 0 0)))
  ;;white + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask1 mask2 mask3 mask4)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 255 255 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 100 300 0 0)))
  ;;red + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 0 0 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 200 200 0 0)))
  ;;green + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 255 0 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 200 300 0 0)))
  ;;blue + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 0 0 255 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 300 200 0 0)))
  ;;white + trans
  (let ([s (sdl-create-rgb-surface 0 200 200 32 mask4 mask3 mask2 mask1)])
    (gfx-filled-ellipse-rgba s 0 0 100 100 255 255 255 200)
    (sdl-blit-surface s #f screen (make-sdl-rect 300 300 0 0)))

  (gfx-string-rgba screen (- (quotient width 2) 
                             (* 5 4))
                   (- height 8)
                   "hello"
                   255 0 0 255)

  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO SDL_INIT_TIMER)

  (sdl-wm-set-caption "My SDL Sample Game-gfx Test-" #f)
  (set! screen (sdl-set-video-mode width height 32 SDL_SWSURFACE))
  (sdl-set-alpha screen SDL_SRCALPHA 0)
  )

(define-constant wait (/ 1000 30))
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
  (sdl-quit))

(initialize)
(main-loop)
(finalize)

