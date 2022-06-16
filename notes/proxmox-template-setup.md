# This should be done in the proxmox server
# Download the cloud image 
`cd /var/lib/vz/template/iso`

`wget https://cloud-images.ubuntu.com/kinetic/current/kinetic-server-cloudimg-amd64.img`

# Install libguestfs-tools to directly install qemu-guest-agent into the iso
`apt-get install libguestfs-tools`

# Install qemu-guest-agent
`virt-customize -a kinetic-server-cloudimg-amd64.img --install qemu-guest-agent`

# Create a new VM
# VM ID (100) can be anything but has to be unique in the environment
`qm create 110 --name "ubuntu-2210-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0`

# Import the downloaded disk to local-lvm storage
`qm importdisk 110 kinetic-server-cloudimg-amd64.img local-lvm`

# Finally attach the new disk to the VM as scsi drive
`qm set 110 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-110-disk-0`

# Configure a CD-ROM drive, which will be used to pass the Cloud-Init data to the VM
`qm set 110 --ide2 local-lvm:cloudinit`

# To be able to boot directly from the Cloud-Init image, set the bootdisk parameter to scsi0
`qm set 110 --boot c --bootdisk scsi0`

# Configure a serial console and use it as a display
`qm set 110 --serial0 socket --vga serial0`

# Enable the agent
`qm set 110 --agent enabled=1`

# Convert the VM into a template
`qm template 110`