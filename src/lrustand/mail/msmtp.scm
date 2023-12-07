(define-module (lrustand mail msmtp)
  #:use-module (ice-9 optargs)
  #:export (msmtp-config))

;;(define* (msmtp-davmail-config-fragment account)
;;  "tls off
;;auth plain
;;host 127.0.0.1
;;port 1025")
;;
;;(define* (msmtp-gmail-config-fragment)
;;  "host smtp.gmail.com")
;;
;;(define* (msmtp-outlook-config-fragment)
;;  "auth xoauth2
;;host smtp.office365.com")
;;
(define* (msmtp-pure-smtp-config-fragment smtp-host smtp-port)
  (string-append
    (format #f "host ~a\n" smtp-host)
    (if smtp-port
        (format #f "port ~d\n" smtp-port)
        "")))

(define* (msmtp-account-config-fragment account)
  (let ((account-name (assoc-ref account "account-name"))
        (address (assoc-ref account "address"))
        (user (assoc-ref account "user"))
        (provider (or (assoc-ref account "provider") #:plain))
        (smtp-port (assoc-ref account "smtp-port"))
        (smtp-host (assoc-ref account "smtp-host")))
    (string-append
     (format #f "account ~a
from ~a
user ~a
passwordeval \"pass show $(find ~~/.password-store -wholename '*/mutt/~a' | cut -d '/' -f 5-)/app_password\"\n"
            account-name
            address
            user
            address)
     (case provider
      ((#:gmail) "host smtp.gmail.com\n")
      ((#:davmail) "tls off
auth plain
host 127.0.0.1
port 1025\n")
      ((#:outlook) "auth xoauth2
host smtp.office365.com\n")
      ((#:plain) (msmtp-pure-smtp-config-fragment smtp-host smtp-port))
      (else "")))))


(define* (msmtp-accounts-config-fragments accounts)
  "Recursive function that returns config fragments for all accounts"
  (if (null? accounts)
      ""
      (let ((acc (car accounts)))
        (string-append (msmtp-account-config-fragment acc) (msmtp-accounts-config-fragments (cdr accounts))))))

(define* (msmtp-config accounts default)
  (string-append "# Set default values for all following accounts.
defaults
auth on
port 587
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log\n\n"
          (msmtp-accounts-config-fragments accounts)
          (format #f "# Set a default account
account default : ~a
" default)))
