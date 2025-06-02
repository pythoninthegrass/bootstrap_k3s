output "nodes" {
  description = "All node information"
  value = {
    for name, node in local.all_nodes : name => {
      hostname = node.hostname
      ip       = node.ip
      mac      = node.mac
      type     = startswith(name, "control-plane") ? "control-plane" : "worker"
    }
  }
}

output "ansible_inventory" {
  description = "Ansible inventory in YAML format"
  value = templatefile("${path.module}/templates/ansible_inventory.yaml.tpl", {
    control_plane_nodes = local.control_plane_nodes
    worker_nodes        = local.worker_nodes
  })
}

output "ssh_config" {
  description = "SSH configuration for all nodes"
  value = templatefile("${path.module}/templates/ssh_config.tpl", {
    nodes = local.all_nodes
  })
}
