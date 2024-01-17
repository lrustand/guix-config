(define-module (lrustand systems semcon)
  #:use-module (lrustand home)
  #:use-module (lrustand services base)
  #:use-module (lrustand systems base)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu packages)
  #:use-module (gnu packages shells)
  #:use-module (gnu services docker)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems))

(define-public %semcon-home-environment
  (home-environment
    (inherit %home-environment)
    (packages
      %lr/default-home-packages)))

(define-public %semcon-services
  (cons*
   (service docker-service-type)
   %lr/desktop-services))

(define-public %semcon-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "semcon")

    (kernel-arguments '("modprobe.blacklist=pcspkr,snd_pcsp"))

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
     %semcon-services)

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

(if (and (string=? "home" (cadr (command-line)))
         (string=? "reconfigure" (caddr (command-line))))
    %semcon-home-environment
    %semcon-operating-system)
