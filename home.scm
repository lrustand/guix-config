(use-modules (gnu)
             (gnu home)
             (gnu home services)
             (gnu packages)
             (gnu services)
             (gnu packages web-browsers)
             (gnu packages python-xyz)
             (guix gexp)
             (guix channels)
             (guix packages)
             (lrustand packages package-groups)
             (lrustand packages lisgd)
             (lrustand home services)
             (lrustand services offlineimap)
             (lrustand services lisgd)
             (lrustand services repos)
             (lrustand services symlinks)
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
      "guile-readline"
      "guile-colorized"
      "cmake"
      "make"
      "gcc-toolchain"
      "sqlite" ;; Needed for qutebrowser
      "tree"
      "file"
      "zip"
      "unzip"
      "ncdu"
      "the-silver-searcher"
      "curl"
      "font-google-noto"
      "font-google-noto-emoji"
      "font-dejavu"
      "nyxt"
      "gst-libav"
      "gst-plugins-base"
      "gst-plugins-good"
      "gst-plugins-bad"
      "gst-plugins-bad-minimal"
      "gst-plugins-ugly"
      "sbcl"
      "sbcl-clx-truetype"
      "sbcl-slynk"
      "python"
      "nss-certs"
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
   (simple-service 'lrustand-channel-service
                   home-channels-service-type
                   (list
                    (channel
                     (name 'lrustand)
                     (url "https://github.com/lrustand/guix-config")
                     (introduction
                      (make-channel-introduction
                       "050796f9d48e8a5af8b99a03cdfe7ff1fda8d2a3"
                       (openpgp-fingerprint
                        "8A20 89FB 60FA 2311 3046  5178 022B 5FFE 7AEE F619"))))))

   (service home-shepherd-service-type)

   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list
                     (local-file "files/zsh/zshrc")))))

   (service home-symlinks-service-type
            '(("/home/lars/code/guix-config/files/emacs/init.el"
               ".emacs.d/init.el")

              ("/home/lars/code/guix-config/files/alacritty/alacritty.yml"
               ".config/alacritty/alacritty.yml")

              ("/home/lars/code/guix-config/files/stumpwm/config"
               ".config/stumpwm/config")

              ("/home/lars/code/guix-config/files/stumpwm/.xinitrc"
               ".xinitrc")

              ("/home/lars/code/guix-config/files/xmodmap/.Xmodmap"
               ".Xmodmap")

              ("/home/lars/code/guix-config/files/stumpwm/start-stump"
               "start-stump")

              ("/home/lars/code/guix-config/files/autorandr"
               ".config/autorandr")

              ("/home/lars/code/guix-config/files/nyxt/config.lisp"
               ".config/nyxt/config.lisp")

              ("/home/lars/code/guix-config/files/offlineimap/auth.py"
               ".config/offlineimap/auth.py")

              ("/home/lars/code/guix-config/files/davmail/davmail.properties"
               ".config/davmail/davmail.properties")

              ("/home/lars/code/guix-config/files/qutebrowser/config.py"
               ".config/qutebrowser/config.py")

              ("/home/lars/code/guix-config/files/qutebrowser/greasemonkey/youtube-ad-blocker.js"
               ".config/qutebrowser/greasemonkey/youtube-ad-blocker.js")

              ("/home/lars/code/guix-config/files/qutebrowser/qutedmenu"
               ".local/share/qutebrowser/userscripts/qutedmenu")

              ("/home/lars/code/guix-config/files/guile/.guile" ".guile")

              ("/home/lars/code/guix-config/files/tmux/tmux.conf"
               ".config/tmux/tmux.conf")))

   (service home-git-clone-service-type
            '(("https://github.com/stumpwm/stumpwm"
               "code/forks/stumpwm")

              ("https://github.com/stumpwm/stumpwm-contrib"
               "code/forks/stumpwm-contrib")

              ("https://github.com/lihebi/clx-truetype"
               ".quicklisp/local-projects/clx-truetype")

              ("https://github.com/atlas-engineer/nyxt"
               "code/forks/nyxt")

              ("https://github.com/lrustand/guix-config"
               "code/guix-config")

              ("https://git.savannah.gnu.org/git/guix.git"
               "code/forks/guix")

              ("https://gitlab.com/nonguix/nonguix"
               "code/forks/nonguix")

              ("https://git.sr.ht/~abcdw/rde"
               "code/forks/rde")

              ("https://github.com/lrustand/dotfiles_ansible"
               "code/dotfiles_ansible")

              ("https://github.com/lrustand/qmk_firmware"
               "code/qmk")

              ("https://github.com/lrustand/zmk"
               "code/zmk")

              ("https://github.com/qutebrowser/qutebrowser"
               "code/forks/qutebrowser")))

   (service home-bash-service-type)

   (service home-syncthing-service-type)

   (service home-offlineimap-service-type)

   (service home-lisgd-service-type
            (lisgd-configuration
             (home-service? #t)
             (extra-options '("-d" "/dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event"
                              "-g" "1,RL,R,*,P,xdotool key Super_L+n"
                              "-g" "1,LR,L,*,P,xdotool key Super_L+p"
                              "-g" "2,RL,*,*,R,xdotool key Super_L+n"
                              "-g" "2,LR,*,*,R,xdotool key Super_L+p"
                              "-g" "1,DU,B,*,P,xdotool key Hyper_L+m"
                              "-g" "1,UD,B,*,P,xdotool key Hyper_L+M"
                              "-g" "1,UD,T,*,P,rofi -show drun -show-icons -icon-theme Papirus"
                              "-g" "1,DLUR,TR,*,P,xdotool key Super_L+f"))))

   (service home-xdg-configuration-files-service-type
            `(("msmtp/config"
               ,(plain-file
                 "" (msmtp-config email-accounts "gmail")))
              ("offlineimap/config"
               ,(plain-file
                 "" (offlineimap-config email-accounts))))))))
