resource "proxmox_vm_qemu" "worker" {
  count       = 2
  name        = "worker-${count.index}"
  target_node = var.proxmox_host
  clone       = var.template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  vcpus       = 2
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  vmid        = count.index + 300

  disk {
    size    = "10G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Cloud init options
  ipconfig0 = "ip=192.168.193.3${count.index}/24,gw=192.168.193.1"
  sshkeys   = file("~/.ssh/id_rsa.pub")
}