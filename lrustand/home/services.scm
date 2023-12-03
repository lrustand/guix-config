(define-module (lrustand home services)
  #:export (use-home-service-modules))

(define service-module-hint
  (@@ (gnu) service-module-hint))

(define-syntax-rule (try-use-modules hint modules ...)
  ((@@ (gnu) try-use-modules) hint modules ...))

(define-syntax-rule (use-home-service-modules module ...)
  (try-use-modules service-module-hint
                   (gnu home services module) ...))
