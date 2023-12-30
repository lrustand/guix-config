(define-module (lrustand deployments semcon)
  #:use-module (lrustand machines semcon)
  #:export (%semcon-deployment))

(define %semcon-deployment
  (list %semcon-machine))

%semcon-deployment
