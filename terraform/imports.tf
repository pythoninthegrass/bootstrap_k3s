# Import blocks for recovering from state drift
# Use these when resources exist but aren't in state

# Example usage:
# 1. Uncomment the import blocks below
# 2. Run: terraform plan -generate-config-out=generated.tf
# 3. Run: terraform apply
# 4. Comment out or remove the import blocks

# import {
#   to = libvirt_domain.node["control-plane-1"]
#   id = "control-plane-1"  # Domain name
# }

# import {
#   to = libvirt_domain.node["worker-1"] 
#   id = "worker-1"  # Domain name
# }

# import {
#   to = libvirt_network.k8s_network[0]
#   id = "k8s_network"  # Network name
# }