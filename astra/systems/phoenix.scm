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
     (mount-point "/boot/efi")
     (device (uuid "1ADC-28E8" 'fat32))
     (type "vfat"))
    (file-system
     (mount-point "/")
     (device
      (uuid "6c3ee1c8-6ee6-4142-b2bf-a370854f63e7"
            'ext4))
     (type "ext4")))
   #:swap-devices
   (list
    (swap-space
     (target (uuid "62f47965-ad3e-40a9-bb5e-46e4387fa449")))))))
