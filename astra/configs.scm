(define-module (engstrand configs)
  #:use-module (guix gexp)
  #:use-module (gnu packages fonts)
  #:use-module (rde features)
  #:use-module (rde features xdg)
  #:use-module (rde features ssh)
  #:use-module (rde features base)
  #:use-module (rde features shells)
  #:use-module (rde features linux)
  #:use-module (rde features shellutils)
  #:use-module (rde features fontutils)
  #:use-module (rde features version-control)
  #:use-module (astra utils)
  #:use-module (astra systems)
  #:use-module (astra features nix)
  #:use-module (astra features state)
  #:use-module (astra features networking)
  #:export (
            %astra-base-system-packages
            %astra-base-home-packages
            %astra-base-features))

;; This module is responsible for creating the rde config.
;; It will define all the different base system services.
;;
;; Operating system configuration should be done in engstrand/systems.scm,
;; and computer specific settings in each corresponding file in engstrand/systems/.
(define %astra-base-system-packages
  (pkgs '("git" "nss-certs")))

;; Move some of the packages to separate features?
(define %astra-base-home-packages
  (pkgs '("curl" "htop" "ncurses"
          "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-extra")))

;; Dynamically create a configuration that can be reproduced
;; without having the correct environment variables set.
;; This is required for some commands to work, e.g. guix pull.
(define (make-entrypoint)
  (scheme-file "entrypoint.scm"
               #~(begin
                   (use-modules (astra reconfigure))
                   (make-config #:user #$(getenv "RDE_USER")
                                #:system #$(gethostname)))))

(define %astra-base-features
  (list
   (feature-base-services
    #:guix-substitute-urls (list "https://substitutes.nonguix.org")
    #:guix-authorized-keys (list (local-file "files/nonguix-signing-key.pub")))
   (feature-desktop-services)
   (feature-networking)
   ;; TODO: Move to systems/*.scm?
   (feature-git
    #:sign-commits? #t)
   (feature-fonts
    #:font-packages (list font-jetbrains-mono font-iosevka-aile)
    #:font-monospace (font "JetBrains Mono" #:size 13)
    #:font-sans (font "Iosevka Aile" #:size 13)
    #:font-serif (font "Iosevka Aile" #:size 13))
   (feature-pipewire)
   (feature-backlight)
   (feature-bash)
   (feature-zsh)
   (feature-ssh)
   (feature-xdg
    #:xdg-user-directories-configuration
    (home-xdg-user-directories-configuration
     (download "$HOME/downloads")
     (documents "$HOME/documents")
     (pictures "$HOME/images")
     (music "$HOME/music")
     (videos "$HOME/videos")
     (publicshare "$HOME")
     (templates "$HOME")
     (desktop "$HOME")))
   (feature-base-packages
    #:system-packages %astra-base-system-packages
    #:home-packages %astra-base-home-packages)
   ;; (feature-state-git
   ;;   #:repos
   ;;   `(("engstrand-config/utils" .
   ;;      "git@github.com:engstrand-config/utils.git")
   ;;     ("engstrand-config/home-dwl-service" .
   ;;      "git@github.com:engstrand-config/home-dwl-service.git")
   ;;     ("engstrand-config/farg" .
   ;;      "git@github.com:engstrand-config/farg.git")))
   (feature-dotfiles
    #:dotfiles
    `(
      (".nix-channels" ,(local-file "files/nix-channels"))
      (".config/guix/channels.scm" ,(local-file "channels.scm"))
      (".config/guix/config.scm" ,(make-entrypoint))))
   (feature-nix)))
