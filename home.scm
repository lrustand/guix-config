(use-modules (gnu home)
             (gnu home services)
             (gnu packages)
             (gnu services)
             (gnu services base)
             (gnu packages web-browsers)
             (guix gexp)
             (lrustand home services)
             (lrustand mail offlineimap)
             (lrustand mail msmtp))

(use-home-service-modules
 shells
 ssh
 mail
 syncthing
 desktop
 shepherd)


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

(define %shell-packages
  (specifications->packages
   '("zsh"
     "zsh-completions"
     "zsh-syntax-highlighting"
     "zsh-autosuggestions"
     "zsh-history-substring-search")))

(define %emacs-packages
  (specifications->packages
   '("emacs-next"
     "emacs-vterm"
     "emacs-geiser")))

(define %mail-packages
  (specifications->packages
   '("msmtp"
     "mu"
     "offlineimap3")))

(define %x11-packages
  (specifications->packages
   '("scrot"
     "rofi"
     "i3lock"
     "xev"
     "xinput"
     "xclip"
     "feh"
     "mpv"
     "youtube-dl"
     "yt-dlp"
     "alacritty"
     "pavucontrol"
     "autorandr")))

(define %password-store-packages
  (specifications->packages
   '("password-store"
     "pass-otp"
     "gnupg"
     "pinentry")))

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
