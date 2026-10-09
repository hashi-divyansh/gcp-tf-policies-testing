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

input "no-default-network-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_network" "no_default_network" {
  locals {
    network_name = core::try(attrs.name, null)
  }

  enforcement_level = input.no-default-network-enforcement-level
  enforce {
    condition     = local.network_name != null && local.network_name != "default"
    error_message = "Delete the VPC network named 'default' and use a custom VPC network instead."
  }
}

resource_policy "google_project" "no_default_network_on_project_create" {
  # google_project.auto_create_network defaults to true, which creates the
  # 'default' VPC network directly (without a google_compute_network
  # resource ever appearing in the plan). Require it to be explicitly false.
  locals {
    auto_create_network_raw = core::try(attrs.auto_create_network, null)
    auto_create_network     = local.auto_create_network_raw == null ? true : local.auto_create_network_raw
  }

  enforcement_level = input.no-default-network-enforcement-level
  enforce {
    condition     = !local.auto_create_network
    error_message = "Set auto_create_network = false on google_project so the default VPC network is not created for the project. Omitting this attribute leaves it true by default."
  }
}
