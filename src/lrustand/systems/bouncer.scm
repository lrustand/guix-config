(define-module (lrustand systems bouncer)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)

  #:use-module (gnu)
  #:use-module (gnu packages firmware)
  #:use-module (gnu services xorg)

  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services admin)
  #:use-module (gnu services vpn))

(define-public %bouncer-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "bouncer")

    (kernel-arguments (list "console=ttyS0,115200"))

    (packages
      (append
        (map specification->package
          (list
            "nss-certs"
            "znc"
            "bitlbee"
            "tmux"))
        %base-packages))

    (services
     (cons*
      (service dhcp-client-service-type)
      (service ntp-service-type)
      %base-services))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device "/dev/vda2")
         (type "ext4"))
       (file-system
         (mount-point "/boot/efi")
         (device "/dev/vda1")
         (type "vfat"))
       %base-file-systems))))

%bouncer-operating-system
