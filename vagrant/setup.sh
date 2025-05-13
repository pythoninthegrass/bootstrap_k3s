#!/usr/bin/env bash

set -euo pipefail

cat << 'DESCRIPTION' >/dev/null
Kubernetes cluster setup script for multiple control planes and workers
DESCRIPTION

# Default values
NODE_TYPE=${1:-"control-plane"}
NODE_INDEX=${2:-1}
CONTROL_PLANE_COUNT=${3:-3}
WORKER_COUNT=${4:-1}
CONTROL_PLANE_IP=${5:-"192.168.56.11"}
K8S_VERSION=${6:-"1.33.0"}
ACTION=${7:-"init"}

# Fix for dpkg stdin error
export DEBIAN_FRONTEND=noninteractive

# Common environment variables
POD_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"
CLUSTER_NAME="kubernetes-cluster"
# Token must be 6 characters dot 16 characters format
KUBEADM_TOKEN="abcdef.0123456789abcdef"
# Certificate key must be quoted as a string
CERT_KEY="1234567890123456789012345678901234567890123456789012345678901234"

# Get the current node's IP address
get_node_ip() {
	# Find the IP on the k8s network (192.168.56.x)
	ip -4 addr | grep '192.168.56' | awk '{print $2}' | cut -d/ -f1
}

NODE_IP=$(get_node_ip)
HOSTNAME=$(hostname)

echo "=== Setting up $NODE_TYPE node $NODE_INDEX with IP $NODE_IP ==="

# System preparation
system_preparation() {
	echo "=== System preparation ==="

	# Disable swap
	swapoff -a
	sed -i '/swap/d' /etc/fstab

	# Load necessary modules
	cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

	modprobe overlay
	modprobe br_netfilter

	# Set up kernel parameters
	cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

	sysctl --system

	# Update and install dependencies
	apt-get update
	apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release openssh-client
}

# Install containerd
install_containerd() {
	echo "=== Installing containerd ==="

	# Add Docker GPG key and repository
	mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
		tee /etc/apt/sources.list.d/docker.list >/dev/null

	# Install containerd
	apt-get update
	apt-get install -y containerd.io

	# Configure containerd
	mkdir -p /etc/containerd
	containerd config default | tee /etc/containerd/config.toml >/dev/null

	# Set SystemdCgroup to true
	sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

	# Restart containerd
	systemctl restart containerd
	systemctl enable containerd
}

# Install kubeadm, kubelet, and kubectl
install_kubernetes_components() {
	echo "=== Installing Kubernetes components ==="

	# Add Kubernetes GPG key and repository
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/ /" |
		tee /etc/apt/sources.list.d/kubernetes.list

	# Install specific Kubernetes version
	apt-get update
	apt-get install -y kubelet=${K8S_VERSION}-* kubeadm=${K8S_VERSION}-* kubectl=${K8S_VERSION}-*
	apt-mark hold kubelet kubeadm kubectl

	# Configure kubelet
	echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" >/etc/default/kubelet
	systemctl restart kubelet
}

# Configure SSH for nodes to communicate
setup_ssh() {
    echo "=== Setting up SSH for node communication ==="

    # Generate SSH key if it doesn't exist
    if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        su - vagrant -c "ssh-keygen -t rsa -N '' -f /home/vagrant/.ssh/id_rsa"
    fi

    # Ensure authorized_keys contains our own public key for loopback connections
    su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"

    # Fix permissions
    chown -R vagrant:vagrant /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/id_rsa
    chmod 644 /home/vagrant/.ssh/id_rsa.pub
    chmod 600 /home/vagrant/.ssh/authorized_keys

    # Configure SSH to not check host keys within the k8s network
    cat > /home/vagrant/.ssh/config <<EOF
Host 192.168.56.*
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile /home/vagrant/.ssh/id_rsa
EOF
    chmod 600 /home/vagrant/.ssh/config
    chown vagrant:vagrant /home/vagrant/.ssh/config

    # Allow SSH inside the cluster (if firewall is enabled)
    if command -v ufw >/dev/null 2>&1; then
        ufw allow from 192.168.56.0/24 to any port 22
        ufw reload
    fi
}

