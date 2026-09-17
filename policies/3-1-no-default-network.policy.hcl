# Copyright IBM Corp. 2026

# Ensure That the Default Network Does Not Exist in a Project

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_compute_network" "no_default_network" {
  locals {
    network_name = core::try(attrs.name, null)
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.network_name != null && local.network_name != "default"
    error_message = "Delete the VPC network named 'default' and use a custom VPC network instead."
  }
}
