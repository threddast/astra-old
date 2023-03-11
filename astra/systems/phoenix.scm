(define-module (astra systems phoenix)
  #:use-module (astra utils)
  #:use-module (astra systems)
  #:use-module (guix gexp)
  #:use-module (rde features system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices))

(define-public %system-features
 (list
  (feature-host-info
   #:host-name "phoenix"
   #:timezone %astra-timezone
   #:locale %astra-locale)
  (feature-bootloader)
  (feature-file-systems
   #:file-systems
   (list
    (file-system
     (mount-point "/")
     (device
      (uuid "36531b8d-0cd1-4164-9725-a5a4094c1840"
            'ext4))
     (type "ext4"))
    (file-system
     (mount-point "/boot/efi")
     (device (uuid "8202-E8AC" 'fat32))
     (type "vfat")))
   #:swap-devices
   (list
    (swap-space
     (target (uuid "5d88bf77-d8bb-4690-bb9b-d2656fbbda90")))))))
