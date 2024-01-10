(define-module (lrustand systems pinephone-pro)
  #:use-module (lrustand packages pinephone-pro)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (lrustand services grow-part)
  #:use-module (gnu image)
  #:use-module (gnu packages)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system images rock64)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system shadow)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu packages shells)
  #:use-module (gnu services)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (guix platforms arm))

(define-public %pinephone-pro-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "pinephonepro")

    (kernel pinephone-pro-kernel-6.3)
    (kernel-arguments
     (append
      (list
       "console=ttyS2,115200"
       "earlycon=uart8250,mmio32,0xff1a0000"
       "earlyprintk")
      (drop-right %default-kernel-arguments 1)))

    (initrd base-initrd)
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

    (services
     (append
      (list
        (service openssh-service-type
                 (openssh-configuration
                  (x11-forwarding? #f)
                  (authorized-keys
                   `(("lars" ,(local-file "../../../files/ssh/yoga.pub"))))
                  (print-last-log? #t)))
        (service dhcp-client-service-type)
        (service wpa-supplicant-service-type)
        (service grow-part-service-type
                 (grow-part-configuration
                  (device "/dev/mmcblk2")
                  (part-number 1)
                  (partition "/dev/mmcblk2p1")))
        %lr/wpa-conf-service)
      %lr/wifi-networks-services
      %lr/base-services))))

(define-public pinephone-pro-image
  (image
   (inherit
    (os+platform->image %pinephone-pro-operating-system aarch64-linux
                        #:type rock64-image-type))
   (name 'pinephone-pro-image)))

pinephone-pro-image
