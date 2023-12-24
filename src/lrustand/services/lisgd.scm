(define-module (lrustand services lisgd)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (lrustand packages lisgd)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 curried-definitions)
  #:use-module (gnu home services)
  ;; For the 'home-shepherd-service-type' mapping.
  #:use-module (gnu home services shepherd)
  #:export (lisgd-configuration
            lisgd-configuration?

            lisgd-configuration-log-file

            lisgd-shepherd-service
            lisgd-service-type
            home-lisgd-service-type))

(define-configuration/no-serialization lisgd-configuration
  (log-file
   (string "/home/lars/lisgd.log")
   "File where ‘lisgd’ writes its log to.")
  (extra-options
   (list-of-strings '())
   "This option provides an “escape hatch” for the user to provide
arbitrary command-line arguments to ‘lisgd’ as a list of strings.")
  (home-service?
   (boolean for-home?)
   ""))

(define lisgd-shepherd-service
  (match-record-lambda <lisgd-configuration>
    (log-file extra-options home-service?)
    (list (shepherd-service
           (provision '(lisgd))
           (documentation "")
           (requirement (if home-service? '() '(networking user-processes)))
           (start #~(make-forkexec-constructor
                      (list (string-append #$lisgd
                                           "/bin/lisgd")
                             #$@extra-options)
                     #:log-file #$log-file))
           (stop #~(make-kill-destructor))
           (one-shot? #f)
           (respawn? #t)))))

(define lisgd-service-type
  (service-type
   (name 'lisgd)
   (extensions
    (list (service-extension shepherd-root-service-type
                             lisgd-shepherd-service)))
   (default-value (lisgd-configuration))
   (description
    "")))

(define home-lisgd-service-type
  (service-type
   (inherit (system->home-service-type lisgd-service-type))
   (default-value (for-home (lisgd-configuration)))))
