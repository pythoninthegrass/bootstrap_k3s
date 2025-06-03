# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a k3s cluster bootstrap project that combines Terraform for infrastructure provisioning and Ansible for cluster configuration. It provides an alternative to k3sup for deploying high-availability k3s clusters with two deployment options: libvirt/KVM VMs.

## Architecture

The project follows a layered approach:

- **Infrastructure Layer** (Terraform): Provisions libvirt/KVM VMs with cloud-init
- **Configuration Layer** (Ansible): Deploys k3s cluster with embedded etcd and WireGuard networking

## LLM Instructions

When working with Terraform in this repository, the LLM should:

- Never run Terraform commands (`terraform init`, `terraform plan`, `terraform apply`, etc.) without explicit user request
  - An exception is to always run `terraform validate` before proposing any Terraform code changes to ensure the configuration is valid
- Only suggest Terraform commands and wait for user approval before executing them
- Explain the purpose and potential impact of any suggested Terraform commands
- Follow linting rules (e.g., `terraform fmt`, `.editorconfig`, `.markdownlint.jsonc`, etc.)

## Common Development Commands

### Environment Setup

```bash
# Initialize Python environment
uv venv && source .venv/bin/activate
uv pip install -r pyproject.toml

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Set vault password (requires Skate)
export ANSIBLE_VAULT_PASSWORD_FILE=$(skate get ansible_vault_password)
```

### Remote libvirt server checks

Assuming that the remote libvirt host is aliased as `dev` in `~/.ssh/config` and the network name is `k8s_network`, these commands can be used to check the status of the VMs from a local machine.

Note that the `qemu:///system` URI is needed to connect to the remote libvirt hypervisor. Without it, `virsh` returns empty results.

```bash
# List all VMs on remote libvirt host
ssh dev "virsh -c qemu:///system list --all"

# Check dhcp leases
ssh dev "virsh -c qemu:///system net-dhcp-leases k8s_network"

# Check VM status
ssh dev "virsh -c qemu:///system dominfo node-1"

# View VM console
ssh dev "virsh -c qemu:///system console node-1"
```

### Terraform Workflow

```bash
cd terraform/
terraform init
terraform plan
terraform apply

# Generate configs for Ansible
../scripts/generate_inventory.sh
../scripts/setup_ssh_config.sh
```

### Ansible Workflow

```bash
# Deploy k3s cluster
ansible-playbook -i inventory.yml main.yml

# Remove k3s cluster
ansible-playbook -i inventory.yml uninstall.yml

# Test connectivity
ansible all -i inventory.yml -m ping
```

## Key Configuration Files

- `terraform/variables.tf` - Infrastructure sizing and network configuration
- `group_vars/all.yml` - k3s cluster configuration and global variables
- `ansible.cfg` - Ansible behavior and SSH settings
- `inventory.yml.example` - Sample inventory structure

## Network Architecture

- **Default Range**: 192.168.56.0/24
- **Control Plane IPs**: .10-.19 (configurable count, default 3)
- **Worker Node IPs**: .20-.29 (configurable count, default 1)
- **Pod CIDR**: 10.42.0.0/16
- **Service CIDR**: 10.43.0.0/16

## Important Notes

- The project uses Ansible Vault with Skate for password management
- Terraform generates Ansible inventory automatically via templates
- k3s is configured with WireGuard backend and embedded etcd for HA
- Both bridge and NAT networking modes are supported
- Cloud-init handles initial VM setup before Ansible takes over

## LLM Online Resources

When working with this codebase, the following online resources should be considered as known:

- [Terraform Libvirt Provider Documentation](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) - Official documentation for the libvirt provider
- [Terraform Libvirt Provider GitHub Repository](https://github.com/dmacvicar/terraform-provider-libvirt) - Source code and examples for the libvirt provider
- [Libvirt Documentation](https://libvirt.org/docs.html) - Official libvirt documentation and guides

These resources should be treated as known and available for reference when working with the codebase.
