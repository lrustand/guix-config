(define-module (lrustand packages package-groups)
  #:use-module (gnu packages))

(define-public %shell-packages
  (specifications->packages
   '("zsh"
     "zsh-completions"
     "zsh-syntax-highlighting"
     "zsh-autosuggestions"
     "zsh-history-substring-search")))

(define-public %emacs-packages
  (specifications->packages
   '("emacs-next"
     "libvterm"
     "emacs-vterm"
     "emacs-multi-vterm"
     "emacs-geiser"
     "emacs-geiser-guile")))

(define-public %mail-packages
  (specifications->packages
   '("msmtp"
     "mu"
     "notmuch"
     "offlineimap3")))

(define-public %x11-packages
  (specifications->packages
   '("scrot"
     "rofi"
     "i3lock"
     "xev"
     "xrandr"
     "xprop"
     "xdotool"
     "xmodmap"
     "xhost"
     "xauth"
     "xinput"
     "xclip"
     "papirus-icon-theme"
     "feh"
     "mpv"
     "youtube-dl"
     "yt-dlp"
     "alacritty"
     "pavucontrol"
     "autorandr")))

(define-public %password-store-packages
  (specifications->packages
   '("password-store"
     "pass-otp"
     "gnupg"
     "pinentry")))

