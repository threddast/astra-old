;; This module is responsible for configuring an operating system,
;; i.e. kernel, microcode, hostname, keyboard layout, etc.
;;
;; Base packages, services and other features should be defined in
;; engstrand/configs, or in one of the custom configs at engstrand/configs/.
(define-module (astra systems)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features keyboard)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system file-systems)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (
            %astra-timezone
            %astra-locale
            ;; %astra-kernel-arguments
            %astra-keyboard-layout
            %astra-initial-os
            %astra-system-base-features))

(define-public %astra-timezone "Europe/Zurich")
(define-public %astra-locale "en_US.utf8")

;; (define-public %astra-kernel-arguments
;;   (list "modprobe.blacklist=pcspkr,snd_pcsp"
;;         "quiet"))

(define-public %astra-keyboard-layout
  (keyboard-layout "us" "colemak_dh"))
                   ;; #:options
                   ;; '("grp:alt_shift_toggle" "grp_led:caps" "caps:escape")))

(define-public %astra-initial-os
  (operating-system
   (host-name "astra")
   (locale %astra-locale)
   (timezone %astra-timezone)
   (kernel linux)
   (firmware (list linux-firmware))
   (initrd microcode-initrd)
   ;; (kernel-arguments %astra-kernel-arguments)
   (keyboard-layout %astra-keyboard-layout)
   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))
   (services '())
   (file-systems (cons* (file-system
                          (mount-point "/boot/efi")
                          (device (uuid "124B-646C"
                                        'fat32))
                          (type "vfat"))
                        (file-system
                          (mount-point "/")
                          (device (uuid
                                   "d17ee161-a77e-456d-b2dc-3c07aa9f61f9"
                                   'ext4))
                          (type "ext4"))
                        %base-file-systems))
          ;; (sudoers-file #f)
   (issue "This is the GNU/Engstrand system. Welcome.\n")))

(define-public %astra-system-base-features
  (list
   (feature-keyboard
    #:keyboard-layout %astra-keyboard-layout)))
