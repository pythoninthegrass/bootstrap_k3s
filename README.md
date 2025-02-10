# bootstrap_k3s

Alternative to [k3sup](https://github.com/alexellis/k3sup) for deploying k3s clusters with Ansible.

## Setup

Create a virtual environment and install the requirements:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
```

Replace  the ansible inventory file with your own:

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

## Usage

### Install k3s and deploy a cluster

```bash
ansible-playbook -i inventory.yml main.yml
```

### Uninstall k3s

```bash
ansible-playbook -i inventory.yml uninstall.yml
```

## TODO

* Debug `ansible-navigator` ssh connection on macos
* Move more vars to `group_vars`
* Add task runners
