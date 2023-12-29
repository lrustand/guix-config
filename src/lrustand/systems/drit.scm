(define-module (lrustand systems drit)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages shells)
  #:use-module (gnu services xorg)

  #:use-module (gnu services networking)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services ssh)
  #:use-module (gnu services admin)
  #:use-module (gnu services desktop))

(define-public %drit-operating-system
  (operating-system
    (locale "en_US.utf8")
    (timezone "Europe/Oslo")
    (keyboard-layout (keyboard-layout "us,no" #:options '("grp:switch")))
    (host-name "drit")

    (kernel linux)
    (initrd microcode-initrd)
    ;;(initrd-modules (append '("vmd") %base-initrd-modules))
    (firmware (list
               linux-firmware
               sof-firmware))

    ;;(kernel-arguments (list "console=ttyS0,115200"))

    (users
      (cons*
        (user-account
          (name "lars")
          (comment "")
          (group "users")
          (shell (file-append zsh "/bin/zsh"))
          (home-directory "/home/lars")
          (supplementary-groups '("wheel" "input")))
        %base-user-accounts))

    (packages
      (append
        (list sof-firmware)
        (map specification->package
          (list
            "nss-certs"
            "neovim"
            "htop"
            "tmux"
            "stumpwm"
            "xinitrc-xsession"
            "libinput"
            "xf86-input-libinput"
            "openssh"))
        %base-packages))

    (services
      (cons*
       (service qemu-binfmt-service-type
                (qemu-binfmt-configuration
                 (platforms (lookup-qemu-platforms "arm" "aarch64"))))
       (set-xorg-configuration
         (xorg-configuration
           (keyboard-layout keyboard-layout)))
       (modify-services %desktop-services
         (guix-service-type config => (guix-configuration
           (inherit config)
           (substitute-urls
            (append (list "https://substitutes.nonguix.org")
              %default-substitute-urls))
           (authorized-keys
            (append (list (plain-file "non-guix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
              %default-authorized-guix-keys)))))))

     (bootloader
       (bootloader-configuration
         (bootloader grub-bootloader)
         (targets '("/dev/sda"))
         (keyboard-layout keyboard-layout)))

     (file-systems
      (cons*
       (file-system
         (mount-point "/")
         (device (file-system-label "drit-root"))
         (type "ext4"))
       %base-file-systems))))

%drit-operating-system
