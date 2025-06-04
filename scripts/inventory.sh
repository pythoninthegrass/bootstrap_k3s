#!/usr/bin/env bash

set -e

GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# get the root directory
if [ -n "$GIT_ROOT" ]; then
	TLD="$(git rev-parse --show-toplevel)"
else
	TLD="${SCRIPT_DIR}"
fi

TF_DIR="${TLD}/terraform"

echo "Generating Ansible inventory..."
terraform -chdir="${TF_DIR}" output -raw ansible_inventory > "${TLD}/inventory.yml"
echo "Inventory saved to ${TLD}/inventory.yml"
