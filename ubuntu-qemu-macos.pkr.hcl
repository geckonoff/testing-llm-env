packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "ROCMVER" {
  type    = string
  default = "5.7.1"
}

variable "AMDGPUVER" {
  type    = string
  default = "5.7.50701-1"
}

variable "UBNAME" {
  type    = string
  default = "focal"
}

variable "UBNUM" {
  type    = string
  default = "20.04"
}

variable "VM_NAME" {
  type    = string
  default = ""
}

variable "ISO_URL" {
  type    = string
  default = ""
}

variable "ISO_CHECKSUM" {
  type    = string
  default = ""
}

source "qemu" "macos" {
  vm_name           = "${var.VM_NAME}.qcow2"
  iso_url           = var.ISO_URL
  iso_checksum      = var.ISO_CHECKSUM
  disk_image        = true
  format            = "qcow2"
  output_directory  = "build/${var.VM_NAME}"
  machine_type      = "q35"
  accelerator       = "hvf"
  cpus              = 4
  memory            = "4096"
  headless          = true
  ssh_port          = 22
  ssh_username      = "packer"
  ssh_password      = "packer"
  ssh_wait_timeout  = "300s"
  qemuargs          = [["-cdrom", "build/cidata.iso"]]
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name = "macos"
  source "qemu.macos" {}

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = [
      "--extra-vars", "ansible_ssh_pass=packer ansible_become_pass=packer rocm_version=${var.ROCMVER} amdgpu_install_version=${var.AMDGPUVER} ubuntu_name=${var.UBNAME} ubuntu_num=${var.UBNUM}"
    ]
    user = "packer"
  }
}
