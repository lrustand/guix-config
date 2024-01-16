(define-module (lrustand deployments vm-host)
  #:use-module (lrustand machines vm-host))

(define-public %vm-host-deployment
  (list %vm-host-machine))

%vm-host-deployment
