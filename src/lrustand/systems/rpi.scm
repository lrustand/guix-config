(define-module (lrustand systems rpi)
  #:use-module (lrustand packages rpi)
  #:use-module (gnu)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)  
  #:use-module (gnu packages linux)
  #:use-module (gnu packages image)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu packages ssh)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix platforms arm)
  #:use-module (srfi srfi-26)
  #:use-module (nongnu packages linux)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))


(define (install-rpi-efi-loader grub-efi esp)
  "Install in ESP directory the given GRUB-EFI bootloader.  Configure it to
load the Grub bootloader located in the 'Guix_image' root partition."
  (let ((uboot-binary "/libexec/u-boot.bin"))
    (copy-file #$(file-append (u-boot-rpi-arm64) uboot-binary ) "/")))

(define u-boot-rpi-arm64
  (make-u-boot-package "rpi_arm64" "aarch64-linux-gnu"))

(define install-rpi-arm64-u-boot
  #~(lambda (bootloader root-index image)
      #t))

(define u-boot-rpi-arm64-bootloader
  (bootloader
   (inherit u-boot-bootloader)
   (package u-boot-rpi-arm64)
   (disk-image-installer install-rpi-arm64-u-boot)))

(define-public raspberry-pi-barebones-os
  (operating-system
   (host-name "rpi")
   (timezone "Europe/Oslo")
   (locale "en_US.utf8")
   (bootloader (bootloader-configuration
		(bootloader  u-boot-rpi-arm64-bootloader)
		(targets '("/dev/vda"))
    (device-tree-support? #f)))
   (kernel linux-raspberry-6.1)
   (kernel-arguments (cons* "cgroup_enable=memory"
                            %default-kernel-arguments))
   (initrd-modules '())
   (firmware (list raspberrypi-firmware brcm80211-firmware))

   (file-systems (append (list 
                          (file-system
                           (device (file-system-label "BOOT"))
                           (mount-point "/boot/firmware")
                           (type "vfat"))
                          (file-system
                           (device (file-system-label "RASPIROOT"))
                           (mount-point "/")
                           (type "ext4")))
                         %base-file-systems))

   (services %base-services)

   (packages %base-packages)

   (users (cons (user-account
                 (name "pi")
                 (comment "raspberrypi user")
                 (password (crypt "123" "123$456"))
                 (group "users")
                 (supplementary-groups '("wheel")))
                %base-user-accounts))
   ))

(define rpi-boot-partition
  (partition
   (size (* 128 (expt 2 20)))
   (label "BOOT")
   (file-system "fat32")
   (flags '())
   (initializer (gexp (lambda* (root #:key
                                 grub-efi
                                 #:allow-other-keys)
                               (use-modules (guix build utils))
                               (mkdir-p root)
                               (copy-recursively #$(file-append u-boot-rpi-arm64 "/libexec/u-boot.bin" )
						 (string-append root "/u-boot.bin"))
                               (copy-recursively #$(file-append raspberrypi-firmware "/" ) root)
                               (copy-recursively #$(plain-file "config.txt"
"enable_uart=1
uart_2ndstage=1
arm_64bit=1
kernel=u-boot.bin")
						 (string-append root "/config.txt"))
                               (copy-recursively #$(plain-file "cmdline.txt"
"root=LABEL=RASPIROOT rw rootwait console=serial0,115200 console=tty1 console=ttyAMA0,115200 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=serial0,115200")
						 (string-append root "/cmdline.txt"))
			       )))))

(define rpi-root-partition
  (partition
   (size 'guess)
   (label "RASPIROOT")
   (file-system "ext4")
   (flags '(boot))
   (initializer (gexp initialize-root-partition))))

(define raspberry-pi-image
  (image-without-os
   (format 'disk-image)
   (partitions (list rpi-boot-partition rpi-root-partition))))

(define-public raspberry-pi-image-type
  (image-type
   (name 'raspberry-pi-raw)
   (constructor (cut image-with-os raspberry-pi-image <>))))

(define-public raspberry-pi-barebones-raw-image
  (image
   (inherit
    (os+platform->image raspberry-pi-barebones-os aarch64-linux
                        #:type raspberry-pi-image-type))
   (partition-table-type 'mbr)
   (name 'raspberry-pi-barebones-raw-image)))

;; Return the default image.
raspberry-pi-barebones-raw-image
