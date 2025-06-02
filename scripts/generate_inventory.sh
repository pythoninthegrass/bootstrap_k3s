#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

echo "Generating Ansible inventory..."
terraform output -raw ansible_inventory > ../inventory.yml
echo "Inventory saved to ../inventory.yml"
