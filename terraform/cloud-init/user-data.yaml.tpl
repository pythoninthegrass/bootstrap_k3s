#cloud-config
hostname: ${hostname}
fqdn: ${fqdn}
manage_etc_hosts: true

package_update: true
packages:
  - ansible
  - build-essential
  - ca-certificates
  - curl
  - git

users:
  - default
  - name: ubuntu
    groups: [adm, audio, cdrom, dialout, dip, floppy, lxd, netdev, plugdev, sudo, video]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
%{ if ssh_public_key != "" ~}
    ssh_authorized_keys:
      - ${ssh_public_key}
%{ endif ~}

# Enable SSH password authentication (disable in production)
ssh_pwauth: true

# Ensure SSH is started
runcmd:
  - systemctl enable ssh
  - systemctl start ssh
