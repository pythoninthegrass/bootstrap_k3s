#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if k3sup is installed
if ! command -v k3sup &> /dev/null; then
    error "k3sup is not installed. Install with: curl -sLS https://get.k3sup.dev | sh"
fi

# Check if terraform directory exists and has state
if [[ ! -d "$TERRAFORM_DIR" ]]; then
    error "Terraform directory not found: $TERRAFORM_DIR"
fi

if [[ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]]; then
    error "Terraform state not found. Run 'terraform apply' first."
fi

# Change to terraform directory to run terraform output
cd "$TERRAFORM_DIR"

log "Extracting node information from Terraform outputs..."

# Get terraform outputs as JSON
NODES_JSON=$(terraform output -json nodes)
CONTROL_PLANE_COUNT=$(terraform output -raw control_plane_count)
WORKER_COUNT=$(terraform output -raw worker_count)

# Parse node information - using temporary files for compatibility
CONTROL_PLANE_TEMP=$(mktemp)
WORKER_TEMP=$(mktemp)
trap "rm -f $CONTROL_PLANE_TEMP $WORKER_TEMP" EXIT

echo "$NODES_JSON" | jq -r 'to_entries[] | select(.value.type == "control-plane") | .value.ip' | sort > "$CONTROL_PLANE_TEMP"
echo "$NODES_JSON" | jq -r 'to_entries[] | select(.value.type == "worker") | .value.ip' | sort > "$WORKER_TEMP"

CONTROL_PLANE_IPS=()
while IFS= read -r line; do
    CONTROL_PLANE_IPS+=("$line")
done < "$CONTROL_PLANE_TEMP"

WORKER_IPS=()
while IFS= read -r line; do
    WORKER_IPS+=("$line")
done < "$WORKER_TEMP"

log "Found $CONTROL_PLANE_COUNT control plane nodes: ${CONTROL_PLANE_IPS[*]}"
log "Found $WORKER_COUNT worker nodes: ${WORKER_IPS[*]}"

# Configuration
SSH_USER="ubuntu"
TAILSCALE_HOST="100.72.47.104"
TAILSCALE_USER="ubuntu"
K3S_CHANNEL="stable"
KUBECONFIG_PATH="$HOME/.kube/config"

# Install k3s on the first control plane node with cluster mode (embedded etcd)
FIRST_CONTROL_PLANE_IP="${CONTROL_PLANE_IPS[0]}"
log "Installing k3s on first control plane node: $FIRST_CONTROL_PLANE_IP via Tailscale proxy"

# Run k3sup install on the Tailscale server since it has direct access to VMs
ssh "$TAILSCALE_USER@$TAILSCALE_HOST" "k3sup install \
    --cluster \
    --host $FIRST_CONTROL_PLANE_IP \
    --user $SSH_USER \
    --k3s-channel $K3S_CHANNEL \
    --local-path /tmp/kubeconfig \
    --print-command"

# Copy kubeconfig back to local machine
scp "$TAILSCALE_USER@$TAILSCALE_HOST:/tmp/kubeconfig" "$KUBECONFIG_PATH"

# Join additional control plane nodes if any
if [[ ${#CONTROL_PLANE_IPS[@]} -gt 1 ]]; then
    log "Joining additional control plane nodes..."
    for i in "${!CONTROL_PLANE_IPS[@]}"; do
        if [[ $i -eq 0 ]]; then continue; fi  # Skip first node

        CONTROL_PLANE_IP=${CONTROL_PLANE_IPS[$i]}
        log "Joining control plane node: $CONTROL_PLANE_IP"

        ssh "$TAILSCALE_USER@$TAILSCALE_HOST" "k3sup join \
            --server \
            --host $CONTROL_PLANE_IP \
            --user $SSH_USER \
            --server-host $FIRST_CONTROL_PLANE_IP \
            --server-user $SSH_USER \
            --k3s-channel $K3S_CHANNEL \
            --print-command"
    done
fi

# Join worker nodes if any
if [[ ${#WORKER_IPS[@]} -gt 0 ]]; then
    log "Joining worker nodes..."
    for i in "${!WORKER_IPS[@]}"; do
        log "Joining worker node: k3s-worker-$((i+1))"

        WORKER_IP="${WORKER_IPS[$i]}"
        ssh "$TAILSCALE_USER@$TAILSCALE_HOST" "k3sup join \
            --host $WORKER_IP \
            --user $SSH_USER \
            --server-host $FIRST_CONTROL_PLANE_IP \
            --server-user $SSH_USER \
            --k3s-channel $K3S_CHANNEL \
            --print-command"
    done
fi

log "k3s cluster deployment completed!"
log "Kubeconfig saved to: $KUBECONFIG_PATH"
log ""
log "To verify the cluster:"
log "  kubectl get nodes"
log "  kubectl cluster-info"
