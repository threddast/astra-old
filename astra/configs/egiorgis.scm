(define-module (astra configs egiorgis)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (rde features base)
  #:use-module (rde features gnupg)
  #:use-module (rde features bittorrent)
  #:use-module (rde features mail)
  #:use-module (astra utils)
  #:use-module (astra configs)
  #:use-module (astra features browsers))

(define-public %user-features
  (append
   (list
    (feature-user-info
     #:user-name "egiorgis"
     #:full-name "Erik Giorgis"
     #:email "egiorgis@egiorg.is")
    (feature-transmission)
    (feature-isync)
    (feature-firefox
     #:default-browser? #t))
   %astra-base-features))
