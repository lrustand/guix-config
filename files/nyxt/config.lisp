(in-package #:nyxt-user)

;;; Reset ASDF registries to allow loading Lisp systems from
;;; everywhere.
(reset-asdf-registries)

;;(start-slynk)


(define-configuration web-buffer
  ((default-modes
    (append '(nyxt/mode/vi:vi-normal-mode nyxt/mode/blocker:blocker-mode) %slot-value%))))

(define-command-global my/follow-hint nil (progn (nyxt/mode/hint:follow-hint) (nyxt/mode/prompt-buffer:toggle-suggestions-display)))

(define-configuration :document-mode
  "Add basic keybindings."
  ((keyscheme-map
    (keymaps:define-keyscheme-map
     "custom" (list :import %slot-value%)
     ;; If you want to have VI bindings overriden, just use
     ;; `scheme:vi-normal' or `scheme:vi-insert' instead of
     ;; `scheme:emacs'.
     nyxt/keyscheme:vi-normal
     (list "J"     'switch-buffer-next
           "K"     'switch-buffer-previous
           "r"     'reload-buffer
           "C-x b" 'switch-buffer
           "M-x"   'execute-command
           "g i"   'nyxt/mode/document:focus-first-input-field
           "C-h k" 'describe-key
           "C-h a" 'describe-any
           "C-h m" 'describe-mode
           "C-h s" 'describe-slot
           "C-h o" 'describe-object
           "C-h c" 'describe-command
           "C-h f" 'describe-function
           "C-h v" 'describe-variable
           )))))

(define-configuration nyxt/mode/hint:hint-mode
  ((nyxt/mode/hint:hinting-type :emacs)
   (nyxt/mode/hint:hints-alphabet "kdjflsgha")))

;;(define-configuration browser
;;  ;; Enable --remote --eval code evaluation.
;;  ((remote-execution-p t)
;;   (external-editor-program
;;    (list "emacsclient" "-nw" "-a" ""))))


(define-command-global custom-follow-hint ()
  "Experimental prompt for element hints and open them in the current buffer."
  (prompt :prompt "Interact with element"
          :extra-modes (list 'nyxt/mode/hint-prompt-buffer:hint-prompt-buffer-mode)
          :auto-return-p t
          :history nil
          :height :fit-to-prompt
          :hide-suggestion-count-p nil
          :sources
          (make-instance
           'nyxt/mode/hint::hint-source
           :enable-marks-p t
           :filter-preprocessor
           (lambda (suggestions source input)
             (declare (ignore source))
             (loop for suggestion in suggestions
                   for hint = (prompter:value suggestion)
                   for hinted-element-id = (nyxt/dom:get-nyxt-id hint)
                   if (str:starts-with-p input
                                         (prompter:attributes-default suggestion)
                                         :ignore-case t)
                     do (nyxt/mode/hint::set-hint-visibility hint "visible")
                     and do (when (nyxt/mode/hint::show-hint-scope-p (find-submode 'nyxt/mode/hint:hint-mode))
                              (ps-eval
                                (nyxt/ps:add-class-nyxt-id hinted-element-id
                                                           "nyxt-element-hint")))
                     and do (nyxt/mode/hint::dim-hint-prefix hint (length input))
                     and collect suggestion
                   else do (nyxt/mode/hint::set-hint-visibility hint "hidden")
                        and do (when (nyxt/mode/hint::show-hint-scope-p (find-submode 'nyxt/mode/hint:hint-mode))
                                 (ps-eval
                                   (nyxt/ps:remove-class-nyxt-id hinted-element-id
                                                                 "nyxt-element-hint")))))
           :actions-on-current-suggestion
           (list (lambda-command focus* (element)
                   (nyxt/dom:focus-select-element element)
                   nil))
           :actions-on-return
           (list (lambda-command click* (elements)
                   (dolist (element (rest elements))
                     (nyxt/dom:click-element element))
                   (nyxt/dom:click-element (first elements))
                   nil)
                 (lambda-command focus* (elements)
                   (dolist (element (rest elements))
                     (nyxt/dom:focus-select-element element))
                   (nyxt/dom:focus-select-element (first elements))
                   nil))
           :constructor
           (lambda (source)
             (declare (ignore source))
             (nyxt/mode/hint::add-hints
              :selector "a, button, input, textarea, details, select")))
          :after-destructor (lambda () (with-current-buffer (current-buffer)
                                         (nyxt/mode/hint::remove-hints)))))
