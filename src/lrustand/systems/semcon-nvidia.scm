(define-module (lrustand systems semcon-nvidia)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu services nvidia)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages wm)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)

  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services admin)
  #:use-module (gnu services linux)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)

  #:use-module (guix packages)
  #:use-module (guix transformations))

;this can be inlined as it's only called once
(define transform
 (options->transformation
  '((with-graft . "mesa=nvda"))))

(define %semcon-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "semcon")

    (kernel linux-lts)
    (kernel-loadable-modules (list nvidia-module))

    (kernel-arguments (append 
			'("modprobe.blacklist=pcspkr,snd_pcsp,nouveau"
			  "acpi_osi=\"Windows 2009\"")
			%default-kernel-arguments))

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

    ;;(packages
    ;;  (append
    ;;    (list sof-firmware)
    ;;          ;;(transform sx))
    ;;    (map specification->package
    ;;      (list
    ;;        "nss-certs"
    ;;        "neovim"
    ;;        "htop"
    ;;        "tmux"
    ;;        ;;"nvidia-driver"
    ;;        ;;"nvidia-module"
    ;;        "stumpwm"
    ;;        "openssh"))
    ;;    %base-packages))

    (services
      (cons*

       ;; This can be removed when nvidia is updated to 535
       ;; https://gitlab.com/nonguix/nonguix/-/merge_requests/328
       (simple-service 'create-nvidiactl shepherd-root-service-type
        (list
         (shepherd-service
          (documentation "Create /dev/nvidiactl.")
          (provision '(nvidiactl))
          (requirement '(nvidia))
          (one-shot? #t)
          (start #~(make-forkexec-constructor
                    (list #$(file-append coreutils "/bin/mknod")
                          "-m" "666" "/dev/nvidiactl" "c" "195" "255")))
          (stop #~(make-forkexec-constructor
                   (list #$(file-append coreutils "/bin/rm")
                         "-f" "/dev/nvidiactl"))))))

       (service nvidia-service-type)

       (service docker-service-type)

       (modify-services %lr/desktop-services
         (xorg-server-service-type config => (xorg-configuration
          (inherit config)
          (modules (cons* nvidia-driver %default-xorg-modules))
          (server (transform xorg-server))
          (drivers '("nvidia")))))))

    (file-systems
     (cons*
      (file-system
        (mount-point "/")
        (device (file-system-label "semcon-guix"))
        (type "ext4"))
      (file-system
        (mount-point "/boot/efi")
        (device (file-system-label "semcon-efi"))
        (type "vfat")) %base-file-systems))))

%semcon-operating-system
