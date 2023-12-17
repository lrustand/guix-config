(define-module (lrustand packages davmail)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages java)
  #:use-module ((guix licenses) #:prefix license:))


(define-public davmail
  (let ((revision "3464"))
    (package
      (name "davmail")
      (version "6.2.0")
      (source
       (origin
         (method url-fetch)
         (uri (string-append
               "https://downloads.sourceforge.net/project/davmail/davmail/"
               version "/davmail-" version "-" revision ".zip"))
         (sha256
          (base32
           "075yip53z29jnf4bi1iw6j60cdicz6hd017nl56991f1vz943aqm"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       '((".." "share/davmail"))))
    (native-inputs
     (list unzip))
    (propagated-inputs
     (list openjdk))
    (home-page "https://davmail.sourceforge.net/")
    (synopsis "DavMail POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange and Office 365 Gateway")
    (description "Ever wanted to get rid of Outlook? DavMail is a
POP/IMAP/SMTP/Caldav/Carddav/LDAP exchange gateway allowing users to use any
mail/calendar client (e.g. Thunderbird with Lightning or Apple iCal) with an
Exchange server, even from the internet or behind a firewall through Outlook
Web Access.")
    (license license:gpl2))))

davmail
