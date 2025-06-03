resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  pool   = var.storage_pool
  format = "qcow2"
}

resource "random_bytes" "mac" {
  count  = var.control_plane_count + var.worker_count
  length = 3
  keepers = {
    node_count = var.control_plane_count + var.worker_count
  }
}

locals {
  mac_addresses = {
    for i in range(var.control_plane_count + var.worker_count) :
    "node-${i + 1}" => format("52:54:00:%s", 
      substr(replace(nonsensitive(random_bytes.mac[i].hex), "/(..)(..)(..)$/", "$1:$2:$3"), 0, 8)
    )
  }
}
