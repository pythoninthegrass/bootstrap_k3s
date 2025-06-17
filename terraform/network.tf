resource "libvirt_network" "k8s_network" {
  count = var.use_bridge_network ? 0 : 1

  name      = var.network_name
  mode      = "nat"
  autostart = true
  addresses = ["${var.base_ip}.0/24"]
  domain    = "k3s.local"

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

    # DNS host entries for each node
    dynamic "hosts" {
      for_each = local.all_nodes
      content {
        hostname = hosts.value.hostname
        ip       = hosts.value.ip
      }
    }
  }

  # DHCP host reservations using dnsmasq options
  dnsmasq_options {
    dynamic "options" {
      for_each = local.all_nodes
      content {
        option_name  = "dhcp-host"
        option_value = "${options.value.mac},${options.value.hostname},${options.value.ip}"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      dns,
      dnsmasq_options
    ]
  }
}
