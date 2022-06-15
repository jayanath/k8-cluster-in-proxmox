# This should be done in the proxmox server
# Download the cloud image 
`cd /var/lib/vz/template/iso`

`wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img`

# Install libguestfs-tools to directly install qemu-guest-agent into the iso
`apt-get install libguestfs-tools`

# Install qemu-guest-agent
`virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent`

# Create a new VM
# VM ID (100) can be anything but has to be unique in the environment
`qm create 100 --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0`

# Import the downloaded disk to local-lvm storage
`qm importdisk 100 focal-server-cloudimg-amd64.img local-lvm`

# Finally attach the new disk to the VM as scsi drive
`qm set 100 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-100-disk-0`

# Configure a CD-ROM drive, which will be used to pass the Cloud-Init data to the VM
`qm set 100 --ide2 local-lvm:cloudinit`

# To be able to boot directly from the Cloud-Init image, set the bootdisk parameter to scsi0
`qm set 100 --boot c --bootdisk scsi0`

# Configure a serial console and use it as a display
`qm set 100 --serial0 socket --vga serial0`

# Enable the agent
`qm set 100 –-agent 1`

# Convert the VM into a template
`qm template 100`