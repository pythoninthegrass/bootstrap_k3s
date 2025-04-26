# Reference the existing VM profile
data "incus_profile" "vm_profile" {
  name = var.vm_profile_name
}

# Create control-plane VMs (t2.large type)
resource "incus_instance" "control_plane" {
  count = var.large_instances
  name  = "control-plane-${count.index + 1}"
  image = "images:${var.vm_image}"
  type  = "virtual-machine"

  config = {
    "limits.cpu"     = var.large_cpu
    "limits.memory"  = "${var.large_memory}GB"
    "boot.autostart" = "true"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      "network" = var.network_adapter
      "name" = "eth0"
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      "path" = "/"
      "pool" = var.storage_pool
      "size" = var.disk_size
    }
  }

  profiles = ["default", data.incus_profile.vm_profile.name]
}

# Create worker VMs (t2.medium type)
resource "incus_instance" "worker" {
  count = var.medium_instances
  name  = "worker-${count.index + 1}"
  image = "images:${var.vm_image}"
  type  = "virtual-machine"

  config = {
    "limits.cpu"     = var.medium_cpu
    "limits.memory"  = "${var.medium_memory}GB"
    "boot.autostart" = "true"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      "network" = var.network_adapter
      "name" = "eth0"
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      "path" = "/"
      "pool" = var.storage_pool
      "size" = var.disk_size
    }
  }

  profiles = ["default", data.incus_profile.vm_profile.name]
}
