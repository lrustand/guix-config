(define-module (lrustand machines vm-host)
  #:use-module (gnu)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (guix)
  #:use-module (lrustand systems vm-host))

(define-public %vm-host-machine
  (machine
   (operating-system %vm-host-operating-system)
   (environment managed-host-environment-type)
   (configuration (machine-ssh-configuration
                   (host-name "10.0.4.103")
                   (system "x86_64-linux")
                   (user "guix-deploy")
                   (identity "./id_rsa")
                   (port 22)))))
