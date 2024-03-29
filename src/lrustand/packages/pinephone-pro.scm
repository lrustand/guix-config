(define-module (lrustand packages pinephone-pro)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (nonguix licenses)
  #:use-module (gnu packages linux)
  #:use-module (ice-9 match))

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
          "pinephone_pro_defconfig"
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
                 (substitute* "arch/arm64/configs/pinephone_pro_defconfig"
                   (("^#CONFIG_EXTRA_FIRMWARE=.*$")
                    (string-append "CONFIG_EXTRA_FIRMWARE=\""
                                   "regulatory.db "
                                   "regulatory.db.p7s "
                                   "brcm/brcmfmac43455-sdio.bin "
                                   "brcm/brcmfmac43455-sdio.pine64,pinephone-pro.txt "
                                   "brcm/brcmfmac43455-sdio.clm_blob "
                                   "brcm/BCM4345C0.hcd "
                                   "rockchip/dptx.bin\"\n"))
                   (("^#CONFIG_EXTRA_FIRMWARE_DIR=.*$")
                    "CONFIG_EXTRA_FIRMWARE_DIR=\"ppp/lib/firmware\"\n")
                   (("^CONFIG_DMA_PERNUMA_CMA.*$") "")) ;; For 6.7
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

(define-public pinephone-pro-kernel-6.7
  (linux-pinephone-pro "orange-pi-6.7-20231203-1729"
                       "0v3gpj6qd9ili9xgsmx2k22hr6p62wxxnyg1fvnsv1f1q1qszhf9"))

(define-public pinephone-pro-kernel-6.3
  (linux-pinephone-pro "orange-pi-6.3-20230612-0227"
                       "0gwv048iak0jis4x0x970sbfpzmdssnnkfg1qclf8ifvy9ays911"))
