#!/usr/bin/env bash
set -eo pipefail
[[ -n "${VERBOSE}" ]] && set -x

# ISO name, VM ID
ISO="kinetic-server-cloudimg-amd64.img"
VMID="110"

# Download the base image into /var/lib/vz/templates/iso

# Install libguestfs-tools to directly install qemu-guest-agent into the iso
apt-get install libguestfs-tools

# Install qemu-guest-agent
virt-customize -a ${ISO} --install qemu-guest-agent

# Create a new VM
# VM ID (100) can be anything but has to be unique in the environment
qm create ${VMID} --name "ubuntu-2210-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0

# Import the downloaded disk to local-lvm storage
qm importdisk ${VMID} ${ISO} local-lvm

# Finally attach the new disk to the VM as scsi drive
qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-${VMID}-disk-0

# Configure a CD-ROM drive, which will be used to pass the Cloud-Init data to the VM
qm set ${VMID} --ide2 local-lvm:cloudinit

# To be able to boot directly from the Cloud-Init image, set the bootdisk parameter to scsi0
qm set ${VMID} --boot c --bootdisk scsi0

# Configure a serial console and use it as a display
qm set ${VMID} --serial0 socket --vga serial0

# Enable the agent
qm set ${VMID} --agent enabled=1

# Convert the VM into a template
qm template ${VMID}