(define-module (lrustand packages package-groups)
  #:use-module (gnu packages))

(define-public %embedded-packages
  (specifications->packages
   '("dfu-util"
     "dtc"
     "minicom"
     "openocd"
     "screen"
     "stlink")))

(define-public %lr/base-packages
  (specifications->packages
   '("curl"
     "file"
     "git"
     "htop"
     "neovim"
     "nss-certs"
     "the-silver-searcher"
     "tmux"
     "tree"
     "unzip"
     "wget"
     "zip")))

(define-public %build-packages
  (specifications->packages
   '("cmake"
     "gcc-toolchain"
     "make"
     "patchelf"
     "python")))

(define-public %nyxt-packages
  (specifications->packages
   '("nyxt"
     "gst-libav"
     "gst-plugins-good"
     ;;"gst-plugins-bad"
     "gst-plugins-bad-minimal"
     "gst-plugins-ugly")))

(define-public %shell-packages
  (specifications->packages
   '("zsh"
     "zsh-autosuggestions"
     "zsh-completions"
     "zsh-history-substring-search"
     "zsh-syntax-highlighting")))

(define-public %emacs-packages
  (specifications->packages
   '("emacs-geiser"
     "emacs-geiser-guile"
     "emacs-multi-vterm"
     "emacs-next"
     "emacs-vterm"
     "libvterm")))

(define-public %mail-packages
  (specifications->packages
   '("msmtp"
     "mu"
     "notmuch"
     "offlineimap3")))

(define-public %guile-packages
  (specifications->packages
   '("guile"
     "guile-colorized"
     "guile-readline")))

(define-public %x11-packages
  (specifications->packages
   '("alacritty"
     "autorandr"
     "feh"
     "font-dejavu"
     "font-google-noto"
     "font-google-noto-emoji"
     "i3lock"
     "mpv"
     ;;"papirus-icon-theme"
     "pavucontrol"
     "rofi"
     "scrot"
     "xauth"
     "xclip"
     "xdotool"
     "xev"
     "xhost"
     "xinput"
     "xmodmap"
     "xprop"
     "xrandr"
     "xss-lock"
     "youtube-dl"
     "yt-dlp")))

(define-public %password-store-packages
  (specifications->packages
   '("gnupg"
     "pass-otp"
     "password-store"
     "pinentry")))

