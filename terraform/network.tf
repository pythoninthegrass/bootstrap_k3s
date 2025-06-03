# Create network XML from template
locals {
  network_config = var.use_bridge_network ? "" : templatefile("${path.module}/templates/network.xml.tpl", {
    network_name = var.network_name
    base_ip      = var.base_ip
    nodes        = local.all_nodes
  })
}

resource "libvirt_network" "k8s_network" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true
  addresses = ["${var.base_ip}.0/24"]

  dhcp {
    enabled = true
  }

  dns {
    enabled = true
    forwarders {
      address = "8.8.8.8"
    }
    forwarders {
      address = "8.8.4.4"
    }
  }
}
