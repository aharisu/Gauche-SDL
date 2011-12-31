(define-module sdl.net.ext
  (extend sdl.net)
  (use srfi-1)
  (use util.list)
  (use gauche.collection)
  (export
    net-alloc-socket-set net-add-socket net-del-socket net-free-socket-set net-check-sockets
    set->list set->vector
    filter-readied! for-each-readied
    )
  )
(select-module sdl.net.ext)

(define-class <socket-set> (<collection>)
  ((set :init-keyword :set)
   (capacity :init-keyword :capacity)
   (len :init-value 0)
   (list :init-value '())
   ))

(define-constant *org-net-free-socket-set* net-free-socket-set)

(define-constant *org-net-alloc-socket-set* net-alloc-socket-set)
(define (net-alloc-socket-set :optional (maxsockets 7));default set size is 7
  (make <socket-set>
        :set (*org-net-alloc-socket-set* maxsockets)
        :capacity maxsockets))
        
(define-constant *org-net-add-socket* net-add-socket)
(define (net-add-socket set sock)
  (when (>= (slot-ref set 'len) (slot-ref set 'capacity))
    ;;resize
    (*org-net-free-socket-set* (slot-ref set 'set))
    (let* ([cap (ceiling->exact (* 1.5 (slot-ref set 'capacity)))]
           [new-set (*org-net-alloc-socket-set* cap)])
      (slot-set! set 'set new-set)
      (slot-set! set 'capacity cap)
      (for-each
        (cut *org-net-add-socket* new-set <>)
        (slot-ref set 'list))))
  (begin0
    (*org-net-add-socket* (slot-ref set 'set) sock)
    (slot-set! set 'list (cons sock (slot-ref set 'list)))
    (slot-set! set 'len (+ (slot-ref set 'len) 1))))

(define-constant *org-net-del-socket* net-del-socket)
(define (net-del-socket set sock)
  (begin0
    (*org-net-del-socket* (slot-ref set 'set) sock)
    (slot-set! set 'len (- (slot-ref set 'len) 1))
    (slot-set! set 'list (remove!
                           (cut eq? sock <>)
                           (slot-ref set 'list)))))

(define (net-free-socket-set set)
  (*org-net-free-socket-set* (slot-ref set 'set)))

(define-constant *org-net-check-sockets* net-check-sockets)
(define (net-check-sockets set timeout)
  (*org-net-check-sockets* (slot-ref set 'set)
                           (if (and (symbol? timeout) (eq? 'inf timeout))
                             #xffffffff timeout)))

(define-method call-with-iterator ((set <socket-set>) proc . opts)
  (let-keywords opts ([start #f])
    (let* ([len (slot-ref set 'len)]
           [i (or start 0)]
           [c (drop* (slot-ref set 'list) i)])
      (proc (lambda () (null? c))
            (lambda () (begin0 (car c) (set! c (cdr c))))))))

;;not support referencer modifier
(define-method size-of ((set <socket-set>)) (slot-ref set 'len))

(define (set->list set) (list-copy (slot-ref set 'list)))
(define (set->vector set) (list->vector (slot-ref set 'list)))

(define (filter-readied! pred set . without)
  (slot-set! set 'list (filter!
                         (lambda (s)
                           (if (and (not (any (cut eq? s <>) without))
                                      (net-socket-ready? s))
                             (pred s)
                             #t))
                         (slot-ref set 'list)))
  set)

(define (for-each-readied proc set . without)
  (for-each
    (lambda (s)
      (when (and (not (any (cut eq? s <>) without))
              (net-socket-ready? s))
        (proc s)))
    (slot-ref set 'list)))


