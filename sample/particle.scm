(use sdl)
(use sdl.image)

(use gauche.record)
(use math.mt-random)

(define rand
  (let ([m (make <mersenne-twister>)])
    (lambda (l u)
      (+ (mt-random-integer m (- u l)) l))))

(define-constant width 640)
(define-constant height 480)

(define screen #f)
(define background-image #f)
(define particle-image #f)

(define-record-type particle #t #f
  (x)
  (y)
  (vx)
  (vy)
  (alive)
  (type)
  (frame))

(define-constant max-particle-count 512)
(define-constant particles (make-vector max-particle-count))

(define (create-particle x y vx vy type)
  (cond
    [(let find-patricle ([i 0])
       (if (particle-alive (vector-ref particles i))
         (if (< (+ i 1) max-particle-count)
           (find-patricle (+ i 1))
           #f)
         (vector-ref particles i)))
     => (lambda (p)
          (particle-alive-set! p #t)
          (particle-x-set! p x)
          (particle-y-set! p y)
          (particle-vx-set! p vx)
          (particle-vy-set! p vy)
          (particle-type-set! p type)
          (particle-frame-set! p 0)
          p)]
    [else #f]))

(define (update-particle p)
  (particle-vy-set! p (+ (particle-vy p) 0.4))
  (particle-x-set! p (+ (particle-x p) (particle-vx p)))
  (particle-y-set! p (+ (particle-y p) (particle-vy p)))
  (particle-frame-set! p (+ (particle-frame p) 0.5))
  (when (>= (particle-frame p) 4)
    (particle-frame-set! p 0))
  (when (> (particle-y p) height)
    (particle-alive-set! p #f)))

(define-macro (for-each-alive-particle index exp)
  `(dotimes (,index max-particle-count)
     (when (particle-alive (vector-ref particles ,index))
       ,exp)))

(define (update)
  (for-each-alive-particle
    i
    (update-particle (vector-ref particles i)))
  (create-particle 320 240 (rand -5 5) (rand -16 -8) 0)
  (create-particle 312 232 (rand -5 5) (rand -16 -8) 1))

(define-macro (int exp)
  `(truncate->exact ,exp))

(define (draw-particle p)
  (sdl-blit-surface particle-image
                    (case (particle-type p)
                      [(0) (make-sdl-rect 
                             (* (int (particle-frame p)) 16) 0 16 16)]
                      [(1) (make-sdl-rect
                             (* (int (particle-frame p)) 32) 16 32 32)])
                    screen
                    (make-sdl-rect 
                      (int (particle-x p))
                      (int (particle-y p))
                      0 0)))

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  (for-each-alive-particle
    i
    (draw-particle (vector-ref particles i)))
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init (logior SDL_INIT_VIDEO SDL_INIT_TIMER))
  (sdl-wm-set-caption "My SDL Sample Game-Particle-" #f)
  (set! screen (sdl-set-video-mode width height 32 SDL_SWSURFACE))
  (set! background-image (img-load "res/background.png"))
  (set! particle-image (img-load "res/particle.png"))
  (dotimes (i max-particle-count 1)
    (vector-set! particles i (make-particle 0 0 0 0 #f 0 0))))

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
  (sdl-free-surface particle-image)
  (sdl-quit))

(initialize)
(main-loop)
(finalize)


