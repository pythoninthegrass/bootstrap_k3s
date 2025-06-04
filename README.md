# bootstrap_k3s

Alternative to [k3sup](https://github.com/alexellis/k3sup) for deploying k3s clusters with Ansible.

## Minimum requirements

* [Python 3.11+](https://www.python.org/downloads/)
* [Terraform](https://www.terraform.io/downloads)
* [Skate](https://github.com/charmbracelet/skate)

## Recommended requirements

* [Devbox](https://www.jetify.com/docs/devbox/installing_devbox/)

## Setup

See the following documentation for detailed setup instructions:

* [Python Setup](docs/PYTHON.md): Virtual environment and Python dependencies
* [Ansible Configuration](docs/ANSIBLE.md): Inventory setup, vault management, and cluster deployment
* [Terraform Configuration](docs/TERRAFORM.md): Infrastructure provisioning workflow

## Quickstart

Deploy a k3s cluster with default settings in 4 steps:

1. **Provision infrastructure:**
   ```bash
   cd terraform/
   terraform init
   terraform plan -out tfplan
   terraform apply tfplan
   ```

2. **Generate Ansible inventory:**
   ```bash
   ./scripts/generate_inventory.sh
   ```

3. **Set up vault password:**
   ```bash
   skate set ansible_vault_password <YOUR_PASSWORD>
   export ANSIBLE_VAULT_PASSWORD_FILE="./scripts/pass.sh"
   ```

4. **Deploy k3s cluster:**
   ```bash
   ansible-playbook -i inventory.yml main.yml
   ```

This creates 3 control plane nodes and 1 worker node on libvirt with embedded etcd. See the docs for customization options.

## TODO

See [TODO.md](TODO.md)
