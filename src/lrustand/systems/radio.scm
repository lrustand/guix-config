(define-module (lrustand systems radio)
  #:use-module (lrustand home)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu packages shells)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu services)
  #:use-module (gnu services audio)
  #:use-module (gnu services networking))

(define-public %radio-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "radio")

    (services
     (cons*
       (service mpd-service-type
         (mpd-configuration
          (music-directory "/srv/music")))

       (service mympd-service-type
         (mympd-configuration
          (port 80)
          (covercache-ttl 0)))

       (service dhcp-client-service-type)

       %lr/base-services))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (file-system-label "radio-guix"))
         (type "ext4"))
       (file-system
         (mount-point "/boot/efi")
         (device (file-system-label "radio-efi"))
         (type "vfat"))
       %base-file-systems))))

%radio-operating-system
