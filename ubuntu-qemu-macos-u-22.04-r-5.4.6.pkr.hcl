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
  default = "5.4.6"
}

variable "AMDGPUVER" {
  type    = string
  default = "5.4.50406-1"
}

variable "vm_name" {
  type    = string
  default = ""
}

locals {
  computed_vm_name = var.vm_name != "" ? var.vm_name : "packer-ubuntu-22.04-rocm-${var.ROCMVER}-amd64"
}

variable "iso_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS"
}

source "qemu" "macos" {
  vm_name           = var.vm_name
  iso_url           = var.iso_url
  iso_checksum      = var.iso_checksum
  disk_image        = true
  format            = "qcow2"
  output_directory  = "build/${local.computed_vm_name}"
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
      "--extra-vars", "ansible_ssh_pass=packer ansible_become_pass=packer rocm_version=${var.ROCMVER} amdgpu_install_version=${var.AMDGPUVER}"
    ]
    user = "packer"
  }
}
