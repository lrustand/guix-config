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


(define-public %lr/wpa-conf-service
  (extra-special-file "/etc/wpa.conf"
                    (local-file "../../../files/wpa/wpa.conf")))

(define-public %lr/wifi-networks-services
  (list
    (extra-special-file "/etc/NetworkManager/system-connections/Altibox532887.nmconnection"
                        (local-file "../../../files/networkmanager/Altibox532887.nmconnection"))
    (extra-special-file "/etc/NetworkManager/system-connections/Altibox532887_5G.nmconnection"
                        (local-file "../../../files/networkmanager/Altibox532887_5G.nmconnection"))
    (extra-special-file "/etc/NetworkManager/system-connections/eduroam.nmconnection"
                        (local-file "../../../files/networkmanager/eduroam.nmconnection"))))

(define-public %lr/base-services
  (cons*
    (service elogind-service-type)
    (modify-services %base-services
      (guix-service-type config => (guix-configuration
        (inherit config)
        (substitute-urls
         (append (list "https://substitutes.nonguix.org")
           %default-substitute-urls))
        (authorized-keys
         (cons
          (local-file "../../../files/nonguix/nonguix.pub")
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
         (cons
          (local-file "../../../files/nonguix/nonguix.pub")
          %default-authorized-guix-keys)))))))
