;;;
;;; sdl.net.ext.scm
;;;
;;; MIT License
;;; Copyright 2011-2012 aharisu
;;; All rights reserved.
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in all
;;; copies or substantial portions of the Software.
;;;
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;; SOFTWARE.
;;;
;;;
;;; aharisu
;;; foo.yobina@gmail.com
;;;

(define-module sdl.net.ext
  (extend sdl.net)
  (use sdl)
  (use srfi-1)
  (use srfi-11) ;for let-values
  (use util.list) ;for drop*
  (use gauche.collection)
  (export
    net-alloc-socket-set net-add-socket net-del-socket net-free-socket-set net-check-sockets
    set->list set->vector
    filter-readied! for-each-readied
    make-nnvector-builder builder-clear make-nnvector-reader reader-clear
    builder-add reader-get
    add-to-builder get-to-reader 
    )
  )
(select-module sdl.net.ext)

(dynamic-load "gauche-sdl-netext")

;;----------
;;extension for socket-set
;;----------

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


;;--------
;;nnvector builder and reader
;;--------

(define-class <nnvector-builder> ()
  (
   (vec :init-keyword :vec)
   (pos :init-keyword :pos :init-value 0)
   ))

(define-class <nnvector-reader> ()
  (
   (vec :init-keyword :vec)
   (pos :init-keyword :pos :init-value 0)
   ))

(define (make-nnvector-builder vec-or-size :optional (init-pos 0))
  (make <nnvector-builder>
        :vec (cond
               [(integer? vec-or-size)
                (make-nnvector nn-u8 vec-or-size)]
               [(is-a? vec-or-size <nnvector>) vec-or-size]
               [else (errorf "the 1st arguments requires a new vector size or <nnvector>, but gut ~s." 
                             vec-or-size)])))

