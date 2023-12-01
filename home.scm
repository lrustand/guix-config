(use-modules (gnu home services)
             (gnu packages)
             (gnu services)
             (gnu packages web-browsers)
             (guix gexp)
             (guix channels)
             (lrustand packages package-groups)
             (lrustand home services)
             (lrustand mail offlineimap)
             (lrustand mail msmtp))

(use-home-service-modules
 shells
 ssh
 mail
 syncthing
 desktop
 shepherd
 guix)


(define email-accounts
  (list '(("account-name" . "gmail")
          ("address" . "rustand.lars@gmail.com")
          ("user" . "rustand.lars@gmail.com")
          ("provider" . #:gmail))
        '(("account-name" . "rustandtech")
          ("address" . "lars@rustand.tech")
          ("user" . "lars")
          ("provider" . #:plain)
          ("imap-host" . "mail.rustand.tech")
          ("smtp-host" . "mail.rustand.tech"))))

(define-public qutebrowser-with-tldextract
  (package/inherit qutebrowser
    (name "qutebrowser-with-adblock")
    (inputs (modify-inputs (package-inputs qutebrowser)
                           (prepend python-tldextract)))))

(home-environment
 (packages
  (append
   (list qutebrowser-with-tldextract)
   %shell-packages
   %emacs-packages
   %mail-packages
   %x11-packages
   %password-store-packages
   (specifications->packages
    '("htop"
      "git"
      "tmux"
      "ecryptfs-utils"
      "glibc-locales"
      "guile-readline"
      "guile-colorized"
      "nyxt"
      "sbcl"
      ;;"qutebrowser-with-tldextract"
      "python"
      "python-tldextract"
      "nss-certs"
      ;sbcl-ttf-fonts
      ;font-dejavu
      "neovim"))))
 
 (services
  (list
   (simple-service 'nonguix-channel-service
                   home-channels-service-type
                   (list
                    (channel
                     (name 'nonguix)
                     (url "https://gitlab.com/nonguix/nonguix")
                     ;; Enable signature verification:
                     (introduction
                      (make-channel-introduction
                       "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                       (openpgp-fingerprint
                        "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))
   (simple-service 'rde-channel-service
                   home-channels-service-type
                   (list
                    (channel
                     (name 'rde)
                     (url "https://git.sr.ht/~abcdw/rde")
                     (introduction
                      (make-channel-introduction
                       "257cebd587b66e4d865b3537a9a88cccd7107c95"
                       (openpgp-fingerprint
                        "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))))
   (service home-shepherd-service-type)
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list
                     (local-file "files/zsh/zshrc")))))
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)))
   (service home-files-service-type
            `((".emacs.d/init.el" ,(local-file "files/emacs/init.el"))))
              ;;(".guile" ,(local-file "files/guile/.guile"))))
   ;; TODO possibly add this in etc
   (service home-xmodmap-service-type
         (home-xmodmap-configuration
          (key-map '(("remove Lock" . "Caps_Lock")
                     ("keysym Caps_Lock" . "Hyper_L")
                     ("remove Mod4" . "Hyper_L")
                     ("add Mod3" . "Hyper_L")))))
   (service home-syncthing-service-type)
   (service home-xdg-configuration-files-service-type
            `(("alacritty/alacritty.yml" ,(local-file "files/alacritty/alacritty.yml"))
              ("stumpwm/config" ,(local-file "files/stumpwm/config"))
              ("nyxt/config.lisp" ,(local-file "files/nyxt/config.lisp"))
              ("msmtp/config"
               ,(plain-file
                 "" (msmtp-config email-accounts)))
              ("offlineimap/config"
               ,(plain-file
                 "" (offlineimap-config email-accounts)))
              ("offlineimap/auth.py" ,(local-file "files/offlineimap/auth.py"))
              ("offlineimap/postsync.sh" ,(local-file "files/offlineimap/postsync.sh"))
              ("davmail/davmail.properties" ,(local-file "files/davmail/davmail.properties"))
              ("qutebrowser/config.py" ,(local-file "files/qutebrowser/config.py"))
              ("tmux/tmux.conf" ,(local-file "files/tmux/tmux.conf")))))))
