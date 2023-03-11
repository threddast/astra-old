(define-module (astra reconfigure)
  #:use-module (ice-9 match)
  #:use-module (ice-9 exceptions)
  #:use-module (ice-9 pretty-print)
  #:use-module (gnu system)
  #:use-module (gnu system accounts)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (astra systems)
  #:export (make-config))

;; Allows dynamic loading of configuration modules based on file name.
(define* (dynamic-load sub mod var-name #:key (throw? #t))
  (let ((var (module-variable
              (resolve-module `(astra ,sub ,(string->symbol mod))) var-name)))
    (if (or (not var) (not (variable-bound? var)))
        (when throw?
          (raise-exception
           (make-exception-with-message
            (string-append "reconfigure: could not load module '" mod "'"))))
        (variable-ref var))))

;; Finds a list of needed user supplementary groups for feature with
;; a value of name. Returns an empty list if no groups are found.
(define (get-feature-kernel-arguments name config)
  (let ((arguments (get-value name config)))
    (if arguments arguments '())))

;; Create a system or home configuration based on some parameters.
;; Generally, you want to call this procedure with no arguments.
(define* (make-config
          #:key
          (user (getenv "RDE_USER"))
          (system (gethostname))
          (target (getenv "RDE_TARGET"))
          (initial-os %astra-initial-os))

  (ensure-pred string? user)
  (ensure-pred string? system)
  (ensure-pred operating-system? initial-os)

  (define %user-features (dynamic-load 'configs user '%user-features))
  ;; (define %user-colorscheme (dynamic-load 'configs user '%user-colorscheme #:throw? #f))
  (define %system-features (dynamic-load 'systems system '%system-features))

  ;; All is good, create the configuration
  (define %generated-config
    (rde-config
     (initial-os initial-os)
     (features
       (append %user-features
               %astra-system-base-features
               %system-features))))


  (define %astra-home
    (rde-config-home-environment %generated-config))

  (define %astra-system
    (operating-system
     (inherit (rde-config-operating-system %generated-config))
     (kernel-arguments
      (append
       (get-value
        'kernel-arguments %generated-config
        (operating-system-user-kernel-arguments initial-os))
       (get-feature-kernel-arguments 'kernel-arguments-radios %generated-config)))
     (issue (operating-system-issue initial-os))))

  (match target
    ("home" %astra-home)
    ("system" %astra-system)
    (_ %astra-system)))
