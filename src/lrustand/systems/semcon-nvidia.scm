(define-module (lrustand systems semcon-nvidia)
  #:use-module (lrustand systems semcon)
  #:use-module (lrustand home)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu services nvidia)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)
  #:use-module (guix packages)
  #:use-module (guix transformations))


;this can be inlined as it's only called once
(define transform
 (options->transformation
  '((with-graft . "mesa=nvda"))))

(define-public %semcon-nvidia-home-environment
  (home-environment
    (inherit %semcon-home-environment)
    (packages
     (cons*
      (transform qutebrowser-with-tldextract)
      (delete qutebrowser-with-tldextract
      %lr/default-home-packages)))))

(define-public %semcon-nvidia-operating-system
  (operating-system (inherit %semcon-operating-system)

    (kernel linux-lts)
    (kernel-loadable-modules (list nvidia-module))

    (kernel-arguments (append
			'("modprobe.blacklist=pcspkr,snd_pcsp,nouveau")
			%default-kernel-arguments))

    (services
      (cons*

       ;; This can be removed when nvidia is updated to 535
       ;; https://gitlab.com/nonguix/nonguix/-/merge_requests/328
       (simple-service 'create-nvidiactl shepherd-root-service-type
        (list
         (shepherd-service
          (documentation "Create /dev/nvidiactl.")
          (provision '(nvidiactl))
          (requirement '(nvidia))
          (one-shot? #t)
          (start #~(make-forkexec-constructor
                    (list #$(file-append coreutils "/bin/mknod")
                          "-m" "666" "/dev/nvidiactl" "c" "195" "255")))
          (stop #~(make-forkexec-constructor
                   (list #$(file-append coreutils "/bin/rm")
                         "-f" "/dev/nvidiactl"))))))

       (service nvidia-service-type)

       (modify-services %semcon-services
         (xorg-server-service-type config => (xorg-configuration
          (inherit config)
          (modules (cons* nvidia-driver %default-xorg-modules))
          (server (transform xorg-server))
          (drivers '("nvidia")))))))))

(if (and (string=? "home" (cadr (command-line)))
         (string=? "reconfigure" (caddr (command-line))))
    %semcon-nvidia-home-environment
    %semcon-nvidia-operating-system)
