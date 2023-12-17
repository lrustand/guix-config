(define-module (lrustand services davmail)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (lrustand packages davmail)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 curried-definitions)
  #:use-module (gnu home services)
  ;; For the 'home-shepherd-service-type' mapping.
  #:use-module (gnu home services shepherd)
  #:export (davmail-configuration
            davmail-configuration?

            davmail-configuration-log-file
            davmail-configuration-pid-file

            davmail-shepherd-service
            davmail-service-type
            home-davmail-service-type))

(define-configuration/no-serialization davmail-configuration
  (config-file
   (string "/home/lars/.config/davmail/davmail.properties")
   "Configuration file to use.")
  (log-file
   (string "/home/lars/davmail.log")
   "File where ‘davmail’ writes its log to.")
  (extra-options
   (list-of-strings '())
   "This option provides an “escape hatch” for the user to provide
arbitrary command-line arguments to ‘davmail’ as a list of strings.")
  (home-service?
   (boolean for-home?)
   ""))

(define davmail-shepherd-service
  (match-record-lambda <davmail-configuration>
    (config-file log-file extra-options home-service?)
    (list (shepherd-service
           (provision '(davmail))
           (documentation "")
           (requirement (if home-service? '() '(user-processes)))
           (start #~(make-forkexec-constructor
                      (list (string-append #$davmail
                                           "/bin/davmail")
                             #$@extra-options
                             "-c" #$config-file)
                     #:log-file #$log-file))
           (stop #~(make-kill-destructor))
           (one-shot? #f)
           (respawn? #t)))))

(define davmail-service-type
  (service-type
   (name 'davmail)
   (extensions
    (list (service-extension shepherd-root-service-type
                             davmail-shepherd-service)))
   (default-value (davmail-configuration))
   (description
    "Gateway for Outlook mail to regular IMAP and SMTP")))

(define home-davmail-service-type
  (service-type
   (inherit (system->home-service-type davmail-service-type))
   (default-value (for-home (davmail-configuration)))))
