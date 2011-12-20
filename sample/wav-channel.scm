(use sdl)
(use sdl.mixer)
(use sdl.image)
(use sdl.ttf)
(use srfi-11)

(define screen #f)
(define background-image #f)
(define font #f)
(define wav0 #f)
(define wav1 #f)
(define wav2 #f)
(define wav3 #f)
(define wav4 #f)

(define (play-wav channel wav)
  ;(mix-halt-channel channel)
  (mix-play-channel channel wav 0))

(define (music-done)
  (mix-halt-music)
  (mix-free-music music)
  (set! music #f))

(define (handle-event event)
  (cond
    [(eq? SDL_KEYDOWN (ref event 'type))
     (let1 key (ref (ref event 'keysym) 'sym)
       (cond
         ([eq? key SDLK_1] (play-wav 0 wav0))
         ([eq? key SDLK_2] (play-wav 1 wav1))
         ([eq? key SDLK_3] (play-wav 2 wav2))
         ([eq? key SDLK_4] (play-wav 3 wav3))
         ([eq? key SDLK_5] (play-wav 4 wav4))))])
  #t)

(define (update)
  )

(define (draw)
  (sdl-blit-surface background-image #f screen #f)
  ;; render text
  (let1 height (ttf-font-height font)
    (dotimes [i 5]
      (sdl-blit-surface 
        (ttf-render-text-blended
          font 
          (string-append "Push " (x->string (+ i 1)) " key. Play " (x->string i) " channel.")
          (make-sdl-color 0 0 0))
        #f
        screen (make-sdl-rect 10 (+ 50 (* i 20) (* i height)) 0 0))))
  ;; update screen
  (sdl-update-rect screen 0 0 0 0))

(define (initialize)
  (sdl-init SDL_INIT_VIDEO SDL_INIT_AUDIO)
  (ttf-init)

  (sdl-wm-set-caption "My SDL Sample Game-Play each channel" #f)
  (set! screen (sdl-set-video-mode 640 480 32 SDL_SWSURFACE))

  (set! background-image (img-load "res/background.png"))
  ;; open ttf font
  (set! font (ttf-open-font "res/YOzBAF.TTC" 42))

  ;; open audio
  (mix-open-audio 22050 AUDIO_S16 2 4096)
  (set! wav0 (mix-load-wav "res/sound0.wav"))
  (set! wav1 (mix-load-wav "res/sound1.wav"))
  (set! wav2 (mix-load-wav "res/sound2.wav"))
  (set! wav3 (mix-load-wav "res/sound3.wav"))
  (set! wav4 (mix-load-wav "res/sound4.wav"))
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


