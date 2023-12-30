(define-module (lrustand deployments pinephone-pro)
  #:use-module (lrustand machines pinephone-pro))

(define-public %pinephone-pro-deployment
  (list %pinephone-pro-machine))

%pinephone-pro-deployment
