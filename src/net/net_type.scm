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
