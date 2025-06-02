# Create network XML from template
resource "libvirt_network" "k8s_network" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true
  bridge    = "virbr1"

  xml {
    xslt = file("${path.module}/templates/network.xsl")
  }
}

# Alternative: Direct XML definition
data "template_file" "network_config" {
  count = var.use_bridge_network ? 0 : 1

  template = file("${path.module}/templates/network.xml.tpl")

  vars = {
    network_name = var.network_name
    base_ip      = var.base_ip
    nodes        = jsonencode(local.all_nodes)
  }
}

resource "libvirt_network" "k8s_network_xml" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true

  xml {
    xslt = data.template_file.network_config[0].rendered
  }
}
