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
    machine_type_parts    = core::split("-", local.machine_type_name)
    machine_family        = core::try(local.machine_type_parts[0], "")
    machine_vcpu_count    = core::try(local.machine_type_parts[2], "")
    is_bare_metal         = core::endswith(local.machine_type_name, "-metal")
    unsupported_c4d_size  = local.machine_family == "c4d" && local.machine_vcpu_count == "384"
    supported_amd_family  = core::contains(["n2d", "c2d", "c3d", "c4d"], local.machine_family) && !local.is_bare_metal && !local.unsupported_c4d_size
    supported_tdx_type    = (core::startswith(local.machine_type_name, "c3-standard-") || core::startswith(local.machine_type_name, "c4-standard-")) && !local.is_bare_metal
  }

  # Confidential Computing is supported on N2D (AMD SEV/SEV-SNP), C2D/C3D/C4D
  # (AMD SEV), and c3-standard-*/c4-standard-* types (Intel TDX), excluding
  # bare-metal and unsupported C4D 384-vCPU shapes. Other general-purpose
  # machine types cannot enable it, so they are out of scope.
  filter = local.supported_amd_family || local.supported_tdx_type

  locals {
    confidential_config_raw = core::try(attrs.confidential_instance_config[0], attrs.confidential_instance_config, null)
    confidential_enabled_raw = core::try(
      local.confidential_config_raw.enable_confidential_compute,
      null,
    )
    confidential_enabled  = local.confidential_enabled_raw == null ? false : local.confidential_enabled_raw
    confidential_type_raw = core::try(local.confidential_config_raw.confidential_instance_type, null)
    confidential_type     = local.confidential_type_raw == null ? "" : local.confidential_type_raw
    # Either field alone enables Confidential Computing, so the disjunction is
    # deliberate. The provider marshals the deprecated boolean with "omitempty",
    # so an explicit false is dropped from the API request while the type is
    # still sent, and GCP creates a Confidential VM anyway.
    is_compliant = local.confidential_config_raw != null && (local.confidential_enabled == true || core::contains(["SEV", "SEV_SNP", "TDX"], local.confidential_type))
  }

  enforcement_level = input.confidential-vm-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Compute instances must include confidential_instance_config with enable_confidential_compute set to true or confidential_instance_type set to SEV, SEV_SNP, or TDX. Recreate the instance with Confidential Computing enabled."
  }
}
