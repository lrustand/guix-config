(define-module (lrustand systems pinephone-pro)
  #:use-module (lrustand packages pinephone-pro)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system shadow)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu packages shells)
  #:use-module (gnu services)
  #:use-module (gnu services ssh)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:export (%pinephone-pro-operating-system))

(define-public %pinephone-pro-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "pinephonepro")

    (kernel pinephone-pro-kernel)
    (kernel-arguments
     (append
      (list
       "console=ttyS2,115200"
       "earlycon=uart8250,mmio32,0xff1a0000"
       "earlyprintk")
      (drop-right %default-kernel-arguments 1)))

    (initrd-modules '())

    (firmware (cons*
               pinephone-pro-firmware
               %base-firmware))

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

    (services
     (append
      %lr/desktop-services
      (list
       (service openssh-service-type
                (openssh-configuration
                 (x11-forwarding? #f)
                 (authorized-keys
                  `(("lars" ,(local-file "../../../files/ssh/yoga.pub"))))
                 (print-last-log? #t))))))))

%pinephone-pro-operating-system
