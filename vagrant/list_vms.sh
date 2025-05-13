#!/usr/bin/env bash

echo "VM Name: IP Address"

(for vm in $(vagrant status | grep running | grep libvirt | awk '{print $1}'); do
  domain_name=$(virsh list --all | grep "$vm" | awk '{print $2}')
  printf "%-16s %s\n" "$vm:" "$(virsh domifaddr "$domain_name" | grep ipv4 | awk '{print $4}' | cut -d'/' -f1)"
done) 2>&1 | awk '!/\[fog\]\[WARNING\]/'
