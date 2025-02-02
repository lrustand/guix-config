(define-module (lrustand mail offlineimap))


(define nametrans-local-gmail
  "#nametrans= lambda f: '[Gmail]/' + f if f in ['Utkast', 'Stjernemerket', 'Viktig', 'S&APg-ppelpost', 'Papirkurv', 'All e-post', 'Sendt e-post'] else f
nametrans= lambda f: '[Gmail]/' + f if f in ['Drafts', 'Starred', 'Important', 'Spam', 'Trash', 'All Mail', 'Sent'] else f")

(define nametrans-remote-gmail
  "nametrans= lambda f: f.replace('[Gmail]/','')")

(define nametrans-remote-outlook
  "# Folders to skip during sync.
folderfilter = lambda foldername: foldername not in [
    'Calendar',
    'Calendar/Birthdays',
    'Calendar/Sub Folder 1',
    'Calendar/Sub Folder 2',
    'Calendar/United States holidays',
    'Contacts',
    'Contacts/Sub Folder 1',
    'Contacts/Sub Folder 2',
    'Contacts/Skype for Business Contacts',
    'Deleted Items',
    'Drafts',
    'Journal',
    'Junk Email',
    'Notes',
    'Outbox',
    'Social Activity Notifications'
    'Sync Issues',
    'Sync Issues/Conflicts',
    'Sync Issues/Local Failures',
    'Sync Issues/Server Failures',
    'Tasks',
    'Tasks/Sub Folder 1',
    'Tasks/Sub Folder 2',
    'Trash']")

(define* (get-default-imap-host provider)
  (case provider
    ((#:gmail) "imap.gmail.com")
    ((#:outlook) "outlook.office365.com")
    ((#:davmail) "127.0.0.1")
    (else "127.0.0.1")))

(define* (get-default-imap-port provider)
  (case provider
    ((#:davmail) 1143)
    (else 993)))

(define-public (offlineimap-config accounts)
  (string-append
    (format #f "[general]
# List of accounts to be synced, separated by a comma.
accounts = ~a\n" (string-join
                  (map (lambda (acc)
                         (assoc-ref acc "account-name")) accounts)
                  ", "))
    "pythonfile = ~/.config/offlineimap/auth.py
postsynchook = ~/.config/offlineimap/postsync.sh
# Controls how many accounts may be synced simultaneously
maxsyncaccounts = 1
"

    (string-join
     (map (lambda (acc)
            (let* ((address (assoc-ref acc "address"))
                   (account-name (or
                                  (assoc-ref acc "account-name")
                                  address))
                   (user (or
                          (assoc-ref acc "user")
                          address))
                   (provider (or
                              (assoc-ref acc "provider")
                              #:plain))
                   (imap-host (or
                               (assoc-ref acc "imap-host")
                               (get-default-imap-host provider)))
                   (imap-port (or
                               (assoc-ref acc "imap-port")
                               (get-default-imap-port provider))))
              (string-append "

[Account " account-name "]
# Identifier for the local repository; e.g. the maildir to be synced via IMAP.
localrepository = " account-name "-local
# Identifier for the remote repository; i.e. the actual IMAP, usually non-local.
remoterepository = " account-name "-remote
# Minutes between syncs
autorefresh = 0.5
# Quick-syncs do not update if the only changes were to IMAP flags.
# autorefresh=0.5 together with quick=10 yields
# 10 quick refreshes between each full refresh, with 0.5 minutes between every
# refresh, regardless of type.
quick = 10

[Repository " account-name "-local]
# OfflineIMAP supports Maildir, GmailMaildir, and IMAP for local repositories.
type = Maildir
# Where should the mail be placed?
localfolders = ~/mail/" account-name "\n"
(case provider
  ((#:gmail) nametrans-local-gmail)
  (else ""))

"
folderfilter = lambda folder: folder not in ['Trash', 'Sent Mail']

[Repository " account-name "-remote]
type = IMAP
remoteuser = " user "
remotehost = " imap-host "
remoteport = " (number->string imap-port) "
"

(if (eq? provider #:davmail)
    "ssl = no\n"
    "")

(if (eq? provider #:outlook)
    (string-append "auth_mechanisms = XOAUTH2
oauth2_request_url = https://login.microsoftonline.com/common/oauth2/v2.0/token
oauth2_client_id_eval = get_client_id('" address "')
oauth2_client_secret_eval = get_client_secret('" address "')
oauth2_refresh_token_eval = get_refresh_token('" address "')
")
    (string-append "remotepasseval = get_app_password('" address "')
"))

"sslcacertfile = /etc/ssl/certs/ca-certificates.crt
"

(case provider
  ((#:gmail) nametrans-remote-gmail)
  ((#:outlook #:davmail) nametrans-remote-outlook)
  (else ""))))) accounts))

"# Instead of closing the connection once a sync is complete, offlineimap will
# send empty data to the server to hold the connection open. A value of 60
# attempts to hold the connection for a minute between syncs (both quick and
# autorefresh).This setting has no effect if autorefresh and holdconnectionopen
# are not both set.
keepalive = 60
# OfflineIMAP normally closes IMAP server connections between refreshes if
# the global option autorefresh is specified.  If you wish it to keep the
# connection open, set this to true. This setting has no effect if autorefresh
# is not set.
holdconnectionopen = yes"))

