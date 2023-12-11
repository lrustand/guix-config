(define-module (lrustand services repos)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:export (home-git-clone-service-type))

(define (clone lst)
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (for-each (lambda (it)
                      (let ((url (car it))
                            (target (string-append #$(getenv "HOME") "/"
                                                   (cadr it))))
                        (system* "git" "clone" url target)))
                    '#$lst))))

(define home-git-clone-service-type
  (service-type
   (name 'git-clone)
   (extensions
    (list (service-extension home-activation-service-type
                             clone)))
   (default-value '(()))
   (description
    "")))
