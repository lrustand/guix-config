(define-module (lrustand systems work-vm)
  #:use-module (lrustand home)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu packages shells)
  #:use-module (gnu system)
  #:use-module (gnu system accounts)
  #:use-module (gnu system shadow)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)
  ;;#:use-module (gnu services home) ;; From RDE. Used to embed HE into OS
  #:use-module (gnu services virtualization)
  #:use-module (guix gexp))

(define-public %work-vm-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "work-vm")

    (users
      (cons*
        (user-account
          (name "lars")
          (comment "")
          (group "users")
          (shell (file-append zsh "/bin/zsh"))
          (home-directory "/home/lars")
          (supplementary-groups '("wheel" "docker")))
        %base-user-accounts))

    (services
      (cons*
       (service qemu-binfmt-service-type
                (qemu-binfmt-configuration
                 (platforms (lookup-qemu-platforms "arm" "aarch64"))))
       (service docker-service-type)
       ;;(service guix-home-service-type
       ;;         `(,(cons
       ;;             "lars"
       ;;             %home-environment)))
       %lr/desktop-services))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (file-system-label "work-vm-guix"))
         (type "ext4"))
       (file-system
         (mount-point "/boot/efi")
         (device (file-system-label "work-vm-efi"))
         (type "vfat"))
       %base-file-systems))))

%work-vm-operating-system
