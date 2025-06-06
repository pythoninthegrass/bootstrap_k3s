# Ansible Configuration

## Installation

Install Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Inventory Setup

Replace the ansible inventory file with your own:

```yaml
k3s_servers:
  hosts:
    server-1:
      ansible_host: 192.168.8.51
      k3s_type: server
      k3s_control_node: true
    server-2:
      ansible_host: 192.168.8.52
      k3s_type: server
    server-3:
      ansible_host: 192.168.8.53
      k3s_type: server

vars:
  ansible_user: ubuntu
  ansible_port: 22
```

## Managing sudo passwords with Vault

The project uses an encrypted `vault.yml` file to manage sudo passwords for each host.

### Creating the Vault

1. Create a vault password:

    ```bash
    # Store your vault password in skate
    skate set ansible_vault_password <YOUR_VAULT_PASSWORD>
    ```

2. Create and encrypt the vault.yml file:

    ```bash
    # Create the vault.yml file with your sudo passwords for each host
    cat > vault.yml << 'EOF'
    ---
    vault_passwords:
    control-plane-1: "correcthorsebatterystaple"
    control-plane-2: "correcthorsebatterystaple"
    control-plane-3: "correcthorsebatterystaple"
    worker-1: "correcthorsebatterystaple"
    worker-2: "correcthorsebatterystaple"
    default: "default_password"
    EOF

### Encrypt the file using the password stored in skate

```bash
ansible-vault encrypt vault.yml \
    --vault-password-file <(./scripts/pass.sh) \
    --encrypt-vault-id default
```

### Using the Vault

You can use the vault in two ways:

1. Set environment variable to avoid specifying the vault password file on every command:

    ```bash
    # Set the ANSIBLE_VAULT_PASSWORD_FILE environment variable
    export ANSIBLE_VAULT_PASSWORD_FILE="./scripts/pass.sh"

    # Now you can run ansible commands without specifying the vault-password-file flag
    ansible-playbook -i inventory.yml main.yml

    # For a specific host
    ansible-playbook -i inventory.yml main.yml --limit server-1
    ```

2. Explicitly specify the vault password file with each command:

    ```bash
    # Run playbooks using the vault password from skate
    ansible-playbook -i inventory.yml main.yml --vault-password-file ./scripts/pass.sh
    ```

### Editing the Vault

To edit the encrypted vault file:

```bash
# If you've set the environment variable:
ansible-vault edit vault.yml

# Or explicitly specify the vault password:
ansible-vault edit vault.yml --vault-password-file ./scripts/pass.sh
```

## Usage

### Install k3s and deploy a cluster

```bash
# If environment variable is set:
ansible-playbook -i inventory.yml main.yml

# Or with explicit vault password file:
ansible-playbook -i inventory.yml main.yml --vault-password-file <(skate list ansible_vault_password -v)

# Run against a specific host
ansible-playbook -i inventory.yml main.yml --limit server-1
```

### Uninstall k3s

```bash
ansible-playbook -i inventory.yml uninstall.yml
```
