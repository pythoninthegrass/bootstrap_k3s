# Create network XML from template
resource "libvirt_network" "k8s_network" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true
  bridge    = "virbr1"

  xml {
    content = templatefile("${path.module}/templates/network.xml.tpl", {
      network_name = var.network_name
      base_ip      = var.base_ip
      nodes        = local.all_nodes
    })
  }
}

# Alternative: Direct XML definition
locals {
  network_config = var.use_bridge_network ? "" : templatefile("${path.module}/templates/network.xml.tpl", {
    network_name = var.network_name
    base_ip      = var.base_ip
    nodes        = jsonencode(local.all_nodes)
  })
}

resource "libvirt_network" "k8s_network_xml" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true

  xml {
    xslt = local.network_config
  }
}
