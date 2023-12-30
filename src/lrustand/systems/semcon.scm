(define-module (lrustand systems semcon)
  #:use-module (lrustand systems base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems))

(define-public %semcon-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "semcon")

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (file-system-label "semcon-guix"))
         (type "ext4"))
       (file-system
         (mount-point "/boot/efi")
         (device (file-system-label "semcon-efi"))
         (type "vfat"))
       %base-file-systems))))

%semcon-operating-system
