output "control_plane_names" {
  description = "Names of the control plane instances"
  value       = incus_instance.control_plane[*].name
}

output "control_plane_ipv4" {
  description = "IPv4 addresses of the control plane instances"
  value       = [for instance in incus_instance.control_plane : instance.ipv4_address]
}

output "worker_names" {
  description = "Names of the worker instances"
  value       = incus_instance.worker[*].name
}

output "worker_ipv4" {
  description = "IPv4 addresses of the worker instances"
  value       = [for instance in incus_instance.worker : instance.ipv4_address]
}
