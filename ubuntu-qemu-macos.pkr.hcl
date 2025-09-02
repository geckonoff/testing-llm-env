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

variable "STIP" {
  type    = string
  default = "192.168.122.101"
}

variable "GW" {
  type    = string
  default = "192.168.122.1"
}

variable "DNS" {
  type    = string
  default = "192.168.178.1"
  description = "DNS servers for static network configuration"
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
      "--extra-vars", "ansible_ssh_pass=packer ansible_become_pass=packer rocm_version=${var.ROCMVER} amdgpu_install_version=${var.AMDGPUVER} ubuntu_name=${var.UBNAME} ubuntu_num=${var.UBNUM} static_ip=${var.STIP} gateway=${var.GW} dns_servers=${var.DNS}"
    ]
    user = "packer"
  }

  # === Post-processor: изменяем владельца и права ===
  post-processors {
    post-processor "shell-local" {
      inline = [
        "echo 'Fixing ownership and permissions for nfsuser...'",
        "sudo chown -R nfsuser:1001 build/${var.VM_NAME}",
        "sudo chmod -R 777 build/${var.VM_NAME}",
        "sudo chmod 664 build/${var.VM_NAME}/*.qcow2"
      ]

      # Выполнять только если нужно (опционально)
      only = ["qemu.macos"]
    }
  }
}
