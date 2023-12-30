(define-module (lrustand systems drit)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system))

(define-public %drit-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "drit")

     (bootloader
       (bootloader-configuration
         (bootloader grub-bootloader)
         (targets '("/dev/sda"))
         (keyboard-layout %lr/keyboard-layout)))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (file-system-label "drit-root"))
         (type "ext4"))
       %base-file-systems))))

%drit-operating-system
