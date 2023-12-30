(define-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (gnu system keyboard)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg)
  #:use-module (gnu services guix)
  #:use-module (gnu services desktop))

(define-public %lr/keyboard-layout
  (keyboard-layout "us,no" #:options '("grp:switch")))

(define-public %lr/base-services
  (cons*
    (modify-services %base-services
      (guix-service-type config => (guix-configuration
        (inherit config)
        (substitute-urls
         (append (list "https://substitutes.nonguix.org")
           %default-substitute-urls))
        (authorized-keys
         (append (list (plain-file "non-guix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
           %default-authorized-guix-keys)))))))

(define-public %lr/desktop-services
  (cons*
    (set-xorg-configuration
      (xorg-configuration
        (keyboard-layout %lr/keyboard-layout)))
    (modify-services %desktop-services
      (guix-service-type config => (guix-configuration
        (inherit config)
        (substitute-urls
         (append (list "https://substitutes.nonguix.org")
           %default-substitute-urls))
        (authorized-keys
         (append (list (plain-file "non-guix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
           %default-authorized-guix-keys)))))))
