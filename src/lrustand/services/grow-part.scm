(define-module (lrustand services grow-part)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 curried-definitions)
  #:export (grow-part-configuration
            grow-part-configuration?

            grow-part-shepherd-service
            grow-part-service-type))

(define-configuration/no-serialization grow-part-configuration
  (device
   (string "/dev/null")
   "")
  (part-number
   (number -999999)
   "")
  (partition
   (string "/dev/null")
   "")
  (size
   (string "100%")
   ""))

(define grow-part-shepherd-service
  (match-record-lambda <grow-part-configuration>
    (device part-number partition size)
    (list (shepherd-service
           (provision '(grow-part))
           (documentation "")
           (requirement '())
           (start #~(make-forkexec-constructor
                      (list "/bin/sh" "-c"
                            (format #f "echo yes | ~a ~a ---pretend-input-tty 'resizepart ~a ~a' quit; ~a; ~a ~a"
                                    (string-append #$parted "/sbin/parted")
                                    #$device
                                    #$part-number
                                    #$size
                                    (string-append #$parted "/sbin/partprobe")
                                    (string-append #$e2fsprogs "/sbin/resize2fs")
                                    #$partition))))
           (stop #~(make-kill-destructor))
           (one-shot? #t)
           (respawn? #f)))))

(define grow-part-service-type
  (service-type
   (name 'grow-part)
   (extensions
    (list (service-extension shepherd-root-service-type
                             grow-part-shepherd-service)))
   (default-value (grow-part-configuration))
   (description
    "Grow partition to fill available space.")))
