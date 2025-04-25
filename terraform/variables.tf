variable "incus_server" {
  description = "Incus server name"
  type        = string
  default     = "incus-server"

}

variable "incus_address" {
  description = "Incus server address"
  type        = string
}

variable "incus_port" {
  description = "Incus API port"
  type        = number
  default     = 8443
}

variable "incus_scheme" {
  description = "Incus connection scheme (unix or https)"
  type        = string
  default     = "https"
}

variable "incus_token" {
  description = "Incus API token name"
  type        = string
}

variable "vm_image" {
  description = "VM image to use for instances"
  type        = string
}

# Add this to your variables.tf file

variable "vm_profile_name" {
  description = "Name of the existing VM profile to use"
  type        = string
  default     = "vm-profile"
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "default-vm"

}

variable "disk_size" {
  description = "Root disk size for VMs"
  type        = string
}

variable "network_adapter" {
  description = "Network adapter for VMs"
  type        = string
}

variable "large_instances" {
  description = "Number of t2.large instances for control-plane"
  type        = number
  default     = 3
}

variable "medium_instances" {
  description = "Number of t2.medium instances for workers"
  type        = number
  default     = 2
}

variable "large_cpu" {
  description = "CPU cores for t2.large instances"
  type        = number
}

variable "large_memory" {
  description = "Memory in GB for t2.large instances"
  type        = number
}

variable "medium_cpu" {
  description = "CPU cores for t2.medium instances"
  type        = number
}

variable "medium_memory" {
  description = "Memory in GB for t2.medium instances"
  type        = number
}
