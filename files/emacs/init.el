;; -*- lexical-binding: t; -*-

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
         '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

(use-package doom-modeline
  :ensure t
  :init
  (require 'doom-modeline)
  :config
  (doom-modeline-mode 1))

(use-package auto-dim-other-buffers
  :ensure t
  :init
  (auto-dim-other-buffers-mode 1))

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
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-terminal-cursor-changer
  :ensure t
  :config
  (unless (display-graphic-p)
          (require 'evil-terminal-cursor-changer)
          (evil-terminal-cursor-changer-activate)))

(use-package emacs
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path) ;; Fix tramp for Guix
  (add-hook 'prog-mode-hook
            (lambda ()
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

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-dark t))

(use-package dap-mode
  :ensure t)

(set-frame-font "DeJavu Sans Mono 10" nil t)

(use-package pcmpl-args
  :ensure t)

(use-package corfu
  :ensure t
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
  (corfu-popupinfo-mode 1)
  (global-corfu-mode))

(defun corfu-enable-in-minibuffer ()
  "Enable Corfu in the minibuffer."
  (when (local-variable-p 'completion-at-point-functions)
    ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
    (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                corfu-popupinfo-delay nil)
    (corfu-mode 1)))
(add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)

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
  :defer t)

(use-package yasnippet
  :ensure t
  :custom
  (yas-indent-line 'auto)
  (yas-also-auto-indent-first-line t)
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-latex
  :ensure t
  :init
  (require 'lsp-latex)

  :config
  (add-hook 'tex-mode-hook 'lsp)
  (add-hook 'latex-mode-hook 'lsp)
  (add-hook 'LaTeX-mode-hook 'lsp)

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
  :config
  (setq-default TeX-master "main") ; All master files called "main".
  :custom
  (TeX-view-program-list '(("Okular" "okular --noraise --unique file:%o#src%n%a")))
  (TeX-view-program-selection '((output-pdf "Okular"))))

(use-package git-gutter
  :ensure t
  :custom
  (git-gutter:hide-gutter t)
  (git-gutter:update-interval 2)
  (git-gutter:unchanged-sign " ")

  :config
  (add-to-list 'git-gutter:update-hooks 'focus-in-hook)
  (defun set-git-gutter-background ()
    (set-face-background 'git-gutter:unchanged (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:modified (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:added (face-attribute 'mode-line :background))
    (set-face-background 'git-gutter:deleted (face-attribute 'mode-line :background)))
  (add-hook 'server-after-make-frame-hook 'set-git-gutter-background)
  (add-hook 'window-setup-hook 'set-git-gutter-background)
  (global-git-gutter-mode 1))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)))

(use-package consult-projectile
  :ensure t
  :bind (("C-c p p" . consult-projectile-switch-project)
         ("C-c p f" . consult-projectile)))

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

(use-package geiser
  :ensure t
  :custom
  (geiser-default-implementation 'guile)
  (geiser-active-implementations '(guile))
  (geiser-implementations-alist '(((regexp "\\.scm$") guile))))

(use-package geiser-guile
  :ensure t
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
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
  (require 'mu4e)
  :config
  ;; Don't create tons of "draft" messages
  (add-hook 'mu4e-compose-mode-hook #'(lambda () (auto-save-mode -1)))
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

(use-package eat
  :ensure t
  :config
  (eat-eshell-mode))
  ;;:custom
  ;;(eshell-visual-commands nil))

(use-package vterm
  :ensure t)

(use-package multi-vterm
  :ensure t)

(use-package erc
  :custom
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 15)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-lurker-hide-list '("JOIN" "PART" "QUIT")))

(use-package erc-twitch
  :ensure t
  :after erc
  :config
  (erc-twitch-enable))

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :config
  (erc-hl-nicks-enable))

(use-package erc-image
  :ensure t
  :after erc
  :config
  (erc-image-enable))

(use-package goggles
  :ensure t
  :config
  (goggles-mode))

(use-package evil-goggles
  :ensure t
  :config
  (evil-goggles-mode))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(defun my/org-roam-get-title (file)
  (save-window-excursion
    (find-file file)
    (org-get-title)))

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

  ;; TODO only collapse DONE items if there are no TODO children
  (defun org-fold-all-done-entries ()
    "Close/fold all entries marked DONE."
    (interactive)
    (save-excursion
      (goto-char (point-max))
      (while (outline-previous-heading)
        (when (org-entry-is-done-p)
          (hide-entry)))))

  (defun org-advance ()
    (interactive)
    (when (buffer-narrowed-p)
    (beginning-of-buffer)
    (widen)
    (org-forward-heading-same-level 1))
      (org-narrow-to-subtree))

  (defun org-retreat ()
    (interactive)
    (when (buffer-narrowed-p)
      (beginning-of-buffer)
      (widen)
     (org-backward-heading-same-level 1))
     (org-narrow-to-subtree))
  (evil-define-key 'normal org-mode-map (kbd "J") 'org-advance)
  (evil-define-key 'normal org-mode-map (kbd "K") 'org-retreat))

(use-package org-contrib
  :ensure t)

(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-edna
  :ensure t
  :config
  (org-edna-mode 1))

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

(use-package org-roam
  :ensure t
  :demand t  ;; Ensure org-roam is loaded by default
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
  (org-roam-db-autosync-mode))

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

(use-package org-transclusion
  :ensure t)


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
(setq dired-listing-switches "-lAh --group-directories-first")
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; change all prompts to y or n
(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(defun set-line-number-background ()
  (set-face-background 'line-number (face-attribute 'mode-line :background)))
(add-hook 'server-after-make-frame-hook 'set-line-number-background)
(add-hook 'window-setup-hook 'set-line-number-background)

(windmove-default-keybindings)

(defun git-status ()
  (let ((default-directory (eshell/pwd)))
    (with-output-to-string
      (with-current-buffer standard-output
        (call-process "git" nil t nil "status" "--porcelain")))))

(defun git-status--dirty-p ()
  (not (string-blank-p (git-status))))

(add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color"))) 
(setq eshell-prompt-function '(lambda () (concat
  "\n"
  ;;(propertize (if venv-current-name (concat " (" venv-current-name ")\n")  "") 'face `(:foreground "#00dc00"))
  (propertize (format-time-string "[%H:%M, %d/%m/%y]\n" (current-time)) 'face '(:foreground "green" :bold))
  (if (= (user-uid) 0)
    (propertize (user-login-name) 'face '(:foreground "red" :bold))
    (propertize (user-login-name) 'face '(:foreground "green" :bold)))
  (propertize "@" 'face `(:foreground "default" :bold))
  (propertize (system-name) 'face `(:foreground "green" :bold))
  (propertize (concat " [" (eshell/pwd) "]") 'face `(:foreground "default" :bold))
  (when (magit-get-current-branch)
      (propertize (concat " [" (magit-get-current-branch)) 'face `(:foreground "default" :bold)))
      (when (git-status--dirty-p) (propertize "*" 'face `(:foreground "red" :bold)))
      (propertize "]" 'face `(:foreground "default" :bold))
  (propertize "\n")
  (propertize " ->" 'face '(:foreground "blue" :bold))
  (propertize " " 'face '(:foreground "default" :bold))
  )))
(setq eshell-prompt-regexp " -> ")

(setq eshell-visual-commands (append eshell-visual-commands
  '("ipython"
    "nvim"
    "neomutt"
    "tmux")))

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

(defun org-dblock-write:thesis-status (params)
  (let* ((date (plist-get params :date))
         (git-changes (shell-command-to-string (concat "cd ~/Documents/master/thesis; git diff --shortstat @{" date "T00:00:00} @{" date "T23:59:59} *.tex")))
         (pdf-pages (shell-command-to-string "cd ~/Documents/master/thesis; pdfinfo main.pdf | grep Pages:")))
    (insert "" pdf-pages)
    (insert "Git changes:" git-changes)))

(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; Use libvterm installed in Guix
(advice-add 'vterm-module-compile :around
            (lambda (f &rest r)
              (make-symbolic-link (expand-file-name "~/.guix-home/profile/lib/vterm-module.so")
                                  (file-name-directory (locate-library "vterm.el" t)) t)))

(defun insert-cut-here-start ()
  "Insert opening \"cut here start\" snippet."
  (interactive)
  (insert "--8<---------------cut here---------------start------------->8---"))

(defun insert-cut-here-end ()
  "Insert closing \"cut here end\" snippet."
  (interactive)
  (insert "--8<---------------cut here---------------end--------------->8---"))
