(define-module (engstrand features xorg)
               #:use-module (rde features)
               #:use-module (rde features predicates)
               #:use-module (engstrand packages engstrand-utils)
               #:use-module (guix gexp)
               #:use-module (gnu services)
               #:use-module (gnu home-services)
               #:use-module (gnu home-services base)
               #:export (feature-xorg-dwm))

(define %xorg-libinput-config
  "
  Section \"InputClass\"
  Identifier \"Touchpads\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsTouchPad \"on\"
  Option \"DisableWhileTyping\" \"on\"
  Option \"NaturalScrolling\" \"true\"
  EndSection
  Section \"InputClass\"
  Identifier \"Keyboards\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsKeyboard \"on\"
  EndSection
  ")

(define %base-xorg-dwm-system-packages
  '("chili-sddm-theme" "engstrand-dwm"))

(define %base-xorg-dwm-home-packages
  '("engstrand-dmenu" "engstrand-dsblocks" "engstrand-st"))

(define* (feature-xorg-dwm
           #:key
           (sddm-theme "chili")
           (extra-config '())
           (base-extra-config (list %xorg-libinput-config)))
         "Sets up xorg with SDDM (display manager), dwm, dsblocks, dmenu and st."

         (ensure-pred string? sddm-theme)
         (ensure-pred list-of-strings? extra-config)
         (ensure-pred list-of-strings? base-extra-config)

         (define (get-home-services config)
           "Return a list of home-services required by xorg and dwm."
           (list
             (simple-service
               'add-xorg-dwm-home-packages-to-profile
               home-profile-service-type
               %base-xorg-dwm-home-packages)
             ; TODO: Consider making this script inline to skip the extra package depenendcy
             (simple-service
               'xorg-dwm-bootstrap home-run-on-first-login-service-type
               #~(system* #$(file-append engstrand-utils "/bin/bootstrap")))))

         (define (get-system-services config)
           "Return a list of system services required by xorg and dwm."
           (require-value 'desktop-services config)
           (require-value 'keyboard-layout config)
           (list
             (simple-service
               'add-xorg-dwm-system-packages-to-profile
               profile-service-type
               %base-xorg-dwm-system-packages)
             (service sddm-service-type
                      (sddm-configuration
                        (theme sddm-theme)
                        (xorg-configuration
                          (xorg-configuration
                            (keyboard-layout (get-value 'keyboard-layout config)
                                             (extra-config (append extra-config
                                                                   base-extra-config)))))))))
         (feature
           (name 'xorg-dwm)
           (home-services-getter get-home-services)
           (system-services-getter get-system-services)))