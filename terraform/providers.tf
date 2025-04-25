terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "~> 0.3.1"
    }
  }
}

provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  remote {
    default = true
    name    = var.incus_server
    address = var.incus_address
    port    = var.incus_port
    scheme  = var.incus_scheme
    token   = var.incus_token
  }
}
