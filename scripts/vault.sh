#!/usr/bin/env bash

set -e

# Determine the git repository root directory
GIT_ROOT=$(git rev-parse --show-toplevel)
VAULT_FILE="${GIT_ROOT}/vault.yml"
VAULT_PASS_SCRIPT="${GIT_ROOT}/bin/pass.sh"

# Set editor with fallback
if command -v code &> /dev/null; then
    EDITOR_CMD="code --wait"
else
    EDITOR_CMD="vim"
fi

# Check if pass.sh exists and is executable
if [ ! -x "$VAULT_PASS_SCRIPT" ]; then
    echo -e "Error: $VAULT_PASS_SCRIPT script not found or not executable" >&2
    exit 1
fi

# Function to display usage help
usage() {
    echo "Usage: $0 [create|encrypt|decrypt|edit|view]"
    echo
    echo "Commands:"
    echo "  create   Create a new vault.yml file"
    echo "  encrypt  Encrypt an existing vault.yml file"
    echo "  decrypt  Decrypt the vault.yml file"
    echo "  edit     Edit the encrypted vault.yml file"
    echo "  view     View the contents of the encrypted vault.yml file"
    echo
}

# Check if ansible-vault is available
if ! command -v ansible-vault &> /dev/null; then
    echo "Error: ansible-vault command not found" >&2
    exit 1
fi

case "$1" in
    create)
        if [ -f "$VAULT_FILE" ]; then
            echo "Warning: $VAULT_FILE already exists."
            read -rp "Do you want to overwrite it? [y/N]: " confirm
            if [[ ! "$confirm" =~ ^[Yy](es)?$ ]]; then
                echo "Operation cancelled."
                exit 0
            fi
        fi

        echo "Creating new vault.yml file..."
        echo "# Ansible vault file - contains sensitive variables" > "$VAULT_FILE"
        echo "---" >> "$VAULT_FILE"
        echo "# Add your secret variables below" >> "$VAULT_FILE"
        ansible-vault encrypt "$VAULT_FILE"
        echo "Vault file created and encrypted at: $VAULT_FILE"
        ;;

    encrypt)
        if [ ! -f "$VAULT_FILE" ]; then
            echo "Error: $VAULT_FILE does not exist." >&2
            echo "Use '$0 create' to create a new vault file." >&2
            exit 1
        fi

        if grep -q "^\$ANSIBLE_VAULT;" "$VAULT_FILE"; then
            echo "File is already encrypted."
            exit 0
        fi

        ansible-vault encrypt "$VAULT_FILE"
        echo "Vault file encrypted successfully."
        ;;

    decrypt)
        if [ ! -f "$VAULT_FILE" ]; then
            echo "Error: $VAULT_FILE does not exist." >&2
            exit 1
        fi

        if ! grep -q "^\$ANSIBLE_VAULT;" "$VAULT_FILE"; then
            echo "File is not encrypted."
            exit 0
        fi

        ansible-vault decrypt "$VAULT_FILE"
        echo "Vault file decrypted successfully."
        echo "IMPORTANT: Remember to re-encrypt the file when finished!"
        ;;

    edit)
        if [ ! -f "$VAULT_FILE" ]; then
            echo "Error: $VAULT_FILE does not exist." >&2
            echo "Use '$0 create' to create a new vault file." >&2
            exit 1
        fi

        EDITOR="$EDITOR_CMD" ansible-vault edit "$VAULT_FILE"
        ;;

    view)
        if [ ! -f "$VAULT_FILE" ]; then
            echo "Error: $VAULT_FILE does not exist." >&2
            exit 1
        fi

        EDITOR="$EDITOR_CMD" ansible-vault view "$VAULT_FILE"
        ;;

    *)
        usage
        exit 1
        ;;
esac
