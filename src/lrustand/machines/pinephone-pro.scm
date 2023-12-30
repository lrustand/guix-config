(define-module (lrustand machines pinephone-pro)
  #:use-module (gnu)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (guix)
  #:use-module (lrustand systems pinephone-pro))

(define-public %pinephone-pro-machine
  (machine
   (operating-system %pinephone-pro-operating-system)
   (environment managed-host-environment-type)
   (configuration (machine-ssh-configuration
                   (host-name "192.168.10.153")
                   (system "aarch64-linux")
                   (user "guix-deploy")
                   (identity "./id_rsa")
                   (port 22)))))