# Initialize the control plane
initialize_control_plane() {
	echo "=== Initializing control plane ==="

	# Generate kubeadm init config - using v1beta4 instead of v1beta3
	cat <<EOF >/tmp/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${NODE_IP}
  bindPort: 6443
bootstrapTokens:
- token: "${KUBEADM_TOKEN}"
  ttl: "0"
certificateKey: "${CERT_KEY}"
nodeRegistration:
  name: ${HOSTNAME}
  criSocket: "unix:///var/run/containerd/containerd.sock"
  kubeletExtraArgs:
    node-ip: ${NODE_IP}
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v${K8S_VERSION}
clusterName: ${CLUSTER_NAME}
networking:
  podSubnet: ${POD_CIDR}
  serviceSubnet: ${SERVICE_CIDR}
controlPlaneEndpoint: "${NODE_IP}:6443"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

	# Initialize cluster
	kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs

	# Set up kubectl
	mkdir -p /home/vagrant/.kube
	cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
	chown -R vagrant:vagrant /home/vagrant/.kube

	# Set up root user kubectl
	mkdir -p /root/.kube
	cp -i /etc/kubernetes/admin.conf /root/.kube/config

	# Install Calico networking
	kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

	# Create join command files
	kubeadm token create --print-join-command >/home/vagrant/worker-join.sh
	echo "kubeadm join ${NODE_IP}:6443 --token ${KUBEADM_TOKEN} --discovery-token-ca-cert-hash sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //') --control-plane --certificate-key ${CERT_KEY}" > /home/vagrant/control-plane-join.sh

	chmod +x /home/vagrant/control-plane-join.sh /home/vagrant/worker-join.sh
	chown vagrant:vagrant /home/vagrant/control-plane-join.sh /home/vagrant/worker-join.sh

	# Wait for all services to be up before allowing joins
	sleep 10
}

# Join an existing cluster as a control plane node
join_control_plane() {
	echo "=== Joining as additional control plane ==="

	# Fetch join command from first control plane - retry a few times
	for i in {1..10}; do
	    if su - vagrant -c "scp vagrant@${CONTROL_PLANE_IP}:/home/vagrant/control-plane-join.sh /tmp/"; then
	        break
	    fi
	    echo "Attempt $i: Waiting for control plane to be ready..."
	    sleep 10
	done

	chmod +x /tmp/control-plane-join.sh

	# Join the cluster
	/tmp/control-plane-join.sh

	# Set up kubectl
	mkdir -p /home/vagrant/.kube
	for i in {1..10}; do
	    if su - vagrant -c "scp vagrant@${CONTROL_PLANE_IP}:/home/vagrant/.kube/config /home/vagrant/.kube/"; then
	        break
	    fi
	    echo "Attempt $i: Waiting for kubeconfig to be available..."
	    sleep 5
	done

	chown -R vagrant:vagrant /home/vagrant/.kube

	# Set up root user kubectl
	mkdir -p /root/.kube
	cp -i /home/vagrant/.kube/config /root/.kube/config
}

# Join an existing cluster as a worker node
join_worker() {
	echo "=== Joining as worker node ==="

	# Fetch join command - retry a few times
	for i in {1..10}; do
	    if su - vagrant -c "scp vagrant@${CONTROL_PLANE_IP}:/home/vagrant/worker-join.sh /tmp/"; then
	        break
	    fi
	    echo "Attempt $i: Waiting for control plane to be ready..."
	    sleep 10
	done

	chmod +x /tmp/worker-join.sh

	# Join the cluster
	/tmp/worker-join.sh
}

# Configure bash completion for kubectl
configure_kubectl_completion() {
	echo "=== Configuring kubectl completion ==="
	apt-get install -y bash-completion
	kubectl completion bash >/etc/bash_completion.d/kubectl
	echo 'source <(kubectl completion bash)' >>/home/vagrant/.bashrc
	echo 'alias k=kubectl' >>/home/vagrant/.bashrc
	echo 'complete -o default -F __start_kubectl k' >>/home/vagrant/.bashrc
}

# Main execution
main() {
	echo "=== Starting Kubernetes node setup ==="

	# STEP 1: System preparation
	system_preparation

	# STEP 2: Install containerd
	install_containerd

	# STEP 3: Install Kubernetes components
	install_kubernetes_components

	# STEP 4: Setup SSH for node communication
	setup_ssh

	# STEP 5: Node-specific setup
	if [[ "$NODE_TYPE" == "control-plane" ]]; then
		if [[ "$ACTION" == "init" ]]; then
			# STEP 5A: Initialize control plane
			initialize_control_plane
		else
			# STEP 5B: Join as additional control plane
			join_control_plane
		fi
	elif [[ "$NODE_TYPE" == "worker" ]]; then
		# Give control plane time to initialize before joining
		sleep 30
		# STEP 5C: Join as worker node
		join_worker
	fi

	# STEP 6: Configure kubectl completion
	configure_kubectl_completion

	echo "=== Kubernetes node setup complete ==="
}

# Execute the script
main

exit 0
