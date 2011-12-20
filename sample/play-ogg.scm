(use sdl)
(use sdl.mixer)
(use sdl.image)
(use sdl.ttf)
(use srfi-11)

(define screen #f)
(define background-image #f)
(define font #f)
(define music #f)

(define (music-done)
  (mix-halt-music)
  (mix-free-music music)
  (set! music #f))

(define (handle-event event)
  (let ([type (ref event 'type)])
    (cond
      [(or (eq? SDL_KEYDOWN type) (eq? SDL_KEYUP type))
       (when (and (eq? (ref (ref event 'keysym) 'sym) SDLK_m)
               (eq? (ref event 'state) SDL_PRESSED))
         (if music
           (music-done)
           (begin 
             (set! music (mix-load-mus "res/sample.ogg"))
             (mix-play-music music 0)
             (mix-hook-music-finished music-done))))]))
  #t)

(define (update)
  )

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  ;; render text
  (sdl-blit-surface 
    (ttf-render-text-blended
      font 
      (if music
        "Push 'm' key!! Stop Music"
        "Push 'm' key!! Play Music")
      (make-sdl-color 255 0 0))
    #f
    screen (make-sdl-rect 10 50 0 0))
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO SDL_INIT_AUDIO)
  (ttf-init)

  (sdl-wm-set-caption "My SDL Sample Game-Play ogg-" #f)
  (set! screen (sdl-set-video-mode 640 480 32 SDL_SWSURFACE))

  (set! background-image (img-load "res/background.png"))
  ;; open ttf font
  (set! font (ttf-open-font "res/YOzBAF.TTC" 42))

  ;; open audio
  (mix-open-audio 22050 AUDIO_S16 2 4096)
  (let-values ([(freq format channels) (mix-query-spec)])
    (print "frequence:" freq)
    (print "format:" format)
    (print "channel:" channels))
  )

(define-constant wait (/ 1000 60))
(define (main-loop)
  (let loop ([next-frame (sdl-get-ticks)])
    (unless (let proc-event ([event (sdl-poll-event)])
              (and event
                (or
                  (eq? (ref event 'type) SDL_QUIT)
                  (and (eq? (ref event 'type) SDL_KEYUP) (eq? (ref (ref event 'keysym) 'sym) SDLK_ESCAPE))
                  (not (handle-event event))
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
  (mix-close-audio)
  (sdl-free-surface background-image)
  (ttf-close-font font)
  (ttf-quit)
  (sdl-quit))

(initialize)
(main-loop)
(finalize)


