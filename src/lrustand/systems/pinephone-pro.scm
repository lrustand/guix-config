(define-module (lrustand systems pinephone-pro)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages linux)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages pulseaudio)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (nonguix licenses)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system shadow)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services ssh)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sound)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages fonts))

(define-public pinephone-pro-firmware
  (let ((commit "5c4c2b89f30a42f5ffabb5b5bcbc799d8ac9f66f")
        (revision "1"))
    (package
      (name "pinephone-pro-firmware")
      (version (git-version "0.0.0" revision commit))
      (home-page "https://megous.com/git/linux-firmware")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0210dpxhb257zwncv5r1qiq7rlyiy1c14mx9vscnsv6rggf1id9w"))))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan
         (list
          (list "anx7688-fw.bin" "lib/firmware/")
          (list "hm5065-af.bin" "lib/firmware/")
          (list "hm5065-init.bin" "lib/firmware/")
          (list "ov5640_af.bin" "lib/firmware/")
          (list "regulatory.db" "lib/firmware/")
          (list "regulatory.db.p7s" "lib/firmware/")
          (list "rockchip" "lib/firmware/")
          (list "rt2870.bin" "lib/firmware/")
          (list "rtl_bt" "lib/firmware/")
          (list "rtlwifi" "lib/firmware/")
          (list "rtw88" "lib/firmware/")
          (list "rtw89" "lib/firmware/")
          (list "brcm" "lib/firmware/"))))
      (synopsis "Nonfree Linux firmware blobs for PinePhone Pro")
      (description "Nonfree Linux firmware blobs for PinePhone Pro.")
      (license
       (nonfree
        (string-append "https://git.kernel.org/pub/scm/linux/kernel/git/"
                       "firmware/linux-firmware.git/plain/WHENCE"))))))

(define (linux-pinephone-urls version)
  "Return a list of URLS for Linux VERSION."
  (list
   (string-append
    "https://codeberg.org/megi/linux/archive/" version ".tar.gz")))

(define* (linux-pinephone-pro
          version
          hash
          #:key
          (name "linux-pinephone-pro")
          (linux linux-libre-arm64-generic))
  (let ((linux-package
         (customize-linux
          #:name name
          #:linux linux
          #:defconfig
          ;; It could be "pinephone_pro_defconfig", but with a small patch
          ;; TODO: Rewrite it to the simple patch for the source code
          ;;(local-file "./pinephone_pro_defconfig")
          "orangepi_defconfig"
          ;;#:configs '("CONFIG_EXTRA_FIRMWARE=\"regulatory.db regulatory.db.p7s brcm/brcmfmac43455-sdio.bin brcm/brcmfmac43455-sdio.pine64,pinephone-pro.txt brcm/brcmfmac43455-sdio.clm_blob brcm/BCM4345C0.hcd rockchip/dptx.bin\""
          ;;            "CONFIG_EXTRA_FIRMWARE_DIR=\"ppp/lib/firmware\"")
          #:extra-version "arm64-pinephone-pro"
          #:source (origin (method url-fetch)
                           (uri (linux-pinephone-urls version))
                           (sha256 (base32 hash))))))
    (package
     (inherit linux-package)
     (version version)
     (inputs (list pinephone-pro-firmware))
     (arguments
      (substitute-keyword-arguments (package-arguments linux-package)
        ((#:phases phases '%standard-phases)
         #~(modify-phases
            #$phases
            (add-after 'unpack 'patch-defconfig
               (lambda _
                 (substitute* "arch/arm64/configs/orangepi_defconfig"
                   (("^#CONFIG_EXTRA_FIRMWARE=.*$") "CONFIG_EXTRA_FIRMWARE=\"regulatory.db regulatory.db.p7s brcm/brcmfmac43455-sdio.bin brcm/brcmfmac43455-sdio.pine64,pinephone-pro.txt brcm/brcmfmac43455-sdio.clm_blob brcm/BCM4345C0.hcd rockchip/dptx.bin\"\n")
                   (("^#CONFIG_EXTRA_FIRMWARE_DIR=.*$") "CONFIG_EXTRA_FIRMWARE_DIR=\"ppp/lib/firmware\"\n"))
                 ))
            (add-after 'configure 'set-firmware-path
               (lambda _
                 (copy-recursively
                  (assoc-ref %build-inputs "pinephone-pro-firmware") "ppp")
                 (format #t "====>")
                 (system "cat .config")
                 (format #t "====>")))))))
     (home-page "https://www.kernel.org/")
     (synopsis "Linux kernel with nonfree binary blobs included")
     (description
      "The unmodified Linux kernel, including nonfree blobs, for running Guix
System on hardware which requires nonfree software to function."))))

(define-public pinephone-pro-kernel
  (linux-pinephone-pro "orange-pi-6.5-20230914-1327"
                       "1ba0ngh253irja0nkbrnk3vjj7a4y16mrvwbls4r0lr8pwb1r3ln"))

(define %my-services
  (append
   %desktop-services
   (list
    ;;(service wpa-supplicant-service-type)
    ;;(service network-manager-service-type)
    ;;(service slim-service-type)
    ;;(service modem-manager-service-type)
    ;;(service alsa-service-type)
    (service openssh-service-type
             (openssh-configuration
              (x11-forwarding? #f)
              (authorized-keys
               `(("lars" ,(local-file "ssh.key"))))
              (print-last-log? #t))))))

(define pinephone-pro-operating-system
  (operating-system
    (kernel pinephone-pro-kernel)
    (kernel-arguments
     (append
      (list
       "console=ttyS2,115200"
       "earlycon=uart8250,mmio32,0xff1a0000"
       "earlyprintk")
      (drop-right %default-kernel-arguments 1)))

    (initrd-modules '())

    (firmware (append
               (list pinephone-pro-firmware)
               %base-firmware))
    (host-name "pinephonepro")
    (timezone "Europe/Oslo")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us" "qwerty"))

    (bootloader
     (bootloader-configuration
      (bootloader u-boot-rockpro64-rk3399-bootloader)
      (targets '("/dev/mmcblk2"))))

    (file-systems
     (cons
      (file-system
        (device "/dev/mmcblk2p1")
        (mount-point "/")
        (type "ext4"))
      %base-file-systems))

    (users (cons (user-account
                  (name "lars")
		  ;; Uncomment and edit this when building image
                  ;; (password (crypt "1234" "$6$abc"))
                  (group "users")
                  (supplementary-groups '("wheel" "audio" "video"))
                  (shell (file-append zsh "/bin/zsh"))
                  (home-directory "/home/lars"))
                 %base-user-accounts))

    (packages
     (append (list
              parted
              stumpwm
              pulseaudio
              alsa-utils
              sof-firmware ;; TODO: Might not be needed, try without
              ;;alsa-firmware
              nss-certs)
      %base-packages))

    (services %my-services)))

pinephone-pro-operating-system
