terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.1"
    }
  }
}

provider "proxmox" {
  # make sure to export PM_API_TOKEN_ID and PM_API_TOKEN_SECRET
  pm_tls_insecure = true
  pm_api_url      = "https://192.168.193.193:8006/api2/json"

  # pm_log_enable = true
  # pm_log_file   = "tf.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}


# Create a local copy of the cloud-init file, to transfer to Proxmox
resource "local_file" "cloud_init_master" {
  content  = data.template_file.cloud_init_master.rendered
  filename = "cloud_init_master_generated.cfg"
}

resource "local_file" "cloud_init_worker" {
  count    = var.worker_count
  content  = data.template_file.cloud_init_worker[count.index].rendered
  filename = "cloud_init_worker${count.index}_generated.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_master" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "192.168.193.193"
  }

  provisioner "file" {
    source      = local_file.cloud_init_master.filename
    destination = "/var/lib/vz/snippets/cloud_init_master.yaml"
  }
}

resource "null_resource" "cloud_init_worker" {
  count = var.worker_count
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "192.168.193.193"
  }

  provisioner "file" {
    source      = local_file.cloud_init_worker[count.index].filename
    destination = "/var/lib/vz/snippets/cloud_init_worker${count.index}.yaml"
  }
}

resource "proxmox_vm_qemu" "master" {
  depends_on = [
    null_resource.cloud_init_master
  ]
  name        = "master"
  target_node = var.proxmox_host
  clone       = var.template_name
  vmid        = 200
  cores       = 2
  sockets     = 1
  memory      = 4096

  disk {
    size    = "30G"
    type    = "scsi"
    storage = "firestore"
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
  cicustom  = "user=local:snippets/cloud_init_master.yaml"
  ipconfig0 = "ip=192.168.193.20/24,gw=192.168.193.1"
}

resource "proxmox_vm_qemu" "worker" {
  count       = var.worker_count
  name        = "worker-${count.index}"
  target_node = var.proxmox_host
  clone       = var.template_name
  vmid        = count.index + 300
  cores       = 2
  sockets     = 1
  memory      = 4096
  disk {
    size    = "30G"
    type    = "scsi"
    storage = "firestore"
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
  cicustom  = "user=local:snippets/cloud_init_worker${count.index}.yaml"
  ipconfig0 = "ip=192.168.193.3${count.index}/24,gw=192.168.193.1"
}


resource "null_resource" "ansible_handover" {
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "jay"
      host        = "master"
      private_key = file("${var.private_key_path}")
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i 'ansible/inventory' --private-key ${var.private_key_path} ansible/k8_cluster_setup.yaml"
  }
}
