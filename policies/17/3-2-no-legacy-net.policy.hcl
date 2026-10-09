# Copyright IBM Corp. 2026

# Ensure Legacy Networks Do Not Exist for Older Projects

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "no-legacy-net-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_network" "no_legacy_networks" {
  # gateway_ipv4 is computed/output-only and unresolved at create time, but the
  # provider has no argument left to create a legacy network anyway. This check
  # only ever fires on update (auditing pre-existing legacy networks).
  operations = ["create", "update"]

  locals {
    gateway_ipv4_raw = core::try(attrs.gateway_ipv4, null)
    gateway_ipv4     = local.gateway_ipv4_raw != null ? local.gateway_ipv4_raw : ""
  }

  enforcement_level = input.no-legacy-net-enforcement-level
  enforce {
    condition     = local.gateway_ipv4 == ""
    error_message = "Legacy Google Compute networks are not permitted. Replace this network with an auto-mode or custom-mode VPC network."
  }
}
