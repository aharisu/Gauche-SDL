(load "cv_struct_generator")

(use file.util)

(define (main args)
  (gen-type (simplify-path (path-sans-extension (car args)))
            structs foreign-pointer
            (lambda () ;;prologue
              (cgen-extern "#include<smpeg/smpeg.h>")
              (cgen-extern "
                           typedef struct SMPEGWrapperRec {
                            SMPEG* smpeg;
                            int audio_enable;
                           }SMPEGWrapper;

                           ")
              (cgen-body "
                         void free_SMPEGWrapper(SMPEGWrapper* wrapper)
                         {
                          SMPEG_delete(wrapper->smpeg);
                         }
                         "))
            (lambda () ;;epilogue
              )
            )
  0)

;;sym-name sym-scm-type pointer? finalize-name finalize-ref
(define structs 
  '(
    (SMPEG_Info <smpeg-info> #t #f "")
    ))

;;sym-name sym-scm-type pointer? finalize finalize-ref 
(define foreign-pointer 
  '(
    (SMPEGWrapper <smpeg> #t #f "")
    ))
