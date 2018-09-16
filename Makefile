SHELL = bash -euET -o pipefail -c
tmp_image := $(shell echo $$$$)

all: hello.tar hello.sizes vm-image to-be-run-in-vm.sh Makefile
	qemu-img create -f qcow2 -o backing_file=vm-image vm-image-tmp-${tmp_image}
# TODO: qcow2: make a derived image.
	qemu-system-x86_64 -enable-kvm -m 4096 -nographic \
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
	guix archive --export --recursive '$*' $$(guix build --source --sources=transitive '$*' $$(for i in \
	  binutils-2.23.2.tar.xz \
	  bison-3.0.4.tar.xz \
	  gc-7.6.4.tar.gz \
	  gcc-4.8.2.tar.xz \
	  glibc-2.18.tar.xz \
	  guile-2.0.9.tar.xz \
	  gcc-4.9.4.tar.xz \
	  gettext-0.19.8.1.tar.gz \
	  gmp-6.1.2.tar.xz \
	  guile-2.2.3.tar.xz \
	  libatomic_ops-7.6.4.tar.gz \
	  libffi-3.2.1.tar.gz \
	  libtool-2.4.6.tar.xz \
	  libunistring-0.9.9.tar.xz \
	  m4-1.4.18.tar.xz \
	  perl-5.26.1.tar.gz \
	  pkg-config-0.29.2.tar.gz \
	  static-binaries.tar.xz \
	  texinfo-6.5.tar.xz \
	  zlib-1.2.11.tar.gz; do \
	    echo /gnu/store/*-$$i.drv; \
	  done) | sort -u) > '$@'

%.tar: %.nar signing-key.pub Makefile
	tar -cf '$@' '$*.nar' signing-key.pub

signing-key.pub: /etc/guix/signing-key.pub Makefile
	cp '$<' '$@'
	chmod +w '$@'

vm-image: config.scm Makefile
	rm -f '$@'
	ln -sf "$$(guix system vm-image --image-size=8G config.scm)" '$@'

clean:
	rm -f vm-image vm-image-tmp-* signing-key.pub \
	  hello.nar hello.tar hello.sizes
