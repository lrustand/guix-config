(define-module (lrustand services offlineimap)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu packages mail)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 curried-definitions)
  #:use-module (gnu home services)
  ;; For the 'home-shepherd-service-type' mapping.
  #:use-module (gnu home services shepherd)
  #:export (offlineimap-configuration
            offlineimap-configuration?

            offlineimap-configuration-log-file
            offlineimap-configuration-pid-file

            offlineimap-shepherd-service
            offlineimap-service-type
            home-offlineimap-service-type))

(define-configuration/no-serialization offlineimap-configuration
  (config-file
   (string "/home/lars/.config/offlineimap/config")
   "Configuration file to use.")
  (log-file
   (string "/home/lars/offlineimap.log")
   "File where ‘offlineimap’ writes its log to.")
  (user
   (string "lars")
   "")
  (extra-options
   (list-of-strings '())
   "This option provides an “escape hatch” for the user to provide
arbitrary command-line arguments to ‘offlineimap’ as a list of strings.")
  (home-service?
   (boolean for-home?)
   ""))

(define offlineimap-shepherd-service
  (match-record-lambda <offlineimap-configuration>
    (config-file log-file user extra-options home-service?)
    (list (shepherd-service
           (provision '(offlineimap))
           (documentation "")
           (requirement (if home-service? '() '(networking user-processes)))
           (start #~(make-forkexec-constructor
                      (list (string-append #$offlineimap
                                           "/bin/offlineimap")
                             #$@extra-options
                             "-c" #$config-file
                             "-l" #$log-file)
                     #:user #$user
                     #:environment-variables
                     (list (string-append "HOME=" (passwd:dir (getpw #$user))))
                     #:log-file #$log-file))
           (stop #~(make-kill-destructor))
           (one-shot? #f)
           (respawn? #t)))))

(define offlineimap-service-type
  (service-type
   (name 'offlineimap)
   (extensions
    (list (service-extension shepherd-root-service-type
                             offlineimap-shepherd-service)))
   (default-value (offlineimap-configuration))
   (description
    "Synchronize remote IMAP mail with local Maildir.")))

(define home-offlineimap-service-type
  (service-type
   (inherit (system->home-service-type offlineimap-service-type))
   (default-value (for-home (offlineimap-configuration)))))
