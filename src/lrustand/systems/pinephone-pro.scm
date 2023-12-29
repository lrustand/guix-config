(define-module (lrustand systems pinephone-pro)
  #:use-module (lrustand packages pinephone-pro)
  #:use-module (gnu packages certs)
  #:use-module (nongnu packages linux)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system shadow)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services ssh)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sound)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages shells)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:export (%pinephone-pro-operating-system))

(define %pinephone-pro-operating-system
  (operating-system
    (kernel pinephone-pro-kernel)
    (kernel-arguments
     (append
      (list
       "console=ttyS2,115200"
       "earlycon=uart8250,mmio32,0xff1a0000"
       "earlyprintk")
      (drop-right %default-kernel-arguments 1)))

    (initrd-modules '())

    (firmware (append
               (list pinephone-pro-firmware)
               %base-firmware))
    (host-name "pinephonepro")
    (timezone "Europe/Oslo")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us" "qwerty"))

    (bootloader
     (bootloader-configuration
      (bootloader u-boot-rockpro64-rk3399-bootloader)
      (targets '("/dev/mmcblk2"))))

    (file-systems
     (cons
      (file-system
        (device "/dev/mmcblk2p1")
        (mount-point "/")
        (type "ext4"))
      %base-file-systems))

    (users (cons (user-account
                  (name "lars")
		  ;; Uncomment and edit this when building image
                  ;; (password (crypt "1234" "$6$abc"))
                  (group "users")
                  (supplementary-groups '("wheel" "audio" "video"))
                  (shell (file-append zsh "/bin/zsh"))
                  (home-directory "/home/lars"))
                 %base-user-accounts))

    (packages
     (append (list
              parted
              stumpwm
              pulseaudio
              alsa-utils
              sof-firmware ;; TODO: Might not be needed, try without
              ;;alsa-firmware
              nss-certs)
      %base-packages))

    (services
     (append
      %base-services
      (list
       (service wpa-supplicant-service-type)
       ;;(service network-manager-service-type)
       ;;(service slim-service-type)
       ;;(service modem-manager-service-type)
       ;;(service alsa-service-type)
       (service openssh-service-type
                (openssh-configuration
                 (x11-forwarding? #f)
                 (authorized-keys
                  `(("lars" ,(local-file "../../../files/ssh/yoga.pub"))))
                 (print-last-log? #t))))))))

%pinephone-pro-operating-system
