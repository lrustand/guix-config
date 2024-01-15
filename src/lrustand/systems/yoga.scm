(define-module (lrustand systems yoga)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services virtualization))

(define-public %yoga-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "yoga")

    (initrd-modules (append '("vmd") %base-initrd-modules))

    (services
      (cons*
       (service qemu-binfmt-service-type
                (qemu-binfmt-configuration
                 (platforms (lookup-qemu-platforms "arm" "aarch64"))))
       (service bluetooth-service-type)
       %lr/desktop-services))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (uuid
                  "8c82369a-ebd9-4ad4-818c-82d270c5f3a9"
                  'ext4))
         (type "ext4"))
       (file-system
         (mount-point "/boot/efi")
         (device (uuid "2C6E-7735"
                       'fat32))
         (type "vfat"))
       %base-file-systems))))

%yoga-operating-system
