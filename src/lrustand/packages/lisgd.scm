(define-module (lrustand packages lisgd)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xorg)
  #:use-module ((guix licenses) #:prefix license:))


(define-public lisgd
  (package
    (name "lisgd")
    (version "0.4.0")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://git.sr.ht/~mil/lisgd")
         (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0rkm6d3jn0i1fwf5qj47hv8w9aax5fijhccnc6f6v59q3aj5jd4n"))))
  (build-system gnu-build-system)
  (arguments
   `(#:phases
     (modify-phases %standard-phases
       (delete 'configure)
       (delete 'check))
     #:make-flags `("CC=gcc"
                    "WITHOUT_WAYLAND=1"
                    ,(string-append "PREFIX=" (assoc-ref %outputs "out")))))
  (native-inputs
   (list libinput
         libx11))
  (home-page "")
  (synopsis "")
  (description "")
  (license license:gpl2)))

lisgd
