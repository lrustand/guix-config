(define-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages shells)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system accounts)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system locale)
  #:use-module (gnu services admin)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

(define-public %base-operating-system
  (operating-system
    (locale "en_US.utf8")
    (timezone "Europe/Oslo")
    (keyboard-layout %lr/keyboard-layout)
    (host-name "base")

    (kernel linux)
    (initrd microcode-initrd)
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
            "git"
            "stumpwm"
            "xterm" ;; For default stump configuration
            "xinitrc-xsession"
            "libinput"
            "xf86-input-libinput"
            "openssh"))
        %base-packages))

    (services
      %lr/wifi-networks-services
      %lr/desktop-services)

     (bootloader
       (bootloader-configuration
         (bootloader grub-efi-bootloader)
         (targets '("/boot/efi"))
         (keyboard-layout keyboard-layout)))

     (file-systems
      (cons*
       %base-file-systems))))

%base-operating-system
