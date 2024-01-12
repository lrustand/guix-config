(define-module (lrustand deployments semcon)
  #:use-module (lrustand machines semcon))

(define-public %semcon-deployment
  (list %semcon-machine))

%semcon-deployment
