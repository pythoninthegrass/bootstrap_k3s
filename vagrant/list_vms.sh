#!/usr/bin/env bash

# Get all running VMs and filter out warnings
vms=$(vagrant status 2>&1 | grep running | grep libvirt | awk '{print $1}' | grep -v "\[fog\]\[WARNING\]")

# Find the length of the longest VM name and add padding
vm_col_width=8
for vm in $vms; do
	if [ ${#vm} -gt "$vm_col_width" ]; then
		vm_col_width=${#vm}
	fi
done
vm_col_width=$((vm_col_width + 2)) # Add padding

# Set IP column width
ip_col_width=16

# Print table with dynamic width
border=$(printf "%0.s-" $(seq 1 $((vm_col_width + 2))))
ip_border=$(printf "%0.s-" $(seq 1 $((ip_col_width + 2))))
printf "+%s+%s+\n" "$border" "$ip_border"
printf "| %-${vm_col_width}s | %-${ip_col_width}s |\n" "VM Name" "IP Address"
printf "+%s+%s+\n" "$border" "$ip_border"

# Process VM data and filter out warnings
{
	for vm in $vms; do
		domain_name=$(virsh list --all | grep "$vm" | awk '{print $2}')
		ip_addr=$(virsh domifaddr "$domain_name" | grep ipv4 | awk '{print $4}' | cut -d'/' -f1)
		printf "| %-${vm_col_width}s | %-${ip_col_width}s |\n" "$vm" "$ip_addr"
	done
} 2>&1 | grep -v "\[fog\]\[WARNING\]"

printf "+%s+%s+\n" "$border" "$ip_border"
