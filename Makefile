SHELL = bash -euET -o pipefail -c
tmp_image := $(shell echo $$$$)

all: hello.nar hello.sizes signing-key.pub vm-image Makefile
	qemu-img create -f qcow2 -o backing_file=vm-image vm-image-${tmp_image}
# TODO: qcow2: make a derived image.
	qemu-system-x86_64 -enable-kvm -m 256 \
	  vm-image-${tmp_image} \
	  -drive format=raw,file=hello.sizes,if=ide,index=1,media=disk \
	  -drive format=raw,file=to-be-run-in-vm.sh,if=ide,index=2,media=disk \
	  -drive format=raw,file=hello.nar,if=ide,index=3,media=disk \
	  # -drive format=raw,file=signing-key.pub,if=ide,index=4,media=disk
	rm vm-image-${tmp_image}

%.sizes: %.nar signing-key.pub Makefile
	printf "%020d\\n%020d\\n%020d\\n%$$((512-((20+1)*3)-1))s\\n" \
	  "$$(wc -c "to-be-run-in-vm.sh" | sed -e 's/^[[:space:]]*\([0-9][0-9]*\)[[:space:]].*$$/\1/')" \
	  "$$(wc -c "$*.nar" | sed -e 's/^[[:space:]]*\([0-9][0-9]*\)[[:space:]].*$$/\1/')" \
	  "$$(wc -c "signing-key.pub" | sed -e 's/^[[:space:]]*\([0-9][0-9]*\)[[:space:]].*$$/\1/')" \
	  "" \
	  > $@

%.nar: Makefile
	guix archive --export --recursive '$*' > '$@'

signing-key.pub: /etc/guix/signing-key.pub Makefile
	cp '$<' '$@'
	chmod +w '$@'

vm-image: config.scm Makefile
	rm -f '$@'
	ln -sf "$$(guix system vm-image config.scm)" '$@'
