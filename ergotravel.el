(setq mugur-user-defined-keys
  '((H . caps)
    (lower . space)
    (raise . space)))

(let ((mugur-qmk-path       "~/code/keyboards/qmk_firmware")
      (mugur-keyboard-name   "ergotravel")
      (mugur-layout-name     "LAYOUT")
      (mugur-keymap-name     "test")
      (mugur-tapping-term    175))

 (mugur-mugur
  '(("base"
      -x- -x-   w    e   r   t   -x-    bspace y   u   i   o   -x-  -x-
       H   q    s    d   f   g   -x-    -x-    h   j   k   l    p   -x-
       S   a    x    c   v   b   -x-    -x-    n   m  ?\, dot  ?\;  ?\'
       M   z   -x-  -x-      G  lower   raise  C      -x- -x-  ?\/   S )

     ("lower"
      -x- -x-  ?\@  ?\# ?\$  ?\% -x-    delete ?\^  ?\&  ?\* ?\(   -x- -x-  
      ?\~ ?\!  -x-  -x- -x-  -x- -x-    ---    left down up  right ?\) ?\=
      --- -x-  -x-  -x- -x-  -x- -x-    -x-    -x-  -x-  -x- -x-   ?\- ?\+
      --- -x-  -x-  -x-      --- ---    ---    ---       -x- -x-   -x- --- )
 
     ("raise"
      -x- -x-   2    3   4   5   -x-    delete  6    7    8   9    -x- -x-  
      ?\`  1   -x-  -x- -x-  -x- -x-    ---    left down up  right  0  ?\|
      -x- -x-  -x-  -x- -x-  -x- -x-    -x-    -x-  -x-  -x- -x-   ?\- ?\+
      --- -x-  -x-  -x-      --- ---    ---    ---       -x- -x-   -x- --- )

     ("adjust"
      -x- -x-   2    3   4   5   -x-    delete  6    7    8   9    -x- -x-  
      ?\`  1   -x-  -x- -x-  -x- -x-    ---    left down up  right  0  ?\|
      -x- -x-  -x-  -x- -x-  -x- -x-    -x-    -x-  -x-  -x- -x-   ?\- ?\+
      --- -x-  -x-  -x-      --- ---    ---    ---       -x- -x-   -x- --- )
     )))
