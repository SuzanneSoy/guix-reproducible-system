SHELL = bash -euET -o pipefail -c
tmp_image := $(shell echo $$$$)

all: hello.tar hello.sizes vm-image to-be-run-in-vm.sh Makefile
	qemu-img create -f qcow2 -o backing_file=vm-image vm-image-tmp-${tmp_image}
# TODO: qcow2: make a derived image.
	qemu-system-x86_64 -enable-kvm -m 256 \
	  vm-image-tmp-${tmp_image} \
	  -drive format=raw,file=hello.sizes,if=ide,index=1,media=disk \
	  -drive format=raw,file=to-be-run-in-vm.sh,if=ide,index=2,media=disk \
	  -drive format=raw,file=hello.tar,if=ide,index=3,media=disk
	rm vm-image-tmp-${tmp_image}

%.sizes: %.tar signing-key.pub to-be-run-in-vm.sh Makefile
	printf "%020d\\n%020d\\n%$$((512-((20+1)*2)-1))s\\n" \
	  "$$(wc -c "to-be-run-in-vm.sh" | sed -e 's/^[[:space:]]*\([0-9][0-9]*\)[[:space:]].*$$/\1/')" \
	  "$$(wc -c "$*.tar" | sed -e 's/^[[:space:]]*\([0-9][0-9]*\)[[:space:]].*$$/\1/')" \
	  "" \
	  > '$@'

%.nar: Makefile
	guix archive --export --recursive '$*' $$(guix build --source --sources=transitive '$*') > '$@'

%.tar: %.nar signing-key.pub Makefile
	tar -cf '$@' '$*.nar' signing-key.pub

signing-key.pub: /etc/guix/signing-key.pub Makefile
	cp '$<' '$@'
	chmod +w '$@'

vm-image: config.scm Makefile
	rm -f '$@'
	ln -sf "$$(guix system vm-image config.scm)" '$@'

clean:
	rm -f vm-image vm-image-tmp-* signing-key.pub \
	  hello.nar hello.tar hello.sizes
