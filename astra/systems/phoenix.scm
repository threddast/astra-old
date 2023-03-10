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
      (uuid "d17ee161-a77e-456d-b2dc-3c07aa9f61f9"
            'ext4))
     (type "ext4"))
    (file-system
     (mount-point "/boot/efi")
     (device (uuid "124B-646C" 'fat32))
     (type "vfat")))
   #:swap-devices
   (list
    (swap-space
     (target (uuid "9b242425-fd79-43a5-ad42-b217e9e3ea2c")))))))
