(use sdl)

(sdl-init)

(define l '(1 2 3 4 5))

(define thread1 (sdl-create-thread 
                 (lambda ()
                   (for-each
                     (lambda (x)
                       (print "thread#1:" (sdl-thread-id) ":" x)
                       (sdl-delay 800))
                     l)
                   0)))

(define thread2 (sdl-create-thread 
                 (lambda ()
                   (for-each
                     (lambda (x)
                       (print "thread#2:" (sdl-thread-id) ":" x)
                       (sdl-delay 1200))
                     l)
                   0)))

(for-each
  (lambda (x)
    (print x)
    (sdl-delay 400))
  l)

(print 'wait)
(sdl-wait-thread thread1)
(sdl-wait-thread thread2)
(print 'finish)


