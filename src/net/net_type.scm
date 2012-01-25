;;;
;;; net_type.scm
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

(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "//sdl header")
              (cgen-extern "#include<SDL/SDL.h>")
              (cgen-extern "#include<SDL/SDL_net.h>")
              (cgen-extern "")
              (cgen-extern "
                           typedef struct {
                           UDPpacket* o;
                           ScmObj vec;
                           }UDPpacketWrapper;

                           struct ScmUDPpacketWrapperRec;

                           typedef struct {
                           UDPpacket** v;
                           struct ScmUDPpacketWrapperRec* packet_ary;
                           int length;
                           }UDPpacketV;

                           ")
              (cgen-body "
                         static void free_UDPpacketWrapper(UDPpacketWrapper* wrapper)
                         {
                          SDLNet_FreePacket(wrapper->o);
                         }

                         static void free_UDPpacketV(UDPpacketV* obj)
                         {
                          SDLNet_FreePacketV(obj->v);
                         }
                         ")
              )
            (lambda () ;;epilogue
              ))
  0)


;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    (IPaddress <net-ip-address> #f #f "")
    (UDPpacketWrapper <net-udp-packet> #t "free_UDPpacketWrapper" "")
    (SDLNet_GenericSocket <net-generic-socket> #f #f "")
    (TCPsocket <net-tcp-socket> #f "SDLNet_TCP_Close" "")
    (UDPsocket <net-udp-socket> #f "SDLNet_UDP_Close" "")
    (UDPpacketV <net-udp-packet-vec> #t "free_UDPpacketV" "")
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    (SDLNet_SocketSet <net-socket-set> #f "SDLNet_FreeSocketSet" "")
    ))
