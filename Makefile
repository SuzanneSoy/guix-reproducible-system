tmp_image := $(shell echo $$$$)

all: hello.nar signing-key.pub vm-image Makefile
	qemu-img create -f qcow2 -o backing_file=vm-image vm-image-${tmp_image}
# TODO: qcow2: make a derived image.
	qemu-system-x86_64 -enable-kvm -m 256 \
	  vm-image-${tmp_image} \
	  -drive format=raw,readonly,file=hello.nar,index=0,if=ide,index=1,media=cdrom \
	  -drive format=raw,readonly,file=signing-key.pub,index=0,if=ide,index=2,media=cdrom
	rm vm-image-${tmp_image}

%.nar: Makefile
	guix archive --export --recursive $* > $@

signing-key.pub: /etc/guix/signing-key.pub Makefile
	cp $< $@
	chmod +w $@

.PHONY: rebuild
rebuild: config.scm Makefile
	ln -s "$$(guix system vm-image config.scm)" vm-image

vm-image: config.scm # Makefile
	ln -s "$$(guix system vm-image config.scm)" vm-image
