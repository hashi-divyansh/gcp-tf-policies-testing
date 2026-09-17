# Copyright IBM Corp. 2026

# Ensure That IP Forwarding Is Not Enabled on Instances

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_compute_instance" "disable_ip_forwarding" {
  locals {
    can_ip_forward_raw = core::try(attrs.can_ip_forward, null)
    can_ip_forward     = local.can_ip_forward_raw == null ? false : local.can_ip_forward_raw
  }

  enforcement_level = "advisory"
  enforce {
    condition     = !local.can_ip_forward
    error_message = "Compute Engine instances must set can_ip_forward to false or omit it. Set can_ip_forward = false and recreate the instance if necessary."
  }
}
