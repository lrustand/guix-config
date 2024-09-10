;; -*- lexical-binding: t; -*-

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
         '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(if package-archive-contents
    ;; Do it in the background if we already have it
    (package-refresh-contents t)
  (package-refresh-contents))

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-dark t))

(use-package doom-modeline
  :ensure t
  :init
  (require 'doom-modeline)
  :custom
  (doom-modeline-workspace-name nil)
  :config
  (doom-modeline-mode 1))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (define-key evil-motion-state-map (kbd "RET") nil) ;; Disable to avoid overriding org-mode follow links
  (evil-mode 1)
  (evil-set-undo-system 'undo-tree))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

(use-package evil-terminal-cursor-changer
  :ensure t
  :after evil
  :config
  (unless (display-graphic-p)
          (require 'evil-terminal-cursor-changer)
          (evil-terminal-cursor-changer-activate)))

(use-package emacs
  :config
  (require 'tramp)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path) ;; Fix tramp for Guix
  :hook
  (prog-mode . (lambda ()
                 (setq-local show-trailing-whitespace t)))
  :custom
  (native-comp-async-report-warnings-errors 'silent))

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package sly
  :ensure t
  :defer t
  :config
  (evil-define-key 'insert sly-mrepl-mode-map (kbd "<up>") 'sly-mrepl-previous-input-or-button)
  (evil-define-key 'insert sly-mrepl-mode-map (kbd "<down>") 'sly-mrepl-next-input-or-button))

(use-package xclip
  :ensure t
  :config
  (xclip-mode 1))

;; Using this to change the auto-dim-other-bufers-face for solarized
;; Taken from alphapapa unpackaged scripts
;;;###autoload
(defun unpackaged/customize-theme-faces (theme &rest faces)
  "Customize THEME with FACES.
Advises `enable-theme' with a function that customizes FACES when
THEME is enabled.  If THEME is already enabled, also applies
faces immediately.  Calls `custom-theme-set-faces', which see."
  (declare (indent defun))
  (when (member theme custom-enabled-themes)
    ;; Theme already enabled: apply faces now.
    (let ((custom--inhibit-theme-enable nil))
      (apply #'custom-theme-set-faces theme faces)))
  (let ((fn-name (intern (concat "unpackaged/enable-theme-advice-for-" (symbol-name theme)))))
    ;; Apply advice for next time theme is enabled.
    (fset fn-name
          (lambda (enabled-theme)
            (when (eq enabled-theme theme)
              (let ((custom--inhibit-theme-enable nil))
                (apply #'custom-theme-set-faces theme faces)))))
    (advice-remove #'enable-theme fn-name)
    (advice-add #'enable-theme :after fn-name)))

(use-package auto-dim-other-buffers
  :ensure t
  :config
  (unpackaged/customize-theme-faces 'solarized-dark
    '(auto-dim-other-buffers-face ((t (:background "#041f27")))))
  :init
  (auto-dim-other-buffers-mode 1))

(use-package dap-mode
  :ensure t
  :defer t)

(set-frame-font "DeJavu Sans Mono 10" nil t)

;; Completion for shell commands
(use-package pcmpl-args
  :ensure t
  :demand t)

(defun get-focused-monitor-geometry ()
  "Get the geometry of the monitor displaying the selected frame in EXWM."
  (let* ((monitor-attrs (frame-monitor-attributes))
         (workarea (assoc 'workarea monitor-attrs))
         (geometry (cdr workarea)))
    (list (nth 0 geometry) ; X
          (nth 1 geometry) ; Y
          (nth 2 geometry) ; Width
          (nth 3 geometry) ; Height
          )))

(use-package corfu
  :ensure t
  :preface
  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer."
    (when (local-variable-p 'completion-at-point-functions)
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))
  (defun advise-corfu-make-frame-with-monitor-awareness (orig-fun frame x y width height buffer)
    "Advise `corfu--make-frame` to be monitor-aware, adjusting X and Y according to the focused monitor."
    ;; Get the geometry of the currently focused monitor
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry))
           ;; You may want to adjust the logic below if you have specific preferences
           ;; on where on the monitor the posframe should appear.
           ;; Currently, it places the posframe at its intended X and Y, but ensures
           ;; it's within the bounds of the focused monitor.
           (new-x (+ monitor-x x))
           (new-y (+ monitor-y y)))
      ;; Call the original function with potentially adjusted coordinates
      (funcall orig-fun frame new-x new-y width height buffer)))


  :hook
  (minibuffer-setup-hook . corfu-enable-in-minibuffer)
  :custom
  (corfu-auto nil)
  ;;(corfu-auto-delay 0.6)
  (corfu-cycle t)
  (corfu-preview-current t)
  (corfu-popupinfo-delay 0)
  (tab-always-indent 'complete)
  (corfu-history-mode t)
  :config
  (with-eval-after-load "sly"
    (setq sly-symbol-completion-mode nil))
  (advice-add 'corfu--make-frame :around #'advise-corfu-make-frame-with-monitor-awareness)
  (corfu-popupinfo-mode 1)
  (global-corfu-mode))


(use-package cape
  :ensure t
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-file)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

(use-package magit
  :ensure t
  :demand t)

;;(use-package yasnippet
;;  :ensure t
;;  :custom
;;  (yas-indent-line 'auto)
;;  (yas-also-auto-indent-first-line t)
;;  :config
;;  (yas-global-mode 1))
;;
;;(use-package yasnippet-snippets
;;  :ensure t)

(use-package lsp-mode
  :ensure t
  :defer t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-latex
  :ensure t
  :defer t
  :after lsp-mode
  :init
  (require 'lsp-latex)

  :hook
  (tex-mode . 'lsp)
  (latex-mode . 'lsp)
  (LaTeX-mode . 'lsp)
  :config

  ;; For YaTeX
  (with-eval-after-load "yatex"
    (add-hook 'yatex-mode-hook 'lsp))

  ;; For bibtex
  (with-eval-after-load "bibtex"
    (add-hook 'bibtex-mode-hook 'lsp))

  :custom
  (lsp-latex-forward-search-executable "okular")
  (lsp-latex-forward-search-args '("--noraise" "--unique" "file:%p#src:%l%f"))
  (lsp-latex-build-forward-search-after t)
  (lsp-latex-build-on-save t))

(use-package shrface
  :ensure t
  :defer t
  :config
  (shrface-basic)
  (shrface-trial)
  (shrface-default-keybindings) ; setup default keybindings
  :custom
  (shrface-href-versatile t))

(use-package eww
  :defer t
  :init
  (add-hook 'eww-after-render-hook #'shrface-mode)
  :config
  (require 'shrface))

;; TODO one of the following options disables shrface conversion to org-mode headings
;; Figure out what and fix it
(require 'mu4e-contrib)
;;(setq mu4e-html2text-command 'mu4e-shr2text)
(setq shr-color-visible-luminance-min 60)
(setq shr-color-visible-distance-min 5)
(setq shr-use-colors nil)
(advice-add #'shr-colorize-region :around (defun shr-no-colourise-region (&rest ignore)))

(use-package hl-todo
  :ensure t
  :config
  (global-hl-todo-mode 1))

(use-package magit-todos
  :ensure t
  :after magit
  :config
  (magit-todos-mode 1))

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

;; Provides only the command “restart-emacs”.
(use-package restart-emacs
  :ensure t
  ;; If I ever close Emacs, it's likely because I want to restart it.
  :bind ("C-x C-c" . restart-emacs)
  ;; Let's define an alias so there's no need to remember the order.
  :config (defalias 'emacs-restart #'restart-emacs))

(use-package bitbake
  :ensure t
  :defer t
  :mode "bitbake-mode"
  :init
  (add-to-list 'auto-mode-alist '("\\.\\(bb\\|bbappend\\|bbclass\\|inc\\|conf\\)\\'" . bitbake-mode))
  :config
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration
      '(bitbake-mode . "bitbake"))
    (lsp-register-client
      (make-lsp-client
      :new-connection (lsp-stdio-connection "bitbake-language-server")
      :activation-fn (lsp-activate-on "bitbake")
      :server-id 'bitbake)))

  (with-eval-after-load "bitbake-mode"
    (add-hook 'bitbake-mode-hook 'lsp)))

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  :custom
  (undo-tree-visualizer-timestamps t)
  (undo-tree-visualizer-diff t)
  (undo-tree-auto-save-history t)
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

(use-package tex
  :ensure auctex
  :defer t
  :config
  (setq-default TeX-master "main") ; All master files called "main".
  :custom
  (TeX-view-program-list '(("Okular" "okular --noraise --unique file:%o#src%n%a")))
  (TeX-view-program-selection '((output-pdf "Okular"))))

(use-package git-gutter
  :ensure t
  :preface
  (defun rpo/git-gutter-mode ()
    "Enable git-gutter mode if current buffer's file is under version control."
    (if (and (buffer-file-name)
             (vc-backend (buffer-file-name))
             ;; Skip filetypes where git-gutter makes problems
             (not (cl-some (lambda (suffix) (string-suffix-p suffix (buffer-file-name)))
                           '(".pdf" ".svg" ".png"))))
        (git-gutter-mode 1)))
  (defun set-git-gutter-background ()
    (set-face-background 'git-gutter:unchanged (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:modified (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:added (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:deleted (face-attribute 'mode-line :background)))
  :custom
  (git-gutter:hide-gutter t)
  (git-gutter:update-interval 2)
  (git-gutter:unchanged-sign " ")

  :config
  (add-to-list 'git-gutter:update-hooks 'focus-in-hook)
  :hook
  (prog-mode . rpo/git-gutter-mode)
  (server-after-make-frame-hook . set-git-gutter-background)
  (window-setup-hook . set-git-gutter-background))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;;(use-package consult
;;  :ensure t
;;  :bind (("C-x b" . consult-buffer)))
;;
;;(use-package consult-projectile
;;  :ensure t
;;  :after consult
;;  :bind (("C-c p p" . consult-projectile-switch-project)
;;         ("C-c p f" . consult-projectile)))

(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless emacs22)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package bibtex-completion
  :ensure t
  :defer t
  :custom
  (bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n")
  (bibtex-completion-additional-search-fields '(keywords))
  (bibtex-completion-display-formats
  '((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
    (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
    (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
    (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
    (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}")))
  (bibtex-completion-pdf-open-function
    (lambda (fpath)
      (call-process "okular" nil 0 nil fpath)))

  :config
  (defun my-open-citation-at-point ()
    (interactive) (bibtex-completion-open-pdf (list (thing-at-point 'symbol))))

  (with-eval-after-load "evil"
    (evil-define-key 'normal 'latex-mode-map "gp" 'my-open-citation-at-point)))

(use-package ace-window
  :ensure t
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package quelpa-use-package
  :ensure t)
;;
;;(use-package mastodon-alt
;;  :quelpa (mastodon-alt :fetcher github :repo "rougier/mastodon-alt"))

(use-package org-gantt
  :after org
  :defer t
  :quelpa (org-gantt :fetcher github :repo "swillner/org-gantt"))

(use-package geiser
  :ensure t
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-implementations-alist '(((regexp "\\.scm$") guile))))

(use-package geiser-guile
  :ensure t
  :after geiser
  :config
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/guix")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/guix-config/src")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/nonguix")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/rde/src"))

(with-eval-after-load "geiser-guile"
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/guix")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/guix-config/src")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/nonguix")
  (add-to-list 'geiser-guile-load-path "/home/lars/code/forks/rde/src"))


(use-package mu4e
  :init
  ;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
  (require 'mu4e)
  :hook
  ;; Don't create tons of "draft" messages
  (mu4e-compose-mode . (lambda () (auto-save-mode -1)))
  :custom
  (mu4e-update-interval 30)
  ;; Use with font-google-noto, or a later version of font-openmoji
  (mu4e-headers-unread-mark    '("u" . "📩"))
  (mu4e-headers-draft-mark     '("D" . "✏️"))
  (mu4e-headers-flagged-mark   '("F" . "🚩"))
  (mu4e-headers-new-mark       '("N" . "✨"))
  (mu4e-headers-passed-mark    '("R" . "↪️"))
  (mu4e-headers-replied-mark   '("R" . "↩️"))
  (mu4e-headers-seen-mark      '("S" . "✔️"))
  (mu4e-headers-trashed-mark   '("T" . "🗑️"))
  (mu4e-headers-attach-mark    '("a" . "📎"))
  (mu4e-headers-encrypted-mark '("x" . "🔒"))
  (mu4e-headers-signed-mark    '("s" . "🔑️"))
  (mu4e-headers-calendar-mark  '("c" . "📅"))
  (mu4e-headers-list-mark      '("l" . "📰"))
  (mu4e-headers-personal-mark  '(""  . ""  )) ; All emails are marked personal; hide this mark

  (mu4e-compose-dont-reply-to-self t)

  (mu4e-attachment-dir "~/Downloads")

  ;; Gmail takes care of sent messages
  (mu4e-sent-messages-behavior 'delete)

  ;; use mu4e for e-mail in emacs
  (mail-user-agent 'mu4e-user-agent)
  (sendmail-program "msmtp")
  (send-mail-function 'smtpmail-send-it)
  (message-sendmail-f-is-evil t)
  (message-sendmail-extra-arguments '("--read-envelope-from"))
  (message-send-mail-function 'message-send-mail-with-sendmail)
  ;; these must start with a "/", and must exist
  ;; (i.e.. /home/user/Maildir/sent must exist)
  ;; you use e.g. 'mu mkdir' to make the Maildirs if they don't
  ;; already exist

  ;; below are the defaults; if they do not exist yet, mu4e offers to
  ;; create them. they can also functions; see their docstrings.
  (mu4e-sent-folder   "/Sent Mail")
  (mu4e-drafts-folder "/Drafts")
  (mu4e-trash-folder  "/Trash"))

(defun my-confirm-empty-subject ()
  "Allow user to quit when current message subject is empty."
  (or (message-field-value "Subject")
      (yes-or-no-p "Really send without Subject? ")
      (keyboard-quit)))

(add-hook 'message-send-hook #'my-confirm-empty-subject)

(use-package mu4e-thread-folding
  :quelpa (mu4e-thread-folding
           :fetcher github
           :repo "rougier/mu4e-thread-folding")
  :after mu4e
  :config
  (add-to-list 'mu4e-header-info-custom
               '(:empty . (:name "Empty"
                           :shortname ""
                           :function (lambda (msg) "  "))))

  (evil-define-key 'normal mu4e-headers-mode-map
    (kbd "TAB")  'mu4e-headers-toggle-at-point)

  :custom
  (mu4e-headers-fields '((:empty         .    2)
                         (:human-date    .   12)
                         (:flags         .    6)
                         ;;(:mailing-list  .   10)
                         (:from          .   22)
                         (:subject       .   nil)))
  (mu4e-thread-folding-default-view 'folded)
  (mu4e-headers-found-hook '(mu4e-headers-mark-threads mu4e-headers-fold-all)))

;;(use-package eat
;;  :ensure t
;;  :config
;;  (eat-eshell-mode))
;;  ;;:custom
;;  ;;(eshell-visual-commands nil))

(use-package vterm
  :ensure t
  :defer t
  :config
  ;; Use libvterm installed in Guix
  (advice-add 'vterm-module-compile :around
              (lambda (f &rest r)
                (make-symbolic-link (expand-file-name "~/.guix-home/profile/lib/libvterm.so.0")
                                    (file-name-directory (locate-library "vterm.el" t)) t)
                (make-symbolic-link (expand-file-name "~/.guix-home/profile/lib/vterm-module.so")
                                    (file-name-directory (locate-library "vterm.el" t)) t))))

(use-package multi-vterm
  :ensure t
  :defer t
  :after vterm)

;; IRC client config
(use-package erc
  :defer t
  :custom
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 15)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT")))

(use-package erc-twitch
  :ensure t
  :after erc
  :defer t
  :config
  (erc-twitch-enable))

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :defer t
  :config
  (erc-hl-nicks-enable))

(use-package erc-image
  :ensure t
  :after erc
  :defer t
  :config
  (erc-image-enable))

(use-package goggles
  :ensure t
  :config
  (goggles-mode))

(use-package evil-goggles
  :ensure t
  :after (evil goggles)
  :config
  (evil-goggles-mode))



(use-package org-roam
  :ensure t
  :demand t  ;; Ensure org-roam is loaded by default
  :after org
  :init
  (make-directory "~/org-roam" t)
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/org-roam")
  (org-roam-dailies-directory "dailies")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" plain "%?"
      :target (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d>")
      :unnarrowed t)))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n p" . my/org-roam-find-project)
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available

  (defun my/org-roam-get-title (file)
    (save-window-excursion
      (find-file file)
      (org-get-title)))

  (defun my/org-roam-filter-by-tag (tag-name)
    (lambda (node)
      (member tag-name (org-roam-node-tags node))))

  (defun my/org-roam-list-notes-by-tag (tag-name)
    (mapcar #'org-roam-node-file
            (seq-filter
             (my/org-roam-filter-by-tag tag-name)
             (org-roam-node-list))))

  (defun my/org-roam-refresh-agenda-list ()
    (interactive)
    (setq org-agenda-files (delete-dups (append (my/org-roam-list-notes-by-tag "project")
                                                (my/org-roam-list-notes-by-tag "todo")))))

  ;; Build the agenda list the first time for the session
  (my/org-roam-refresh-agenda-list)

  (defun my/org-roam-project-finalize-hook ()
    "Adds the captured project file to `org-agenda-files' if the
capture was not aborted."
    ;; Remove the hook since it was added temporarily
    (remove-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

    ;; Add project file to the agenda list if the capture was confirmed
    (unless org-note-abort
      (with-current-buffer (org-capture-get :buffer)
        (add-to-list 'org-agenda-files (buffer-file-name)))))

  (defun my/org-roam-find-project ()
    (interactive)
    ;; Add the project file to the agenda after capture is finished
    (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

    ;; Select a project file to open, creating it if necessary
    (org-roam-node-find
     nil
     nil
     (my/org-roam-filter-by-tag "project")
     nil
     :templates
     '(("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
        :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: project")
        :unnarrowed t))))

  (defun my/org-roam-copy-todo-to-today ()
    (interactive)
    (let ((org-refile-keep t) ;; Set this to nil to delete the original!
          (org-roam-dailies-capture-templates
           '(("t" "tasks" entry "%?"
              :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Tasks")))))
          (org-after-refile-insert-hook #'save-buffer)
          today-file
          pos)
      (save-window-excursion
        (org-roam-dailies--capture (current-time) t)
        (setq today-file (buffer-file-name))
        (setq pos (point)))

      ;; Only refile if the target file is different than the current file
      (unless (equal (file-truename today-file)
                     (file-truename (buffer-file-name)))
        (org-refile nil nil (list "Tasks" today-file nil pos)))))

  (add-to-list 'org-after-todo-state-change-hook
               (lambda ()
                 (when (equal org-state "DONE")
                   (my/org-roam-copy-todo-to-today))))
  (org-roam-db-autosync-mode))
(use-package org
  :config
  (require 'org-inlinetask)
  :custom
  (org-ellipsis " ▾")
  (org-hide-emphasis-markers t)
  (org-return-follows-link  t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-modules (append org-modules '(org-checklist
                                     org-habit)))
  (org-agenda-window-setup 'current-window)
  (org-agenda-skip-scheduled-if-deadline-is-shown t)

  (org-todo-keywords
   '((sequence
      "TODO(t)" ; doing later
      "NEXT(n)" ; doing now or soon
      "|"
      "DONE(d!)" ; done
      )
     (sequence
      "BLOCKED(b@/!)"
      "HOLD(h)"
      "IDEA(i)" ; maybe someday
      "|"
      "CANCELED(c@/!)" ; stopped waiting, decided not to work on it
      )))
  (org-todo-keyword-faces
   '(("NEXT" . "green")
     ("BLOCKED" . "orange")
     ("CANCELED" . (:foreground "red" :weight bold))))

  (org-agenda-prefix-format '(
                              ;; (agenda  . " %i %-12:c%?-12t% s") ;; file name + org-agenda-entry-type
                              (agenda  . " %i %(org-get-title) ")
                              (timeline  . "  %(org-get-title) ")
                              (todo  . " %i %(org-get-title) ")
                              (tags  . " %i %(org-get-title) ")
                              (search . " %i %(org-get-title) ")))

  (org-agenda-custom-commands
   `(("d" "Dashboard"
      ((agenda "" ((org-deadline-warning-days 7)))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Tasks")))
       (tags-todo "work"
                  ((org-agenda-overriding-header "Work Tasks")))
       (tags-todo "+irl-TODO=\"HOLD\"-recurring"
                  ((org-agenda-overriding-header "IRL Tasks")))
       ,@(my/org-agenda-create-project-heading-agenda-views)))
     ("h" "Habits"
      ((tags-todo "STYLE=\"habit\""
                  ((org-agenda-overriding-header "Habits")))))
     ("p" "Projects"
      ,(my/org-agenda-create-project-heading-agenda-views))
     ("t" "Tags"
      ,(my/org-agenda-create-tag-heading-agenda-views))))


  :hook (org-mode . (lambda ()
                      (visual-line-mode 1)
                      (org-hide-drawer-all)
                      (org-fold-all-done-entries)))

  :config
  ;; This function generates headings for org-agenda for project files
  (defun my/org-agenda-create-project-heading-agenda-views ()
    (mapcar (lambda (file)
              `(todo "" ((org-agenda-files '(,file))
                         (org-agenda-overriding-header ,(my/org-roam-get-title file))
                         (org-agenda-prefix-format '((todo . ""))))))
            (my/org-roam-list-notes-by-tag "project")))

  ;; This function generates headings for org-agenda per tag
  (defun my/org-agenda-create-tag-heading-agenda-views ()
    (mapcar (lambda (tag)
              `(tags-todo ,(car tag) ((org-agenda-overriding-header ,(car tag)))))
            (seq-filter (lambda (it) (not (or (string-equal (car it) "project")
                                              (string-equal (car it) "todo"))))
                        (org-roam-db-query [:select :distinct [tag] :from tags ]))))

  (defun my/org-checkbox-todo ()
    "Switch header TODO state to DONE when all checkboxes are ticked, to TODO otherwise"
    (interactive)
    (let ((todo-state (org-get-todo-state)) beg end)
      (unless (not todo-state)
        (save-excursion
          (org-back-to-heading t)
          (setq beg (point))
          (end-of-line)
          (setq end (point))
          (goto-char beg)
          (if (re-search-forward "\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]"
                                 end t)
              (if (match-end 1)
                  (if (equal (match-string 1) "100%")
                      (unless (string-equal todo-state "DONE")
                        (org-todo 'done)))
                (if (and (> (match-end 2) (match-beginning 2))
                         (equal (match-string 2) (match-string 3)))
                    (unless (string-equal todo-state "DONE")
                      (org-todo 'done)))))))))

  (add-hook 'org-checkbox-statistics-hook 'my/org-checkbox-todo)

  (defun org-summary-todo (n-done n-not-done)
    "Switch entry to DONE when all subentries are done."
    (if (= n-not-done 0) (org-todo "DONE")))

  (add-hook 'org-after-todo-statistics-hook #'org-summary-todo)

  ;; TODO only collapse DONE items if there are no TODO children
  (defun org-fold-all-done-entries ()
    "Close/fold all entries marked DONE."
    (interactive)
    (save-excursion
      (goto-char (point-max))
      (while (outline-previous-heading)
        (when (org-entry-is-done-p)
          (hide-entry))))))

(use-package org-contrib
  :ensure t
  :after org)

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-edna
  :ensure t
  :after org
  :config
  (org-edna-mode 1))



(use-package org-transclusion
  :ensure t
  :after org)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind ("C-x C-j" . dired-jump)
  :custom
  (dired-listing-switches "-lAh --group-directories-first")
  :hook
  (dired-mode . dired-hide-details-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

;; Open archive files seamlessly in dired
(use-package dired-avfs
  :ensure t
  :after dired)

;; Filetype icons in dired
(use-package all-the-icons-dired
  :ensure t
  :after dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; Collapse multiple dirctory levels if each only has one dir
;; Like the file explorer on github does
(use-package dired-collapse
  :ensure t
  :after dired
  :config
  (global-dired-collapse-mode))

;; Keep reusing a single dired buffer instead of opening new
;; every time you navigate to another folder
;; TODO: Integrate in normal dired commands
(use-package dired-single
  :ensure t
  :after dired)

;; Open some filetypes in external program
;; TODO: Automatically open correct program through mime/xdg
(use-package dired-open
  :ensure t
  :after dired
  :custom
  (dired-open-extensions
   '(("png" . "feh")
     ("mp4" . "mpv")
     ("pdf" . "okular"))))

(use-package pdf-tools
  :ensure nil ;; Use package from Guix
  :config
  (pdf-tools-install))

(setq backup-directory-alist '((".*" . "~/.emacs.d/backup")))
(setq create-lockfiles nil)

(setq x-select-enable-clipboard t)
(setq-default indent-tabs-mode nil)

(xterm-mouse-mode 1)
(savehist-mode 1)
(global-hl-line-mode 1)
(setq auto-revert-use-notify nil)
(global-auto-revert-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; change all prompts to y or n
(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)
;; TODO Do this same way as for auto dim, see above
(defun set-line-number-background ()
  (set-face-background 'line-number (face-attribute 'mode-line :background)))
(add-hook 'server-after-make-frame-hook 'set-line-number-background)
(add-hook 'window-setup-hook 'set-line-number-background)


(use-package eshell
  :preface
  ;; Define a variable to hold the cd history
  (defvar eshell-cd-history nil
    "History of directories visited in EShell.")

  ;; Function to view and select from cd history
  (defun eshell-cd-history-view ()
    "View and select a directory from the cd history."
    (interactive)
    (if eshell-cd-history
        (let ((directory (completing-read "Select directory: " eshell-cd-history)))
          (cd directory))
      (message "No history available.")))

  ;; Advice function to modify the original cd command
  (defun eshell-cd-advice (orig-fun &rest args)
    "Advice around the original cd function to record history."
    (let ((directory (car args)))  ;; Get the first argument (the directory)
      (when (and directory (stringp directory))
        (setq eshell-cd-history (cons (expand-file-name directory) eshell-cd-history)))
      ;; Call the original cd function
      (apply orig-fun args)))

  ;; Apply the advice to the original eshell/cd function
  (advice-add 'eshell/cd :around #'eshell-cd-advice)
  ;; TODO: Make functions to navigate back/forward

  ;; Bind the history view function to a key for easy access
  (define-key eshell-mode-map (kbd "C-c C-d") 'eshell-cd-history-view)

  (defun my-eshell-evil-insert ()
    "Move cursor to end of prompt when entering insert mode in Eshell."
    (when (and (eq major-mode 'eshell-mode)
               (evil-insert-state-p))
      (goto-char (point-max))
      (eshell-bol)))

  (defun git-status ()
    (let ((default-directory (eshell/pwd)))
      (with-output-to-string
        (with-current-buffer standard-output
          (call-process "git" nil t nil "status" "--porcelain")))))

  (defun git-status--dirty-p ()
    (not (string-blank-p (git-status))))
  :hook
  (eshell-mode . (lambda ()
                   (setenv "TERM" "xterm-256color")
                   ;; Buffer local hook
                   (add-hook 'evil-insert-state-entry-hook
                             #'my-eshell-evil-insert nil t)))
  :custom
  (eshell-prompt-function
   (lambda ()
     (let* ((green (face-foreground 'term-color-green))
            (red (face-foreground 'term-color-red))
            (black (face-foreground 'term-color-black))
            (blue (face-foreground 'term-color-blue))
            (bright-black (face-foreground 'term-color-bright-black))
            (prompt-bg black)
            (username-fg (if (= (user-uid) 0) red green))
            (username-face `(:foreground ,username-fg
                                         :background ,prompt-bg
                                         :weight bold))
            (hostname-face `(:foreground ,green
                                         :background ,prompt-bg
                                         :weight bold))
            (timedate-face `(:foreground ,green
                                         :background ,prompt-bg
                                         :weight bold))
            (git-branch-face `(:foreground ,bright-black
                                           :background ,prompt-bg))
            (default-prompt-face `(:foreground "default"
                                               :background ,black
                                               :weight bold)))
       (concat
        "\n"
        ;;(propertize (if venv-current-name (concat " (" venv-current-name ")\n")  "") 'face `(:foreground "#00dc00"))
        (propertize (format-time-string "[%H:%M, %d/%m/%y]" (current-time)) 'face timedate-face)
        "\n"
        (propertize (user-login-name) 'face username-face)
        (propertize "@" 'face default-prompt-face)
        (propertize (system-name) 'face hostname-face)
        (propertize (format " [%s]" (f-abbrev (eshell/pwd))) 'face default-prompt-face)
        (when (magit-get-current-branch)
          (concat
           (propertize (format " [%s" (magit-get-current-branch)) 'face git-branch-face)
           (when (git-status--dirty-p)
             (propertize "*" 'face `(:foreground "red" :background ,prompt-bg :bold)))
           (propertize "]" 'face git-branch-face)))
        "\n"
        (propertize "\n" 'face default-prompt-face)
        (propertize " ->" 'face `(:foreground ,blue :background ,prompt-bg :bold))
        (propertize " " 'face default-prompt-face)))))
  (eshell-prompt-regexp "^ -> "))

;; Highlight command names in eshell
(use-package eshell-syntax-highlighting
  :after eshell
  :ensure t
  :custom
  ;; Do not print the "nobreak" character
  (nobreak-char-display nil)
  :config
  ;; Enable in all Eshell buffers.
  (eshell-syntax-highlighting-global-mode 1))

;;(defun highlight-selected-window ()
;;  "Highlight selected window with a different background color."
;;  (walk-windows (lambda (w)
;;                  (unless (eq w (selected-window))
;;                    (with-current-buffer (window-buffer w)
;;                      (buffer-face-set '(:background "#041f27"))))))
;;  (buffer-face-set 'default))
;;(add-hook 'buffer-list-update-hook 'highlight-selected-window)
;;
;;(add-to-list 'default-frame-alist '(background-color . "#073642"))

(defun tmux-navigate-directions ()
  (let* ((x (nth 0 (window-edges)))
         (y (nth 1 (window-edges)))
         (w (nth 2 (window-edges)))
         (h (nth 3 (window-edges)))

         (can_go_up (> y 2))
         (can_go_down (<  (+ y h) (- (frame-height) 2)))
         (can_go_left (> x 1))
         (can_go_right (< (+ x w) (frame-width))))

    (send-string-to-terminal
     (format "\e]2;emacs %s #%s\a"
    (buffer-name)
        (string
          (if can_go_up    ?U 1)
          (if can_go_down  ?D 1)
          (if can_go_left  ?L 1)
          (if can_go_right ?R 1))))))

(unless (display-graphic-p)
  (add-hook 'buffer-list-update-hook 'tmux-navigate-directions))

(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(defun insert-cut-here-start ()
  "Insert opening \"cut here start\" snippet."
  (interactive)
  (insert "--8<---------------cut here---------------start------------->8---"))

(defun insert-cut-here-end ()
  "Insert closing \"cut here end\" snippet."
  (interactive)
  (insert "--8<---------------cut here---------------end--------------->8---"))



(use-package exwm
  :ensure t
  :demand t
  :init (require 'exwm)
  :config
  (defun efs/exwm-update-class ()
    (exwm-workspace-rename-buffer exwm-title))

  (defun lr/exwm-resize-left ()
    (interactive)
    (if (window-at-side-p nil 'right)
        (exwm-layout-enlarge-window-horizontally 30)
      (exwm-layout-shrink-window-horizontally 30)))
  (defun lr/exwm-resize-right ()
    (interactive)
    (if (window-at-side-p nil 'right)
        (exwm-layout-shrink-window-horizontally 30)
      (exwm-layout-enlarge-window-horizontally 30)))
  (defun lr/exwm-resize-up ()
    (interactive)
    (if (window-at-side-p nil 'bottom)
        (exwm-layout-enlarge-window 30)
      (exwm-layout-shrink-window 30)))
  (defun lr/exwm-resize-down ()
    (interactive)
    (if (window-at-side-p nil 'bottom)
        (exwm-layout-shrink-window 30)
      (exwm-layout-enlarge-window 30)))
  :init
  (start-process-shell-command "xmodmap" nil "xmodmap ~/.Xmodmap")
  :custom
  ;; Set the default number of workspaces
  (exwm-workspace-number 5)
  ;; These keys should always pass through to Emacs
  (exwm-input-prefix-keys
   '(?\C-x
     ?\C-u
     ?\C-h
     ?\M-x
     ?\M-`
     ?\M-&
     ?\M-:
     ?\C-\ ))  ;; Ctrl+Space
  ;; Set up global key bindings.  These always work, no matter the input state!
  (exwm-input-global-keys
   `(
     ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
     ([?\s-r] . exwm-reset)

     ([?\H-d] . app-launcher-run-app)
     ([s-backspace] . kill-current-buffer)
     ([s-return] . multi-vterm-dedicated-toggle)

     ;; Move focus between windows
     ([s-left] . windmove-left)
     ([s-right] . windmove-right)
     ([s-up] . windmove-up)
     ([s-down] . windmove-down)
     ([?\s-h] . windmove-left)
     ([?\s-l] . windmove-right)
     ([?\s-k] . windmove-up)
     ([?\s-j] . windmove-down)

     ;; Swap windows
     ([M-s-left] . windmove-swap-states-left)
     ([M-s-right] . windmove-swap-states-right)
     ([M-s-up] . windmove-swap-states-up)
     ([M-s-down] . windmove-swap-states-down)
     ([?\M-\s-h] . windmove-swap-states-left)
     ([?\M-\s-l] . windmove-swap-states-right)
     ([?\M-\s-k] . windmove-swap-states-up)
     ([?\M-\s-j] . windmove-swap-states-down)

     ;; Resize window
     ([C-s-left] . lr/exwm-resize-left)
     ([C-s-down] . lr/exwm-resize-down)
     ([C-s-up] . lr/exwm-resize-up)
     ([C-s-right] . lr/exwm-resize-right)
     ([?\C-\s-h] . lr/exwm-resize-left)
     ([?\C-\s-j] . lr/exwm-resize-down)
     ([?\C-\s-k] . lr/exwm-resize-up)
     ([?\C-\s-l] . lr/exwm-resize-right)

     ;; Launch applications via shell command
     ([?\s-&] . (lambda (command)
                  (interactive (list (read-shell-command "$ ")))
                  (start-process-shell-command command nil command)))

     ;; Switch workspace
     ([?\s-w] . exwm-workspace-switch)

     ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
     ,@(mapcar (lambda (i)
                 `(,(kbd (format "s-%d" i)) .
                   (lambda ()
                     (interactive)
                     (exwm-workspace-switch-create ,i))))
               (number-sequence 0 9))))
  :hook
  (exwm-randr-screen-change-hook . exwm-randr-refresh)
  :config
  ;; When window "class" updates, use it to set the buffer name
  ;;(add-hook 'exwm-update-class-hook #'efs/exwm-update-class)
  (add-hook 'exwm-update-title-hook #'efs/exwm-update-class)

  ;; Ctrl+Q will enable the next key to be sent directly
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Make posframe appear in front of X11 windows
  (with-eval-after-load 'posframe
    (define-advice posframe-show (:filter-return (frame) exwm-deparent)
      (set-frame-parameter frame 'parent-frame nil)
      frame))

  (exwm-randr-mode 1)
  (exwm-enable))

;; Rofi application launcher alternative
(use-package app-launcher
  :quelpa (app-launcher :fetcher github :repo "SebastienWae/app-launcher"))

;; Let windmove move to other frames as well
;; TODO Send PR. I have modified framemove to get correct frame coords in EXWM
;; Lines 45-48 in framemove.el. Use exwm-workspace--get-geometry.
(use-package framemove
  :quelpa (framemove :fetcher github :repo "jsilve24/framemove")
  :custom (framemove-hook-into-windmove t))

;; Make vertico display in a floating window
(use-package vertico-posframe
  :ensure t
  :after vertico
  :preface
  (defun advise-vertico-posframe-show-with-monitor-awareness (orig-fun buffer window-point &rest args)
    "Advise `vertico-posframe--show` to position the posframe according to the focused monitor."
    ;; Extract the focused monitor's geometry
    (let* ((monitor-geometry (get-focused-monitor-geometry))
           (monitor-x (nth 0 monitor-geometry))
           (monitor-y (nth 1 monitor-geometry)))
      ;; Override poshandler buffer-local variable to use monitor-aware positioning
      (let ((vertico-posframe-poshandler
             (lambda (info)
               (let* ((parent-frame-width (plist-get info :parent-frame-width))
                      (parent-frame-height (plist-get info :parent-frame-height))
                      (posframe-width (plist-get info :posframe-width))
                      (posframe-height (plist-get info :posframe-height))
                      ;; Calculate center position on the focused monitor
                      (x (+ monitor-x (/ (- parent-frame-width posframe-width) 2)))
                      (y (+ monitor-y (/ (- parent-frame-height posframe-height) 2))))
                 (cons x y)))))
        ;; Call the original function with potentially adjusted poshandler
        (apply orig-fun buffer window-point args))))

  :config
  (advice-add 'vertico-posframe--show :around #'advise-vertico-posframe-show-with-monitor-awareness)
  (vertico-posframe-mode 1))

(use-package tab-bar
  :preface
  (defun lr/tab-bar-time-and-date ()
    (let* ((tab-bar-time-face '(:weight bold :foreground "white"))
           (tab-bar-time-format  "%a %-d %b, %H:%M "))
      `((menu-bar menu-item
                  ,(propertize (format-time-string tab-bar-time-format)
                               'font-lock-face
                               tab-bar-time-face)
                  nil ;; <- Function to run when clicked
                  :help "My heltp"))))
  (defun lr/tab-bar-separator () " | ")
  (defun ram ()
    (propertize
     (lemon-monitor-display my/memory-monitor)
     'font-lock-face
     '(:foreground "default")))
  (defun cpu ()
    (propertize
     (lemon-monitor-display my/cpu-monitor)
     'font-lock-face
     '(:foreground "default")))
  (defun bat ()
    (lemon-monitor-display my/battery-monitor))
  (defun net ()
    (propertize
     (concat
      (lemon-monitor-display my/network-rx-monitor)
      (lemon-monitor-display my/network-tx-monitor))
     'face
     '(:foreground "default")))

  (defface my-tab-bar-face
    '((t :inherit mode-line-active))  ;; Inherit attributes from mode-line-active
    "Face for the tab bar.")
  :config
  (tab-bar-mode 1)

  ;; Set the tab-bar face to use the custom face
  (set-face-attribute 'tab-bar nil :inherit 'my-tab-bar-face)
  :custom
  (tab-bar-format '(tab-bar-format-history
                    tab-bar-format-tabs
                    tab-bar-separator
                    tab-bar-format-add-tab
                    tab-bar-format-align-right
                    net
                    ram
                    cpu
                    bat
                    lr/tab-bar-separator
                    lr/tab-bar-time-and-date)))

(use-package lemon
  :quelpa (lemon :fetcher codeberg :repo "emacs-weirdware/lemon"))

(setq my/battery-monitor
      (lemon-battery :display-opts '(:charging-indicator "+"
                                     :discharging-indicator "-")))
(setq my/battery-monitor-timer
      (run-with-timer 0 30
                      (lambda ()
                        (lemon-monitor-update
                         my/battery-monitor))))
(setq my/cpu-monitor
      (lemon-cpu-linux :display-opts '(:index "CPU: "
                                       :unit "%")))
(setq my/cpu-monitor-timer
      (run-with-timer 0 1
                      (lambda ()
                        (lemon-monitor-update
                         my/cpu-monitor))))
(setq my/memory-monitor
      (lemon-memory-linux :display-opts '(:index "MEM: "
                                          :unit "%")))
(setq my/memory-monitor-timer
      (run-with-timer 0 30
                      (lambda ()
                        (lemon-monitor-update
                         my/memory-monitor))))
(setq my/network-rx-monitor (lemon-linux-network-rx))
(setq my/network-tx-monitor (lemon-linux-network-tx))
(setq my/network-monitor-timer
      (run-with-timer 0 1
                      (lambda ()
                        (lemon-monitor-update
                         my/network-rx-monitor)
                        (lemon-monitor-update
                         my/network-tx-monitor))))
(setq my/tab-bar-refresh-timer
      (run-with-timer 0 1
                      'force-mode-line-update))

;; Process Editor (htop-like)
(use-package proced
  :preface
  (defvar proced-guix-nix-readable-mode-keywords
    '(("\\(/nix/store/[0-9a-z]*-\\)"
       (1 '(face nil invisible t)))
      ("\\(/gnu/store/[0-9a-z/\.-]*/\\).* ?.*"
       (1 '(face nil invisible t)))))

  (define-minor-mode proced-guix-nix-readable-mode
    "Make proced filenames more readable in Guix and Nix"
    :lighter " proced-hash-filter-mode"
    (if proced-guix-nix-readable-mode
        (progn
          (make-variable-buffer-local 'font-lock-extra-managed-props)
          (add-to-list 'font-lock-extra-managed-props 'invisible)
          (font-lock-add-keywords nil
                                  proced-guix-nix-readable-mode-keywords)
          (font-lock-mode t))
      (progn
        (font-lock-remove-keywords nil
                                   proced-guix-nix-readable-mode-keywords)
        (font-lock-mode t))))
  :custom
  (proced-auto-update-flag 'visible)
  (proced-auto-update-interval 1)
  (proced-enable-color-flag t)
  ;; Enable remote proced over tramp
  (proced-show-remote-processes t)
  :hook
  (proced-mode . proced-guix-nix-readable-mode))

;; Drag stuff up/down etc with M-<up>, M-<down>...
(use-package drag-stuff
  :ensure t
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))


;; TODO Separate out search history from regular history
;; i.e. remove Google, Ebay, Amazon, Youtube searches etc
(require 'sqlite)
(require 'marginalia)
(defun select-from-qutebrowser-history ()
  (let* ((db (sqlite-open "~/.local/share/qutebrowser/history.sqlite"))
         (history (sqlite-select db "SELECT url,substr(title,0,99) FROM History GROUP BY url ORDER BY COUNT(url) DESC"))
         (candidates (mapcar (lambda (row)
                               (let* ((url (nth 0 row))
                                      (title (nth 1 row))
                                      (display-url (truncate-string-to-width url 50 0 ?\ )))
                                 (cons
                                  (format "%s %s"
                                          display-url
                                          (propertize title
                                                      'face 'marginalia-value))
                                  url)))
                             history))
         (completion-table
          (lambda (string pred action)
            (if (eq action 'metadata)
                `(metadata
                  (display-sort-function . identity)
                  (cycle-sort-function . identity)
                  (category . qutebrowser-history)
                  (annotation-function . nil))
              (complete-with-action action candidates string pred))))
         (selected (completing-read "Choose URL from history: " completion-table nil nil)))
    ;; Return the URL of the selected candidate
    (cdr (or (assoc selected candidates)
             (cons nil selected)))))

(defun launch-url-in-qutebrowser--internal (target)
  (let ((url (select-from-qutebrowser-history))
        (pipe (getenv "QUTE_FIFO"))
        (flag (pcase target
                    ('window "-w")
                    ('tab "-t")
                    ('private-window "-p"))))
    (if pipe
        (write-region (format "open %s %s" flag url) nil pipe t)
      (start-process "qutebrowser" nil "qutebrowser" "--target" (symbol-name target) url))))

(defun launch-url-in-qutebrowser ()
  (interactive)
  (launch-url-in-qutebrowser--internal 'auto))

(defun launch-url-in-qutebrowser-tab ()
  (interactive)
  (launch-url-in-qutebrowser--internal 'tab))

(defun launch-url-in-qutebrowser-window ()
  (interactive)
  (launch-url-in-qutebrowser--internal 'window))

(defun launch-url-in-qutebrowser-private ()
  (interactive)
  (launch-url-in-qutebrowser--internal 'private))
