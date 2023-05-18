variable "proxmox_host" {
  default = "firefly"
}

variable "template_name" {
  default = "ubuntu-2310-mantic-cloudinit-template"
}

variable "worker_count" {
  default = 2
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}