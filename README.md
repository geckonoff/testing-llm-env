---

# 📦 Ubuntu + ROCm Image Builder with Packer & QEMU (macOS HVF)

This repository automates the creation of **custom Ubuntu cloud images with ROCm pre-installed**, using **Packer**, **QEMU**, and the **macOS Hypervisor.Framework (HVF)** for fast, native virtualization. It's designed for testing different combinations of **Ubuntu versions** and **ROCm versions** in a reproducible way.

---

## 🔧 Technologies

- **[Packer](https://packer.io)** – HashiCorp tool for building machine images.
- **[QEMU](https://www.qemu.org)** – Emulator with support for hardware acceleration via macOS **HVF** (`-accel hvf`).
- **[Hypervisor.Framework](https://developer.apple.com/documentation/hypervisor)** – Apple’s native hypervisor for high-performance VMs.
- **[cloud-init](https://cloudinit.readthedocs.io/en/latest/)** – Initial VM setup using `NoCloud` datasource via an ISO (`cidata.iso`).
- **[Ansible](https://ansible.com)** – System customization, including ROCm installation via the `rocm-install` role.

---

## 🎯 Purpose

Build ready-to-use **qcow2 images of Ubuntu with ROCm** installed, enabling:
- Fast testing of **different ROCm versions** (e.g., 5.7.3, 6.2.4).
- Validation across **multiple Ubuntu releases** (e.g., 20.04, 22.04).
- Reproducible CI/CD pipelines or local development environments.

---

## 🖼️ Base Image

Uses official **Ubuntu Cloud Images** from:
```
https://cloud-images.ubuntu.com/releases/
```

Examples:
- `ubuntu-20.04-server-cloudimg-amd64.img` (Focal)
- `ubuntu-22.04-server-cloudimg-amd64.img` (Jammy)

These are minimal, cloud-optimized images with cloud-init preconfigured.

---

## 🛠️ How It Works

1. **Download** the base Ubuntu cloud image.
2. Generate a `cidata.iso` (configdrive) with:
   - `meta-data`: Instance metadata (e.g., `instance-id`).
   - `user-data`: Cloud-init configuration to create a `packer` user for SSH access.
3. Launch QEMU VM using:
   - The cloud image as system disk.
   - `cidata.iso` as a CD-ROM (NoCloud datasource).
   - HVF acceleration for near-native performance.
4. Packer connects via SSH and runs Ansible to:
   - Install system packages.
   - Deploy **ROCm** via the `rocm-install` role.
5. VM is shut down and a clean `qcow2` image is saved in `build/`.

---

## 📦 Key Components

### `Makefile`
Handles automation:
- Downloads and checksum verification.
- Generates `cidata.iso`.
- Installs Ansible dependencies.
- Runs Packer with correct variables.

### `ubuntu-qemu-macos.pkr.hcl`
Packer configuration using the **QEMU builder**:
- Uses HVF acceleration: `accelerator = "hvf"`.
- Boots with `cidata.iso` via `qemuargs`.
- Connects via SSH using `packer`/`packer`.
- Runs Ansible provisioner.

### `ansible/roles/rocm-install`
Custom Ansible role to:
- Add AMD repositories.
- Install `rocm-opencl`, `rocm-dev`, or specific versions.
- Configure kernel modules and permissions.

---

## ⚙️ Configuration (Variables)

Default values in `ubuntu-qemu-macos.pkr.hcl`:

| Variable       | Default       | Description                         |
|----------------|---------------|-------------------------------------|
| `UBNAME`       | `focal`       | Ubuntu codename (e.g., jammy)       |
| `UBNUM`        | `20.04`       | Ubuntu version number               |
| `ROCMVER`      | `5.7.3`       | ROCm version to install             |
| `AMDGPUVER`    | `5.7.50701-1` | AMDGPU kernel driver version        |
| `VM_NAME`      | auto-generated| Output image directory name         |
| `ISO_URL`      | auto-built    | URL to Ubuntu cloud image           |
| `ISO_CHECKSUM` | auto-fetched  | SHA256 from Ubuntu’s checksum file  |

---

## 🚀 Quick Start

### 1. Prerequisites

Install on macOS:

```bash
# Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Required tools
brew install packer ansible qemu

# Initialize Packer plugins
packer init .
```

> ✅ Ensure your system supports HVF (Intel or Apple Silicon Mac).

---

### 2. Build Default Image

```bash
make all
```

This builds:
```
packer-ubuntu-20.04-rocm-5.7.3-amd64/
```

---

### 3. Build Custom Ubuntu + ROCm Version

Example: **Ubuntu 22.04 + ROCm 6.2.4**

```bash
make all \
  UBNAME=jammy \
  UBNUM=22.04 \
  ROCMVER=6.2.4 \
  AMDGPUVER=6.2.60204-1
```

> ✅ All variables are passed via `make` and exported as `PKR_VAR_*` for Packer.

---

### 4. Clean Build Artifacts

```bash
make clean
```

Removes:
- `build/` directory (VM output and ISO).
- No effect on source or Ansible roles.

---

### 5. Debug: View Resolved Variables

```bash
make print-vars
```

Useful to verify URLs, checksums, and VM names before building.

---

### 6. Ansible Dependencies

Install required roles:

```bash
make ansible-deps
```

Uses `ansible/requirements.yml` (e.g., for `rocm-install` if from Galaxy).

---

## 💾 Output

Generated image:
```
build/packer-ubuntu-<version>-rocm-<rocmver>-amd64/packer-qemu.qcow2
```

Ready for use in:
- QEMU/KVM
- Libvirt
- Cloud platforms (after conversion)
- CI/CD testing pipelines

---

## 🧪 Testing & Extending

- Modify `ansible/playbook.yml` to add more roles.
- Adjust `user-data` to enable additional services.
- Add post-processors in Packer (e.g., compress, upload).

---

## 📝 Notes

- **cloud-init NoCloud**: Simulates cloud environment locally using `cidata.iso`.
- **HVF Limitations**: No nested virtualization. Works best on macOS Intel and Apple Silicon.
- **SSH Access**: Uses password `packer` — removed or rotated in production use.
- **Checksums**: Automatically fetched from Ubuntu’s `SHA256SUMS` for integrity.

---

## 🙌 Acknowledgements

Based on standard Packer QEMU workflows and cloud-init NoCloud patterns.

---

## 📚 References

- [Packer QEMU Builder](https://developer.hashicorp.com/packer/plugins/builders/qemu)
- [QEMU HVF Support](https://wiki.qemu.org/Features/HVF)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
- [cloud-init NoCloud](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html)

---

## 📬 Feedback

PRs and issues welcome! Ideal for:
- Adding new Ubuntu versions.
- Supporting ARM64.
- Integrating with CI systems (GitHub Actions, etc.).

