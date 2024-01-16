(define-module (lrustand systems vm-host)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (gnu packages firmware)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization))

(define-public %vm-host-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "ryzen")

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

    (kernel-loadable-modules (list (specification->package "vendor-reset-linux-module")))

    (groups
      (cons*
        (user-group (name "admin"))
        %base-groups))

    (users
      (cons*
        (user-account
          (name "guix-deploy")
          (comment "")
          (group "admin"))
        (user-account
          (name "lars")
          (comment "")
          (group "users")
          (home-directory "/home/lars")
          (supplementary-groups '("wheel" "netdev" "audio" "video" "libvirt" "kvm")))
        %base-user-accounts))

    (sudoers-file
     (plain-file "sudoers"
                 (string-append (plain-file-content %sudoers-specification)
                                (format #f "~a ALL = NOPASSWD: ALL~%"
                                        "guix-deploy"))))
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
            "vendor-reset-linux-module"
            "openssh"
            "net-tools"
            "tpm2-tss"
            "tpm2-tools"
            "ovmf"
            "virt-manager"
            "libvirt"))
        %base-packages))

    (services
      (cons*
        (service openssh-service-type
          (openssh-configuration
            (x11-forwarding? #t)
            (authorized-keys
             `(("lars" ,(local-file "../../../files/ssh/yoga.pub"))
               ("guix-deploy" ,(local-file "../../../files/ssh/yoga.pub"))))
            (print-last-log? #t)))
        (service libvirt-service-type
          (libvirt-configuration
            (unix-sock-group "kvm")))
        (service virtlog-service-type)
        %lr/desktop-services))

    (swap-devices
      (list
        (swap-space (target (uuid "7490c696-a596-4d9e-9ff9-ba7444a001db")))
        (swap-space (target (uuid "9b6e0c75-1f85-4ba7-84fb-8e2eceae5c1f")))))

    (file-systems
      (cons*
        (file-system
          (mount-point "/")
          (device (uuid
                   "4b202f82-2d40-4cf7-9737-784c0123151d"
                   'ext4))
          (type "ext4"))
        (file-system
          (mount-point "/boot/efi")
          (device (uuid "CE8E-65A2"
                        'fat32))
          (type "vfat"))
        %base-file-systems))))

%vm-host-operating-system
