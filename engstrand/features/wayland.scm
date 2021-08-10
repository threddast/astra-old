(define-module (engstrand features wayland)
               #:use-module (rde features)
               #:use-module (rde features predicates)
               #:use-module (gnu services)
               #:use-module (gnu packages xdisorg)
               #:use-module (gnu packages terminals)
               #:use-module (gnu home-services)
               #:use-module (engstrand utils)
               #:use-module (engstrand systems)
               #:use-module (dwl-guile patches)
               #:use-module (dwl-guile home-service)
               #:export (
                         feature-wayland-dwl-guile
                         feature-wayland-bemenu
                         feature-wayland-foot
                         feature-wayland-mako

                         %engstrand-dwl-guile-patches
                         %engstrand-dwl-guile-config))

(define %engstrand-dwl-guile-patches
  (list %patch-xwayland
        %patch-alpha
        %patch-focusmon
        %patch-vanitygaps
        %patch-attachabove))

(define %engstrand-dwl-guile-config
  (dwl-config
    (terminal '("foot"))
    (natural-scrolling? #t)
    (xkb-rules %engstrand-keyboard-layout)
    (colors
      (dwl-colors
        (root '(0 0 1 1))))))

;; rewrite with match
(define (transform-bemenu-options lst)
  (define (make-cli-argument config-pair)
    (let ((argument (car config-pair)) (value (cdr config-pair)))
      (if (not value) ""
          (string-append "--" argument
                         (cond ((eq? value #t) "")
                               ((string? value) (string-append " " "'" value "'"))
                               ((number? value) (string-append " " (number->string value)))
                               (else (raise "invalid bemenu argument!")))))))
  (string-join (map make-cli-argument lst)))

; TODO: Add this feature AFTER adding all other features, e.g. mako, foot, bemenu, etc.
;       Doing this means that we can check if certain features are available and
;       add special configuration (for example keybindings).
(define* (feature-wayland-dwl-guile
           #:key
           (dwl-guile-configuration (home-dwl-guile-configuration)))
         "Setup dwl-guile."

         (ensure-pred home-dwl-guile-configuration? dwl-guile-configuration)

         (define (get-home-services config)
           "Return a list of home services required by dwl."
           (list
             (service home-dwl-guile-service-type
                      dwl-guile-configuration)))

         (feature
           (name 'wayland-dwl-guile)
           (home-services-getter get-home-services)))

(define* (feature-wayland-mako)
         "Setup mako, a lightweight notification daemon for Wayland"

         (define (get-home-services config)
           "Return a list of home services required by mako"
           (list
             (simple-service
               'add-mako-home-packages-to-profile
               home-profile-service-type
               (pkgs '("mako" "libnotify")))))

         ; TODO: Allow configuration using Guile.

         (feature
           (name 'wayland-mako)
           (home-services-getter get-home-services)))

(define* (feature-wayland-foot)
         "Setup foot terminal."

         (define (get-home-services config)
           "Return a list of home services required by foot."
           (list
             (simple-service
               'add-foot-home-packages-to-profile
               home-profile-service-type
               (pkgs '("foot")))))

         ; TODO: Allow configuration using Guile.

         (feature
           (name 'wayland-foot)
           (home-services-getter get-home-services)))

(define* (feature-wayland-bemenu
           #:key
           (options '()))
         "Setup bemenu."

         (define (get-home-services config)
           "Return a list of home services required by bemenu."
           (list
             (simple-service
               'add-bemenu-home-packages-to-profile
               home-profile-service-type
               (pkgs '("bemenu")))

             ; TODO: Convert options list into a configuration
             ;       and automatically transform when enabling feature.
             (simple-service
               'bemenu-options
               home-environment-variables-service-type
               `(("BEMENU_OPTS" . ,(string-append
                                     "\""
                                     (transform-bemenu-options
                                       '(("ignorecase" . #t)
                                         ("line-height" . 21)
                                         ("filter" . #f)
                                         ("wrap" . #f)
                                         ("list" . #f)
                                         ("prompt" . #f)
                                         ("prefix" . #f)
                                         ("index" . #f)
                                         ("password" . #f)
                                         ("scrollbar" . #f)
                                         ("ifne" . #f)
                                         ("fork" . #f)
                                         ("no-exec" . #f)
                                         ("bottom" . #f)
                                         ("grab" . #f)
                                         ("no-overlap" . #f)
                                         ("monitor" . #f)
                                         ("line-height" . 0)
                                         ("fn" . "'JetBrains Mono 10'")
                                         ("tb" . #f)
                                         ("tf" . #f)
                                         ("fb" . #f)
                                         ("ff" . #f)
                                         ("nb" . #f)
                                         ("nf" . #f)
                                         ("hb" . #f)
                                         ("hf" . #f)
                                         ("sb" . #f)
                                         ("sf" . #f)
                                         ("scb" . #f)
                                         ("scf" . #f)))
                                     "\""))))))

         (feature
           (name 'wayland-bemenu)
           (home-services-getter get-home-services)))
