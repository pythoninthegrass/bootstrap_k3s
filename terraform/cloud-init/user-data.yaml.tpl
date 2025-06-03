#cloud-config

hostname: ${hostname}
fqdn: ${fqdn}
manage_etc_hosts: true

package_update: true
packages:
  - ca-certificates
  - curl
  - git
  - make
  - wget

users:
  - default
  - name: ubuntu
    groups: [adm, audio, cdrom, dialout, dip, floppy, lxd, netdev, plugdev, sudo, video]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
%{ if ssh_public_key != "" ~}
    ssh_authorized_keys:
      - ${ssh_public_key}
%{ endif ~}
%{ if github_user != "" ~}
    ssh_import_id:
      - gh:${github_user}
%{ endif ~}

chpasswd:
  expire: false
  users:
    - {name: ubuntu, password: ubuntu, type: text}

ssh_pwauth: true

runcmd:
  - systemctl enable ssh
  - systemctl start ssh
