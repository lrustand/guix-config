(define-module (lrustand systems bouncer))
(use-modules
  (gnu)
  (gnu packages firmware)
  (gnu services xorg))

(use-service-modules
 networking
 ssh
 admin
 vpn)

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Oslo")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "yoga")

  (kernel-arguments (list "console=ttyS0,115200"))

  (users
    (cons*
      (user-account
        (name "lars")
        (comment "")
        (group "users")
        (home-directory "/home/lars")
        (supplementary-groups '("wheel")))
      %base-user-accounts))

  (packages
    (append
      (map specification->package
        (list
          "nss-certs"
          "znc"
          "tmux"))
      %base-packages))

  (services
    (cons*
     (service dhcp-client-service-type)
     (service ntp-service-type)
     %base-services))

   (bootloader
     (bootloader-configuration
       (bootloader grub-efi-bootloader)
       (targets '("/boot/efi"))
       (keyboard-layout keyboard-layout)))

   (file-systems
    (cons*
     (file-system
       (mount-point "/")
       (device "/dev/vda")
       (type "ext4"))
     (file-system
       (mount-point "/boot/efi")
       (device "/dev/vda")
       (type "vfat")) %base-file-systems)))
