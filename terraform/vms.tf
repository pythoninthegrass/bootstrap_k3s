# Cloud-init configuration
data "template_file" "cloud_init" {
  for_each = local.all_nodes

  template = file("${path.module}/cloud-init/user-data.yaml.tpl")

  vars = {
    hostname       = each.value.hostname
    fqdn           = "${each.value.hostname}.local"
    ssh_public_key = var.ssh_public_key
  }
}

# Node volumes
resource "libvirt_volume" "node_volume" {
  for_each = local.all_nodes

  name           = "${each.value.hostname}.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool           = var.storage_pool
  size           = each.value.disk_size * 1073741824
  format         = "qcow2"
}

# Cloud-init disks
resource "libvirt_cloudinit_disk" "node_cloudinit" {
  for_each = local.all_nodes

  name      = "${each.value.hostname}-cloudinit.iso"
  pool      = var.storage_pool
  user_data = data.template_file.cloud_init[each.key].rendered
}

# VM domains
resource "libvirt_domain" "node" {
  for_each = local.all_nodes

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.vcpu

  cloudinit = libvirt_cloudinit_disk.node_cloudinit[each.key].id

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.node_volume[each.key].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  # Bridge network interface
  dynamic "network_interface" {
    for_each = var.use_bridge_network ? [1] : []
    content {
      bridge = var.bridge_interface
      mac    = each.value.mac
    }
  }

  # NAT network interface
  dynamic "network_interface" {
    for_each = var.use_bridge_network ? [] : [1]
    content {
      network_name   = libvirt_network.k8s_network[0].name
      mac            = each.value.mac
      wait_for_lease = true
    }
  }
}
