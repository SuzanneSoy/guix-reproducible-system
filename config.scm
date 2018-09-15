(use-modules (gnu)
             (gnu services shepherd)
             (gnu packages admin))

(define my-service
  (shepherd-service-type
   'run-commands-at-boot
   (lambda (x)
     (shepherd-service
      (documentation "This command is executed when the GUIX system boots.")
      (provision '(my-stuff))
      (start #~(lambda ()
                 (system (string-append "(read len < /dev/sdb; head -c $len < /dev/sdc | sh -s "
                                        #$shepherd
                                        ") > /dev/tty1"))))))))

(operating-system
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (target "/dev/sdX")
   (timeout 1)))
 (kernel-arguments '("console=ttyS0"))
 (host-name "hostname")
 (file-systems
  (cons (file-system
         (device "/dev/sdX")
         (mount-point "/")
         (type "ext4"))
        %base-file-systems))
 (services (cons (service my-service 42)
                 %base-services))
 (timezone "GMT"))
