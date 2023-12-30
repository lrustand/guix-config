(define-module (lrustand machines semcon)
  #:use-module (gnu)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (guix)
  #:use-module (lrustand systems semcon))

(define-public %semcon-machine
  (machine
   (operating-system %semcon-operating-system)
   (environment managed-host-environment-type)
   (configuration (machine-ssh-configuration
                   (host-name "192.168.10.x")
                   (system "x86_64-linux")
                   (user "guix-deploy")
                   (identity "./id_rsa")
                   (port 22)))))
