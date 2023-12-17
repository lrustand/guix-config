(define-module (lrustand deployments pinephone-pro)
  #:use-module (lrustand machines pinephone-pro)
  #:export (%pinephone-pro-deployment))

(define %pinephone-pro-deployment
  (list %pinephone-pro-machine))

%pinephone-pro-deployment
