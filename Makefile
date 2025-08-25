.PHONY: all clean ansible-deps

all: build/ubuntu-qcow2

clean:
	rm -rf build

build/cidata.iso: cidata/meta-data cidata/user-data
	mkdir -p build
	rm -f build/cidata.iso
	hdiutil makehybrid -o build/cidata.iso cidata -iso -joliet

ansible-deps:
	ansible-galaxy install -r ansible/requirements.yml -p ansible/roles

build/ubuntu-qcow2: build/cidata.iso ansible-deps
	packer build ubuntu-qemu-macos-u-20.0.4-r-5.7.3.pkr.hcl