(define (builder-clear builder)
  (slot-set! builder 'pos 0))

(define (make-nnvector-reader vec :optional (pos 0))
  (make <nnvector-reader>
        :vec vec
        :pos pos))

(define (reader-clear reader)
  (slot-set! reader 'pos 0))

(define-generic add-to-builder)
(define-generic get-to-reader)

(define (set-len vec pos s len)
  (when (zero? s) 
    (case s
      [(1) (nnu8vector-set! vec 0 len pos)]
      [(2) (nnu16vector-set! vec 0 len pos)]
      [(4) (nnu32vector-set! vec 0 len pos)])))

(define-constant type->adder-dict
  (let ([h (make-hash-table)])
    (hash-table-put! h 'u8 (lambda (vec val pos s) 
                             (set-len vec pos s 1)
                             (nnu8vector-set! vec 0 val (+ pos s))
                             (+ 1 s)))
    (hash-table-put! h 's8 (lambda (vec val pos s)
                             (set-len vec pos s 1)
                             (nns8vector-set! vec 0 val (+ pos s))
                             (+ 1 s)))
    (hash-table-put! h 'u16 (lambda (vec val pos s)
                              (set-len vec pos s 2)
                              (nnu16vector-set! vec 0 val (+ pos s))
                              (+ 2 s)))
    (hash-table-put! h 's16 (lambda (vec val pos s)
                              (set-len vec pos s 2)
                              (nns16vector-set! vec 0 val (+ pos s))
                              (+ 2 s)))
    (hash-table-put! h 'u32 (lambda (vec val pos s)
                              (set-len vec pos s 4)
                              (nnu32vector-set! vec 0 val (+ pos s))
                              (+ 4 s)))
    (hash-table-put! h 's32 (lambda (vec val pos s)
                              (set-len vec pos s 4)
                              (nns32vector-set! vec 0 val (+ pos s))
                              (+ 4 s)))
    (hash-table-put! h 'f32 builder-add-f32)
    (hash-table-put! h 'real builder-add-real)
    (hash-table-put! h 'str builder-add-string)
    h))

(define (builder-add builder obj :key (type #f) (with-size 0))
  (unless (or (eq? with-size 0) (eq? with-size 1) (eq? with-size 2) (eq? with-size 4))
    (error ":with-size accepts 0 1 2 4"))
  (unless type
    (cond
      [(string? obj) (set! type 'str)]
      [(integer? obj) (set! type 's32)]
      [(real? obj) (set! type 'real)]
      [(number? obj) (error  "numeric type accepts <integer> or <real>.")]
      [else (set! type 'obj)]))
  (cond
    [(eq? type 'obj)
     (let1 pos (slot-ref builder 'pos)
       (slot-set! builder 'pos (+ pos with-size))
       (add-to-builder obj builder)
       (set-len (slot-ref builder 'vec) pos with-size 
                (- (slot-ref builder 'pos) pos))
       builder)]
    [(hash-table-get type->adder-dict type #f) 
     => (lambda (adder)
          (let1 len (adder (slot-ref builder 'vec)
                           obj
                           (slot-ref builder 'pos)
                           with-size)
            (slot-set! builder 'pos (+ len (slot-ref builder 'pos)))
            builder))]
    [else (errorf "unkown type '~s'. accepts symbol are ~s."
                  type
                  (hash-table-keys type->adder-dict))]))

(define-method object-apply ((builder <nnvector-builder>) obj :key (type #f) (with-size 0))
  (builder-add builder obj :type type :with-size with-size))


(define-constant type->getter-dict
  (let ([h (make-hash-table)])
    (hash-table-put! h 'u8 (lambda (vec pos s)
                             (values 
                               (nnu8vector-ref vec 0 (+ pos s))
                               (+ 1 s))))
    (hash-table-put! h 's8 (lambda (vec pos s)
                             (values
                               (nns8vector-ref vec 0 (+ pos s))
                               (+ 1 s))))
    (hash-table-put! h 'u16 (lambda (vec pos s)
                              (values
                                (nnu16vector-ref vec 0 (+ pos s))
                                (+ 2 s))))
    (hash-table-put! h 's16 (lambda (vec pos s)
                              (values
                                (nns16vector-ref vec 0 (+ pos s))
                                (+ 2 s))))
    (hash-table-put! h 'u32 (lambda (vec pos s)
                              (values
                                (nnu32vector-ref vec 0 (+ pos s))
                                (+ 4 s))))
    (hash-table-put! h 's32 (lambda (vec pos s)
                              (values 
                                (nns32vector-ref vec 0 (+ pos s))
                                (+ 4 s))))
    (hash-table-put! h 'f32 reader-get-f32)
    (hash-table-put! h 'real reader-get-real)
    h))

(define (reader-num reader type with-size)
  (unless (or (eq? with-size 0) (eq? with-size 1) (eq? with-size 2) (eq? with-size 4))
    (error ":with-size accepts 0 1 2 4"))
  (cond
    [(hash-table-get type->getter-dict type #f) 
     => (lambda (getter)
          (let-values ([(obj len) (getter (slot-ref reader 'vec)
                                          (slot-ref reader 'pos)
                                          with-size)])
            (slot-set! reader 'pos (+ len (slot-ref reader 'pos)))
            obj))]
    [else (errorf "unkown type '~s'. accepts symbol are ~s" 
                  type
                  (hash-table-keys type->getter-dict))]))

(define (reader-str reader size with-size)
  (when (and (not size) (not with-size))
    (error ":size or :with-size requires either."))
  (when (and size with-size)
    (error ":size or :with-size requires either."))
  (let ([s (cond
             [size
               (if (< size 0)
                 (error ":size is negative number")
                 size)]
             [else (case with-size
                     [(1) (nnu8vector-ref (slot-ref reader 'vec) 
                                          0 (slot-ref reader 'pos))]
                     [(2) (nnu16vector-ref (slot-ref reader 'vec) 
                                           0 (slot-ref reader 'pos))]
                     [(4) (nnu32vector-ref (slot-ref reader 'vec) 
                                           0 (slot-ref reader 'pos))]
                     [else (error ":with-size accepts 1 2 4")])])]
        [pos (slot-ref reader 'pos)])
    (slot-set! reader 'pos (+ s 
                              (if with-size with-size 0)
                              (slot-ref reader 'pos)))
    (reader-get-string (slot-ref reader 'vec) 
                       (+ pos (if with-size with-size 0))
                       s)))

(define (reader-obj reader class with-size)
  (unless (or (zero? with-size) (eq? with-size 1) (eq? with-size 2) (eq? with-size 4))
    (error ":with-size accepts 0 1 2 4"))
  (get-to-reader 
    class 
    reader
    (if (zero? with-size) #f with-size)))

(define (reader-get reader type :key size with-size)
  (case type
    [(str) (reader-str reader
                       (if (undefined? size) #f size)
                       (if (undefined? with-size) #f with-size))]
    [(u8 s8 u16 s16 u32 s32 f32 real) 
     (reader-num reader
                 type
                 (if (undefined? with-size) 0 with-size))]
    [else
      (if (is-a? type <class>)
        (reader-obj  reader type
                     (if (undefined? with-size) 0 with-size))
        (errorf "unkown type '~s'. accepts symbol are ~s, or class instance."
                type
                (cons 'str (hash-table-keys type->getter-dict))))]))

(define-method object-apply ((reader <nnvector-reader>) type :key size with-size)
  (reader-get reader type
              :size (if (undefined? size) (undefined) size)
              :with-size (if (undefined? with-size) (undefined) with-size)))


