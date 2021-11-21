#!/usr/bin/env bash

# Download appropriate cloud image and create vm template

# more info about creating templates and storage type selections can be found here
# https://pve.proxmox.com/pve-docs/chapter-qm.html#_preparing_cloud_init_templates
# https://forum.proxmox.com/threads/local-lvm-vs-local.91666/
# https://gist.github.com/aw/ce460c2100163c38734a83e09ac0439a

set -eo pipefail

[[ -n "${VERBOSE}" ]] && set -x

# Additional steps identified during troubleshooting

# Set the support for content like snippets in the storage
# pvesm set local -content images,rootdir,vztmpl,backup,iso,snippets

# Ubuntu cloud image does not come with QEMU guest agent
# Need to install that separately
# The approach of using libguestfs-tools didn't really work.
# Therefore had to manually create a VM and install the QEMU guest agent

# Trying out Debian cloud image instead
# That also didn't work.
# Falling back to manually creating the VM template

# Download the base image into /var/lib/vz/templates/iso
wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2

# Create a new VM to later convert into a template
qm create 100 -name debian-cloudinit -memory 2048 -net0 virtio,bridge=vmbr0

# Import the downloaded disk image to Proxmox storage
qm importdisk 100 debian-11-generic-amd64.qcow2 local-lvm

# Attach the imported disk to the new VM as a scsi driver
qm set 100 -scsihw virtio-scsi-pci -virtio0 local-lvm:vm-100-disk-0

# Add cloud-init CD ROM to pass data to the VM
qm set 100 -ide2 local-lvm:cloudinit

# Configure a serial console and use it as a display. Many Cloud-Init images rely on this
qm set 100 -serial0 socket -vga qxl

# To be able to boot directly from the Cloud-Init image, set the bootdisk parameter to scsi0
qm set 100 -boot c -bootdisk virtio0

# Enable the Qemu agent
qm set 100 -agent 1

# Allow hotplugging of network, USB and disks
qm set 100 -hotplug disk,network,usb

# Set prefered number of vCPUs
qm set 100 -vcpus 2


# Convert the VM to the template
qm template 100