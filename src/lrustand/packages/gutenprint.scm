(define-module (lrustand packages gutenprint)
  #:use-module (gnu packages)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages time)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

;; This package is taken from an unmerged patch https://issues.guix.gnu.org/45725
(define-public gutenprint
  (package
    (name "gutenprint")
    (version "5.3.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/gimp-print/" name "-"
                           (version-major+minor version) "/" version "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32 "0fq2y9sx37d342fihp1ys9kf4sr2j5nc1kl33j9sirmqs80sfi6v"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:test-target "check-parallel"
       #:configure-flags (list "--enable-cups-level3-ppds"
                               "--enable-globalized-cups-ppds"
                               "--enable-cups-ppds"
                               "--enable-cups-1_2-enhancements")
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'fix-paths
           (lambda* (#:key outputs native-inputs #:allow-other-keys)
             (substitute* "Makefile.in"
               (("/usr/bin/time") "time"))
             (let ((out (assoc-ref outputs "out")))
               (substitute* (find-files "." "^(Makefile|Makefile\\.in|configure)$")
                 (("^(\\s*)cups_conf_serverbin(\\s*)=(.+)$")
                  (string-append "cups_conf_serverbin=" out "/lib/cups\n"))
                 (("^(\\s*)cups_conf_serverroot(\\s*)=(.+)$")
                  (string-append "cups_conf_serverroot=" out "/etc/cups\n"))
                 (("^(\\s*)cups_conf_datadir(\\s*)=(.+)$")
                  (string-append "cups_conf_datadir=" out "/share/cups\n")))
               (substitute* "src/cups/Makefile.in"
                 (("^(\\s*)bindir(\\s*)=(.+)$")
                  (string-append "bindir = " out "/bin\n"))
                 (("^(\\s*)sbindir(\\s*)=(.+)$")
                  (string-append "sbindir = " out "/sbin\n")))
               #t))))))
    (native-inputs
     (list perl
           time))
    (inputs
     (list cups-minimal))
    (synopsis "Printer drivers for CUPS")
    (description "This package provides printer drivers for CUPS.
This project also maintains an enhanced Print plug-in for GIMP 2.x from
the same code base.  This driver supports widespread inkjet printers by major vendors,
  including Canon, Epson, Fujitsu, SONY, @dots{}")
    (home-page "http://gimp-print.sourceforge.net/")
    (license license:gpl2+)))
