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
    passwd: "$6$bONkc7jMujBGjjNb$byInFIKvQiF0t8ORXuzdWhz4z.d69ZQb4CfGJQKoioN4TZvH1l.2NuaBQAfwuRwLaLccOZHrz7s63MTQ6Bkfd."
    lock_passwd: false
%{ if ssh_public_key != "" ~}
    ssh_authorized_keys:
      - ${ssh_public_key}
%{ endif ~}
%{ if github_user != "" ~}
    ssh_import_id:
      - gh:${github_user}
%{ endif ~}

ssh_pwauth: true

runcmd:
  - systemctl enable ssh
  - systemctl start ssh
