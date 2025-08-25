.PHONY: all
all: build/ubuntu22.04_rocm_5.7.3.qcow2

.PHONY: clean
clean:
	rm -rf build

build/cidata.iso: cidata/meta-data cidata/user-data
	mkdir -p build
	rm -rf build/cidata.iso
	hdiutil makehybrid -o build/cidata.iso cidata -iso -joliet

.PHONY: ansible-deps
ansible-deps:
	ansible-galaxy install -r ansible/requirements.yml -p ansible/roles

.PHONY: packer
build/ubuntu22.04_rocm_5.7.3.qcow2: ubuntu-qemu-macos.pkr.hcl build/cidata.iso ansible-deps
	mkdir -p build
	rm -rf build/ubuntu22.04_rocm_5.7.3.qcow2
	packer build ubuntu-qemu-macos.pkr.hcl
