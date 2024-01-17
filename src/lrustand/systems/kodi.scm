(define-module (lrustand systems kodi)
  #:use-module (lrustand systems base)
  #:use-module (lrustand services base)
  #:use-module (gnu)
  #:use-module (gnu home)
  ;; TODO submit patch for documentation.
  ;; Docs refer to (gnu home services kodi)
  ;; which does not exist
  #:use-module (gnu home services media)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services networking))
  ;;#:use-module (gnu services home))

(define-public %kodi-home-environment
  (home-environment
   (packages '())
   (services
    (list
     (service home-shepherd-service-type)
     (service home-kodi-service-type)))))

(define-public %kodi-operating-system
  (operating-system (inherit %base-operating-system)
    (host-name "kodi")
    (services
     (cons*
      ;;(service guix-home-service-type
      ;;         `(,(cons"lars" %kodi-home-environment)))
      ;;(service dhcp-client-service-type)
      (modify-services %desktop-services
       (gdm-service-type config => (gdm-configuration
        (inherit config)
        (default-user "lars")
        (auto-suspend? #f)
        (auto-login? #t))))))

    (file-systems
     (cons*
      (file-system
        (mount-point "/")
        (device (file-system-label "kodi-guix"))
        (type "ext4"))
      (file-system
        (mount-point "/boot/efi")
        (device (file-system-label "kodi-boot"))
        (type "vfat"))
      %base-file-systems))))

%kodi-operating-system
