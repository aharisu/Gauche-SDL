(use sdl)
(use sdl.mixer)
(use sdl.smpeg)

(define-constant movie-file "res/sample.mpg")

(define screen #f)
(define mpeg #f)

(define (update)
  (smpeg-status mpeg)
  )

(define (draw)
  )

(define (initialize)
  (sdl-init SDL_INIT_VIDEO SDL_INIT_AUDIO)

  (sdl-wm-set-caption "My SDL Sample SMPEG" #f)

  (set! mpeg (smpeg-new movie-file #t))

  (let1 info (smpeg-get-info mpeg)
    (set! screen (sdl-set-video-mode 
                   (ref info 'width) (+ 50 (ref info 'height))
                   32 SDL_SWSURFACE)))

  (let1 spec (smpeg-wanted-spec mpeg)
    (mix-open-audio
      (ref spec 'freq)
      (ref spec 'format)
      (ref spec 'channels)
      (ref spec 'samples)))

  (smpeg-set-display mpeg screen)
  (smpeg-move mpeg 0 25)
  (smpeg-scale mpeg 1)
  (smpeg-loop mpeg #t)
  (smpeg-set-volume mpeg 100)
  (smpeg-play mpeg)
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
  (smpeg-stop mpeg)
  (smpeg-delete mpeg)
  (sdl-quit))

(initialize)
(main-loop)
(finalize)

