(use-modules (gnu))

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
 (timezone "GMT"))
