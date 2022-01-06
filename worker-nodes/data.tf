# Source the Cloud Init Config file
data "template_file" "cloud_init_worker" {
  count = var.worker_count
  template = file("./configs/cloud_init_worker.yaml")
  vars = {
    ssh_public_key = file("~/.ssh/id_rsa.pub")
    node           = "worker${count.index}"
  }
}
