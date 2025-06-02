#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

SSH_CONFIG_DIR="$HOME/.ssh/config.d"
mkdir -p "$SSH_CONFIG_DIR"

echo "Generating SSH config..."
terraform output -raw ssh_config > "$SSH_CONFIG_DIR/k8s-cluster"
echo "SSH config saved to $SSH_CONFIG_DIR/k8s-cluster"
echo "Make sure your ~/.ssh/config includes: Include config.d/*"
