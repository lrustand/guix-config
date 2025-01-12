;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((scheme-mode
  .
  ((geiser-guile-binary . ("guix" "repl"))
   (eval . (add-to-list 'geiser-guile-load-path
                        (locate-dominating-file
                         default-directory ".dir-locals.el")
                        t)))))
