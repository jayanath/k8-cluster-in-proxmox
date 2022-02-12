# Deploy a K8 cluster in Proxmox using Terraform and Ansible
Running a kube cluster in any public cloud provider is a costly business.
There are many ways to deploy a local cluster with virtualbox, kind etc.
However I wanted to use Proxmox with my home server and I could not find any complete example of deploying a fully automated cluster using Terraform and Ansible.
So I created this repo.
This is not production grade at all but perfect for running a 3 node cluster at home.


# Pre-requisits
- Proxmox with API token to create VMs
- VM template (follow steps below to create a template)
- CIDR range to setup static IPs for the cluster nodes. Below are the default IPs.
```
master  192.168.193.20
worker0 192.168.193.30
worker1 192.168.193.31
```
- Terraform and Ansible

# How to use this code
- Make sure you have all the pre-requisites
- Clone this repo
- Run Terraform init from the root folder
- Run Terraform apply

# Notes
- If you want to change the CIDR range/username etc, you may have to dig a little bit. I will update this documentation to make it easier at some point.
- Check the locations of the SSH keys, I used the usual default locations and file names ```( ~/.ssh/id_rsa )```
- Use MetalLB https://metallb.universe.tf/installation/ to play with Ingress and Ingress Controller.
- Use https://github.com/kubernetes-sigs/metrics-server metrics server, but make sure to ```--kubelet-insecure-tls``` to get it running. 
## How to create a VM template in Proxmox
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



