#!/usr/bin/env bash

set -e

creds="ansible_vault_password"

case "$1" in
    get)
        # Just retrieve the password
        if skate list | grep -q "${creds}"; then
            skate get ${creds}
        else
            echo "Ansible vault password not found in skate." >&2
            exit 1
        fi
        ;;
    set)
        # Set a new password
        if [ -n "$2" ]; then
            echo "$2" | skate set "$creds"
            echo "Ansible vault password set successfully."
        else
            echo "Please enter a new ansible vault password:"
            read -rs password
            echo "$password" | skate set "$creds"
            echo "Ansible vault password set successfully."
        fi
        ;;
    delete)
        # Delete the password
        if skate list | grep -q "${creds}"; then
            skate delete ${creds}
            echo "Ansible vault password deleted."
        else
            echo "No ansible vault password found to delete." >&2
        fi
        ;;
    "")
        # Default behavior for ansible (no parameters)
        if skate list | grep -q "${creds}"; then
            skate get ${creds}
        else
            echo "Ansible vault password not found in skate."
            echo "Please enter a new ansible vault password:"
            read -rs password
            echo "$password" | skate set "$creds"
            echo "Ansible vault password set successfully."
            echo "$password"
        fi
        ;;
	*)
		echo "Usage: $0 [get|set|delete]" >&2
		exit 1
		;;
esac
