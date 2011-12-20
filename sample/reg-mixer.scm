(use sdl)
(use sdl.mixer)

(sdl-init SDL_INIT_AUDIO)
(mix-open-audio 22050 AUDIO_S16 2 4096)

(define-constant chan 0)

(define wav (mix-load-wav "res/sound.wav"))
(define mix0 (mix-load-wav "res/sound0.wav"))
(define mix1 (mix-load-wav "res/sound1.wav"))

(mix-play-channel chan wav 0)
(mix-pause chan)

(mix-register-effect 
  chan 
  (let ([dpos 0])
    (lambda (chan vec arg)
      (let* ([abuf (ref mix0 'abuf)]
             [amount (min (- (ref abuf 'size) dpos)
                          (ref vec 'size))])
        (sdl-mix-audio vec abuf amount 
                       (quotient SDL_MIX_MAXVOLUME 2)
                       dpos)
        (set! dpos (+ dpos amount)))))
  #f
  'arg)

(mix-register-effect 
  chan 
  (let ([dpos 0])
    (lambda (chan vec)
      (let* ([abuf (ref mix1 'abuf)]
             [amount (min (- (ref abuf 'size) dpos)
                          (ref vec 'size))])
        (sdl-mix-audio vec abuf amount 
                       SDL_MIX_MAXVOLUME
                       dpos)
        (set! dpos (+ dpos amount)))))
  (lambda (chan)
    (print "finish")))

(mix-resume chan)
(sdl-delay 2000)
(mix-halt-channel chan)

(mix-close-audio)
(sdl-quit)

