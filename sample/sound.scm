(use sdl)

(define-constant filename "res/sound.wav")

(sdl-init SDL_INIT_AUDIO)

(define (get-play-time size freq format channels)
  (/ size (* freq 
             (if (zero? (remainder (logand #xff format) 16)) 2 1)
             channels)))

(define desired
  (make-sdl-audio-spec 22050 AUDIO_S16 2 8192
                       (let ([dpos 0])
                         (lambda (userdata vec)
                           (let ([amount (min (- (ref wav-cvt 'len-cvt) dpos)
                                              (ref vec 'size))])
                             (sdl-mix-audio vec (ref wav-cvt 'buf) amount SDL_MIX_MAXVOLUME dpos)
                             (set! dpos (+ dpos amount)))))))

(define obtained (sdl-open-audio desired))

(define-values (wav-spec wav-buf) (sdl-load-wav filename))

(define wav-cvt (sdl-build-audio-cvt 
                  (ref wav-spec 'format) (ref wav-spec 'channels) (ref wav-spec 'freq)
                  (ref obtained 'format) (ref obtained 'channels) (ref obtained 'freq)))

(sdl-copy-audio-cvt-buf wav-cvt wav-buf)

(sdl-convert-audio wav-cvt)

(format #t "freq:\t\t~A\n" (ref obtained 'freq))
(format #t "format:\t\t~A\n" (if (zero? (remainder (logand #xff (ref obtained 'format)) 16))
                               "16bit" "8bit"))
(format #t "channel:\t~A\n" (if (eq? 1 (ref obtained 'channels))
                              "mono" "stereo"))
(format #t "samples:\t~A\n" (ref obtained 'samples))
(format #t "data-len:\t~A\n" (ref wav-cvt 'len-cvt))
(format #t "time:\t~A\n" (truncate->exact (* (get-play-time
                                 (ref wav-cvt 'len-cvt)
                                 (ref obtained 'freq)
                                 (ref obtained 'format)
                                 (ref obtained 'channels))
                               1000)
                            ))

(sdl-pause-audio #f)

(sdl-delay (truncate->exact (* (get-play-time
                                 (ref wav-cvt 'len-cvt)
                                 (ref obtained 'freq)
                                 (ref obtained 'format)
                                 (ref obtained 'channels))
                               1000)
                            ))

(sdl-close-audio)
(print 'close)

