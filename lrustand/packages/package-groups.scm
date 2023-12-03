(define-module (lrustand packages package-groups)
  #:use-module (gnu packages)
  #:export (%shell-packages)
  #:export (%emacs-packages)
  #:export (%mail-packages)
  #:export (%x11-packages)
  #:export (%password-store-packages))

(define-public %shell-packages
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

