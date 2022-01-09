# Deploy a K8 cluster in Proxmox using Terraform
Deploying a Kubernetes cluster in Proxmox using Terraform

# Pre-requisit - create a VM template
## In proxmox terminal
```
# download the cloud image 
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

# install libguestfs-tools to directly install qemu-guest-agent into the iso
apt-get install libguestfs-tools

# install qemu-guest-agent
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent

# create a new VM
qm create 100 --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0

# import the downloaded disk to local-lvm storage
qm importdisk 100 focal-server-cloudimg-amd64.img local-lvm

# finally attach the new disk to the VM as scsi drive
qm set 100 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-100-disk-0

# configure a CD-ROM drive, which will be used to pass the Cloud-Init data to the VM
qm set 100 --ide2 local-lvm:cloudinit

# to be able to boot directly from the Cloud-Init image, set the bootdisk parameter to scsi0
qm set 100 --boot c --bootdisk scsi0

# configure a serial console and use it as a display
qm set 100 --serial0 socket --vga serial0

# enable the agent
qm set 100 –-agent 1

# convert the VM into a template
qm template 100
```

#### Reference: #####
https://pve.proxmox.com/pve-docs/chapter-qm.html#_preparing_cloud_init_templates
https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/



