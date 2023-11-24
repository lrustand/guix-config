(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu home services ssh)
             (gnu home services mail)
             (gnu home services syncthing)
             (gnu home services desktop)
             (gnu services)
             (gnu services base)
             (gnu packages base)
             (gnu packages admin)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages vim)
             (gnu packages version-control)
             (gnu packages terminals)
             (gnu packages tmux)
             (gnu packages shells)
             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages shellutils)
             (gnu packages web-browsers)
             (gnu packages certs)
             (gnu packages mail)
             (gnu packages xdisorg)
             (gnu packages video)
             (gnu packages lisp)
             (gnu packages pulseaudio)
             (gnu packages image-viewers)
             (gnu packages password-utils)
             (guix gexp)
             (lrustand mail offlineimap)
             (lrustand mail msmtp))

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

(home-environment
 (packages (list
            htop
            git
            alacritty
            tmux
            emacs-next
            emacs-vterm
            emacs-geiser
            zsh
            zsh-completions
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-history-substring-search
            glibc-locales
            guile-readline
            guile-colorized
            nyxt
            sbcl
            msmtp
            scrot
            feh
            offlineimap
            autorandr
            mpv
            youtube-dl
            yt-dlp
            password-store
            pass-otp
            pavucontrol
            qutebrowser
            nss-certs
            neovim))
 (services
  (list
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
                     ("clear" . "Mod3")
                     ("keysym Caps_Lock" . "Hyper_L")
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
