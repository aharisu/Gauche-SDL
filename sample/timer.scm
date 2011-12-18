(use sdl)

(sdl-init SDL_INIT_TIMER)

(define timer (sdl-add-timer 1000 
                             (lambda (interval p)
                               (display "callback,")
                               (format #t  "interval:~S," interval)
                               (format #t "param:~S\n" p)
                               (quotient interval 2))
                             "param obj"))
(print "timer start:" timer)

(sdl-delay 2000)

(sdl-remove-timer timer)

(print "exit")

