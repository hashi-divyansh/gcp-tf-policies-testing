# Copyright IBM Corp. 2026

# Ensure That Compute Instances Have Confidential Computing Enabled

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "confidential-vm-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_instance" "require_confidential_computing" {
  locals {
    machine_type_raw = core::lower(core::try(attrs.machine_type, ""))
    # machine_type may be a bare type name ("c3d-standard-4") or a full
    # resource URL/path ("zones/us-central1-a/machineTypes/c3d-standard-4");
    # take the last path segment before splitting out the family token.
    machine_type_segments = core::split("/", local.machine_type_raw)
    machine_type_name     = local.machine_type_segments[core::length(local.machine_type_segments) - 1]
    machine_family        = core::try(core::split("-", local.machine_type_name)[0], "")
  }

  # Confidential Computing is currently supported on the N2D and C2D (AMD
  # SEV), C3D and C4D (AMD SEV/SEV-SNP), and C3 and C4 (Intel TDX,
  # c3-standard-*/c4-standard-*) machine families. Other machine types cannot
  # enable it at all, so they are out of scope.
  filter = core::contains(["n2d", "c2d", "c3d", "c4d", "c3", "c4"], local.machine_family)

  locals {
    confidential_config_raw = core::try(attrs.confidential_instance_config[0], attrs.confidential_instance_config, null)
    confidential_enabled_raw = core::try(
      local.confidential_config_raw.enable_confidential_compute,
      null,
    )
    confidential_enabled = local.confidential_enabled_raw == null ? false : local.confidential_enabled_raw
    is_compliant         = local.confidential_config_raw != null && local.confidential_enabled == true
  }

  enforcement_level = input.confidential-vm-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Compute instances must include confidential_instance_config and explicitly set enable_confidential_compute to true. Recreate the instance with Confidential Computing enabled."
  }
}
