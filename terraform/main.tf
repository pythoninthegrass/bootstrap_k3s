resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  pool   = var.storage_pool
  format = "qcow2"
}

locals {
  # Generate deterministic MAC addresses based on IP addresses
  mac_addresses = merge(
    {
      for i in range(1, var.control_plane_count + 1) :
      "node-${i}" => format("52:54:00:%02x:%02x:%02x", 
        10 + i - 1,  # Use the IP last octet for MAC
        0,
        i
      )
    },
    {
      for i in range(1, var.worker_count + 1) :
      "node-${var.control_plane_count + i}" => format("52:54:00:%02x:%02x:%02x",
        20 + i - 1,  # Use the IP last octet for MAC
        1,
        i
      )
    }
  )
}
