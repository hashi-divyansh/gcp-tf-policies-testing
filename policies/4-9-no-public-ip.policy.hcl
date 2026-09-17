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

resource_policy "google_compute_instance" "no_public_ip_addresses" {
  locals {
    name_raw               = core::try(attrs.name, null)
    name                   = local.name_raw != null ? local.name_raw : ""
    labels_raw             = core::try(attrs.labels, null)
    labels                 = local.labels_raw != null ? local.labels_raw : {}
    network_interfaces_raw = core::try(attrs.network_interface, null)
    network_interfaces     = local.network_interfaces_raw != null ? local.network_interfaces_raw : []
    is_gke_instance        = core::startswith(local.name, "gke-") && core::try(local.labels["goog-gke-node"], null) != null
    public_interfaces = [for interface in local.network_interfaces : interface if core::length(core::try(interface.access_config, null) != null ? core::try(interface.access_config, []) : []) > 0 || core::length(core::try(interface.ipv6_access_config, null) != null ? core::try(interface.ipv6_access_config, []) : []) > 0]
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.is_gke_instance || core::length(local.public_interfaces) == 0
    error_message = "Compute instances must omit access_config and ipv6_access_config from every network interface. Remove public IPv4 and IPv6 access configuration."
  }
}
