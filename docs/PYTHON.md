# Python Setup

## Virtual Environment Setup

Create a virtual environment and install the requirements:

```bash
# python only
python -m venv .venv
python -m pip install -r requirements.txt

# uv
uv venv
source .venv/bin/activate
uv pip install -r pyproject.toml
```

## Environment Configuration

Set vault password for Ansible operations:

```bash
# Set the ANSIBLE_VAULT_PASSWORD_FILE environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=$(skate get ansible_vault_password)
```
