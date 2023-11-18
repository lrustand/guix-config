(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
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
             (gnu packages shellutils)
             (gnu packages web-browsers)
             (gnu packages certs)
             (guix gexp))


(home-environment
 (packages (list
            htop
            git
            kitty
            tmux
            emacs-next
            emacs-vterm
            zsh
            zsh-completions
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-history-substring-search
            glibc-locales
            nyxt
            nss-certs
            neovim))
 (services
  (list
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list
                     (local-file "zshrc")))))
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)))
   (simple-service 'tmux-config
                   home-xdg-configuration-files-service-type
                   (list `("tmux/tmux.conf"
                           ,(local-file "tmux.conf")))))))
