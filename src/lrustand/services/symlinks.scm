(define-module (lrustand services symlinks)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services))

(define (symlink-files lst)
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils))
        (for-each
         (lambda (it)
          (let ((from-file (car it))
                (target-file (string-append #$(getenv "HOME") "/"
                                            (cadr it))))
            (mkdir-p (dirname target-file))
            (if (and (file-exists? target-file)
                     (equal? 'symlink (stat:type (lstat target-file)))
                     (equal? (canonicalize-path target-file)
                             (canonicalize-path from-file)))
                (format #t "~a is already a symlink to ~a!\n"
                        target-file from-file)
                (symlink from-file
                         target-file))))
         '#$lst))))

(define-public home-symlinks-service-type
  (service-type
   (name 'symlink)
   (extensions
    (list (service-extension home-activation-service-type
                             symlink-files)))
   (default-value '(()))
   (description
    "")))
