# Deploy a K8 cluster in Proxmox using Terraform
Deploying a Kubernetes cluster in Proxmox using Terraform

# Manual steps for the time being:
- Setup static IP using netplan
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens18:
      dhcp4: false
      addresses: [192.168.193.21/24]
      gateway4: 192.168.193.1
      nameservers:
              addresses: [192.168.193.1]
  version: 2

  - Apply netplan ```netplan try```
  - Generate ssh keys ```ssh-keygen -A```
  - Enable ssh service ```sudo systemctl start ssh```

# From Mac:
  - Copy public keys from main machine ```ssh-copy-id -i ~/.ssh/id_rsa.pub jay@192.168.193.20``` 
  - Set hostname ```sudo hostnamectl set-hostname master```
  - Add to hosts file ```127.0.0.1 master```


