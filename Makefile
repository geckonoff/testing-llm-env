.PHONY: all 
all: build/packer-ubuntu-22.04-amd64

.PHONY: clean
clean:
	rm -rf build

build/cidata.iso: cidata/meta-data cidata/user-data
	mkdir -p build
	rm -rf build/cidata.iso
	hdiutil makehybrid -o build/cidata.iso cidata -iso -joliet

.PHONY: packer
build/packer-ubuntu-22.04-amd64: ubuntu-qemu-macos.pkr.hcl build/cidata.iso
	mkdir -p build
	rm -rf build/packer-ubuntu-22.04-amd64
	packer build ubuntu-qemu-macos.pkr.hcl
