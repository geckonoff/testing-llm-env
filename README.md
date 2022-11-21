# Building an Ubuntu image with Packer on MacOS with QEMU and hypervisor-framework

Fetching ubuntu cloud image from https://cloud-images.ubuntu.com/.


Then using the QEMU backend of Packer to customize the image and build a new 
image out of it:
- https://packer.io
- https://developer.hashicorp.com/packer/plugins/builders/qemu


QEMU is capable of using the MacOS hypervisor-framework to run vm-s with the MacOS-native 
hypervisor:
- https://developer.apple.com/documentation/hypervisor
- https://wiki.qemu.org/Features/HVF


The build mounts the cloud image of ubuntu, as a system disk, then an initial cloud-init
config is run from a cdrom mount to set up a provisioning user so packer can log into
the instance and do it's thing:
- https://cloudinit.readthedocs.io/en/0.7.8/topics/datasources.html#no-cloud
