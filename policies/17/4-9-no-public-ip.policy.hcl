# Copyright IBM Corp. 2026

# Ensure That Compute Instances Do Not Have Public IP Addresses

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "no-public-ip-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_instance" "no_public_ip_addresses" {
  locals {
    network_interfaces_raw = core::try(attrs.network_interface, null)
    network_interfaces     = local.network_interfaces_raw != null ? local.network_interfaces_raw : []
    public_interfaces = [for interface in local.network_interfaces : interface if core::length(core::try(interface.access_config, null) != null ? core::try(interface.access_config, []) : []) > 0 || core::length(core::try(interface.ipv6_access_config, null) != null ? core::try(interface.ipv6_access_config, []) : []) > 0]
  }

  enforcement_level = input.no-public-ip-enforcement-level
  enforce {
    condition     = core::length(local.public_interfaces) == 0
    error_message = "Compute instances must omit access_config and ipv6_access_config from every network interface. Remove public IPv4 and IPv6 access configuration."
  }
}
