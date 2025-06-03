variable "libvirt_uri" {
  description = "Libvirt connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "storage_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "use_bridge_network" {
  description = "Use bridge networking instead of NAT"
  type        = bool
  default     = false
}

variable "bridge_interface" {
  description = "Bridge interface name for bridge networking"
  type        = string
  default     = "eno1"
}

variable "network_name" {
  description = "Name of the libvirt network"
  type        = string
  default     = "k8s_network"
}

variable "base_ip" {
  description = "Base IP address for the network (first 3 octets)"
  type        = string
  default     = "192.168.56"
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "memory_control" {
  description = "Memory allocation for control plane nodes (MB)"
  type        = number
  default     = 2048
}

variable "memory_worker" {
  description = "Memory allocation for worker nodes (MB)"
  type        = number
  default     = 4096
}

variable "cpu_control" {
  description = "CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "cpu_worker" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size for all nodes (GB)"
  type        = number
  default     = 32
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""
}

variable "github_user" {
  description = "GitHub username to import SSH keys from (e.g. 'pythoninthegrass' will import from https://github.com/pythoninthegrass.keys)"
  type        = string
  default     = ""
}

# Local variables for node generation
locals {
  control_plane_ip_start = 10
  worker_ip_start        = 20

  control_plane_nodes = {
    for i in range(1, var.control_plane_count + 1) :
    "control-plane-${i}" => {
      index     = i
      hostname  = "control-plane-${i}"
      ip        = "${var.base_ip}.${local.control_plane_ip_start + i - 1}"
      mac       = local.mac_addresses["node-${i}"]
      memory    = var.memory_control
      vcpu      = var.cpu_control
      disk_size = var.disk_size
    }
  }

  worker_nodes = {
    for i in range(1, var.worker_count + 1) :
    "worker-${i}" => {
      index     = i
      hostname  = "worker-${i}"
      ip        = "${var.base_ip}.${local.worker_ip_start + i - 1}"
      mac       = local.mac_addresses["node-${var.control_plane_count + i}"]
      memory    = var.memory_worker
      vcpu      = var.cpu_worker
      disk_size = var.disk_size
    }
  }

  all_nodes = merge(local.control_plane_nodes, local.worker_nodes)
}
