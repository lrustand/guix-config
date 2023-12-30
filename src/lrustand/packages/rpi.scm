(define-module (lrustand packages rpi)
 #:use-module (gnu)
 #:use-module (gnu system)
 #:use-module (gnu packages)
 #:use-module (gnu packages base)
 #:use-module (gnu packages compression)
 #:use-module (gnu packages linux)
 #:use-module (gnu packages tls)
 #:use-module (guix gexp)
 #:use-module (guix packages)
 #:use-module (guix utils)
 #:use-module (guix download)
 #:use-module (guix git-download)
 #:use-module (guix build-system copy)
 #:use-module (guix build-system gnu)
 #:use-module (guix build-system linux-module)
 #:use-module (guix build-system trivial)
 #:use-module (guix platform)
 #:use-module (ice-9 match)
  #:use-module ((guix licenses) #:prefix license:))

(define (config->string options)
  (string-join (map (match-lambda
                     ((option . 'm)
                      (string-append option "=m"))
                     ((option . #t)
                      (string-append option "=y"))
                     ((option . #f)
                      (string-append option "=n")))
                    options)
               "\n"))

(define %default-extra-linux-options
  `(;; Some very mild hardening.
    ("CONFIG_SECURITY_DMESG_RESTRICT" . #t)
    ;; All kernels should have NAMESPACES options enabled
    ("CONFIG_NAMESPACES" . #t)
    ("CONFIG_UTS_NS" . #t)
    ("CONFIG_IPC_NS" . #t)
    ("CONFIG_USER_NS" . #t)
    ("CONFIG_PID_NS" . #t)
    ("CONFIG_NET_NS" . #t)
    ;; Various options needed for elogind service:
    ;; https://issues.guix.gnu.org/43078
    ("CONFIG_CGROUP_FREEZER" . #t)
    ("CONFIG_BLK_CGROUP" . #t)
    ("CONFIG_CGROUP_WRITEBACK" . #t)
    ("CONFIG_CGROUP_SCHED" . #t)
    ("CONFIG_CGROUP_PIDS" . #t)
    ("CONFIG_CGROUP_FREEZER" . #t)
    ("CONFIG_CGROUP_DEVICE" . #t)
    ("CONFIG_CGROUP_CPUACCT" . #t)
    ("CONFIG_CGROUP_PERF" . #t)
    ("CONFIG_SOCK_CGROUP_DATA" . #t)
    ("CONFIG_BLK_CGROUP_IOCOST" . #t)
    ("CONFIG_CGROUP_NET_PRIO" . #t)
    ("CONFIG_CGROUP_NET_CLASSID" . #t)
    ("CONFIG_MEMCG" . #t)
    ("CONFIG_MEMCG_SWAP" . #t)
    ("CONFIG_MEMCG_KMEM" . #t)
    ("CONFIG_CPUSETS" . #t)
    ("CONFIG_PROC_PID_CPUSET" . #t)
    ;; Allow disk encryption by default
    ("CONFIG_DM_CRYPT" . m)
    ;; Modules required for initrd:
    ("CONFIG_NET_9P" . m)
    ("CONFIG_NET_9P_VIRTIO" . m)
    ("CONFIG_VIRTIO_BLK" . m)
    ("CONFIG_VIRTIO_NET" . m)
    ("CONFIG_VIRTIO_PCI" . m)
    ("CONFIG_VIRTIO_BALLOON" . m)
    ("CONFIG_VIRTIO_MMIO" . m)
    ("CONFIG_FUSE_FS" . m)
    ("CONFIG_CIFS" . m)
    ("CONFIG_9P_FS" . m)))

(define-public linux-raspberry-6.1
  (package
   (inherit linux-libre-6.1)
   (name "linux-raspberry")
   (version "6.1.0")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/raspberrypi/linux")
                  (commit "1.20230405")))
            (file-name (string-append "linux-" version))
            (sha256
             (base32
              "04mpklc550yy7157f7i0kynpy8y2sjphf54hhn3dw13mfrq1xg10"))))
   (native-inputs (modify-inputs (package-native-inputs linux-libre-6.1)
                                 (append openssl)))
   (arguments
    (substitute-keyword-arguments
      (package-arguments linux-libre-6.1)
      ((#:phases phases)
       #~(modify-phases #$phases

          (replace 'configure
           (lambda* (#:key inputs target #:allow-other-keys)
             ;; Avoid introducing timestamps
             (setenv "KCONFIG_NOTIMESTAMP" "1")
             (setenv "KBUILD_BUILD_TIMESTAMP" (getenv "SOURCE_DATE_EPOCH"))

             ;; Other variables useful for reproducibility.
             (setenv "KBUILD_BUILD_USER" "guix")
             (setenv "KBUILD_BUILD_HOST" "guix")

             ;; Set ARCH and CROSS_COMPILE.
             (let ((arch #$(platform-linux-architecture
                            (lookup-platform-by-target-or-system
                             (or (%current-target-system)
                                 (%current-system))))))
               (setenv "ARCH" arch)
               (format #t "`ARCH' set to `~a'~%" (getenv "ARCH"))

               (when target
                 (setenv "CROSS_COMPILE" (string-append target "-"))
                 (format #t "`CROSS_COMPILE' set to `~a'~%"
                         (getenv "CROSS_COMPILE"))))
             (setenv "KERNEL" "kernel8")
             (invoke "make" "bcm2711_defconfig")
             (let ((port (open-file ".config" "a"))
                   (extra-configuration #$(config->string %default-extra-linux-options)))
               (display extra-configuration port)
               (close-port port))))))))))

(define-public brcm80211-firmware
  (package
    (name "brcm80211-firmware")
    (version "20210818-1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://ftp.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-brcm80211_"
                    version "_all.deb"))
              (sha256 (base32 "04wg9fqay6rpg80b7s4h4g2kwq8msbh81lb3nd0jj45nnxrdxy7p"))))
    (build-system copy-build-system)
    (native-inputs (list tar bzip2))
    (arguments
      '(#:phases
        (modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((source (assoc-ref inputs "source")))
                (invoke "ar" "x" source)
                (invoke "ls")
                (invoke "tar" "-xvf" "data.tar.xz"))))
          (add-after 'install 'make-symlinks
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                (symlink (string-append out "/lib/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.txt")
                         (string-append out "/lib/firmware/brcm/brcmfmac43455-sdio.txt"))
                (symlink (string-append out "/lib/firmware/brcm/brcmfmac43455-sdio.bin")
                         (string-append out "/lib/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-compute-module.bin"))))))
        #:install-plan
        '(("lib/firmware/" "lib/firmware"))))
    (home-page "https://packages.debian.org/sid/firmware-brcm80211")
    (synopsis "Binary firmware for Broadcom/Cypress 802.11 wireless cards")
    (description "This package contains the binary firmware for wireless
network cards supported by the brcmsmac or brcmfmac driver.")
    (license license:expat)))
