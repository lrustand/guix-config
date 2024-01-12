(define-module (lrustand systems pinephone-pro)
  #:use-module (lrustand packages pinephone-pro)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (lrustand services grow-part)
  #:use-module (gnu)
  #:use-module (gnu image)
  #:use-module (gnu packages)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (gnu system images rock64)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system shadow)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu packages shells)
  #:use-module (gnu services)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sound)
  #:use-module (gnu services desktop)
  #:use-module (srfi srfi-26)
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
      %default-kernel-arguments))

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
        (service slim-service-type)
        (service dhcp-client-service-type)
        (service wpa-supplicant-service-type
                 (wpa-supplicant-configuration
                  (config-file "/etc/wpa.conf")
                  (interface "wlan0")))
        (service x11-socket-directory-service-type)
        (service pulseaudio-service-type)
        (service alsa-service-type)
        (service grow-part-service-type
                 (grow-part-configuration
                  (device "/dev/mmcblk2")
                  (part-number 1)
                  (partition "/dev/mmcblk2p1")))
        %lr/wpa-conf-service)
      %lr/wifi-networks-services
      %lr/base-services))))

;; TODO All this shit below is untested
(define pinephone-pro-root-partition
  (partition
   (size 'guess)
   (offset (expt 2 24))
   (label "ppp-root")
   (flags '(boot))
   (initializer (gexp initialize-root-partition))))

(define pinephone-pro-image
  (image-without-os
   (format 'disk-image)
   (partitions (list pinephone-pro-root-partition))))

(define-public pinephone-pro-image-type
  (image-type
   (name 'pinephone-pro-raw)
   (constructor (cut image-with-os pinephone-pro-image <>))))

(define-public pinephone-pro-barebones-raw-image
  (image
   (inherit
    (os+platform->image %pinephone-pro-operating-system aarch64-linux
                        #:type pinephone-pro-image-type))
   (name 'pinephone-pro-barebones-raw-image)))

;; Return the default image.
pinephone-pro-barebones-raw-image

