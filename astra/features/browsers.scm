(define-module (astra features browsers)
  #:use-module (ice-9 ftw)
  #:use-module (srfi srfi-1)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (nongnu packages mozilla)
  #:use-module (gnu packages web-browsers)
  #:use-module (astra utils)
  #:export (feature-firefox))

(define* (feature-firefox
          #:key
          (default-browser? #t))
  "Setup Firefox."

  (ensure-pred boolean? default-browser?)

  (define (get-home-services config)
    "Return a list of home services required by Firefox."
    (make-service-list
     (if default-browser?
         (simple-service
          'set-firefox-environment-variable
          home-environment-variables-service-type
          `(("BROWSER" . ,(file-append firefox/wayland "/bin/firefox")))))
     (simple-service
      'add-firefox-home-packages-to-profile
      home-profile-service-type
      (list firefox/wayland))))

  (feature
   (name 'firefox)
   (home-services-getter get-home-services)))
