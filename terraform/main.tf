terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# Ubuntu 24.04 base image
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  pool   = var.storage_pool
  format = "qcow2"
}
