# Source the Cloud Init Config file
data "template_file" "cloud_init_master" {
  count    = var.master_count
  template = file("./configs/cloud_init_master.yaml")
  vars = {
    ssh_public_key = file("~/.ssh/id_rsa.pub")
    node           = "master${count.index}"
  }
}
