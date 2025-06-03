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

output "control_plane_count" {
  description = "Number of control plane nodes"
  value       = var.control_plane_count
}

output "worker_count" {
  description = "Number of worker nodes"
  value       = var.worker_count
}

output "memory_control" {
  description = "Memory allocation for control plane nodes (MB)"
  value       = var.memory_control
}

output "memory_worker" {
  description = "Memory allocation for worker nodes (MB)"
  value       = var.memory_worker
}

output "cpu_control" {
  description = "CPU cores for control plane nodes"
  value       = var.cpu_control
}

output "cpu_worker" {
  description = "CPU cores for worker nodes"
  value       = var.cpu_worker
}

output "disk_size" {
  description = "Disk size for all nodes (GB)"
  value       = var.disk_size
}

output "base_ip" {
  description = "Base IP address for the network"
  value       = var.base_ip
}

output "network_name" {
  description = "Name of the libvirt network"
  value       = var.network_name
}

output "use_bridge_network" {
  description = "Whether bridge networking is enabled"
  value       = var.use_bridge_network
}

output "ssh_public_key" {
  description = "SSH public key for VM access"
  value       = var.ssh_public_key
  sensitive   = true
}

output "github_user" {
  description = "GitHub username for SSH key import"
  value       = var.github_user
}
