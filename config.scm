(use-modules (gnu)
             (gnu services shepherd))

(define (my-service)
  (shepherd-service
   (documentation "This command is executed when the GUIX system boots.")
   (provision '(my-stuff))
   (start #~(lambda ()
              (system* "seq 1000")))))

(operating-system
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (target "/dev/sdX")))
 (host-name "hostname")
 (file-systems
  (cons (file-system
         (device "/dev/sdX")
         (mount-point "/")
         (type "ext4"))
        %base-file-systems))
 (services (cons (my-service)
                 %base-services))
 (timezone "GMT"))
