(define-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (gnu system keyboard)
  #:use-module (gnu packages wm)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg)
  #:use-module (gnu services guix)
  #:use-module (gnu services networking)
  #:use-module (gnu services desktop))

(define-public %lr/keyboard-layout
  (keyboard-layout "us,no" #:options '("grp:switch")))


;; TODO make private repository containing these files
(define-public %lr/wpa-conf-service
  (extra-special-file "/etc/wpa.conf"
                    (local-file "../../../files/wpa/wpa.conf")))

;; TODO make private repository containing these files
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

    (service ntp-service-type)

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

(define (auto-login-to-tty config tty user)
  (if (string=? tty (mingetty-configuration-tty config))
        (mingetty-configuration
         (inherit config)
         (auto-login user))
        config))

(define-public %lr/desktop-services
  (cons*
    (service xorg-server-service-type
      (xorg-configuration
        (keyboard-layout %lr/keyboard-layout)))

    (service screen-locker-service-type
             (screen-locker-configuration
              (name "i3lock")
              (program (file-append i3lock "/bin/i3lock"))))

    (udev-rules-service 'autorandr
                        (udev-rule
                         "40-autorandr.rules"
                         (string-append "ACTION==\"change\", SUBSYSTEM==\"drm\", "
                                        "RUN+=\"/home/lars/.guix-home/profile/bin/autorandr --batch --change\"")))

    (service wpa-supplicant-service-type)

    (service network-manager-service-type)

    %lr/base-services))

    ;; TODO make stronger connection between this and VT1
    ;; Xorg autostart
    ;;(modify-services %lr/base-services
    ;;  (mingetty-service-type config =>
    ;;                         (auto-login-to-tty
    ;;                          config "tty1" "lars")))))
