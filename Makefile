all: hello.nar /etc/guix/signing-key.pub Makefile
	qemu-system-x86_64 -enable-kvm -m 256 \
	  "$$(guix system vm-image config.scm)" \
	  -drive format=raw,readonly,file=hello.nar,index=0,if=ide,index=1,media=disk \
	  -drive format=raw,readonly,file=/etc/guix/signing-key.pub,index=0,if=ide,index=2,media=disk

%.nar: Makefile
	guix archive --export --recursive $* > $@
