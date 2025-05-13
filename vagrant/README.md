# Kubernetes Cluster Setup

This is a Vagrant-based setup for creating a multi-node Kubernetes cluster with configurable number of control plane and worker nodes. The setup uses libvirt as the hypervisor and provisions Ubuntu 24.04 VMs.

## Features

- Configurable number of control plane nodes (default: 3)
- Configurable number of worker nodes (default: 1)
- Automatic IP address allocation for nodes
- Consistent hostname nomenclature (`control-plane-1..N`, `worker-1..N`)
- Full Kubernetes setup with Calico networking

## Prerequisites

- Vagrant (2.2.0+)
- Libvirt with Vagrant libvirt plugin
- Sufficient system resources to run the VMs

To install the Vagrant libvirt plugin:

```bash
vagrant plugin install vagrant-libvirt
```

## Configuration

All configuration is done via the `.env` file. Here are the available options:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `CONTROL_PLANE_COUNT` | Number of control plane nodes | 3 |
| `WORKER_COUNT` | Number of worker nodes | 1 |
| `NETWORK_NAME` | Name of the libvirt network | k8s_network |
| `BASE_IP` | Base IP address for the network | 192.168.56 |
| `MEMORY_CONTROL` | Memory allocation for control plane nodes (MB) | 2048 |
| `MEMORY_WORKER` | Memory allocation for worker nodes (MB) | 4096 |
| `CPU_CONTROL` | CPU cores for control plane nodes | 2 |
| `CPU_WORKER` | CPU cores for worker nodes | 2 |
| `DISK_SIZE` | Disk size for all nodes (GB) | 32 |

## Usage

### Starting the Cluster

```bash
cd vagrant
vagrant up
```

This will create all the VMs and set up the Kubernetes cluster. The first control plane node (`control-plane-1`) will be the initial master node, and all other nodes will join the cluster.

### Accessing the Cluster

To SSH into a node:

```bash
vagrant ssh control-plane-1
```

### Stopping the Cluster

```bash
vagrant halt
```

### Destroying the Cluster

```bash
vagrant destroy -f
```

## Network Details

The cluster uses a private network with the following IP allocation:

- Control plane nodes: `BASE_IP.11` to `BASE_IP.(10+CONTROL_PLANE_COUNT)`
- Worker nodes: `BASE_IP.21` to `BASE_IP.(20+WORKER_COUNT)`

## License

This project is licensed under the terms specified in the LICENSE file.
