UBNAME ?= focal
UBNUM ?= 20.04
ROCMVER ?= 5.7.3
AMDGPUVER ?= 5.7.50701-1
ISO_FILENAME = ubuntu-$(UBNUM)-server-cloudimg-amd64.img
VM_NAME ?= packer-ubuntu-$(UBNUM)-rocm-$(ROCMVER)-amd64
ISO_URL ?= https://cloud-images.ubuntu.com/releases/releases/$(UBNUM)/release/ubuntu-$(UBNUM)-server-cloudimg-amd64.img
ISO_CHECKSUM ?= sha256:$(shell curl -sL https://cloud-images.ubuntu.com/releases/$(UBNUM)/release/SHA256SUMS | grep "$(ISO_FILENAME)" | awk '{print $$1}')

PKR_VAR_UBNAME       = $(UBNAME)
PKR_VAR_UBNUM        = $(UBNUM)
PKR_VAR_ROCMVER      = $(ROCMVER)
PKR_VAR_AMDGPUVER    = $(AMDGPUVER)
PKR_VAR_VM_NAME      = $(VM_NAME)
PKR_VAR_ISO_URL      = $(ISO_URL)
PKR_VAR_ISO_CHECKSUM = $(ISO_CHECKSUM)

# Экспорт переменных
export PKR_VAR_UBNAME
export PKR_VAR_UBNUM
export PKR_VAR_ROCMVER
export PKR_VAR_AMDGPUVER
export PKR_VAR_VM_NAME
export PKR_VAR_ISO_URL
export PKR_VAR_ISO_CHECKSUM

.PHONY: all clean ansible-deps print-vars

all: build/ubuntu-qcow2

print-vars:
	@echo "PKR_VAR_UBNAME: $(PKR_VAR_UBNAME)"
	@echo "PKR_VAR_UBNUM: $(PKR_VAR_UBNUM)"
	@echo "PKR_VAR_ROCMVER: $(PKR_VAR_ROCMVER)"
	@echo "PKR_VAR_AMDGPUVER: $(PKR_VAR_AMDGPUVER)"
	@echo "PKR_VAR_VM_NAME: $(PKR_VAR_VM_NAME)"
	@echo "PKR_VAR_ISO_URL: $(PKR_VAR_ISO_URL)"
	@echo "PKR_VAR_ISO_CHECKSUM: $(PKR_VAR_ISO_CHECKSUM)"

clean:
	rm -rf build

build/cidata.iso: cidata/meta-data cidata/user-data
	mkdir -p build
	rm -f build/cidata.iso
	hdiutil makehybrid -o build/cidata.iso cidata -iso -joliet

ansible-deps:
	ansible-galaxy install -r ansible/requirements.yml -p ansible/roles

build/ubuntu-qcow2: build/cidata.iso ansible-deps
	packer build ubuntu-qemu-macos.pkr.hcl
