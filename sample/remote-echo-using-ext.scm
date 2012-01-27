(use sdl)
(use sdl.net.ext)
(use gauche.parseopt)
(use srfi-1)

(define sock #f)
(define set #f)

(define echo-port 19816)

(define (usage)
  (print "Server mode --server")
  (print "Client mode --remote=remote-host")
  (exit 2))

(define (initialize)
  (sdl-init)
  (net-init)
  )

(define (finalize)
  (when sock
    (net-tcp-close sock))
  (when set
    (net-free-socket-set set))
  (net-quit)
  (sdl-quit)
  )

(define echo-back
  (let ([buf (make-nnvector nn-u8 512)])
    (lambda (peer)
      (if (<= (net-tcp-recv peer buf) 0)
        #f
        (let* ([len (ref buf 0)]
               [text (nnvector->string buf 1 (+ 1 len))])
          (print "> " text)
          (set! (ref buf 0) len)
          (string->nnvector! buf 1 text)
          (net-tcp-send peer buf 0 (+ 1  len))
          #t)))))

(define (run-server-mode)
  (set! set (net-alloc-socket-set))
  ;;server start
  (let ([ip (net-resolve-host #f echo-port)])
    (print "server ip:" ip)
    (set! sock (net-tcp-open ip))
    (net-add-socket set sock))
  (print "server start")
  ;;main loop
  (let loop ()
    (unless (zero? (net-check-sockets set 250))
      ;;connect new peer
      (when (net-socket-ready? sock)
        (let ([peer (net-tcp-accept sock)])
          (print "accept")
          (net-add-socket set peer)))
      (filter-readied!
        (lambda (peer)
          ;;recv data
          (if (echo-back peer)
            #t
            (begin
              (net-del-socket set peer)
              (net-tcp-close peer)
              #f)))
        set
        sock)) ;without server sock 
    (sdl-delay 0)
    (loop)))


(define echo
  (let ([buf (make-nnvector nn-u8 512)])
    (lambda (text)
      (let* ([text-vec (string->nnvector text nn-u8)]
             [size (size-of text-vec)])
        (set! (ref buf 0) size)
        (nnvector-copy! buf 1 text-vec)
        (net-tcp-send sock buf 0 (+ 1 size))
        (net-check-sockets set #xffffffff)
        (when (net-socket-ready? sock)
          (if (<= (net-tcp-recv sock buf) 0)
            (print "# error!")
            (let* ([len (ref buf 0)]
                   [text (nnvector->string buf 1 (+ 1 len))])
              (print "> " text))))))))

(define (run-client-mode host)
  (set! set (net-alloc-socket-set 1))
  ;;client start
  (let ([ip (net-resolve-host host echo-port)])
    (print "remote ip:" ip)
    (set! sock (net-tcp-open ip))
    (net-add-socket set sock))
  (print "start")
  ;;main loop
  (let loop ()
    (let ([text (read-line (current-input-port))])
      (unless (string=? text "exit") 
        (echo text)
        (sdl-delay 0)
        (loop)))))


(define (main args)
  (let-args (cdr args)
    ([server "s|server"]
     [remote "r|remote=s"]
     [else (opt . _) (usage)])
    (when (or (and server remote)
          (and (not server) (not remote)))
      (print "Please specify either")
      (usage))
    (initialize)
    (if server
      (run-server-mode)
      (run-client-mode remote))
    (finalize)
  ))

