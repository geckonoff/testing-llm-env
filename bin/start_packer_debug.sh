PACKER_LOG=1 packer build -on-error=ask ubuntu-qemu-macos.pkr.hcl 2>&1 | tee packer-debug.log
