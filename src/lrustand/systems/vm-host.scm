(define-module (lrustand systems vm-host)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu packages firmware)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services xorg)
  #:use-module (gnu services virtualization)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix build-system linux-module))

(define-public vendor-reset
  (let ((commit "4b466e92a2d9f76ce1082cde982c7be0be91e248"))
    (package
      (name "vendor-reset")
      (version (git-version "0.8" "2" commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/gnif/vendor-reset")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1gaf4j20grng689c9fylcqri3j9ycnhr2bsva2z6qcdqvzl6yxbi"))))
      (build-system linux-module-build-system)
      (arguments
       (list #:tests? #f))              ; no test suite
      (home-page "https://github.com/gnif/vendor-reset")
      (synopsis "")
      (description "")
      (license gpl2))))

(define %vm-host-operating-system
  (operating-system
    (locale "en_US.utf8")
    (timezone "Europe/Oslo")
    (keyboard-layout (keyboard-layout "us"))
    (host-name "ryzen")

    (kernel linux)
    (initrd microcode-initrd)
    (firmware (list linux-firmware))

    (kernel-arguments
      (append
        (list
          "video=efifb:off"
          "iommu=pt"
          "amd_iommu=on"
          "amd_iommu=pt"
          "kvm_amd.npt=1"
          "kvm_amd.avic=1"
          "kvm_amd.nested=0"
          "kvm_amd.sev=0"
          "kvm.ignore_msrs=1"
          "kvm.report_ignored_msrs=0"
          "pcie_acs_override=downstream,multifunction"
          "rd.driver.pre=vfio-pci"
          "nomodeset")))
    (initrd-modules (cons* "vfio" "vfio_pci" "vfio_iommu_type1" %base-initrd-modules))

    (kernel-loadable-modules (list vendor-reset))

    ;; The list of user accounts ('root' is implicit).
    (users
      (cons*
        (user-account
          (name "lars")
          (comment "")
          (group "users")
          (home-directory "/home/lars")
          (supplementary-groups '("wheel" "netdev" "audio" "video" "libvirt" "kvm")))
        %base-user-accounts))

    ;; Packages installed system-wide.  Users can also install packages
    ;; under their own account: use 'guix search KEYWORD' to search
    ;; for packages and 'guix install PACKAGE' to install a package.
    (packages
      (append
        (map specification->package
          (list
            "nss-certs"
            "neovim"
            "htop"
            "qtile"
            "tmux"
            "mdadm"
            "xf86-video-amdgpu"
            "openssh"
            "net-tools"
            "tpm2-tss"
            "tpm2-tools"
            "ovmf"
            "virt-manager"
            "libvirt"))
        (list vendor-reset)
        %base-packages))

    ;; Below is the list of system services.  To search for available
    ;; services, run 'guix system search KEYWORD' in a terminal.
    (services
      (cons*
        (service openssh-service-type
          (openssh-configuration
            (x11-forwarding? #t)))
        (service libvirt-service-type
          (libvirt-configuration
            (unix-sock-group "kvm")))
        (service virtlog-service-type)
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
        (bootloader grub-efi-removable-bootloader)
        (targets (list "/boot/efi"))
        (keyboard-layout keyboard-layout)))

    (mapped-devices
      (list
        (mapped-device
          (source (list "/dev/nvme0n1p2" "/dev/nvme1n1p3"))
          ;; TODO: post bug
          ;; (source (list (uuid "a07c54da-eb61-4135-86b8-8791e863e46a") (uuid "c40026af-ace9-47fc-9d3f-4b8d6a2219cb")))
          (target "/dev/md0")
          (type raid-device-mapping))))

    (swap-devices
      (list
        (swap-space (target (uuid "7490c696-a596-4d9e-9ff9-ba7444a001db")))
        (swap-space (target (uuid "9b6e0c75-1f85-4ba7-84fb-8e2eceae5c1f")))))

    ;; The list of file systems that get "mounted".  The unique
    ;; file system identifiers there ("UUIDs") can be obtained
    ;; by running 'blkid' in a terminal.
    (file-systems
      (cons*
        (file-system
          (mount-point "/")
          (device (uuid
                   "4b202f82-2d40-4cf7-9737-784c0123151d"
                   'ext4))
          (type "ext4"))
        (file-system
          (mount-point "/asdf")
          (device "/dev/md0")
          (type "ext4"))
        (file-system
          (mount-point "/boot/efi")
          (device (uuid "CE8E-65A2"
                        'fat32))
          (type "vfat")) %base-file-systems))))

%vm-host-operating-system
