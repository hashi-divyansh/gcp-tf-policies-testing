# Copyright IBM Corp. 2026

# Ensure Compute Instances Are Launched With Shielded VM Enabled

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "shielded-vm-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_instance" "shielded_vm_enabled" {
  locals {
    shielded_config_raw = core::try(attrs.shielded_instance_config[0], attrs.shielded_instance_config, null)
    has_shielded_config = local.shielded_config_raw != null

    # The Google provider defaults enable_vtpm and enable_integrity_monitoring
    # to true whenever a shielded_instance_config block is present, so an
    # omitted/null value must resolve to true.
    vtpm_raw = core::try(local.shielded_config_raw.enable_vtpm, null)
    vtpm     = local.vtpm_raw == null ? true : local.vtpm_raw

    integrity_monitoring_raw = core::try(local.shielded_config_raw.enable_integrity_monitoring, null)
    integrity_monitoring     = local.integrity_monitoring_raw == null ? true : local.integrity_monitoring_raw

    # enable_secure_boot defaults to false in the provider, so an omitted/null
    # value must resolve to false (not true, unlike the two fields above).
    secure_boot_raw = core::try(local.shielded_config_raw.enable_secure_boot, null)
    secure_boot     = local.secure_boot_raw == null ? false : local.secure_boot_raw
  }

  enforcement_level = input.shielded-vm-enforcement-level
  enforce {
    condition     = local.has_shielded_config && local.vtpm && local.integrity_monitoring && local.secure_boot
    error_message = "Compute instances must include shielded_instance_config with enable_secure_boot, enable_vtpm, and enable_integrity_monitoring set to true."
  }
}
